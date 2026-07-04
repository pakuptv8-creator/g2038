local widget_base = require("ui.widget.widget_base")
local WidgetDisasterItem = Lib.derive(widget_base)

function WidgetDisasterItem:init()
  widget_base.init(self, "DisasterItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDisasterItem:initUI()
  self.imgNormalIcon = self:child("DisasterItem-NormalIcon")
  self.imgSelectIcon = self:child("DisasterItem-SelectIcon")
  self.txtActionTitle = self:child("DisasterItem-ActionTitle")
  self.lytMaskPanel = self:child("DisasterItem-MaskPanel")
  self.lytCDMaskPanel = self:child("DisasterItem-CDMaskPanel")
  self.txtCD = self:child("DisasterItem-TextCD")
  self.lytMaskPanel:SetVisible(false)
end

function WidgetDisasterItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.lytMaskPanel:IsVisible() then
      return
    end
    if self.lytCDMaskPanel:IsVisible() then
      return
    end
    Lib.emitEvent(Event.EVENT_UPDATE_DISASTER_SELECT, self.disasterId)
  end)
  self._allEvent[#self._allEvent + 1] = self:subscribe(self.lytMaskPanel, UIEvent.EventWindowClick, function()
    Me:showBuyPrivilegeDialog(Define.PRIVILEGE_TYPE.DISASTER)
  end)
end

function WidgetDisasterItem:onDataChanged(data)
  self.data = data
  if not data.id then
    return
  end
  if data.select then
    self.imgNormalIcon:SetVisible(false)
    self.imgSelectIcon:SetVisible(true)
  else
    self.imgNormalIcon:SetVisible(true)
    self.imgSelectIcon:SetVisible(false)
  end
  self.disasterId = data.id
  self.txtActionTitle:SetText(Lang:toText(data.disasterName))
  if data.isFree == 1 then
    self.lytMaskPanel:SetVisible(false)
  elseif Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", Me.platformUserId, Define.PRIVILEGE_TYPE.DISASTER) then
    self.lytMaskPanel:SetVisible(false)
  else
    self.lytMaskPanel:SetVisible(true)
  end
  if data.remainCD and data.remainCD > 0 then
    self.lytCDMaskPanel:SetVisible(true)
    self.txtCD:SetText(data.remainCD .. "s")
  else
    self.lytCDMaskPanel:SetVisible(false)
  end
end

function WidgetDisasterItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDisasterItem
