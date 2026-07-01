local widget_base = require("ui.widget.widget_base")
local WidgetPokemonRotaryRatioItem = Lib.derive(widget_base)

function WidgetPokemonRotaryRatioItem:init()
  widget_base.init(self, "PokemonRotaryRatioItem.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonRotaryRatioItem:initUI()
  self.lytPanel = self:child("PokemonRotaryRatioItem-Panel")
  self.txtDescTxt = self:child("PokemonRotaryRatioItem-descTxt")
end

function WidgetPokemonRotaryRatioItem:initEvent()
end

function WidgetPokemonRotaryRatioItem:updateItemInfo(ratioNum)
  self.txtDescTxt:SetText("x" .. ratioNum)
end

function WidgetPokemonRotaryRatioItem:updateItemBorderColor(ratioBorderColor)
  self.txtDescTxt:SetProperty("TextBorderColor", ratioBorderColor)
end

function WidgetPokemonRotaryRatioItem:onInvoke(key, ...)
  local fn = WidgetPokemonRotaryRatioItem[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonRotaryRatioItem
