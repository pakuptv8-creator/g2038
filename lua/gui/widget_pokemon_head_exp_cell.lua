local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local PokemonConfig = T(Config, "PokemonConfig")
local smoothTime = 20
local jumpLevelTime = 3

function M:init()
  widget_base.init(self, "pokemon_head_exp_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  function self.animationCancel()
  end
  
  self.sleepTick = 0
  self.levelsInfo = {}
  self._allEvent = {}
  self._root:SetHorizontalAlignment(0)
  self._root:SetVerticalAlignment(0)
  self.lytPokemonHeadCellHead = self:child("pokemon_head_exp_cell-Head")
  self.widget_item = UIMgr:new_widget("pokemon_packet_item_cell")
  self.widget_item:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytPokemonHeadCellHead:AddChildWindow(self.widget_item)
  self.txtPokemonHeadExpCellLv = self.widget_item:invoke("getLevelItem")
  self.txtPokemonHeadExpCellName = self:child("pokemon_head_exp_cell-name")
  self.txtPokemonHeadExpCellHp = self:child("pokemon_head_exp_cell-hp")
  self.txtPokemonHeadExpCellHpNum = self:child("pokemon_head_exp_cell-hp_num")
  self.txtPokemonHeadExpCellAddition = self:child("pokemon_head_exp_cell-addition")
  self.grdPokemonHeadExpCellHpProgressBar = self:child("pokemon_head_exp_cell-hp_progressBar")
  self.imgPokemonHeadExpCellDbuffIcon = self:child("pokemon_head_exp_cell-dbuff_icon")
  self.lytPokemonHeadExpCellEmpty = self:child("pokemon_head_exp_cell-Empty")
  self.imgPokemonHeadExpCellEmptyIcon = self:child("pokemon_head_exp_cell-Empty-Icon")
  self.imgPokemonHeadExpCellMask = self:child("pokemon_head_exp_cell-mask")
  self.imgPokemonHeadExpCellLvUp = self:child("pokemon_head_exp_cell-LvUp")
  self.imgPokemonHeadExpCellArray = self:child("pokemon_head_exp_cell-Array")
  self.txtProgress = self:child("pokemon_head_exp_cell-ProgressTxt")
  self.txtLevelMax = self:child("pokemon_head_exp_cell-LevelMax")
  self.txtLevelMax:SetText(Lang:toText("gui.level.max"))
end

function M:initEvent()
end

function M:onDestroy()
  self.animationCancel()
  if self._allEvent then
    for _, func in pairs(self._allEvent) do
      func()
    end
  end
  self._allEvent = {}
end

function M:getPokemon()
  return self.pokemon
end

function M:updateInfo(pokemon, addExp, petExpAddition)
  self.pokemon = pokemon
  if not pokemon then
    return
  end
  self.widget_item:invoke("onDataChanged", {pokemon = pokemon})
  self.txtPokemonHeadExpCellName:SetText(pokemon:getName())
  self.imgPokemonHeadExpCellDbuffIcon:SetImage(pokemon:getDebuffIcon())
  self.txtPokemonHeadExpCellHpNum:SetVisible(addExp ~= 0)
  self.txtPokemonHeadExpCellHpNum:SetText("+" .. tostring(addExp))
  self.imgPokemonHeadExpCellLvUp:SetVisible(false)
  if petExpAddition and 0 < petExpAddition then
    self.txtPokemonHeadExpCellAddition:SetVisible(true)
    local text = "(\226\134\145" .. petExpAddition .. "%)"
    self.txtPokemonHeadExpCellAddition:SetText(text)
  else
    self.txtPokemonHeadExpCellAddition:SetVisible(false)
  end
  self:startAnimation(pokemon, addExp)
  local levelMax = pokemon:getCurExp() == pokemon:getMaxExp()
  self.txtLevelMax:SetVisible(levelMax)
  self:startTick(levelMax)
end

function M:startAnimation(pokemon, addExp)
  self.showLv = pokemon:getLevel()
  self.showExp = pokemon:getCurExp()
  self.isTicking = false
  self:refreshExp()
  if self.tickDoneCallback then
    self.tickDoneCallback()
  end
end

function M:animationTick()
  if self.sleepTick > 0 then
    self.sleepTick = self.sleepTick - 1
    return false
  end
  local showMaxExp = PokemonConfig:getMaxExp(self.pokemon:getCfgId(), self.showLv)
  local addExp = math.ceil(showMaxExp / smoothTime)
  self.showExp = math.min(self.showExp + addExp, showMaxExp)
  if self.showExp == showMaxExp and self.showLv < self.pokemon:getLevel() then
    self.imgPokemonHeadExpCellLvUp:SetVisible(true)
    self.showLv = self.showLv + 1
    self.showExp = self.showLv < self.pokemon:getLevel() and self.pokemon:getMaxExp(self.showLv) or 0
    self.sleepTick = jumpLevelTime
  end
  return self.showExp >= self.pokemon:getCurExp() and self.showLv == self.pokemon:getLevel()
end

function M:refreshExp()
  local showMaxExp = self.pokemon:getMaxExp(self.showLv)
  self.grdPokemonHeadExpCellHpProgressBar:SetProgress(self.showExp / showMaxExp)
  self.txtProgress:SetText(self.showExp .. "/" .. showMaxExp)
  self.txtPokemonHeadExpCellLv:SetText("Lv." .. tostring(self.showLv))
end

function M:startTick(levelMax)
  if not levelMax then
    return
  end
  self.time = 0
  self._allEvent[#self._allEvent + 1] = World.Timer(1, function()
    self.time = self.time + 0.15
    local value = 0.5 + math.sin(self.time) * 0.5
    self.txtLevelMax:SetAlpha(value)
    return true
  end)
end

function M:subscribeTickDoneCallback(callback)
  self.tickDoneCallback = callback
end

function M:getIsTicking()
  return self.isTicking
end

function M:playLvUp()
  print("self.upLv:::::::::", self.upLv)
end

function M:onChecked(isChecked)
  self.imgPokemonHeadExpCellMask:SetVisible(isChecked)
  self.imgPokemonHeadExpCellArray:SetVisible(isChecked)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
