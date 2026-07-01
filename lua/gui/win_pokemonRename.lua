local max_char_num = 18

function M:init()
  WinBase.init(self, "PokemonRename.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytPokemonRenameContent = self:child("PokemonRename-Content")
  self.lytPokemonRenameTop = self:child("PokemonRename-Top")
  self.txtPokemonRenameTitle = self:child("PokemonRename-Title")
  self.btnPokemonRenameClose = self:child("PokemonRename-Close")
  self.btnPokemonRenameSure = self:child("PokemonRename-Sure")
  self.btnPokemonRenameCancel = self:child("PokemonRename-Cancel")
  self.lytPokemonRenameNameLayout = self:child("PokemonRename-Name-Layout")
  self.txtPokemonRenameCharNum = self:child("PokemonRename-Char-Num")
  self.txtPokemonRenameNameText = self:child("PokemonRename-Name-Text")
  self.editPokemonRenameNameInput = self:child("PokemonRename-Name-Input")
  self.txtPokemonRenameTip = self:child("PokemonRename-Tip")
  self.imgPokemonRenameTipIcon = self:child("PokemonRename-Tip-Icon")
  self:initLang()
end

function M:initLang()
  self.txtPokemonRenameTitle:SetText(Lang:toText("gui.title.rename"))
  self.btnPokemonRenameSure:SetText(Lang:toText("gui.btn.rename"))
  self.btnPokemonRenameCancel:SetText(Lang:toText("gui.btn.cancel"))
  self.txtPokemonRenameTip:SetText(Lang:toText("gui.tip.rename"))
end

function M:initEvent()
  self:subscribe(self.editPokemonRenameNameInput, UIEvent.EventEditTextInput, function()
    self:onNameChange()
  end)
  self:subscribe(self.btnPokemonRenameClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRenameSure, UIEvent.EventButtonClick, function()
    if #self.curName > max_char_num then
      Me:showChatShopDialog({
        titleText = "gui.tip.title",
        msgText = "gui.rename.too.long"
      })
      return
    end
    Me:sendPacket({
      pid = "pokemonRename",
      objId = self.cur_pokemon:getObjId(),
      newName = self.curName
    })
    self:onHide()
  end)
  self:subscribe(self.btnPokemonRenameCancel, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:onHide()
  UI:closeWnd("pokemonRename")
end

function M:onShow(pokemon)
  if not pokemon then
    return
  end
  self.cur_pokemon = pokemon
  self.editPokemonRenameNameInput:SetText(pokemon:getName(true))
  self:onNameChange()
  UI:openWnd("pokemonRename")
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function M:onNameChange()
  self.curName = self.editPokemonRenameNameInput:GetText()
  self.txtPokemonRenameNameText:SetText(self.curName)
  self.txtPokemonRenameCharNum:SetText(#self.curName .. "/" .. max_char_num)
end

return M
