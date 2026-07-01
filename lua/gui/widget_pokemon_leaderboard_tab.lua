local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local SelectStatus = {NotSelect = 1, Select = 2}
local tabs = {
  [1] = Define.RANK_SUB_TYPE.POWER,
  [2] = Define.RANK_SUB_TYPE.WATER_GYM,
  [3] = Define.RANK_SUB_TYPE.FIRE_GYM,
  [4] = Define.RANK_SUB_TYPE.GRASS_GYM,
  [5] = Define.RANK_SUB_TYPE.SUPER_GYM,
  [6] = Define.RANK_SUB_TYPE.SPECIAL_GYM
}
local tabIcons = {
  [1] = "set:pokemon_leaderboard.json image:img_0_icon_battle",
  [2] = "set:pokemon_leaderboard.json image:img_0_icon_water",
  [3] = "set:pokemon_leaderboard.json image:img_0_icon_fire",
  [4] = "set:pokemon_leaderboard.json image:img_0_icon_grass",
  [5] = "set:pokemon_leaderboard.json image:img_0_icon_super",
  [6] = "set:pokemon_leaderboard.json image:img_0_icon_specail"
}

function M:init()
  widget_base.init(self, "pokemon_leaderboard_tab.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.select = self:child("pokemon_leaderboard_tab-select")
  self.unselect = self:child("pokemon_leaderboard_tab-unselect")
  self.icon = self:child("pokemon_leaderboard_tab-icon")
end

function M:initEvent()
end

function M:initTabByType(tabType)
  self.type = tabType
  self.selectStatus = SelectStatus.NotSelect
  self.icon:SetImage(tabIcons[self.type])
end

function M:onCheckClick(type)
  if self.type == type then
    self.selectStatus = SelectStatus.Select
  else
    self.selectStatus = SelectStatus.NotSelect
  end
  self:changeSelectStatus()
end

function M:changeSelectStatus()
  if self.selectStatus == SelectStatus.Select then
    Lib.logDebug("self.type = ", self.type)
    self.select:SetVisible(true)
  else
    self.select:SetVisible(false)
  end
end

function M:onDataChanged(data)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
