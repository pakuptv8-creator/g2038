local widget_base = require("ui.widget.widget_base")
local WidgetG2052GuideCell = Lib.derive(widget_base)

function WidgetG2052GuideCell:init()
  widget_base.init(self, "G2052GuideCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetG2052GuideCell:initUI()
  self.imgImg = self:child("G2052GuideCell-img")
  self.txtText = self:child("G2052GuideCell-text")
end

function WidgetG2052GuideCell:onDataChanged(info)
  if info.data then
    self.imgImg:SetImage(info.data.img)
    self.txtText:SetText(Lang:toText(info.data.text))
  end
end

function WidgetG2052GuideCell:initEvent()
end

function WidgetG2052GuideCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetG2052GuideCell
