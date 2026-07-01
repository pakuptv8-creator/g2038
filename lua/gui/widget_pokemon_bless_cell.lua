local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)
local icon_list = {
  [Define.POKEMON_ATTR_TYPE.Hp] = "set:pokemon_pet_attribute.json image:img_0_attribute_hp",
  [Define.POKEMON_ATTR_TYPE.Speed] = "set:pokemon_pet_attribute.json image:img_0_attribute_speed",
  [Define.POKEMON_ATTR_TYPE.PAtk] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicalattacks",
  [Define.POKEMON_ATTR_TYPE.PDef] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicaldefense",
  [Define.POKEMON_ATTR_TYPE.SAtk] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellattacks",
  [Define.POKEMON_ATTR_TYPE.SDef] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellprotection"
}

function M:init()
  widget_base.init(self, "pokemon_bless_cell.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgPokemonBlessCellIcon = self:child("pokemon_bless_cell-Icon")
  self.lytPokemonBlessCellAttrLayout = self:child("pokemon_bless_cell-Attr-Layout")
  self.txtPokemonBlessCellText1 = self:child("pokemon_bless_cell-Text1")
  self.txtPokemonBlessCellText2 = self:child("pokemon_bless_cell-Text2")
  self.txtPokemonBlessCellText3 = self:child("pokemon_bless_cell-Text3")
  self.txtPokemonBlessCellText4 = self:child("pokemon_bless_cell-Text4")
  self.btnPokemonBlessCellDelete = self:child("pokemon_bless_cell-Delete")
end

function M:initEvent()
  self:subscribe(self.btnPokemonBlessCellDelete, UIEvent.EventButtonClick, function()
    UI:openWnd("pokemonBlessRemove", self.cur_pokemon, self.attr_type)
  end)
end

function M:setPokemon(pokemon, attr_type)
  if self.cur_pokemon ~= pokemon then
    self.oldBlessValue = pokemon:getBlessValue(attr_type)
  end
  self.cur_pokemon = pokemon
  self.attr_type = attr_type
  local curBlessValue = pokemon:getBlessValue(attr_type)
  local blessTimes = pokemon:getBlessTimes(attr_type)
  self:onDataChanged({
    text1 = pokemon:getAttrByType(attr_type) - curBlessValue,
    text2 = "+" .. curBlessValue,
    text3 = curBlessValue > self.oldBlessValue and "+" .. curBlessValue - self.oldBlessValue or curBlessValue - self.oldBlessValue,
    text4 = blessTimes .. "/" .. pokemon:getBlessLimit(attr_type),
    icon = icon_list[attr_type],
    show_delete = 0 < blessTimes
  })
end

function M:onDataChanged(data)
  self.txtPokemonBlessCellText1:SetText(data.text1)
  self.txtPokemonBlessCellText2:SetText(data.text2)
  self.txtPokemonBlessCellText3:SetText(data.text3)
  self.txtPokemonBlessCellText4:SetText(data.text4)
  self.imgPokemonBlessCellIcon:SetImage(data.icon)
  self.btnPokemonBlessCellDelete:SetVisible(data.show_delete or false)
  if data.icon == "" then
    self.lytPokemonBlessCellAttrLayout:SetBackgroundColor({
      0,
      0,
      0,
      0
    })
    self.txtPokemonBlessCellText1:SetTextColor({
      0.7843137254901961,
      0.2627450980392157,
      0.03529411764705882,
      1
    })
    self.txtPokemonBlessCellText2:SetTextColor({
      0.7843137254901961,
      0.2627450980392157,
      0.03529411764705882,
      1
    })
    self.txtPokemonBlessCellText3:SetTextColor({
      0.7843137254901961,
      0.2627450980392157,
      0.03529411764705882,
      1
    })
    self.txtPokemonBlessCellText4:SetTextColor({
      0.7843137254901961,
      0.2627450980392157,
      0.03529411764705882,
      1
    })
  end
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

return M
