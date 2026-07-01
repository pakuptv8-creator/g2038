local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "battle_top_time.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgBattleTopTimeTopBg = self:child("battle_top_time-top_bg")
  self.txtBattleTopTimeRounds = self:child("battle_top_time-rounds")
  self.txtBattleTopTimeTime = self:child("battle_top_time-time")
end

function M:initEvent()
end

function M:updateTime(time)
  self.txtBattleTopTimeTime:SetText(time)
end

function M:updateRounds(rounds)
  self.txtBattleTopTimeRounds:SetText(rounds)
end

function M:showInCurrentWnd(wnd, posy)
  wnd:AddChildWindow(self._root)
  self._root:SetYPosition(posy)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
