local widget_base = require("ui.widget.widget_base")
local WidgetDramaTemplateCover = Lib.derive(widget_base)

function WidgetDramaTemplateCover:init()
  widget_base.init(self, "DramaTemplateCover.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaTemplateCover:initUI()
  self.imgCoverIcon = self:child("DramaTemplateCover-CoverIcon")
end

function WidgetDramaTemplateCover:initEvent()
end

function WidgetDramaTemplateCover:updateCoverIcon(value)
  self.imgCoverIcon:SetImage(value)
end

function WidgetDramaTemplateCover:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaTemplateCover
