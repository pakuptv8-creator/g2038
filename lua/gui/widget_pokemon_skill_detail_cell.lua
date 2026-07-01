local widget_base = require("ui.widget.widget_base")
local RaceConfig = T(Config, "RaceConfig")
local SkillConfig = T(Config, "SkillConfig")
local M = Lib.derive(widget_base)
local hurtAbilityImg = {
  [0] = "set:pokemon_pet_attribute.json image:img_0_attribute_special",
  [1] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicalattacks",
  [2] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellattacks",
  [3] = "set:pokemon_pet_attribute.json image:img_0_attribute_special"
}
local defAbilityImg = {
  [1] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicaldefense",
  [2] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellprotection"
}
local speedAbilityImg = "set:pokemon_pet_attribute.json image:img_0_attribute_speed"
local speedAbilityImg = "set:pokemon_pet_attribute.json image:img_0_attribute_hit"

function M:init()
  widget_base.init(self, "pokemon_skill_detail_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonSkillDetailCellAbilityIcon = self:child("pokemon_skill_detail_cell-ability_icon")
  self.imgPokemonSkillDetailCellInfo = self:child("pokemon_skill_detail_cell-info")
  self.txtPokemonSkillDetailCellName = self:child("pokemon_skill_detail_cell-name")
  self.txtPokemonSkillDetailCellNum = self:child("pokemon_skill_detail_cell-num")
  self.lytPokemonSkillDetailCellDetailList = self:child("pokemon_skill_detail_cell-detail_list")
  self.txtPokemonSkillDetailCellDetailText = self:child("pokemon_skill_detail_cell-detail_text")
  self.abilityIcon = {}
  self.abilityNum = {}
  for i = 1, 3 do
    self.abilityIcon[i] = self:child(string.format("pokemon_skill_detail_cell-ability_%d", i))
    self.abilityNum[i] = self:child(string.format("pokemon_skill_detail_cell-ability_num_%d", i))
  end
  self.gvSkillDec = UIMgr:new_widget("grid_view")
  self:initList()
end

function M:initList()
  self.lytPokemonSkillDetailCellDetailList:AddChildWindow(self.gvSkillDec)
  self.gvSkillDec:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvSkillDec:InitConfig(0, 0, 1)
  self.gvSkillDec:AddItem(self.txtPokemonSkillDetailCellDetailText)
end

function M:initEvent()
end

function M:updateInfo(data)
  local config = SkillConfig:getConfigById(data.skillId) or {}
  self.txtPokemonSkillDetailCellName:SetText(Lang:toText(config.name or "SkillName"))
  self.txtPokemonSkillDetailCellDetailText:SetText(Lang:toText(config.describe or "DescText"))
  self.imgPokemonSkillDetailCellAbilityIcon:SetImage(RaceConfig:getIcon(config.race))
  self.txtPokemonSkillDetailCellNum:SetText(tostring(data.curTimes) .. "/" .. tostring(data.maxTimes))
  self.abilityIcon[1]:SetImage(hurtAbilityImg[config.hurt_type])
  local hurt = (not config.hurt or config.hurt == 0) and "--" or config.hurt
  self.abilityNum[1]:SetText(hurt)
  self.abilityNum[2]:SetText(config.skill_speed or 0)
  self.abilityNum[3]:SetText(config.accuracy or 0)
end

function M:setType()
  self.txtPokemonSkillDetailCellNum:SetVisible(false)
  self.lytPokemonSkillDetailCellDetailList:SetBackImage("set:pokemon_pet_packet.json image:img_9_skilldescribeboard_color")
  self.imgPokemonSkillDetailCellInfo:SetImage("")
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
