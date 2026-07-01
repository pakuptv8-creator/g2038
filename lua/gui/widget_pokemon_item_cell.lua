local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local setting = require("common.setting")

function M:init()
  widget_base.init(self, "pokemon_item_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.data = {}
  self.imgPokemonItemCellFrameIcon = self:child("pokemon_item_cell-frame_icon")
  self.imgPokemonItemCellIcon = self:child("pokemon_item_cell-icon")
  self.txtPokemonItemCellNum = self:child("pokemon_item_cell-num")
  self.imgPokemonItemCellSelect = self:child("pokemon_item_cell-select")
  self.imgPokemonItemCellEmpty = self:child("pokemon_item_cell-Empty")
  self.lytPokemonItemCellEffect = self:child("pokemon_item_cell-effect")
  self.lytPokemonItemCellEffect:SetVisible(false)
  self.imgPokemonItemCellFinish = self:child("pokemon_item_cell-finish")
  self.imgPokemonItemCellCheck = self:child("pokemon_item_cell-check")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemon_item_cell _root event : EventWindowClick", self._root, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.clickCallBack then
      self.clickCallBack(window, dx, dy)
      return
    end
  end)
end

function M:onChecked(isChecked)
  self.imgPokemonItemCellSelect:SetVisible(isChecked)
end

function M:onFinished(status)
  Lib.logDebug("pokemon_item_cell onFinished = ", status)
  if status == true then
    self.imgPokemonItemCellFinish:SetVisible(true)
    self.imgPokemonItemCellCheck:SetVisible(true)
  else
    self.imgPokemonItemCellFinish:SetVisible(false)
    self.imgPokemonItemCellCheck:SetVisible(false)
  end
end

function M:isChecked()
  return self.imgPokemonItemCellSelect:IsVisible()
end

function M:showEffect(show)
  self.lytPokemonItemCellEffect:SetVisible(show)
end

function M:initViewDataWithoutCoinAdapter(coinId, cnt)
  self.imgPokemonItemCellFrameIcon:SetImage("set:pokemon_bag.json image:chb_0_box")
  if cnt < 1000 then
    self.txtPokemonItemCellNum:SetText(cnt or "")
  else
    local displayNum = string.format("%.1f", cnt / 1000)
    self.txtPokemonItemCellNum:SetText(displayNum .. "K")
  end
  self.imgPokemonItemCellIcon:SetImage(Coin:iconByCoinName(coinId))
end

function M:initViewDataWithoutAdapter(full_name, cnt, clickCallBack, select)
  self.imgPokemonItemCellFrameIcon:SetImage("set:pokemon_bag.json image:chb_0_box")
  self.txtPokemonItemCellNum:SetText(cnt or "")
  self.imgPokemonItemCellIcon:SetImage("")
  self.full_name = full_name
  self.clickCallBack = clickCallBack
  if full_name then
    if full_name == "add" then
      self.imgPokemonItemCellFrameIcon:SetImage("set:pokemon_bag.json image:chb_0_+")
      return
    end
    local cfg = setting:fetch("item", full_name)
    if cfg then
      self.imgPokemonItemCellFrameIcon:SetImage(string.format("set:pokemon_bag.json image:chb_0_quality_%d", cfg.rarity))
      self.imgPokemonItemCellIcon:SetImage(cfg.icon)
    end
  end
  if select ~= nil then
    self:onChecked(select)
  end
end

function M:setType()
  self.txtPokemonItemCellNum:SetArea({1, 0}, {0, 0}, {1, 0}, {1, 0})
  self.txtPokemonItemCellNum:SetHorizontalAlignment(0)
  self.txtPokemonItemCellNum:SetVerticalAlignment(1)
  self.txtPokemonItemCellNum:SetTextHorzAlign(1)
  self.txtPokemonItemCellNum:SetTextVertAlign(1)
  if self.full_name == "add" then
    self.imgPokemonItemCellFrameIcon:SetImage("set:pokemon_blessing.json image:btn_0_add")
    return
  end
end

function M:onDataChanged(data)
  if "table" == type(data.item) then
    if not data.item._cfg then
      self:initViewDataWithoutAdapter(nil, nil, data.clickCallBack, data.select)
      return
    end
    self:initViewDataWithoutAdapter(data.item._cfg.fullName, data.item:stack_count(), data.clickCallBack, data.select)
    return
  end
  self:initViewDataWithoutAdapter(data.item, nil, data.clickCallBack, data.select)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
