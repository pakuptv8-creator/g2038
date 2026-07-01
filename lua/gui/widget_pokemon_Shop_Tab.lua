local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local SelectStatus = {NotSelect = 1, Select = 2}
local tabIcons = {
  [1] = "set:pokemon_shop.json image:img_0_shop",
  [2] = "set:pokemon_shop.json image:img_0_commonlyused",
  [3] = "set:pokemon_shop.json image:img_0_fairyball",
  [4] = "set:pokemon_shop.json image:img_0_drug",
  [5] = "set:pokemon_shop.json image:img_0_culturing",
  [6] = "set:pokemon_shop.json image:img_0_special"
}

function M:init()
  widget_base.init(self, "pokemon_Shop_Tab.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonShopTabIcon1 = self:child("pokemon_Shop_Tab-Icon1")
  self.imgPokemonShopTabIcon2 = self:child("pokemon_Shop_Tab-Icon2")
  self.imgPokemonShopTabIcon3 = self:child("pokemon_Shop_Tab-Icon3")
  self.imgPokemonShopTabRedDotIcon = self:child("pokemon_Shop_Tab-red_icon")
  self.txtPokemonShopTabTitle = self:child("pokemon_Shop_Tab-title")
  self.llPokemonShopTabSTabList = self:child("pokemon_Shop_Tab-sTab_list")
  self.imgPokemonShopTabUnfold = self:child("pokemon_Shop_Tab-unfold")
  self.llPokemonShopTabSTabInfo = self:child("pokemon_Shop_Tab-sTab_info")
  self.llPokemonShopTabInfo = self:child("pokemon_Shop_Tab-info")
end

function M:initEvent()
end

function M:initTabByType(tabType)
  self.type = tabType
  self.selectStatus = SelectStatus.NotSelect
  self.imgPokemonShopTabIcon3:SetImage(tabIcons[tabType])
  self.txtPokemonShopTabTitle:SetText(Lang:toText(string.format("ui_shop_tab_%d", tabType)))
  self:changeSelectStatus()
end

function M:onCheckClick(type)
  if self.type == type then
    self.selectStatus = SelectStatus.Select
  else
    self.selectStatus = SelectStatus.NotSelect
  end
  self:changeSelectStatus()
end

function M:changeSelectStatus()
  if self.selectStatus == SelectStatus.Select then
    self.imgPokemonShopTabIcon1:SetVisible(false)
  else
    self.imgPokemonShopTabIcon1:SetVisible(true)
  end
end

function M:getSTabList()
  return self.llPokemonShopTabSTabList
end

function M:setSTabListHeight(height)
  self._root:SetHeight({
    0,
    height + 72
  })
end

function M:onShopUnfold(isShow)
  self.imgPokemonShopTabUnfold:SetVisible(isShow)
end

function M:getSTabInfoList()
  return self.llPokemonShopTabSTabInfo
end

function M:getClickTriggerCorrelationNode()
  return self.llPokemonShopTabInfo
end

function M:updateUnfold(isSelected)
  local img = "set:pokemon_shop.json image:img_0_triangle_optional"
  if isSelected then
    img = "set:pokemon_shop.json image:img_0_triangle_selected"
  end
  self.imgPokemonShopTabUnfold:SetImage(img)
end

function M:onShowRedDotIcon(isShow)
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_SHOP_BTN_RED, isShow)
  self.imgPokemonShopTabRedDotIcon:SetVisible(isShow)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
