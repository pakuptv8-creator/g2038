local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemon_swap_cell.json")
  self:initUI()
  self:initEvent()
  self:subscribeEvent()
end

function M:initUI()
  self.lytPokemonSwapCellBg = self:child("pokemon_swap_cell-Bg")
  self.txtPokemonSwapCellLevel = self:child("pokemon_swap_cell-Level")
  self.imgPokemonSwapCellIcon = self:child("pokemon_swap_cell-Icon")
  self.widget_item = UIMgr:new_widget("pokemon_packet_item_cell")
  self.widget_lua_item = self.widget_item:invoke("getLuaCell")
  self.widget_item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.widget_lua_item.txtPokemonPacketItemCellLevelBg:SetVisible(false)
  self.imgPokemonSwapCellIcon:AddChildWindow(self.widget_item)
  self.lytPokemonSwapCellStarLayout = self:child("pokemon_swap_cell-Star-Layout")
  self.imgPokemonSwapCellStarImg = self:child("pokemon_swap_cell-Star-Img")
  self.lytPokemonSwapCellAttrLayout = self:child("pokemon_swap_cell-Attr-Layout")
  self.txtPokemonSwapCellHpText = self:child("pokemon_swap_cell-Hp-Text")
  self.txtPokemonSwapCellPAtkText = self:child("pokemon_swap_cell-PAtk-Text")
  self.txtPokemonSwapCellPDefText = self:child("pokemon_swap_cell-PDef-Text")
  self.txtPokemonSwapCellSpeedText = self:child("pokemon_swap_cell-Speed-Text")
  self.txtPokemonSwapCellSAtkText = self:child("pokemon_swap_cell-SAtk-Text")
  self.txtPokemonSwapCellSDefText = self:child("pokemon_swap_cell-SDef-Text")
  self.txtPokemonSwapCellScore = self:child("pokemon_swap_cell-Score")
  self.txtPokemonSwapCellScoreNum = self:child("pokemon_swap_cell-Score-Num")
  self.txtPokemonSwapCellName = self:child("pokemon_swap_cell-Name")
end

function M:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.clickCallBack then
      self.clickCallBack(self.cur_pokemon)
    end
  end)
end

function M:subscribeEvent()
  self._allEvent = {}
end

function M:initCell(targetId, clickCallBack)
  self.targetId = targetId
  self.clickCallBack = clickCallBack
end

function M:setLock(isLock)
  if isLock then
    self.lytPokemonSwapCellBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe2")
    self.lytPokemonSwapCellAttrLayout:SetBackImage("set:pokemon_swap.json image:img_9_bottom_data2")
  else
    self.lytPokemonSwapCellBg:SetBackImage("set:pokemon_swap.json image:img_9_displayframe")
    self.lytPokemonSwapCellAttrLayout:SetBackImage("set:pokemon_swap.json image:img_9_bottom_data")
  end
end

function M:setPokemon(pokemon)
  self.cur_pokemon = pokemon
  self.lytPokemonSwapCellBg:SetVisible(pokemon ~= nil)
  if not pokemon then
    return
  end
  self.lytPokemonSwapCellStarLayout:SetWidth({
    0,
    21.6 * pokemon:getStarLevel()
  })
  self.imgPokemonSwapCellStarImg:SetImage("set:g2038_pokemon_star.json image:img_0_bigrareness" .. pokemon:getStarLevel())
  self.imgPokemonSwapCellIcon:SetImage(pokemon:getIcon())
  self.widget_lua_item:updateInfo(pokemon)
  self.txtPokemonSwapCellName:SetText(pokemon:getName())
  self.txtPokemonSwapCellLevel:SetText("Lv." .. pokemon:getLevel())
  self.txtPokemonSwapCellHpText:SetText(pokemon:getMaxHp())
  self.txtPokemonSwapCellSpeedText:SetText(pokemon:getSpeed())
  self.txtPokemonSwapCellPAtkText:SetText(pokemon:getPhysicalAtk())
  self.txtPokemonSwapCellPDefText:SetText(pokemon:getPhysicalDef())
  self.txtPokemonSwapCellSAtkText:SetText(pokemon:getSpecialAtk())
  self.txtPokemonSwapCellSDefText:SetText(pokemon:getSpecialDef())
  self.txtPokemonSwapCellScoreNum:SetText(pokemon:getFightPower())
end

function M:getPokemon()
  return self.cur_pokemon
end

function M:onDestroy()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
