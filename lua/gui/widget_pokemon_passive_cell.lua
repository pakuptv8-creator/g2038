local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local SkillConfig = T(Config, "SkillConfig")
local math = require("math")
local waitTime = 0.1

function M:init()
  self._allEvent = {}
  widget_base.init(self, "pokemon_passive_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.skillId = 0
  self.imgPokemonPassiveCellSelect = self:child("pokemon_passive_cell-select")
  self.imgPokemonPassiveCellIcon = self:child("pokemon_passive_cell-icon")
  self.imgPokemonPassiveCellEmpty = self:child("pokemon_passive_cell-Empty")
  self.imgPokemonPassiveCellLock = self:child("pokemon_passive_cell-Lock")
  self.imgReadyToUnlock = self:child("pokemon_passive_cell-ReadyToUnlock")
end

function M:initEvent()
end

function M:updateInfo(skillId, isLock, readyToUnlock)
  self.skillId = skillId or 0
  local skill_config = SkillConfig:getConfigById(self.skillId)
  if skill_config then
    self.imgPokemonPassiveCellIcon:SetImage(skill_config.icon)
  end
  self.imgPokemonPassiveCellEmpty:SetVisible(not skill_config)
  self.imgPokemonPassiveCellLock:SetVisible(isLock)
  self:reset()
  if readyToUnlock then
    self:startTick()
  end
end

function M:reset()
  self.imgPokemonPassiveCellLock:SetAlpha(1)
  self.time = 0
  if self.tickFun then
    self.tickFun()
  end
end

function M:evaluate(time)
  local value = 0.5 + math.sin(time) * (1 + waitTime - 0.5)
  return value < 0 and 0 or value
end

function M:onTick()
  self.time = self.time + 0.1
  self.imgPokemonPassiveCellLock:SetAlpha(self:evaluate(self.time))
end

function M:startTick()
  self.tickFun = World.Timer(1, function()
    self:onTick()
    return true
  end)
end

function M:onDestroy()
  self.tickFun()
end

function M:getSkillId()
  return self.skillId
end

function M:onChecked(isChecked)
  self.imgPokemonPassiveCellSelect:SetVisible(isChecked)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
