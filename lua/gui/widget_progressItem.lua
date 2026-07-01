local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "ProgressItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgProgressItemBG = self:child("ProgressItem-BG")
  self.txtProgressItemProgressTxt = self:child("ProgressItem-ProgressTxt")
  self.txtProgressItemProgressTxt:SetText(Lang:toText("progress_title") .. " : ")
end

function M:initEvent()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
