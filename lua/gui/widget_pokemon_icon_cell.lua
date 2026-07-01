local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  widget_base.init(self, "pokemon_icon_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonIcon = self:child("pokemon_icon_cell-content")
  self.imgPokemonSelect = self:child("pokemon_icon_cell-select")
  self.imgPokemonSelect:SetVisible(false)
  self.lytPokemonEffect = self:child("pokemon_icon_cell-effect")
  self.lytPokemonEffect:SetVisible(false)
end

function M:initEvent()
end

function M:initById(id)
  self.id = id
  local config = PokemonConfig:getConfigById(id)
  Lib.logDebug("config.icon = ", config.icon)
  self.imgPokemonIcon:SetImage(config.icon)
end

function M:onChecked(id)
  if id == self.id then
    self.imgPokemonSelect:SetVisible(true)
  else
    self.imgPokemonSelect:SetVisible(false)
  end
end

function M:showEffect(show)
  self.lytPokemonEffect:SetVisible(show)
end

function M:onDataChanged(data)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
