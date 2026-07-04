local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "widget_notify_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgVip = self:child("widget_notify_cell-vip")
end

function M:initEvent()
end

function M:updateInfo(str, isVip)
  local textLen = self._root:GetFont():GetTextExtent(str, 1.0)
  self._root:SetWidth({0, textLen})
  self._root:SetText(str)
  self.imgVip:SetVisible(isVip)
  return textLen
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
