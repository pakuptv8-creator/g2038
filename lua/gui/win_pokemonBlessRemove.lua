local BlessItemConfig = T(Config, "BlessItemConfig")
local icon_list = {
  [Define.POKEMON_ATTR_TYPE.Hp] = "set:pokemon_pet_attribute.json image:img_0_attribute_hp",
  [Define.POKEMON_ATTR_TYPE.Speed] = "set:pokemon_pet_attribute.json image:img_0_attribute_speed",
  [Define.POKEMON_ATTR_TYPE.PAtk] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicalattacks",
  [Define.POKEMON_ATTR_TYPE.PDef] = "set:pokemon_pet_attribute.json image:img_0_attribute_physicaldefense",
  [Define.POKEMON_ATTR_TYPE.SAtk] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellattacks",
  [Define.POKEMON_ATTR_TYPE.SDef] = "set:pokemon_pet_attribute.json image:img_0_attribute_spellprotection"
}
local lang_list = {
  [Define.POKEMON_ATTR_TYPE.Hp] = "gui.text.hp",
  [Define.POKEMON_ATTR_TYPE.Speed] = "gui.text.speed",
  [Define.POKEMON_ATTR_TYPE.PAtk] = "gui.text.pAtk",
  [Define.POKEMON_ATTR_TYPE.PDef] = "gui.text.pDef",
  [Define.POKEMON_ATTR_TYPE.SAtk] = "gui.text.sAtk",
  [Define.POKEMON_ATTR_TYPE.SDef] = "gui.text.sDef"
}

function M:init()
  WinBase.init(self, "PokemonBlessRemove.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonBlessRemoveContent = self:child("PokemonBlessRemove-Content")
  self.lytPokemonBlessRemoveTop = self:child("PokemonBlessRemove-Top")
  self.txtPokemonBlessRemoveTitle = self:child("PokemonBlessRemove-Title")
  self.btnPokemonBlessRemoveClose = self:child("PokemonBlessRemove-Close")
  self.lytPokemonBlessRemoveMain = self:child("PokemonBlessRemove-Main")
  self.btnPokemonBlessRemoveRemove = self:child("PokemonBlessRemove-Remove")
  self.imgPokemonBlessRemoveAttrIcon = self:child("PokemonBlessRemove-Attr-Icon")
  self.txtPokemonBlessRemoveAttrText = self:child("PokemonBlessRemove-Attr-Text")
  self.txtPokemonBlessRemoveAttrLimit = self:child("PokemonBlessRemove-Attr-Limit")
  self.lytPokemonBlessRemoveRemoveList = self:child("PokemonBlessRemove-RemoveList")
  self.txtPokemonBlessRemoveTitle:SetText(Lang:toText("gui.bless.remove.title"))
  self.btnPokemonBlessRemoveRemove:SetText(Lang:toText("gui.bless.btn.remove"))
  self.removeItems = {}
  local itemWidth = self.lytPokemonBlessRemoveRemoveList:GetPixelSize().x
  local height = self.lytPokemonBlessRemoveRemoveList:GetPixelSize().y
  local itemHeight = (height - 40) / 3
  local positionY = 0
  for index = 1, 3 do
    local item = UIMgr:new_widget("pokemon_bless_remove_cell")
    item:SetArea({0, 0}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    item:SetVerticalAlignment(0)
    self.lytPokemonBlessRemoveRemoveList:AddChildWindow(item)
    self.removeItems[index] = item
    positionY = positionY + itemHeight + 20
  end
end

function M:initEvent()
  self:subscribe(self.btnPokemonBlessRemoveClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPokemonBlessRemoveRemove, UIEvent.EventButtonClick, function()
    self:sendBlessRemove()
  end)
end

function M:initView(pokemon, attr_type)
  self.cur_pokemon = pokemon
  local bless_table = pokemon:getBlessByType(attr_type)
  self.txtPokemonBlessRemoveAttrLimit:SetText(pokemon:getBlessTimes(attr_type) .. "/" .. pokemon:getBlessLimit(attr_type))
  self.imgPokemonBlessRemoveAttrIcon:SetImage(icon_list[attr_type])
  local showText = Lang:toText(lang_list[attr_type])
  self.txtPokemonBlessRemoveAttrText:SetText(showText)
  local textLen = self.txtPokemonBlessRemoveAttrText:GetFont():GetTextExtent(showText, 1.0)
  self.txtPokemonBlessRemoveAttrText:SetWidth({0, textLen})
  local showItems = BlessItemConfig:getConfigListByType(attr_type)
  table.sort(showItems, function(a, b)
    return a.bless_level > b.bless_level
  end)
  for index, itemData in pairs(showItems) do
    self.removeItems[index]:invoke("setData", itemData.fullName, bless_table[tostring(itemData.bless_level)], itemData.bless_level)
  end
end

function M:sendBlessRemove()
  local removeList = {}
  for _, item in pairs(self.removeItems) do
    local removeTable = item:invoke("getData")
    if removeTable.removeNum > 0 then
      table.insert(removeList, removeTable)
    end
  end
  Me:sendPacket({
    pid = "pokemonBlessRemove",
    objId = self.cur_pokemon:getObjId(),
    removeList = removeList
  }, function(result)
    if result.success then
      self:onHide()
    end
  end)
end

function M:onHide()
  UI:closeWnd("pokemonBlessRemove")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonBlessRemove")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(pokemon, attr_type)
  self._allEvent = {}
  self:initView(pokemon, attr_type)
end

function M:onClose()
end

return M
