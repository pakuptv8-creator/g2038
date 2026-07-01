local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")

function M:init()
  widget_base.init(self, "pokemon_race_tab_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonRaceTabCellIcon = self:child("pokemon_race_tab_cell-Icon")
  self.txtPokemonRaceTabCellText = self:child("pokemon_race_tab_cell-Text")
  self.txtPokemonRaceTabCellMask = self:child("pokemon_race_tab_cell-Mask")
end

function M:initEvent()
end

function M:getPokemon()
  return self.pokemon
end

function M:setRaceId(raceId)
  self.raceId = raceId
  self.txtPokemonRaceTabCellText:SetText(Lang:toText(RaceConfig:getName(raceId)))
  self.imgPokemonRaceTabCellIcon:SetImage(RaceConfig:getClassifyIcon(raceId))
end

function M:getRaceId()
  return self.raceId
end

function M:setEnabled(enable)
  self.txtPokemonRaceTabCellMask:SetVisible(not enable)
  self._root:SetTouchable(enable)
end

function M:setType(type)
  if type == "replace" then
    self.txtPokemonRaceTabCellText:SetVisible(false)
    self._root:SetNormalImage("")
    self._root:SetPushedImage("set:pokemon_pet_packet.json image:chb_9_race_checked")
    self.imgPokemonRaceTabCellIcon:SetXPosition({0, 0})
    self.imgPokemonRaceTabCellIcon:SetHorizontalAlignment(1)
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
