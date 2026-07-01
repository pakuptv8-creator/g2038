local RaceConfig = T(Config, "RaceConfig")
local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "PokemonOthersItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonOthersItemBg = self:child("PokemonOthersItem-HeadImgBg")
  self.imgPokemonOthersItemIcon = self:child("PokemonOthersItem-HeadImg")
  self.imgPokemonOthersItemFrame = self:child("PokemonOthersItem-HeadFrame")
  self.txtPokemonOthersItemLevelTxt = self:child("PokemonOthersItem-level-txt")
end

function M:initEvent()
end

function M:onDataChanged(data)
  self.imgPokemonOthersItemIcon:SetImage(data.icon)
  local color = RaceConfig:getColorBg(data.race)
  self.imgPokemonOthersItemBg:SetDrawColor({
    tonumber(color[1]) / 255,
    tonumber(color[2]) / 255,
    tonumber(color[3]) / 255,
    1
  })
  self.txtPokemonOthersItemLevelTxt:SetText("Lv." .. data.level)
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
