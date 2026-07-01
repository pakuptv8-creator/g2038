local SkillConfig = T(Config, "SkillConfig")
local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_passive_detail_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPassiveDetailCellIconBg = self:child("pokemon_passive_detail_cell-Icon-Bg")
  self.txtPokemonPassiveDetailCellName = self:child("pokemon_passive_detail_cell-Name")
  self.txtPokemonPassiveDetailCellText = self:child("pokemon_passive_detail_cell-Text")
  self.txtPokemonPassiveDetailCellDescLayout = self:child("pokemon_passive_detail_cell-Desc-Layout")
  self.stPassiveDescIcon = UIMgr:new_widget("pokemon_passive_cell")
  self.stPassiveDescIcon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.imgPokemonPassiveDetailCellIconBg:AddChildWindow(self.stPassiveDescIcon)
end

function M:initEvent()
end

function M:updateSize()
  local rootHeight = self:root():GetPixelSize().y
  local headSize = math.floor((rootHeight - 20) / 2)
  self.imgPokemonPassiveDetailCellIconBg:SetHeight({0, headSize})
  self.imgPokemonPassiveDetailCellIconBg:SetWidth({0, headSize})
  self.txtPokemonPassiveDetailCellDescLayout:SetHeight({0, headSize})
end

function M:updateInfo(skillId)
  local skill_config = SkillConfig:getConfigById(skillId) or {}
  self.txtPokemonPassiveDetailCellName:SetText(Lang:toText(skill_config.name or "SkillName"))
  self.txtPokemonPassiveDetailCellText:SetText(Lang:toText(skill_config.describe or "DescText"))
  self.stPassiveDescIcon:invoke("updateInfo", skillId, false)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
