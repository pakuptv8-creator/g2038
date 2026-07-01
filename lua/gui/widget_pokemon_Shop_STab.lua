local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local SelectStatus = {NotSelect = 1, Select = 2}
local subTabIcons = {
  [1] = {
    [1] = "set:pokemon_shop.json image:btn_0_limited-timediscount_clicked",
    [2] = "set:pokemon_shop.json image:btn_0_goods_clicked",
    [3] = "set:pokemon_shop.json image:btn_0_preferential_clicked"
  },
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {
    [1] = "set:pokemon_shop.json image:btn_0_skillbooks_normal",
    [2] = "set:pokemon_shop.json image:btn_0_skillbooks_water",
    [3] = "set:pokemon_shop.json image:btn_0_skillbooks_fire",
    [4] = "set:pokemon_shop.json image:btn_0_skillbooks_grass",
    [5] = "set:pokemon_shop.json image:btn_0_skillbooks_super"
  }
}

function M:init()
  widget_base.init(self, "pokemon_Shop_STab.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonShopSTabIcon2 = self:child("pokemon_Shop_STab-Icon2")
  self.imgPokemonShopSTabIcon1 = self:child("pokemon_Shop_STab-Icon1")
  self.imgPokemonShopSTabIcon3 = self:child("pokemon_Shop_STab-Icon3")
  self.imgPokemonShopSTabRedDotIcon = self:child("pokemon_Shop_STab-red_icon")
  self.txtPokemonShopSTabTitle = self:child("pokemon_Shop_STab-title")
end

function M:initEvent()
end

function M:initTabByType(tabType, stabType)
  self.type = tabType
  self.smallType = stabType
  self.selectStatus = SelectStatus.NotSelect
  self.imgPokemonShopSTabIcon3:SetImage(subTabIcons[tabType][stabType] or "")
  self.txtPokemonShopSTabTitle:SetText(Lang:toText(string.format("ui_shop_sTab_%d_%d", tabType, stabType)))
  self:changeSelectStatus()
end

function M:setTabImgRes(tabImage)
  self.imgPokemonShopSTabIcon2:SetImage(tabImage.selectedRes)
  self.imgPokemonShopSTabIcon1:SetImage(tabImage.unSelectRes)
end

function M:onCheckClick(type, smallType)
  if self.type == type and self.smallType == smallType then
    self.selectStatus = SelectStatus.Select
  else
    self.selectStatus = SelectStatus.NotSelect
  end
  self:changeSelectStatus()
end

function M:changeSelectStatus()
  if self.selectStatus == SelectStatus.Select then
    self.imgPokemonShopSTabIcon1:SetVisible(false)
  else
    self.imgPokemonShopSTabIcon1:SetVisible(true)
  end
end

function M:onShowRedDotIcon(isShow)
  self.imgPokemonShopSTabRedDotIcon:SetVisible(isShow)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
