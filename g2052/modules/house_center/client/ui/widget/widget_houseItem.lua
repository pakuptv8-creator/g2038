local widget_base = require("ui.widget.widget_base")
local WidgetHouseItem = Lib.derive(widget_base)

function WidgetHouseItem:init()
  widget_base.init(self, "HouseItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHouseItem:initUI()
  self.imgNormalIcon = self:child("HouseItem-NormalIcon")
  self.imgSelectIcon = self:child("HouseItem-SelectIcon")
  self.txtActionTitle = self:child("HouseItem-ActionTitle")
  self.imgIcon = self:child("HouseItem-icon")
  self.imgRedDot = self:child("HouseItem-redDot")
  self.lytMaskPanel = self:child("HouseItem-MaskPanel")
  self.imgLockIcon = self:child("HouseItem-LockIcon")
  self.imgDiamondIcon = self:child("HouseItem-DiamondIcon")
  self.imgSubscribeIcon = self:child("HouseItem-SubscribeIcon")
  self.imgFishIcon = self:child("HouseItem-FishIcon")
  self.imgFreeIcon = self:child("HouseItem-FreeIcon")
  self.txtFreeCount = self:child("HouseItem-FreeCount")
end

function WidgetHouseItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.info.isWatchAd and self.info.isWatchAd > 0 then
      Me:requestWatchAd(Define.AdvertisingType.House)
      return
    end
    if self.imgFreeIcon:IsVisible() then
      if self.fun then
        self.fun()
      end
      return
    end
    if self.lytMaskPanel:IsVisible() then
      if self.info.lockState == Define.UNLOCK_TYPE.MUST_FISH then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.activity.to.unlock")
        return
      end
      if self.info.needBuy and 0 < self.info.needBuy then
        Me:showBuyBusinessItemTips(Define.BUSINESS_ITEM_TYPE.House, self.info)
        return
      end
      if self.info and self.info.needPrivilege == Define.PRIVILEGE_TYPE.VIP then
        Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.VIP)
      end
      return
    end
    if self.fun then
      self.fun()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    if self.info then
      self:updateView()
    end
  end)
end

function WidgetHouseItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  if self.info then
    self:updateView()
  else
    self:empty()
  end
end

function WidgetHouseItem:updateView()
  self.txtActionTitle:SetText(Lang:toText(self.info.name))
  self.imgIcon:SetImage(self.info.icon)
  self.imgSelectIcon:SetVisible(self.info.inUse)
  self.imgRedDot:SetVisible(self.info.isNew)
  self:updateUnlock()
end

function WidgetHouseItem:empty()
  self.txtActionTitle:SetText("")
  self.imgIcon:SetImage()
  self.lytMaskPanel:SetVisible(false)
end

function WidgetHouseItem:updateUnlock()
  self.imgFishIcon:SetVisible(false)
  self.imgDiamondIcon:SetVisible(false)
  self.imgSubscribeIcon:SetVisible(false)
  self.imgLockIcon:SetVisible(false)
  self.imgFreeIcon:SetVisible(false)
  if self.info.isWatchAd and self.info.isWatchAd > 0 then
    self.lytMaskPanel:SetVisible(false)
    return
  end
  if self.info.inUse then
    self.lytMaskPanel:SetVisible(false)
    return
  end
  local canUse = Me:checkHouseUnlock(self.info)
  if canUse then
    self.lytMaskPanel:SetVisible(false)
    return
  else
    self.lytMaskPanel:SetVisible(true)
  end
  local isFish = self.info.lockState == Define.UNLOCK_TYPE.MUST_FISH
  if isFish then
    self.imgFishIcon:SetVisible(true)
  elseif self.info.needBuy and 0 < self.info.needBuy then
    local freeCount = 0
    if Me:getIsWatchedAd() then
      freeCount = freeCount + 1
    end
    if self.info.id then
      freeCount = freeCount + Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", Me, Define.BUSINESS_ITEM_TYPE.House, self.info.id)
    end
    if 0 < freeCount then
      self.imgFreeIcon:SetVisible(true)
      self.lytMaskPanel:SetVisible(false)
      self.txtFreeCount:SetText("(" .. tostring(freeCount) .. ")")
    else
      self.imgDiamondIcon:SetVisible(true)
      local subscribe_vipSetting = World.cfg.subscribe_vipSetting
      for _, houseId in pairs(subscribe_vipSetting.heightVipHouseIdList) do
        if houseId == self.info.id then
          self.imgSubscribeIcon:SetVisible(true)
        end
      end
    end
  else
    self.imgLockIcon:SetVisible(true)
  end
end

function WidgetHouseItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHouseItem
