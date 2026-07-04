local widget_base = require("ui.widget.widget_base")
local WidgetModSearchPopularItem = Lib.derive(widget_base)

function WidgetModSearchPopularItem:init()
  widget_base.init(self, "ModSearchPopularItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModSearchPopularItem:initUI()
  self.btnBtn = self:child("ModSearchPopularItem-Btn")
end

function WidgetModSearchPopularItem:initEvent()
  self:subscribe(self.btnBtn, UIEvent.EventButtonClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetModSearchPopularItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

local MinWidth = 120

function WidgetModSearchPopularItem:reload(params)
  self.data = params
  if not self.data then
    return
  end
  local rootHigh = self:root():GetHeight()[2]
  local edgeX = 10
  local width = self.btnBtn:GetFont():GetStringWidth(params.str) + edgeX * 2
  width = math.max(width, MinWidth)
  if params.pos.x + width > params.standardWidth then
    params.pos.x = params.startX
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

return WidgetModSearchPopularItem
