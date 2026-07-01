local widget_base = require("ui.widget.widget_base")
local WidgetPokemonRotaryGoodItem = Lib.derive(widget_base)
local PokemonConfig = T(Config, "PokemonConfig")

function WidgetPokemonRotaryGoodItem:init()
  widget_base.init(self, "PokemonRotaryGoodItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonRotaryGoodItem:initUI()
  self.lytPanel = self:child("PokemonRotaryGoodItem-Panel")
  self.lytGoodPanel = self:child("PokemonRotaryGoodItem-goodPanel")
  self.imgNormalBg = self:child("PokemonRotaryGoodItem-normalBg")
  self.imgSelectBg = self:child("PokemonRotaryGoodItem-selectBg")
  self.imgGoodIcon = self:child("PokemonRotaryGoodItem-goodIcon")
  self.imgGoodFrame = self:child("PokemonRotaryGoodItem-goodFrame")
  self.txtGoodNumTxt = self:child("PokemonRotaryGoodItem-goodNumTxt")
  self.lytGoodBlack = self:child("PokemonRotaryGoodItem-goodBlack")
  self.imgGou = self:child("PokemonRotaryGoodItem-gou")
  self.imgEffectIcon = self:child("PokemonRotaryGoodItem-effectIcon")
  self.imgEffectIcon:SetVisible(false)
end

function WidgetPokemonRotaryGoodItem:initEvent()
  self:subscribe(self.lytGoodPanel, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.itemData.fullName ~= "" then
      UI:getWnd("pokemonItemDetail"):onShow(self.itemData.fullName, dx, dy)
    elseif self.itemData.goldIcon ~= "" then
      return
    elseif self.itemData.pkm_id ~= 0 then
      UI:getWnd("pokemonLuckyDetails"):onShow(true, self.itemData.pkm_id)
    end
  end)
end

function WidgetPokemonRotaryGoodItem:initItemInfo(itemData)
  self.itemData = itemData
  self:updateSelectState(false)
  self.imgGoodFrame:SetVisible(false)
  self.txtGoodNumTxt:SetText("x" .. tostring(BigInteger.Create(itemData.award_num)))
  if itemData.fullName ~= "" then
    local setting = require("common.setting")
    local cfg = setting:fetch("item", itemData.fullName)
    if cfg then
      self.imgGoodIcon:SetImage(cfg.icon)
    end
  elseif itemData.goldIcon ~= "" then
    self.imgGoodIcon:SetImage(itemData.goldIcon)
  elseif itemData.pkm_id ~= 0 then
    local pkmInfo = PokemonConfig:getConfigById(itemData.pkm_id)
    self.imgGoodIcon:SetImage(pkmInfo.icon)
    local qualityFrame = PokemonConfig:getQualityFrame(itemData.pkmId)
    self.imgGoodFrame:SetVisible(true)
    self.imgGoodFrame:SetImage(qualityFrame)
  end
end

function WidgetPokemonRotaryGoodItem:updateGoodBgShow(tabKey)
  if tabKey == Define.RotaryTabType.goldTab then
    self.imgSelectBg:SetImage("set:pokemon_rotary_table.json image:img_0_received_gold")
    self.imgNormalBg:SetImage("set:pokemon_rotary_table.json image:img_0_frame_gold")
  else
    self.imgSelectBg:SetImage("set:pokemon_rotary_table.json image:img_0_received_candy")
    self.imgNormalBg:SetImage("set:pokemon_rotary_table.json image:img_0_frame_candy")
  end
end

function WidgetPokemonRotaryGoodItem:updateSelectState(value)
  self.lytGoodBlack:SetVisible(value)
  self.imgGou:SetVisible(value)
  self.imgSelectBg:SetVisible(value)
end

function WidgetPokemonRotaryGoodItem:onInvoke(key, ...)
  local fn = WidgetPokemonRotaryGoodItem[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonRotaryGoodItem
