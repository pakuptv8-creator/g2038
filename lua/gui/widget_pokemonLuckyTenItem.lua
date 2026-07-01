local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  widget_base.init(self, "PokemonLuckyTenItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPanel = self:child("PokemonLuckyTenItem-Panel")
  self.imgBg = self:child("PokemonLuckyTenItem-Bg")
  self.imgBbg = self:child("PokemonLuckyTenItem-bbg")
  self.imgPkmIcon = self:child("PokemonLuckyTenItem-pkmIcon")
  self.imgFrame = self:child("PokemonLuckyTenItem-frame")
  self.imgRaceIcon = self:child("PokemonLuckyTenItem-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyTenItem-starIcon")
  self.imgNewIcon = self:child("PokemonLuckyTenItem-newIcon")
  self.imgItemEffect = self:child("PokemonLuckyTenItem-itemEffect")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
end

function M:initEvent()
  self:subscribe(self.lytPanel, UIEvent.EventWindowClick, function()
    if not self.curPokemon then
      return
    end
    UI:getWnd("pokemonLuckyDetails"):onShow(true, self.curPokemon:getCfgId(), UI:getWnd("pokemonLuckyEgg").curSelectTab)
  end)
end

function M:onDataChanged(pkmInfo)
  self.imgNewIcon:SetVisible(pkmInfo.isNew)
  PokemonManager:getPokemon(tonumber(pkmInfo.pkmObjId), function(pokemon)
    if not pokemon then
      Lib.logError("handles PokemonValue not pokemon", pkmInfo.pkmObjId)
      return
    end
    self:updatePkmInfoShow(pokemon)
  end)
end

function M:updatePkmInfoShow(pokemon)
  self.curPokemon = pokemon
  self.imgRaceIcon:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
  self.imgPkmIcon:SetImage(pokemon:getIcon())
  self.itemStarLevel:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake(), 1)
  local cfgId = pokemon:getCfgId()
  local config = PokemonConfig:getConfigById(cfgId)
  local qualityIconFrame = {
    "set:pokemon_pet_frame.json image:img_0_frame_blue",
    "set:pokemon_pet_frame.json image:img_0_frame_purple",
    "set:pokemon_pet_frame.json image:img_0_frame_orange"
  }
  self.imgFrame:SetImage(qualityIconFrame[config.quality])
  self.imgItemEffect:UnprepareEffect()
  self.imgItemEffect:SetEffectName("g2038_choudan_kuang" .. config.quality .. ".effect")
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
