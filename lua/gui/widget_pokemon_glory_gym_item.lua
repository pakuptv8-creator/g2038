local widget_base = require("ui.widget.widget_base")
local WidgetPokemonGloryGymItem = Lib.derive(widget_base)

function WidgetPokemonGloryGymItem:init()
  widget_base.init(self, "pokemon_glory_gym_item.json")
  self:initUI()
  self:initEvent()
end

function WidgetPokemonGloryGymItem:initUI()
  self.imgPokemonGloryGymItemIcon = self:child("pokemon_glory_gym_item-icon")
end

function WidgetPokemonGloryGymItem:initEvent()
end

function WidgetPokemonGloryGymItem:updateInfo(gymIcon)
  self.imgPokemonGloryGymItemIcon:SetImage(gymIcon)
end

function WidgetPokemonGloryGymItem:onInvoke(key, ...)
  local fn = WidgetPokemonGloryGymItem[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return WidgetPokemonGloryGymItem
