local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetMaterialButton = Lib.derive(widget_base)

function WidgetMobileEditorWidgetMaterialButton:init(data)
  widget_base.init(self, "MobileEditorWidgetMaterialButton.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  if data then
    self.imgImage:SetImage(data.icon)
  end
end

function WidgetMobileEditorWidgetMaterialButton:initUI()
  self.imgImage = self:child("MobileEditorWidgetMaterialButton-image")
  self.imgSelection = self:child("MobileEditorWidgetMaterialButton-selection")
  self.imgSelection:SetVisible(false)
end

function WidgetMobileEditorWidgetMaterialButton:initEvent()
end

function WidgetMobileEditorWidgetMaterialButton:highLightSelect(show)
  self.imgSelection:SetVisible(show)
end

function WidgetMobileEditorWidgetMaterialButton:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorWidgetMaterialButton
