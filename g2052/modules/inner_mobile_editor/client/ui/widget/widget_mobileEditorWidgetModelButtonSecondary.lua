local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetModelButtonSecondary = Lib.derive(widget_base)

function WidgetMobileEditorWidgetModelButtonSecondary:init()
  widget_base.init(self, "MobileEditorWidgetModelButtonSecondary.json")
  self._allEvent = {}
  self:initUI()
end

function WidgetMobileEditorWidgetModelButtonSecondary:initUI()
  self.imgBg = self:child("MobileEditorWidgetModelButtonSecondary-bg")
  self.imgIcon = self:child("MobileEditorWidgetModelButtonSecondary-icon")
end

function WidgetMobileEditorWidgetModelButtonSecondary:setDrawColor(color)
  self.imgIcon:SetDrawColor(color)
end

function WidgetMobileEditorWidgetModelButtonSecondary:setContent(data)
  self.id = data.id
  self.name = data.name
  self.cfgName = data.cfgName
  self.imgIcon:SetImage(data.icon)
end

function WidgetMobileEditorWidgetModelButtonSecondary:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorWidgetModelButtonSecondary
