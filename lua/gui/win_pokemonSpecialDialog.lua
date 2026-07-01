local popupAgain = {}

function M:init()
  WinBase.init(self, "PokemonSpecialDialog.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytContent = self:child("PokemonSpecialDialog-Content")
  self.btnBtnClose = self:child("PokemonSpecialDialog-BtnClose")
  self.txtTitle = self:child("PokemonSpecialDialog-Title")
  self.txtText = self:child("PokemonSpecialDialog-Text")
  self.btnBtnCancel = self:child("PokemonSpecialDialog-BtnCancel")
  self.btnBtnConfirm = self:child("PokemonSpecialDialog-BtnConfirm")
  self.lytDontPopupAgainLyt = self:child("PokemonSpecialDialog-DontPopupAgainLyt")
  self.chkCheckBox = self:child("PokemonSpecialDialog-checkBox")
  self.imgCheckYes = self:child("PokemonSpecialDialog-checkYes")
  self.txtDontPopTxt = self:child("PokemonSpecialDialog-dontPopTxt")
end

function M:initEvent()
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnBtnCancel, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnBtnConfirm, UIEvent.EventButtonClick, function()
    if self.callback then
      self.callback(true)
    end
    popupAgain[self.popupKey] = not self.chkCheckBox:GetChecked()
    self:onHide()
  end)
  self:subscribe(self.chkCheckBox, UIEvent.EventCheckStateChanged, function()
    self.imgCheckYes:SetVisible(self.chkCheckBox:GetChecked())
  end)
end

function M:subscribeEvent()
end

function M:initView()
  self.txtTitle:SetText(Lang:toText(self.titleText))
  self.txtText:SetText(Lang:toText(self.msgText))
  self.txtDontPopTxt:SetText(Lang:toText("gui.dont.popup"))
  self.chkCheckBox:SetChecked(false)
end

function M:onHide()
  UI:closeWnd("pokemonSpecialDialog")
end

function M:onShow(titleText, msgText, popupKey, callback)
  self.titleText = titleText or ""
  self.msgText = msgText or ""
  self.callback = callback
  self.popupKey = popupKey
  if self.popupKey == nil then
    Lib.logDebug("pokemonSpecialDialog \230\178\161\230\156\137\232\174\190\231\189\174\231\177\187\229\158\139", "popupKey:" .. popupKey)
    return
  end
  UI:openWnd("pokemonSpecialDialog")
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  if popupAgain[self.popupKey] ~= nil and popupAgain[self.popupKey] == false then
    if self.callback then
      self.callback(true)
    end
    UI:closeWnd(self)
    return
  end
  popupAgain[self.popupKey] = true
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
