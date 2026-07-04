local widget_base = require("ui.widget.widget_base")
local WidgetPhoneCareerItem = Lib.derive(widget_base)

function WidgetPhoneCareerItem:init()
  widget_base.init(self, "PhoneCareerItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPhoneCareerItem:initUI()
  self.imgBg1 = self:child("PhoneCareerItem-bg1")
  self.imgProfessionIcon = self:child("PhoneCareerItem-ProfessionIcon")
  self.txtProfessionName = self:child("PhoneCareerItem-ProfessionName")
  self.imgCountBg = self:child("PhoneCareerItem-CountBg")
  self.txtCountNum = self:child("PhoneCareerItem-CountNum")
  self.lytMaskPanel = self:child("PhoneCareerItem-MaskPanel")
end

function WidgetPhoneCareerItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.lytMaskPanel:IsVisible() then
      return
    end
    Me:requestCallOneCareer(self.data.id)
    UI:getWnd("phoneCareerWnd"):onShow(false)
  end)
end

function WidgetPhoneCareerItem:onDataChanged(data)
  self.data = data
  self.imgProfessionIcon:SetImage(data.sceneIcon)
  self.txtProfessionName:SetText(Lang:toText(data.careerName))
  if data.counts > 0 then
    self.imgCountBg:SetVisible(true)
    self.txtCountNum:SetText(data.counts)
    self.lytMaskPanel:SetVisible(false)
  else
    self.imgCountBg:SetVisible(false)
    self.lytMaskPanel:SetVisible(true)
  end
end

function WidgetPhoneCareerItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPhoneCareerItem
