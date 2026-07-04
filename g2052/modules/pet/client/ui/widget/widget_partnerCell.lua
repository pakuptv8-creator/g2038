local PetConfig = T(Config, "PetConfig")
local widget_base = require("ui.widget.widget_base")
local WidgetPartnerCell = Lib.derive(widget_base)

function WidgetPartnerCell:init()
  widget_base.init(self, "PartnerCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPartnerCell:initUI()
  self.lytDanceItem = self:child("PartnerCell")
  self.imgDanceItemIcon = self:child("PartnerCell-Icon")
  self.imgDanceItemIconSelect = self:child("PartnerCell-Icon_select")
  self.imgHeadIcon = self:child("PartnerCell-HeadIcon")
  self.lytMaskPanel = self:child("PartnerCell-MaskPanel")
  self.imgLockIcon = self:child("PartnerCell-LockIcon")
  self.imgVipIcon = self:child("PartnerCell-VipIcon")
  self.imgDiamondIcon = self:child("PartnerCell-DiamondIcon")
  self.imgSubscribeIcon = self:child("PartnerCell-SubscribeIcon")
  self.imgFishIcon = self:child("PartnerCell-FishIcon")
  self.imgFreeIcon = self:child("PartnerCell-FreeIcon")
  self.txtFreeCount = self:child("PartnerCell-FreeCount")
end

function WidgetPartnerCell:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.data.isWatchAd and self.data.isWatchAd > 0 then
      Me:requestWatchAd(Define.AdvertisingType.Pet)
      return
    end
    if self.imgFreeIcon:IsVisible() then
      self:DoUsePetItem()
      return
    end
    if self.lytMaskPanel:IsVisible() then
      if self.data.lockState == Define.UNLOCK_TYPE.MUST_FISH then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
        return
      end
      if self.data.needBuy and 0 < self.data.needBuy then
        Me:showBuyBusinessItemTips(Define.BUSINESS_ITEM_TYPE.Pet, self.data)
        return
      end
      local tipsTxt = Plugins.CallTargetPluginFunc("tendering_land", "getTenderingPetTips", self.data.id)
      if tipsTxt and tipsTxt ~= "" then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tipsTxt)
      end
      if self.data.lockState == Define.UNLOCK_TYPE.VIP then
        Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.VIP)
      end
      if self.data.lockState == Define.UNLOCK_TYPE.ACTIVITY or self.data.lockState == Define.UNLOCK_TYPE.PEAK_DAY then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
      end
      return
    end
    self:DoUsePetItem()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PET_CARRY_CHANGE, function()
    self:updateStatus()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_TENDERING_INFO, function()
    self:updateMaskVisible()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    self:updateMaskVisible()
  end)
end

function WidgetPartnerCell:DoUsePetItem()
  if self.operationLock == true then
    return
  end
  local carryPetId = Me:getCurCarryPetId()
  local petData = Me:getPetDataByPetId(carryPetId)
  if self.data then
    if petData and petData.cfgId == self.data.id then
      Me:recoverPartner()
    else
      Me:changePartner(self.data)
    end
    self.operationLock = true
    World.Timer(10, function()
      self.operationLock = nil
    end)
  end
end

function WidgetPartnerCell:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetPartnerCell:onDataChanged(params)
  self.data = params.data
  self.imgHeadIcon:SetImage(PetConfig:getPetIcon(self.data.id))
  self:updateStatus()
end

function WidgetPartnerCell:updateStatus()
  local carryPetId = Me:getCurCarryPetId()
  local petData = Me:getPetDataByPetId(carryPetId)
  if self.data then
    if petData and petData.cfgId == self.data.id then
      self.imgDanceItemIconSelect:SetVisible(true)
    else
      self.imgDanceItemIconSelect:SetVisible(false)
    end
  end
  self:updateMaskVisible()
end

function WidgetPartnerCell:updateMaskVisible()
  if self.data then
    self.imgFishIcon:SetVisible(false)
    self.imgDiamondIcon:SetVisible(false)
    self.imgVipIcon:SetVisible(false)
    self.imgLockIcon:SetVisible(false)
    self.imgSubscribeIcon:SetVisible(false)
    self.imgFreeIcon:SetVisible(false)
    if self.data.isWatchAd and self.data.isWatchAd > 0 then
      self.lytMaskPanel:SetVisible(false)
      return
    end
    if self.imgDanceItemIconSelect:IsVisible() then
      self.lytMaskPanel:SetVisible(false)
      return
    end
    local canUse = Me:checkPetUnlock(self.data)
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
        freeCount = freeCount + Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", Me, Define.BUSINESS_ITEM_TYPE.Pet, self.data.id)
      end
      if 0 < freeCount then
        self.imgFreeIcon:SetVisible(true)
        self.lytMaskPanel:SetVisible(false)
        self.txtFreeCount:SetText("(" .. tostring(freeCount) .. ")")
      else
        self.imgDiamondIcon:SetVisible(true)
        local subscribe_vipSetting = World.cfg.subscribe_vipSetting
        for _, petId in pairs(subscribe_vipSetting.subscribePetIdList) do
          if petId == self.data.id then
            self.imgSubscribeIcon:SetVisible(true)
          end
        end
      end
    elseif self.data.lockState == Define.UNLOCK_TYPE.VIP then
      self.imgVipIcon:SetVisible(true)
    else
      self.imgLockIcon:SetVisible(true)
    end
  end
end

function WidgetPartnerCell:hideNormalImage()
  self.imgDanceItemIcon:SetVisible(false)
end

return WidgetPartnerCell
