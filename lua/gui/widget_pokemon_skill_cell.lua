local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local TempSkill = {
  skillId = 0,
  curTimes = 0,
  maxTimes = 0
}

function M:init()
  widget_base.init(self, "pokemon_skill_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.skill = Lib.copy(TempSkill)
  self.txtPokemonSkillCellName = self:child("pokemon_skill_cell-name")
  self.txtPokemonSkillCellPpCount = self:child("pokemon_skill_cell-pp_count")
  self.imgPokemonSkillCellSelect = self:child("pokemon_skill_cell-select")
  self.imgPokemonSkillCellMask = self:child("pokemon_skill_cell-mask")
  self.imgPokemonSkillCellEmpty = self:child("pokemon_skill_cell-Empty")
  self.txtPokemonSkillCellResult = self:child("pokemon_skill_cell-result")
  self.txtPokemonSkillCellUnlockLevel = self:child("pokemon_skill_cell-unlock_level")
  self:child("pokemon_skill_cell-Empty-Text"):SetText(Lang:toText("gui.wait.skill.learn"))
  self:child("pokemon_skill_cell-unlock_text"):SetText(Lang:toText("gui.skill.cell.unlock"))
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemon_skill_cell _root event : EventWindowClick", self._root, UIEvent.EventWindowClick, function()
    if self.clickCallBack then
      self.clickCallBack()
      return
    end
  end)
end

function M:onDataChanged(data)
  self:updateInfo(data.skill)
  self:setCallBack(data.callBack)
  self:onChecked(data.select == true)
end

function M:setCallBack(callBack)
  self.clickCallBack = callBack
end

function M:updateInfo(skill)
  self.skill = skill or Lib.copy(TempSkill)
  local skill_config = SkillConfig:getConfigById(self.skill.skillId)
  if not skill_config then
    self.imgPokemonSkillCellEmpty:SetVisible(true)
    return
  end
  self.imgPokemonSkillCellEmpty:SetVisible(false)
  self.skill.maxTimes = self.skill.maxTimes or skill_config.max_number
  self.txtPokemonSkillCellName:SetText(Lang:toText(skill_config.name))
  local curTimes = tostring(self.skill.curTimes)
  if self.skill.curTimes < 5 then
    curTimes = "\226\150\162FFFF0000" .. curTimes
  end
  self.txtPokemonSkillCellPpCount:SetText(curTimes .. "\226\150\162FFFFFFFF/" .. tostring(self.skill.maxTimes))
  self._root:SetImage(RaceConfig:getSkillBg(skill_config.race))
  self.skillRace = skill_config.race
  self.txtPokemonSkillCellUnlockLevel:SetText("Lv." .. (skill.unlockLevel or 0))
  self.txtPokemonSkillCellUnlockLevel:SetVisible(skill.unlockLevel ~= nil)
  self.txtPokemonSkillCellPpCount:SetVisible(skill.unlockLevel == nil)
end

function M:associatedWithThePet(pet)
  self.pet = pet
end

function M:getRelatedPet()
  return self.pet
end

function M:updateInfoById(skillId)
  local skill_config = SkillConfig:getConfigById(skillId)
  if not skill_config then
    self.imgPokemonSkillCellEmpty:SetVisible(true)
    return
  end
  self:updateInfo({
    skillId = skillId,
    curTimes = skill_config.max_number
  })
end

function M:showMask(isShow)
  self.imgPokemonSkillCellMask:SetVisible(isShow)
end

function M:getSkill()
  return self.skill
end

function M:getSkillRace()
  return self.skillRace
end

function M:showSkillResult(result)
  self.txtPokemonSkillCellResult:SetVisible(result)
  if result then
    self.txtPokemonSkillCellName:SetVerticalAlignment(0)
  else
    self.txtPokemonSkillCellName:SetVerticalAlignment(1)
  end
  if not result then
    return
  end
  if result < 1 and 0 < result then
    result = 2
  elseif 1 < result then
    result = 3
  end
  self.txtPokemonSkillCellResult:SetText(Lang:toText(string.format("ui_skill_result_%d", result)))
end

function M:onChecked(isChecked)
  self.imgPokemonSkillCellSelect:SetVisible(isChecked)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
