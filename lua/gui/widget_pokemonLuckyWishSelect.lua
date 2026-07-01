local widget_base = require("ui.widget.widget_base")
local WidgetPokemonLuckyWishSelect = Lib.derive(widget_base)
local PokemonConfig = T(Config, "PokemonConfig")
local RaceConfig = T(Config, "RaceConfig")
local blingCycle = 35

function WidgetPokemonLuckyWishSelect:init()
  widget_base.init(self, "PokemonLuckyWishSelect.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonLuckyWishSelect:initUI()
  self.lytPanel = self:child("PokemonLuckyWishSelect-Panel")
  self.lytPkmItem = self:child("PokemonLuckyWishSelect-pkmItem")
  self.imgBg = self:child("PokemonLuckyWishSelect-Bg")
  self.imgPkmIcon = self:child("PokemonLuckyWishSelect-pkmIcon")
  self.imgBbg = self:child("PokemonLuckyWishSelect-bbg")
  self.imgFrame = self:child("PokemonLuckyWishSelect-frame")
  self.imgRaceIcon = self:child("PokemonLuckyWishSelect-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyWishSelect-starIcon")
  self.txtPkmName = self:child("PokemonLuckyWishSelect-pkmName")
  self.imgNoneIcon = self:child("PokemonLuckyWishSelect-noneIcon")
  self.imgAddIcon = self:child("PokemonLuckyWishSelect-addIcon")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
end

function WidgetPokemonLuckyWishSelect:initEvent()
  self:subscribe(self.lytPanel, UIEvent.EventWindowClick, function()
    if self.wishClickCallFunc then
      self.wishClickCallFunc()
    end
  end)
end

function WidgetPokemonLuckyWishSelect:initClickCallFunc(wishClickCallFunc)
  self.wishClickCallFunc = wishClickCallFunc
end

function WidgetPokemonLuckyWishSelect:updateWishState(state)
  self.curState = state
  if self.bling_cancel then
    self.bling_cancel()
  end
  if self.curState == 2 then
    self.imgNoneIcon:SetVisible(false)
    self.lytPkmItem:SetVisible(true)
  else
    self.imgNoneIcon:SetVisible(true)
    self.lytPkmItem:SetVisible(false)
    self.blinkTick = 0
    self.bling_cancel = World.Timer(1, function()
      self:onBlingTick()
      return true
    end)
  end
end

function WidgetPokemonLuckyWishSelect:updateWishItemData(pkm_id)
  local pkmInfo = PokemonConfig:getConfigById(pkm_id)
  self.txtPkmName:SetText(Lang:toText(pkmInfo.name))
  local qualityIconFrame = {
    "set:pokemon_pet_frame.json image:img_0_frame_blue",
    "set:pokemon_pet_frame.json image:img_0_frame_purple",
    "set:pokemon_pet_frame.json image:img_0_frame_orange"
  }
  self.imgFrame:SetImage(qualityIconFrame[pkmInfo.quality])
  self.imgPkmIcon:SetImage(pkmInfo.icon)
  self.imgRaceIcon:SetImage(RaceConfig:getClassifyIcon(pkmInfo.race))
  self.itemStarLevel:invoke("updateUI", pkmInfo.newStar or pkmInfo.starLevel, pkmInfo.maxWake, 1)
end

function WidgetPokemonLuckyWishSelect:onBlingTick()
  self.blinkTick = (self.blinkTick + 1) % blingCycle
  self.imgAddIcon:SetAlpha(math.abs(self.blinkTick - blingCycle / 2) / (blingCycle / 2))
end

function WidgetPokemonLuckyWishSelect:onDestroy()
  if self.bling_cancel then
    self.bling_cancel()
  end
end

function WidgetPokemonLuckyWishSelect:onInvoke(key, ...)
  local fn = WidgetPokemonLuckyWishSelect[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonLuckyWishSelect
