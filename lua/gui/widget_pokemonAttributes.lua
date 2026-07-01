local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "pokemonAttributes.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgAttributesLayout = self:child("AttributesLayout")
  self.txtHPName = self:child("HPName")
  self.txtHPAdd = self:child("HPAdd")
  self.txtCurHP = self:child("CurHP")
  self.txtSpeedName = self:child("SpeedName")
  self.txtSpeedAdd = self:child("SpeedAdd")
  self.txtCurSpeed = self:child("CurSpeed")
  self.txtPAtkName = self:child("PAtkName")
  self.txtPAtkAdd = self:child("PAtkAdd")
  self.txtCurPAtk = self:child("CurPAtk")
  self.txtPDefName = self:child("PDefName")
  self.txtPDefAdd = self:child("PDefAdd")
  self.txtCurPDef = self:child("CurPDef")
  self.txtMAtkName = self:child("MAtkName")
  self.txtMAtkAdd = self:child("MAtkAdd")
  self.txtCurMAtk = self:child("CurMAtk")
  self.txtMDefName = self:child("MDefName")
  self.txtMDefAdd = self:child("MDefAdd")
  self.txtCurMDef = self:child("CurMDef")
  self.txtHPName:SetText(Lang:toText("gui.text.growth.hp"))
  self.txtSpeedName:SetText(Lang:toText("gui.text.growth.speed"))
  self.txtPAtkName:SetText(Lang:toText("gui.text.growth.pAtk"))
  self.txtPDefName:SetText(Lang:toText("gui.text.growth.pDef"))
  self.txtMAtkName:SetText(Lang:toText("gui.text.growth.sAtk"))
  self.txtMDefName:SetText(Lang:toText("gui.text.growth.sDef"))
end

function M:updateBaseAttributes(pokemon, copy_pokemon)
  self.txtCurHP:SetText(tostring(math.floor(pokemon:getMaxHp())))
  self.txtCurSpeed:SetText(tostring(math.floor(pokemon:getSpeed())))
  self.txtCurPAtk:SetText(tostring(math.floor(pokemon:getPhysicalAtk())))
  self.txtCurPDef:SetText(tostring(math.floor(pokemon:getPhysicalDef())))
  self.txtCurMAtk:SetText(tostring(math.floor(pokemon:getSpecialAtk())))
  self.txtCurMDef:SetText(tostring(math.floor(pokemon:getSpecialDef())))
  self.txtHPAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getMaxHp() - pokemon:getMaxHp())))
  self.txtSpeedAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getSpeed() - pokemon:getSpeed())))
  self.txtPAtkAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getPhysicalAtk() - pokemon:getPhysicalAtk())))
  self.txtPDefAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getPhysicalDef() - pokemon:getPhysicalDef())))
  self.txtMAtkAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getSpecialAtk() - pokemon:getSpecialAtk())))
  self.txtMDefAdd:SetText("+" .. tostring(math.floor(copy_pokemon:getSpecialDef() - pokemon:getSpecialDef())))
end

function M:updateUIByType(pokemon, up_key, up_value)
  if not pokemon then
    return
  end
  local copy_pokemon = Me:copyPokemon(pokemon)
  copy_pokemon:setValue(up_key, copy_pokemon:getValue(up_key) + (up_value or 1))
  self:updateBaseAttributes(pokemon, copy_pokemon)
end

function M:initEvent()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
