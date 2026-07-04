local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetColorButton = Lib.derive(widget_base)

function WidgetMobileEditorWidgetColorButton:init(data)
  widget_base.init(self, "MobileEditorWidgetColorButton.json")
  self._allEvent = {}
  self:initUI()
  if data then
    local rgba = data.rgba
    self.imgImage:SetDrawColor({
      rgba.r / 255,
      rgba.g / 255,
      rgba.b / 255,
      rgba.a / 255
    })
  end
end

function WidgetMobileEditorWidgetColorButton:initUI()
  self.imgImage = self:child("MobileEditorWidgetColorButton-image")
  self.imgSelection = self:child("MobileEditorWidgetColorButton-selection")
  self.imgSelection:SetVisible(false)
end

function WidgetMobileEditorWidgetColorButton:highLightSelect(show)
  self.imgSelection:SetVisible(show)
end

function WidgetMobileEditorWidgetColorButton:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorWidgetColorButton
