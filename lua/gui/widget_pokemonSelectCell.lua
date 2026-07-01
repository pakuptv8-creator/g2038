local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")
local qualityIconBG = {
  "blue",
  "purple",
  "orange"
}
local blingCycle = 35

function M:init()
  widget_base.init(self, "pokemonSelectCell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonSelectCellItem = self:child("pokemonSelectCell-Item")
  local pokemonItem = UIMgr:new_widget("pokemon_packet_item_cell")
  pokemonItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.imgPokemonSelectCellItem:AddChildWindow(pokemonItem)
  self.pokemonItem = pokemonItem
  self.imgPokemonSelectCellLimitHeadIcon = self:child("pokemonSelectCell-Limit-HeadIcon")
  self.imgPokemonSelectCellAdd = self:child("pokemonSelectCell-Add")
  self:setLimitHeadIcon()
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.clickCallBack then
      self.clickCallBack(self.pokemon)
      return
    end
  end)
end

function M:setLimitHeadIcon(imgStr, dontBling)
  self.imgPokemonSelectCellLimitHeadIcon:SetVisible(imgStr ~= nil)
  self.imgPokemonSelectCellAdd:SetVisible(not dontBling)
  self.imgPokemonSelectCellLimitHeadIcon:SetAlpha(dontBling and 1 or 0.5)
  if self.bling_cancel then
    self.bling_cancel()
  end
  if imgStr and not dontBling then
    self.imgPokemonSelectCellLimitHeadIcon:SetImage(imgStr or "")
    self.blinkTick = 0
    self.bling_cancel = World.Timer(1, function()
      self:onBlingTick()
      return true
    end)
  end
end

function M:onBlingTick()
  self.blinkTick = (self.blinkTick + 1) % blingCycle
  self.imgPokemonSelectCellAdd:SetAlpha(math.abs(self.blinkTick - blingCycle / 2) / (blingCycle / 2))
end

function M:updatePokemonItem(pokemon)
  self.pokemonItem:invoke("onDataChanged", {pokemon = pokemon})
  self.pokemonItem:SetVisible(true)
end

function M:hidePokemonItem()
  self.pokemonItem:SetVisible(false)
end

function M:setData(clickCallBack, pokemon)
  self.clickCallBack = clickCallBack
  self.pokemon = pokemon
  self:updateUI()
end

function M:setPokemon(pokemon)
  self.pokemon = pokemon
  self:updateUI()
end

function M:updateUI()
  if self.pokemon then
    self:updatePokemonItem(self.pokemon)
  else
    self:hidePokemonItem()
  end
end

function M:onDataChanged(data)
  self:setData(data.clickCallBack, data.pokemon)
end

function M:onDestroy()
  if self.bling_cancel then
    self.bling_cancel()
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
