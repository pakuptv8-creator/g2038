local widget_base = require("ui.widget.widget_base")
local WidgetPokemonGloryAwardItem = Lib.derive(widget_base)
local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")

function WidgetPokemonGloryAwardItem:init()
  widget_base.init(self, "pokemon_glory_award_item.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonGloryAwardItem:initUI()
  self.imgPokemonGloryAwardItemFrameIcon = self:child("pokemon_glory_award_item-frame_icon")
  self.imgPokemonGloryAwardItemIcon = self:child("pokemon_glory_award_item-icon")
  self.txtPokemonGloryAwardItemNum = self:child("pokemon_glory_award_item-num")
  self.imgPokemonGloryAwardItemBg = self:child("pokemon_glory_award_item-bg")
  self.imgChengEffect = self:child("pokemon_glory_award_item-chengEffect")
  self.txtPokemonGloryAwardItemNum:SetVisible(false)
  self.imgChengEffect:SetVisible(false)
end

function WidgetPokemonGloryAwardItem:initEvent()
  self:subscribe(self:root(), UIEvent.EventWindowClick, function(window, dx, dy)
    if self.itemData.pkmId and self.itemData.pkmId > 0 then
      UI:getWnd("pokemonLuckyDetails"):onShow(true, self.itemData.pkmId)
    elseif self.itemData.fullName then
      UI:getWnd("pokemonItemDetail"):onShow(self.itemData.fullName, dx, dy)
    end
  end)
end

function WidgetPokemonGloryAwardItem:updateInfo(itemData)
  self.itemData = itemData
  self.imgChengEffect:SetVisible(false)
  if itemData.pkmId then
    local pkmInfo = PokemonConfig:getConfigById(itemData.pkmId)
    self.imgPokemonGloryAwardItemIcon:SetImage(pkmInfo.icon)
    self.imgPokemonGloryAwardItemBg:SetImage("set:pokemon_lucky_egg.json image:img_0_frame_bg")
    local qualityFrame = PokemonConfig:getQualityFrame(itemData.pkmId)
    self.imgPokemonGloryAwardItemFrameIcon:SetVisible(true)
    self.imgPokemonGloryAwardItemFrameIcon:SetImage(qualityFrame)
    self.imgChengEffect:SetVisible(pkmInfo.quality == 3)
  elseif itemData.fullName then
    local cfg = setting:fetch("item", itemData.fullName)
    if cfg then
      self.imgPokemonGloryAwardItemBg:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
      self.imgPokemonGloryAwardItemIcon:SetImage(cfg.icon)
    end
    self.imgPokemonGloryAwardItemFrameIcon:SetVisible(false)
  elseif itemData.goldIcon then
    self.imgPokemonGloryAwardItemIcon:SetImage(itemData.goldIcon)
    self.imgPokemonGloryAwardItemFrameIcon:SetVisible(false)
  end
end

function WidgetPokemonGloryAwardItem:onInvoke(key, ...)
  local fn = WidgetPokemonGloryAwardItem[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonGloryAwardItem
