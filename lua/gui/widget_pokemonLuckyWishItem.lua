local widget_base = require("ui.widget.widget_base")
local WidgetPokemonLuckyWishItem = Lib.derive(widget_base)
local RaceConfig = T(Config, "RaceConfig")

function WidgetPokemonLuckyWishItem:init()
  widget_base.init(self, "PokemonLuckyWishItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonLuckyWishItem:initUI()
  self.lytPanel = self:child("PokemonLuckyWishItem-Panel")
  self.imgBg = self:child("PokemonLuckyWishItem-Bg")
  self.imgPkmIcon = self:child("PokemonLuckyWishItem-pkmIcon")
  self.imgBbg = self:child("PokemonLuckyWishItem-bbg")
  self.imgFrame = self:child("PokemonLuckyWishItem-frame")
  self.imgRaceIcon = self:child("PokemonLuckyWishItem-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyWishItem-starIcon")
  self.txtPkmName = self:child("PokemonLuckyWishItem-pkmName")
  self.imgMaskIcon = self:child("PokemonLuckyWishItem-maskIcon")
  self.imgGouIcon = self:child("PokemonLuckyWishItem-gouIcon")
  self.imgSelectIcon = self:child("PokemonLuckyWishItem-selectIcon")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
end

function WidgetPokemonLuckyWishItem:initEvent()
  self:subscribe(self.lytPanel, UIEvent.EventWindowClick, function()
    if self.selectCallFunc then
      self.selectCallFunc()
    end
  end)
end

function WidgetPokemonLuckyWishItem:onDataChanged(pkmInfo)
  self.pkmInfo = pkmInfo
  self.selectCallFunc = pkmInfo.selectCallFunc
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
  self:updateSelectIcon(false)
  self:updateMaskIcon(false)
end

function WidgetPokemonLuckyWishItem:updateSelectIcon(value)
  self.imgSelectIcon:SetVisible(false)
end

function WidgetPokemonLuckyWishItem:updateMaskIcon(value)
  self.imgMaskIcon:SetVisible(value)
end

function WidgetPokemonLuckyWishItem:getItemPkmId()
  return self.pkmInfo.id
end

function WidgetPokemonLuckyWishItem:onInvoke(key, ...)
  local fn = WidgetPokemonLuckyWishItem[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonLuckyWishItem
