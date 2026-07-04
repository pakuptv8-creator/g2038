local widget_base = require("ui.widget.widget_base")
local WidgetCarItem = Lib.derive(widget_base)

function WidgetCarItem:init()
  widget_base.init(self, "CarItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetCarItem:initUI()
  self.imgNormalIcon = self:child("CarItem-NormalIcon")
  self.imgSelectIcon = self:child("CarItem-SelectIcon")
  self.txtActionTitle = self:child("CarItem-ActionTitle")
  self.imgIcon = self:child("CarItem-icon")
  self.imgRedDot = self:child("CarItem-redDot")
  self.lytMaskPanel = self:child("CarItem-MaskPanel")
  self.imgLockIcon = self:child("CarItem-LockIcon")
  self.imgVipIcon = self:child("CarItem-VipIcon")
  self.imgDiamondIcon = self:child("CarItem-DiamondIcon")
  self.imgSubscribeIcon = self:child("CarItem-SubscribeIcon")
  self.imgFishIcon = self:child("CarItem-FishIcon")
  self.imgFreeIcon = self:child("CarItem-FreeIcon")
  self.txtFreeCount = self:child("CarItem-FreeCount")
end

function WidgetCarItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.info.isWatchAd and self.info.isWatchAd > 0 then
      Me:requestWatchAd(Define.AdvertisingType.Car)
      return
    end
    if self.imgFreeIcon:IsVisible() then
      if self.fun then
        self.fun()
      end
      return
    end
    if self.lytMaskPanel:IsVisible() then
      if self.info then
        if self.info.lockState == Define.UNLOCK_TYPE.MUST_FISH then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
          return
        end
        if self.info.needBuy and 0 < self.info.needBuy then
          Me:showBuyBusinessItemTips(Define.BUSINESS_ITEM_TYPE.Car, self.info)
          return
        end
        if self.info.needPrivilege == Define.PRIVILEGE_TYPE.VIP or self.info.lockState == Define.UNLOCK_TYPE.VIP then
          Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.VIP)
        end
        if self.info.lockState == Define.UNLOCK_TYPE.ACTIVITY then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
        end
      end
      return
    end
    if self.fun then
      self.fun()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    self:updateView()
  end)
end

function WidgetCarItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  self:updateView()
  self.imgSelectIcon:SetVisible(self.info.isHave)
  self.imgRedDot:SetVisible(self.info.isNew == 1)
end

function WidgetCarItem:updateUnlock()
  self.imgFishIcon:SetVisible(false)
  self.imgDiamondIcon:SetVisible(false)
  self.imgVipIcon:SetVisible(false)
  self.imgSubscribeIcon:SetVisible(false)
  self.imgLockIcon:SetVisible(false)
  self.imgFreeIcon:SetVisible(false)
  if self.info.isWatchAd and self.info.isWatchAd > 0 then
    self.lytMaskPanel:SetVisible(false)
    return
  end
  local needLock = false
  if not Me:checkCarUnlock(self.info) then
    needLock = true
  end
  if self.info.isHave then
    needLock = false
  end
  self.lytMaskPanel:SetVisible(needLock)
  if not needLock then
    return
  end
  local isVip = self.info.needPrivilege == Define.PRIVILEGE_TYPE.VIP or self.info.lockState == Define.UNLOCK_TYPE.VIP
  local isFish = self.info.lockState == Define.UNLOCK_TYPE.MUST_FISH
  if isFish then
    self.imgFishIcon:SetVisible(true)
  elseif self.info.needBuy and 0 < self.info.needBuy then
    local freeCount = 0
    if Me:getIsWatchedAd() then
      freeCount = freeCount + 1
    end
    if self.info.id then
      freeCount = freeCount + Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", Me, Define.BUSINESS_ITEM_TYPE.Car, self.info.id)
    end
    if 0 < freeCount then
      self.imgFreeIcon:SetVisible(true)
      self.lytMaskPanel:SetVisible(false)
      self.txtFreeCount:SetText("(" .. tostring(freeCount) .. ")")
    else
      self.imgDiamondIcon:SetVisible(true)
      local subscribe_vipSetting = World.cfg.subscribe_vipSetting
      for _, carId in pairs(subscribe_vipSetting.normalVipCarIdList) do
        if carId == self.info.id then
          self.imgSubscribeIcon:SetVisible(true)
        end
      end
    end
  elseif isVip then
    self.imgVipIcon:SetVisible(true)
  else
    self.imgLockIcon:SetVisible(true)
  end
end

function WidgetCarItem:updateView()
  if self.info then
    self.txtActionTitle:SetText("")
    self.imgIcon:SetImage(self.info.icon)
    self:updateUnlock()
  end
end

function WidgetCarItem:empty()
  self.txtActionTitle:SetText("")
  self.imgIcon:SetImage()
end

function WidgetCarItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetCarItem:hideNormalImage()
  self.imgNormalIcon:SetVisible(false)
end

return WidgetCarItem
