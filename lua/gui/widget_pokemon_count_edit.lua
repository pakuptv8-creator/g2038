local widget_base = require("ui.widget.widget_base")
local LuaTimer = T(Lib, "LuaTimer")
local M = Lib.derive(widget_base)
local longPressType = {Add = 1, Sub = 2}

function M:init()
  widget_base.init(self, "pokemon_count_edit.json")
  self:initNum(1)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonCountEditBg = self:child("pokemon_count_edit-bg")
  self.imgPokemonCountEditEditBg = self:child("pokemon_count_edit-edit_bg")
  self.editPokemonCountEditText = self:child("pokemon_count_edit-text")
  self.btnPokemonCountEditBtnMin = self:child("pokemon_count_edit-btn_min")
  self.btnPokemonCountEditBtnMax = self:child("pokemon_count_edit-btn_max")
  self.btnPokemonCountEditBtnSub = self:child("pokemon_count_edit-btn_sub")
  self.btnPokemonCountEditBtnAdd = self:child("pokemon_count_edit-btn_add")
  self.editPokemonCountEditText:getEditBoxImpl():setInputMode(2)
  self.editPokemonCountEditText:SetTextHorzAlign(1)
  self.editPokemonCountEditText:SetTextVertAlign(1)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnMin event : EventButtonClick", self.btnPokemonCountEditBtnMin, UIEvent.EventButtonClick, function()
    self:editInput(1)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnMax event : EventButtonClick", self.btnPokemonCountEditBtnMax, UIEvent.EventButtonClick, function()
    self:editInput(self.maximum)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnSub event : EventButtonClick", self.btnPokemonCountEditBtnSub, UIEvent.EventButtonClick, function()
    if self.num <= 1 then
      return
    end
    self:editInput(self.num - 1)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnAdd event : EventButtonClick", self.btnPokemonCountEditBtnAdd, UIEvent.EventButtonClick, function()
    if self.num >= self.maximum then
      return
    end
    self:editInput(self.num + 1)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit editPokemonCountEditText event : EventEditTextInput", self.editPokemonCountEditText, UIEvent.EventEditTextInput, function()
    self:editInput()
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnSub event : EventWindowLongTouchStart", self.btnPokemonCountEditBtnSub, UIEvent.EventWindowLongTouchStart, function()
    self:getCountByTrigger(longPressType.Sub)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnSub event : EventWindowLongTouchEnd", self.btnPokemonCountEditBtnSub, UIEvent.EventWindowLongTouchEnd, function()
    LuaTimer:cancel(self.showTimer)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnAdd event : EventWindowLongTouchStart", self.btnPokemonCountEditBtnAdd, UIEvent.EventWindowLongTouchStart, function()
    self:getCountByTrigger(longPressType.Add)
  end)
  self:lightSubscribe("error!!!!! script_client widget_pokemon_count_edit btnPokemonCountEditBtnAdd event : EventWindowLongTouchEnd", self.btnPokemonCountEditBtnAdd, UIEvent.EventWindowLongTouchEnd, function()
    LuaTimer:cancel(self.showTimer)
  end)
end

function M:setShowWnd(wnd, area)
  wnd:AddChildWindow(self._root)
  self._root:SetArea(area.x, area.y, area.w, area.h)
end

function M:setCallback(fun)
  self.fun = fun
  self:editInput(1)
end

function M:setMaximum(maximum)
  self.maximum = maximum
  if self.num > self.maximum and self.fun then
    self:editInput(self.maximum)
  end
end

function M:editInput(string)
  local str = string
  if not string then
    str = self.editPokemonCountEditText:GetPropertyString("Text", "")
  end
  local num = tonumber(str)
  if type(num) == "number" then
    num = math.floor(num)
    num = 1 < num and num or 1
    num = num > self.maximum and self.maximum or num
    self.num = num
    self.editPokemonCountEditText:SetText(num)
    self.fun(num)
    return num == string
  end
  self.fun(false)
  return false
end

function M:getCountByTrigger(triggerType)
  if self.showTimer then
    LuaTimer:cancel(self.showTimer)
  end
  local btnLongTriggerEfficiency = World.cfg.btnLongTriggerEfficiency
  local value = btnLongTriggerEfficiency.initialVelocity
  local i = 0
  self.showTimer = LuaTimer:scheduleTimer(function()
    for k, _value in pairs(btnLongTriggerEfficiency.variateNode or {}) do
      if _value == i then
        value = btnLongTriggerEfficiency.variate[k]
      end
    end
    self.num = triggerType == longPressType.Add and self.num + value or self.num - value
    if not self:editInput(self.num) or self.num == 1 then
      LuaTimer:cancel(self.showTimer)
    end
    i = i + 1
  end, btnLongTriggerEfficiency.frequency, -1)
end

function M:initNum(num)
  self.num = num
  self.maximum = num
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
