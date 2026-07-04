local widget_base = require("ui.widget.widget_base")
local WidgetInteractTips = Lib.derive(widget_base)

function WidgetInteractTips:init()
  widget_base.init(self, "InteractTips.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetInteractTips:initUI()
  self.imgTipBg = self:child("InteractTips-tip_bg")
  self.lytTipNormal = self:child("InteractTips-tip_normal")
  self.txtTipNormalStr = self:child("InteractTips-tip_normalStr")
end

function WidgetInteractTips:initEvent()
end

function WidgetInteractTips:updateTipsData(content)
  self.txtTipNormalStr:SetText(Lang:toText(content or ""))
end

function WidgetInteractTips:setVisible(isShow)
  self._root:SetVisible(isShow)
end

function WidgetInteractTips:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetInteractTips
