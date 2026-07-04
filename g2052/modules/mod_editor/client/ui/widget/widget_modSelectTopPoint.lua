local widget_base = require("ui.widget.widget_base")
local WidgetModSelectTopPoint = Lib.derive(widget_base)

function WidgetModSelectTopPoint:init()
  widget_base.init(self, "ModSelectTopPoint.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModSelectTopPoint:initUI()
  self.imgNormalIcon = self:child("ModSelectTopPoint-NormalIcon")
  self.imgSelectIcon = self:child("ModSelectTopPoint-SelectIcon")
end

function WidgetModSelectTopPoint:initEvent()
end

function WidgetModSelectTopPoint:updatePointStateShow(state)
  self.imgSelectIcon:SetVisible(state)
  self.imgNormalIcon:SetVisible(not state)
end

function WidgetModSelectTopPoint:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModSelectTopPoint
