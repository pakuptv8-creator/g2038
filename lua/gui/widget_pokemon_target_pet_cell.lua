local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")

function M:init()
  widget_base.init(self, "pokemon_target_pet_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonTargetPetCellFrame = self:child("pokemon_target_pet_cell-frame")
  self.imgPokemonTargetPetCellIcon = self:child("pokemon_target_pet_cell-icon")
  self.imgPokemonTargetPetCellIconFrame = self:child("pokemon_target_pet_cell-icon_frame")
  self.txtPokemonTargetPetCellPetName = self:child("pokemon_target_pet_cell-pet_name")
  self.txtPokemonTargetPetCellPlayerName = self:child("pokemon_target_pet_cell-player_name")
  self.txtPokemonTargetPetCellEffectText = self:child("pokemon_target_pet_cell-effect_text")
  self.imgPokemonTargetPetCellSelect = self:child("pokemon_target_pet_cell-select")
  self.imgPokemonTargetPetCellSelect1 = self:child("pokemon_target_pet_cell-select_1")
  self.imgPokemonTargetPetCellMask = self:child("pokemon_target_pet_cell-mask")
end

function M:initEvent()
end

function M:updateInfo(pokemon, skillRace)
  self.pokemon = pokemon
  self.imgPokemonTargetPetCellIcon:SetImage(pokemon:getIcon())
  self.txtPokemonTargetPetCellPetName:SetText(pokemon:getName())
  local masterId = pokemon:getMasterId()
  local masterInfo = Game.GetPlayerByUserId(masterId)
  self.txtPokemonTargetPetCellPlayerName:SetText(masterInfo and masterInfo.name or "")
  if pokemon and skillRace then
    local petRace = pokemon:getRace()
    local result = RaceConfig:getDamageRateByRaceInfo(petRace, skillRace)
    self:showSkillResult(result)
  else
    self.txtPokemonTargetPetCellEffectText:SetVisible(false)
  end
end

function M:setCellMask(isShow)
  self.imgPokemonTargetPetCellMask:SetVisible(isShow)
end

function M:setCellSelected(isShow)
  self.imgPokemonTargetPetCellSelect:SetVisible(isShow)
end

function M:showSkillResult(result)
  self.txtPokemonTargetPetCellEffectText:SetVisible(result)
  if not result then
    return
  end
  if result < 1 and 0 < result then
    result = 2
  elseif 1 < result then
    result = 3
  end
  self.txtPokemonTargetPetCellEffectText:SetText(Lang:toText(string.format("ui_skill_result_%d", result)))
end

function M:getPokemon()
  return self.pokemon
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
