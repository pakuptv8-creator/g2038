local widget_base = require("ui.widget.widget_base")
local setting = require("common.setting")
local PokemonConfig = T(Config, "PokemonConfig")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_gift_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonGiftItemCellFrame = self:child("pokemon_gift_item_cell-frame")
  self.imgPokemonGiftItemCellItemIcon = self:child("pokemon_gift_item_cell-item_icon")
  self.txtPokemonGiftItemCellCount = self:child("pokemon_gift_item_cell-count")
  self.lytPokemonGiftItemCellEffect = self:child("pokemon_gift_item_cell-effect")
  self.llPokemonGiftItemCellStarLevel = self:child("pokemon_gift_item_cell-star_level")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.llPokemonGiftItemCellStarLevel:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("setHInterval", -0.5)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemon_item_cell _root event : EventWindowClick", self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.isShow then
      return
    end
    if self.info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET then
      if type(self.info.item) == "table" then
        UI:getWnd("pokemon_three_select_one"):onShow(self.info.id, true)
      else
        UI:getWnd("pokemonLuckyDetails"):onShow(true, self.info.item)
      end
    elseif self.info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.GOLD then
    elseif self.info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.ITEM then
      UI:getWnd("pokemonItemDetail"):onShow(self.info.item, dx, dy)
    end
  end)
end

function M:updateInfo(info)
  if not info then
    return
  end
  self.info = info
  local icon = ""
  if info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET then
    if type(info.item) == "table" then
      icon = info.sp_icon
    else
      local pokemon = PokemonConfig:getConfigById(info.item)
      icon = pokemon and pokemon.icon
    end
  elseif info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.GOLD then
    icon = "set:pokemonRechargeAward.json image:goldIcon"
  elseif info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.ITEM then
    local cfg = setting:fetch("item", info.item)
    icon = cfg.icon
  end
  local frameImg = "set:pokemon_gift_bag.json image:img_0_itemboard2"
  local showEffect = false
  if info.highlight then
    frameImg = "set:pokemon_gift_bag.json image:img_0_itemboard1"
    showEffect = true
  end
  self.imgPokemonGiftItemCellFrame:SetImage(frameImg)
  self.imgPokemonGiftItemCellItemIcon:SetImage(icon)
  self.txtPokemonGiftItemCellCount:SetText("x" .. info.count)
  self.lytPokemonGiftItemCellEffect:SetVisible(showEffect)
  self.itemStarLevel:invoke("updateUI", info.petStarLevel or 0, 0, 1)
  self:onCellShow(true)
end

function M:onCellShow(isShow)
  self.isShow = isShow
  self.imgPokemonGiftItemCellFrame:SetVisible(isShow)
  self.imgPokemonGiftItemCellItemIcon:SetVisible(isShow)
  self.txtPokemonGiftItemCellCount:SetVisible(isShow)
  self.llPokemonGiftItemCellStarLevel:SetVisible(isShow)
  if not isShow then
    self.lytPokemonGiftItemCellEffect:SetVisible(isShow)
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
