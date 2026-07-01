local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "GuideTipsDialog.json")
  self:initWnd()
end

function M:initWnd()
  self.txtTitle = self:child("GuideTipsDialog-Title")
  self.txtInfo = self:child("GuideTipsDialog-Info")
end

function M:initView(title, info, pos, size, alig, root)
  self.txtTitle:SetText(Lang:toText(title))
  self.txtInfo:SetText(Lang:toText(info))
  self._root:SetArea({
    pos[1],
    pos[2]
  }, {
    pos[3],
    pos[4]
  }, {
    0,
    size[1]
  }, {
    0,
    size[2]
  })
  self._root:SetHorizontalAlignment(alig[1])
  self._root:SetVerticalAlignment(alig[2])
  root:AddChildWindow(self._root)
  return self._root
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
