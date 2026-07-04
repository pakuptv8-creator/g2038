local widget_base = require("ui.widget.widget_base")
local WidgetModMapWordItem = Lib.derive(widget_base)

function WidgetModMapWordItem:init()
  widget_base.init(self, "ModMapWordItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetModMapWordItem:initUI()
  self.btnBtn = self:child("ModMapWordItem-Btn")
end

function WidgetModMapWordItem:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if self.fun then
      self.fun(self.data.str)
    end
  end)
end

function WidgetModMapWordItem:reload(params)
  self.data = params
  if not self.data then
    return
  end
  local rootHigh = self:root():GetHeight()[2]
  local edgeX = 1
  local width = self.btnBtn:GetFont():GetStringWidth(params.str) + edgeX * 2
  if params.pos.x + width > params.standardWidth then
    params.pos.x = 0
    params.pos.y = params.pos.y + rootHigh + params.spaceY
  end
  self.fun = params.cb
  self:root():SetArea({
    0,
    params.pos.x
  }, {
    0,
    params.pos.y
  }, {0, width}, {0, rootHigh})
  self.btnBtn:SetText(Lang:toText(params.str))
  params.pos.x = params.pos.x + width + params.spaceX
end

return WidgetModMapWordItem
