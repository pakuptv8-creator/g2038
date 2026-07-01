local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")

function M:init()
  widget_base.init(self, "pokemon_leaderboard_rank_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.bottomLine = self:child("pokemon_leaderboard_rank_cell-bottom-line")
  self.icon = self:child("pokemon_leaderboard_rank_cell-rank-icon")
  self.place = self:child("pokemon_leaderboard_rank_cell-rank-text")
  self.name = self:child("pokemon_leaderboard_rank_cell-rank-name")
  self.scoreIcon = self:child("pokemon_leaderboard_rank_cell-rank-score-icon")
  self.scoreText = self:child("pokemon_leaderboard_rank_cell-rank-score-text")
  self.scoreEffect = self:child("pokemon_leaderboard_rank_cell-score-icon-effect")
end

function M:initEvent()
end

function M:initItem(data)
end

function M:onDataChanged(data)
end

function M:initViewDataWithoutAdapter(subId, data)
  self.data = data
  self.subId = subId
  if self.data.rank < 4 then
    self.bottomLine:SetVisible(false)
    self.icon:SetVisible(true)
    self.icon:SetImage("set:pokemon_leaderboard.json image:img_0_medals_" .. self.data.rank)
    self.place:SetVisible(false)
    self.scoreIcon:SetVisible(true)
    self.scoreIcon:SetImage("set:pokemon_leaderboard.json image:img_0_cup_" .. self.data.rank)
    self._root:SetBackImage("set:pokemon_leaderboard.json image:img_9_board_no" .. self.data.rank)
    self.scoreEffect:SetVisible(true)
    self.scoreEffect:SetEffectName("g2038_rank_badge" .. self.data.rank .. ".effect")
    self.scoreEffect:PlayEffect()
  else
    self.bottomLine:SetVisible(true)
    self.icon:SetVisible(false)
    self.place:SetVisible(true)
    self.place:SetText(self.data.rank)
    self.scoreIcon:SetVisible(false)
    self._root:SetBackImage("")
    self.scoreEffect:SetVisible(false)
  end
  if self.data.isnpc == true then
    local npc_data = GymDefaultRankConfig:getSpecificNpc(self.subId, self.data.userId)
    Lib.logDebug("widget npc_data = ", Lib.v2s(npc_data))
    if npc_data then
      self.name:SetText(Lang:toText(npc_data.name))
    end
  else
    self.name:SetText(self.data.name)
  end
  self.scoreText:SetText(self.data.score)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
