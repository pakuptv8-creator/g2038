local widget_base = require("ui.widget.widget_base")
local WidgetDressItem = Lib.derive(widget_base)

function WidgetDressItem:init()
  widget_base.init(self, "DressItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDressItem:initUI()
  self.imgNormalIcon = self:child("DressItem-NormalIcon")
  self.imgSelectIcon = self:child("DressItem-SelectIcon")
  self.imgIcon = self:child("DressItem-icon")
  self.imgRedDot = self:child("DressItem-redDot")
  self.lytMaskPanel = self:child("DressItem-MaskPanel")
  self.imgLockIcon = self:child("DressItem-LockIcon")
  self.imgVipIcon = self:child("DressItem-vipIcon")
  self.imgDiamondIcon = self:child("DressItem-DiamondIcon")
  self.imgFishIcon = self:child("DressItem-FishIcon")
  self.imgFreeIcon = self:child("DressItem-FreeIcon")
  self.txtFreeTime = self:child("DressItem-FreeTime")
  self.txtFreeCount = self:child("DressItem-FreeCount")
end

function WidgetDressItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.data.isWatchAd and self.data.isWatchAd > 0 then
      Me:requestWatchAd(Define.AdvertisingType.Dress)
      return
    end
    if self.imgFreeIcon:IsVisible() then
      self:DoClickDressItem()
      return
    end
    if self.lytMaskPanel:IsVisible() then
      if self.data.lockState == Define.UNLOCK_TYPE.MUST_FISH then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
        return
      end
      if self.data.needBuy and 0 < self.data.needBuy then
        Me:showBuyBusinessItemTips(Define.BUSINESS_ITEM_TYPE.Dress, self.data)
        return
      end
      local tipsTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingDressTips", self.data.id)
      if tipsTxt and tipsTxt ~= "" then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tipsTxt)
      end
      if self.data.lockState == Define.UNLOCK_TYPE.VIP then
        Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.VIP)
      end
      if self.data.lockState == Define.UNLOCK_TYPE.ACTIVITY then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
      end
      return
    end
    self:DoClickDressItem()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_TENDERING_INFO, function()
    self:updateMaskVisible()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    self:updateMaskVisible()
  end)
end

function WidgetDressItem:DoClickDressItem()
  if self.clickCb then
    self.clickCb()
    if self.select then
      Me.dressId = self.data.id
    elseif Me.dressId == self.data.id then
      Me.dressId = nil
    end
  end
  local isReset = false
  local skinData = {}
  local isSelect
  if self.isProfessionRecommend then
    isSelect = not self.data.isHave
  else
    isSelect = self.select
  end
  if isSelect then
    skinData = self.data.parts
  else
    local originalSkin = Me:getOriginalSkin()
    for key, _ in pairs(self.data.parts) do
      skinData[key] = originalSkin[key] or ""
    end
    isReset = true
  end
  local packet = {
    pid = "roleChangeSkin",
    skinData = skinData,
    isReset = isReset,
    conflictParts = self.data.conflictParts,
    conflictOriginal = self.data.conflictOriginal,
    id = self.data.id,
    lockState = self.data.lockState,
    needBuy = self.data.needBuy,
    opOrder = Me:getChangeSkinOpOrder()
  }
  Me:sendPacket(packet)
  Me:changeSkinClient(packet)
end

function WidgetDressItem:onDataChanged(params)
  self.data = params.data
  self.select = params.select
  self.remainTime = -1
  if self.isProfessionRecommend then
    self.imgNormalIcon:SetVisible(not self.data.isHave)
    self.imgSelectIcon:SetVisible(self.data.isHave)
  else
    self.imgNormalIcon:SetVisible(not params.select)
    self.imgSelectIcon:SetVisible(params.select)
  end
  self.clickCb = params.clickCb
  self.imgIcon:SetImage(self.data.icon)
  self:updateMaskVisible()
  self:updateRedDotVisible(self.data.isNew == 1)
end

function WidgetDressItem:updateRedDotVisible(isVisible)
  self.imgRedDot:SetVisible(isVisible)
end

function WidgetDressItem:updateMaskVisible()
  if self.data then
    self.imgFishIcon:SetVisible(false)
    self.imgDiamondIcon:SetVisible(false)
    self.imgVipIcon:SetVisible(false)
    self.imgLockIcon:SetVisible(false)
    self.imgFreeIcon:SetVisible(false)
    self:stopDownTimer()
    if self.data.isWatchAd and self.data.isWatchAd > 0 then
      self.lytMaskPanel:SetVisible(false)
      return
    end
    local canUse = Me:checkAppearanceUnlock(self.data)
    if self.imgSelectIcon:IsVisible() then
      self.lytMaskPanel:SetVisible(false)
      self:startDownTimer()
      return
    end
    if canUse then
      self.lytMaskPanel:SetVisible(false)
      return
    else
      self.lytMaskPanel:SetVisible(true)
    end
    local isFish = self.data.lockState == Define.UNLOCK_TYPE.MUST_FISH
    if isFish then
      self.imgFishIcon:SetVisible(true)
    elseif self.data.needBuy and 0 < self.data.needBuy then
      local freeCount = 0
      if Me:getIsWatchedAd() then
        freeCount = freeCount + 1
      end
      if self.data.id then
        freeCount = freeCount + Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", Me, Define.BUSINESS_ITEM_TYPE.Dress, self.data.id)
      end
      if 0 < freeCount then
        self.imgFreeIcon:SetVisible(true)
        self.lytMaskPanel:SetVisible(false)
        self.txtFreeCount:SetText("(" .. tostring(freeCount) .. ")")
      else
        self.imgDiamondIcon:SetVisible(true)
      end
    elseif self.data.lockState == Define.UNLOCK_TYPE.VIP then
      self.imgVipIcon:SetVisible(true)
    else
      self.imgLockIcon:SetVisible(true)
    end
  end
end

function WidgetDressItem:setIsProfessionRecommend(val)
  self.isProfessionRecommend = val
end

function WidgetDressItem:UpdateFreeTimeShow()
  if self.remainTime >= 0 then
    self.txtFreeTime:SetVisible(true)
    local timeMinute = math.fmod(math.floor(self.remainTime / 60), 60)
    local timeSecond = math.fmod(self.remainTime, 60)
    local text = string.format("%02d:%02d", timeMinute, timeSecond)
    self.txtFreeTime:SetText(text)
  else
    self:stopDownTimer()
  end
end

function WidgetDressItem:startDownTimer()
  self:stopDownTimer()
  local startTime = Me:getOneFreeAdStartTime(self.data.id)
  if startTime ~= nil then
    local passTime = os.time() - startTime
    self.remainTime = Define.FreeAdDressTime - passTime
    self:UpdateFreeTimeShow()
    if self.remainTime >= 0 then
      self.downTimer = World.Timer(20, function()
        self.remainTime = self.remainTime - 1
        self:UpdateFreeTimeShow()
        return true
      end)
    end
  end
end

function WidgetDressItem:stopDownTimer()
  if self.downTimer then
    self.downTimer()
    self.downTimer = nil
  end
  self.txtFreeTime:SetVisible(false)
end

function WidgetDressItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:stopDownTimer()
end

function WidgetDressItem:hideNormalImage()
  self.imgNormalIcon:SetVisible(false)
end

return WidgetDressItem
