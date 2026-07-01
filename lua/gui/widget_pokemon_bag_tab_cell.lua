local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local tabImg = {
  [Define.BAG_TYPE.BALL] = "set:pokemon_bag.json image:img_0_fairyball",
  [Define.BAG_TYPE.CURE] = "set:pokemon_bag.json image:img_0_reply",
  [Define.BAG_TYPE.OTHER] = "set:pokemon_bag.json image:img_0_special",
  [Define.BAG_TYPE.SKILL] = "set:pokemon_bag.json image:img_0_skill"
}

function M:init()
  widget_base.init(self, "pokemon_bag_tab_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBagTabCellIcon = self:child("pokemon_bag_tab_cell-icon")
end

function M:initEvent()
end

function M:onChecked(isChecked)
  local notCheckedImg = "set:pokemon_bag.json image:tab-9-Unselect"
  local checkedImg = "set:pokemon_bag.json image:tab-9-Select"
  self._root:SetImage(isChecked and checkedImg or notCheckedImg)
end

function M:updateInfo(tabType)
  self.imgPokemonBagTabCellIcon:SetImage(tabImg[tabType])
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
