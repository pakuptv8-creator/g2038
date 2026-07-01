local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local PokemonConfig = T(Config, "PokemonConfig")
local RaceConfig = T(Config, "RaceConfig")

function M:init()
  widget_base.init(self, "pokemon_book_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBookItemCellIcon = self:child("pokemon_book_item_cell-Icon")
  self.imgPokemonBookItemCellIconBG = self:child("pokemon_book_item_cell-IconBG")
  self.imgPokemonBookItemCellStarLayout = self:child("pokemon_book_item_cell-Star-Layout")
  self.starBG = self:child("pokemon_book_item_cell-StarBG")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgPokemonBookItemCellStarLayout:AddChildWindow(self.itemStarLevel)
  self.imgPokemonBookItemCellRaceIcon = self:child("pokemon_book_item_cell-RaceIcon")
  self.imgPokemonBookItemCellSelected = self:child("pokemon_book_item_cell-Selected")
  self.txtPokemonBookItemCellName = self:child("pokemon_book_item_cell-Name")
  self.lytPokemonBookItemCellMask = self:child("pokemon_book_item_cell-Mask")
  self.curRedNode = UIRedDotMgr:createOneRedNodeSignal("", self:root(), 0, 0)
end

function M:onDataChanged(data)
  local pokemon_config = data.cfg
  self.txtPokemonBookItemCellName:SetText(Lang:toText(pokemon_config.name))
  self.imgPokemonBookItemCellIcon:SetImage(pokemon_config.icon)
  self.imgPokemonBookItemCellIconBG:SetImage(PokemonConfig:getQualityFrame(pokemon_config.id))
  self.imgPokemonBookItemCellRaceIcon:SetImage(RaceConfig:getClassifyIcon(pokemon_config.race))
  self.starBG:SetVisible(not data.dontCreateStar)
  local starLevel = data.starLevel and data.starLevel or pokemon_config.starLevel
  self.itemStarLevel:invoke("updateUI", data.dontCreateStar and 0 or starLevel, 0, 1)
  self.imgPokemonBookItemCellSelected:SetVisible(data.select)
  self.lytPokemonBookItemCellMask:SetVisible(data.lock)
  self.clickCallBack = data.clickCallBack
  if data.isPetBookWnd then
    if not self.redDotIcon then
      self.redDotIcon = true
      UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.PET_BOOK_ITEM_RED, nil, 0, 0, pokemon_config.id)
    end
    local isShowRed = UIRedDotMgr.petBookItemRedState[pokemon_config.id] == 2
    self.curRedNode:SetVisible(isShowRed)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.PET_BOOK_ITEM_RED, isShowRed, nil, nil, pokemon_config.id)
  end
end

function M:initEvent()
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    if self.clickCallBack then
      self.clickCallBack()
    end
  end)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
