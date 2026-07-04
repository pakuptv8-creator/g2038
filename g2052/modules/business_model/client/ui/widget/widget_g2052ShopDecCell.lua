local widget_base = require("ui.widget.widget_base")
local WidgetG2052ShopDecCell = Lib.derive(widget_base)

function WidgetG2052ShopDecCell:init()
  widget_base.init(self, "G2052ShopDecCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetG2052ShopDecCell:initUI()
  self.imgSign = self:child("G2052ShopDecCell-sign")
  self.txtDecText = self:child("G2052ShopDecCell-dec_text")
end

function WidgetG2052ShopDecCell:initEvent()
end

function WidgetG2052ShopDecCell:updateText(text)
  self.txtDecText:SetText(Lang:toText(text))
  self:root():SetHeight({
    0,
    self.txtDecText:GetHeight()[2]
  })
end

function WidgetG2052ShopDecCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetG2052ShopDecCell
