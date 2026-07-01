local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local setting = require("common.setting")
local color = {
  [1] = "\226\150\162FF873E01",
  [2] = "\226\150\162FF548135",
  [3] = "\226\150\162FF12A2FF",
  [4] = "\226\150\162FF6F258E",
  [5] = "\226\150\162FFFF8402"
}

function M:init()
  widget_base.init(self, "pokemon_buy_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBuyItemCellBuyItemBg = self:child("pokemon_buy_item_cell-buy_item_bg")
  self.imgPokemonBuyItemCellBuyItemIcon = self:child("pokemon_buy_item_cell-buy_item_icon")
  self.txtPokemonBuyItemCellBuyItemNum = self:child("pokemon_buy_item_cell-buy_item_num")
  self.txtPokemonBuyItemCellBuyItemName = self:child("pokemon_buy_item_cell-buy_item_name")
end

function M:initEvent()
end

function M:updateInfo(fullName, count)
  if not fullName then
    return
  end
  local cfg = setting:fetch("item", fullName)
  if not cfg then
    return
  end
  self.txtPokemonBuyItemCellBuyItemName:SetText(color[cfg.rarity] .. Lang:toText(cfg.itemName))
  self.imgPokemonBuyItemCellBuyItemBg:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
  self.imgPokemonBuyItemCellBuyItemIcon:SetImage(cfg.icon)
  self.txtPokemonBuyItemCellBuyItemNum:SetText(count)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
