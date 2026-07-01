local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")

function M:init()
  widget_base.init(self, "PokemonPlayerInfoPet.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonPlayerInfoPetHeadImg = self:child("PokemonPlayerInfoPet-HeadImg")
  self.imgPokemonPlayerInfoPetHeadImgBg = self:child("PokemonPlayerInfoPet-HeadImgBg")
  self.imgPokemonPlayerInfoPetBarBg = self:child("PokemonPlayerInfoPet-BarBg")
  self.grdPokemonPlayerInfoPetHpBar = self:child("PokemonPlayerInfoPet-HpBar")
  self.imgPokemonPlayerInfoPetState = self:child("PokemonPlayerInfoPet-State")
end

function M:initEvent()
  self.changeCancel = Lib.lightSubscribeEvent("error!!!!! script_client widget_pokemonPlayerInfoPet Lib event : EVENT_POKEMON_DATA_CHANGE", Event.EVENT_POKEMON_DATA_CHANGE, function(objId)
    if self.pokemon and tostring(objId) == tostring(self.pokemon:getObjId()) then
      self:initViewData(self.pokemon)
    end
  end)
  self.clickEvent = self:lightSubscribe("error!!!!! script_client widget_pokemonPlayerInfoPet event : EventWindowClick", self:child("PokemonPlayerInfoPet-HeadFrame"), UIEvent.EventWindowClick, function()
    UI:getWnd("pokemonReplace"):onShow()
  end)
end

function M:onDestroy()
  if self.changeCancel then
    self.changeCancel()
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:initViewData(pokemon)
  if not pokemon then
    self.imgPokemonPlayerInfoPetState:SetVisible(false)
    self.imgPokemonPlayerInfoPetBarBg:SetVisible(false)
    self.grdPokemonPlayerInfoPetHpBar:SetVisible(false)
    self.imgPokemonPlayerInfoPetHeadImg:SetVisible(false)
    self.imgPokemonPlayerInfoPetHeadImgBg:SetImage("set:pokemon_pet_packet.json image:img_0_addpet")
    return
  end
  self.pokemon = pokemon
  self.imgPokemonPlayerInfoPetState:SetVisible(true)
  self.imgPokemonPlayerInfoPetBarBg:SetVisible(true)
  self.grdPokemonPlayerInfoPetHpBar:SetVisible(true)
  self.imgPokemonPlayerInfoPetHeadImg:SetVisible(true)
  self.imgPokemonPlayerInfoPetHeadImg:SetImage(pokemon:getIcon())
  self.imgPokemonPlayerInfoPetState:SetImage(pokemon:getDebuffIcon())
  self.grdPokemonPlayerInfoPetHpBar:SetProgress(pokemon:getCurHp() / pokemon:getMaxHp())
  local color = RaceConfig:getColorBg(pokemon:getRace())
  self.imgPokemonPlayerInfoPetHeadImgBg:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
end

return M
