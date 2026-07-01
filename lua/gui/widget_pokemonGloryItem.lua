local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "PokemonGloryItem.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonGloryItemBg = self:child("PokemonGloryItem-Bg")
  self.imgPokemonGloryItemIcon = self:child("PokemonGloryItem-Icon")
  self.imgPokemonGloryItemRedMask = self:child("PokemonGloryItem-RedMask")
  self.imgPokemonGloryItemGrayMask = self:child("PokemonGloryItem-GrayMask")
  self.imgPokemonGloryItemTic = self:child("PokemonGloryItem-Tic")
  self.imgPokemonGloryItemSel = self:child("PokemonGloryItem-Sel")
  self.ltyPokemonGloryItemEffect = self:child("PokemonGloryItem-Effect")
end

function M:initEvent()
  self:subscribe(self.imgPokemonGloryItemBg, UIEvent.EventWindowClick, function()
    UI:getWnd("pokemonGloryDialog"):onShow(self.info)
  end)
end

function M:onDataChanged(data)
  self.info = {
    id = data.id,
    name = data.name,
    title = data.title,
    info = data.info,
    rare = data.rare,
    icon = data.icon,
    effect = data.effect
  }
  local gloryStatus = Me:getGloryStatus(data.id)
  self.imgPokemonGloryItemRedMask:SetVisible(gloryStatus == Define.GLORY_STATUS.LOST)
  self.imgPokemonGloryItemGrayMask:SetVisible(gloryStatus == Define.GLORY_STATUS.INIT)
  self.imgPokemonGloryItemTic:SetVisible(gloryStatus == Define.GLORY_STATUS.LOST)
  self.ltyPokemonGloryItemEffect:SetVisible(gloryStatus == Define.GLORY_STATUS.GAIN)
  self.imgPokemonGloryItemSel:SetVisible(data.id == Me:getCurSelGlory())
  self.imgPokemonGloryItemIcon:SetImage(data.icon)
  if data.effect ~= "" then
    self.ltyPokemonGloryItemEffect:SetEffectName(data.effect)
    self.ltyPokemonGloryItemEffect:PlayEffect()
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
