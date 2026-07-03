function M:init()
  WinBase.init(self, "PokemonCommonDialog.json", false)
  
  self:initData()
  self:initWnd()
  self:initEvent()
end

function M:initData()
  self.title = ""
  self.content = ""
  self.callback = nil
  self.mode = 1
end

function M:initWnd()
  self.btnClose = self:child("PokemonCommonDialog-BtnClose")
  self.btnCancel = self:child("PokemonCommonDialog-BtnCancel")
  self.btnConfirm = self:child("PokemonCommonDialog-BtnConfirm")
  self.stText = self:child("PokemonCommonDialog-Text")
  self.stTitle = self:child("PokemonCommonDialog-Title")
end

function M:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    if self.callback then
      self.callback(false)
    end
    self:onHide()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    if self.callback then
      self.callback(false)
    end
    self:onHide()
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if self.callback then
      self.callback(true)
    end
    self:onHide()
  end)
end

function M:onShow(title, content, callback, mode, alignment)
  self.title = title
  self.content = content
  self.callback = callback
  self.alignment = alignment or 1
  self.mode = mode or Define.COMMON_DIALOG_MODE.TWOBUTTON
  UI:openWnd("pokemonCommonDialog")
end

function M:onHide()
  UI:closeWnd("pokemonCommonDialog")
end

function M:onOpen()
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(2)
  self.stTitle:SetText(Lang:toText(self.title or ""))
  self.stText:SetText(Lang:toText(self.content or ""))
  if self.alignment == 1 then
    self.stText:SetTextHorzAlign(1)
    self.stText:SetTextVertAlign(1)
  elseif self.alignment == 0 then
    self.stText:SetTextHorzAlign(0)
    self.stText:SetTextVertAlign(1)
  elseif self.alignment == 2 then
    self.stText:SetTextHorzAlign(2)
    self.stText:SetTextVertAlign(1)
  end
  if self.mode == Define.COMMON_DIALOG_MODE.NOBUTTON then
    self.btnCancel:SetVisible(false)
    self.btnConfirm:SetVisible(false)
  elseif self.mode == Define.COMMON_DIALOG_MODE.TWOBUTTON then
    self.btnCancel:SetVisible(true)
    self.btnConfirm:SetVisible(true)
  end

  if self.callback and (Me:isInBattle() or UI:isOpen("battle_results")) then
    World.Timer(1, function()
      if self.callback then
        self.callback(true)
        self:onHide()
      end
    end)
  end
end

function M:onClose()
  self.title = ""
  self.content = ""
  self.callback = nil
end

return M
