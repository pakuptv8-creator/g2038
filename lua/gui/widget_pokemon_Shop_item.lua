local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_Shop_item.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonShopItemPanel = self:child("pokemon_Shop_item-panel")
  self.imgPokemonShopItemBg = self:child("pokemon_Shop_item-bg")
  self.imgPokemonShopItemGoodsIcon = self:child("pokemon_Shop_item-goods_icon")
  self.imgPokemonShopDisBg = self:child("pokemon_Shop_dis_bg")
  self.txtPokemonShopDisTxt = self:child("pokemon_Shop_dis_txt")
  self.imgPokemonShopItemRedIcon = self:child("pokemon_Shop_item-red_icon")
  self.txtPokemonShopLimitNum = self:child("pokemon_Shop_item-limit_num")
  self.imgPokemonShopItemItemSelected = self:child("pokemon_Shop_item-item_selected")
  self.imgPokemonShopItemEffect = self:child("pokemon_Shop_item-effect")
  self.imgPokemonShopItemCurrency = self:child("pokemon_Shop_item-currency")
  self.txtPokemonShopItemPriceNum = self:child("pokemon_Shop_item-price_num")
  self.txtPokemonShopItemName = self:child("pokemon_Shop_item-name")
  self.imgPokemonShopItemMask = self:child("pokemon_Shop_item-mask")
  self:child("pokemon_Shop_item-mask_text"):SetText(Lang:toText("ui_sold_out"))
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.clickCallBack and not self.sellOut then
      self.clickCallBack()
      return
    end
  end)
  self:subscribe(self._root, UIEvent.EventWindowTouchDown, function()
    self:onChecked(true)
  end)
  self:subscribe(self._root, UIEvent.EventWindowTouchUp, function()
    self:onChecked(false)
  end)
end

function M:onDataChanged(data)
  self.clickCallBack = data.clickCallBack
  self:onChecked(false)
  self.imgPokemonShopItemBg:SetImage("set:pokemon_bag.json image:chb_0_box")
  self.imgPokemonShopItemGoodsIcon:SetImage()
  self.txtPokemonShopLimitNum:SetVisible(false)
  self.imgPokemonShopItemRedIcon:SetVisible(false)
  self.imgPokemonShopDisBg:SetVisible(false)
  self.imgPokemonShopItemMask:SetVisible(false)
  self.txtPokemonShopItemName:SetYPosition({0.62, 0})
  self.sellOut = false
  if not data.id then
    return
  end
  self.imgPokemonShopItemBg:SetImage(string.format("set:pokemon_shop.json image:img_9_commodity_quality_%d", data.rarity))
  self.imgPokemonShopItemGoodsIcon:SetImage(data.icon)
  if 0 < data.buyCount then
    self.txtPokemonShopLimitNum:SetVisible(true)
    local curBuyCount = data.curBuyCount or 0
    self.txtPokemonShopLimitNum:SetText(Lang:toText("ui_remaining_goods") .. ":" .. data.buyCount - curBuyCount)
    self.sellOut = curBuyCount == data.buyCount
    self.imgPokemonShopItemMask:SetVisible(self.sellOut)
    self.txtPokemonShopItemName:SetYPosition({0.547619, 0})
  end
  if data.discount ~= 1 then
    self.imgPokemonShopDisBg:SetVisible(true)
    local DisTxt
    if data.discount == 0 then
      DisTxt = Lang:toText("ui_free")
    else
      DisTxt = "-" .. math.floor(100 - 100 * data.discount) .. "%"
    end
    self.txtPokemonShopDisTxt:SetText(DisTxt)
  end
  self.imgPokemonShopItemRedIcon:SetVisible(data.showRedDot == 1 and not self.sellOut)
  self.imgPokemonShopItemEffect:SetVisible(data.showEffect == 1)
  self.txtPokemonShopItemName:SetText(Lang:toText(data.name))
  local currencyIcon = "set:pokemonMain.json image:icon_coin"
  if data.isPay then
    currencyIcon = "set:pokemonMain.json image:icon_dimond"
  end
  self.imgPokemonShopItemCurrency:SetImage(currencyIcon)
  local price = math.ceil(data.originalPrice * data.discount)
  self.txtPokemonShopItemPriceNum:SetText(price)
end

function M:onChecked(isSelect)
  self.imgPokemonShopItemItemSelected:SetVisible(isSelect)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
