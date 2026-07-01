local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_active_tip.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.stCount = self:child("pokemon_active_tip-count")
end

function M:initEvent()
end

function M:initByCount(count)
  self.stCount:SetText(count)
end

function M:onDataChanged(data)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
