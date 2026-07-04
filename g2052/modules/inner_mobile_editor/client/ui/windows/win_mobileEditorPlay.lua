local WinMobileEditorPlay = M

function WinMobileEditorPlay:init()
  WinBase.init(self, "MobileEditorPlay.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorPlay:initUI()
  self.btnEditBtn = self:child("MobileEditorPlay-editBtn")
  self.txtEditBtnTxt = self:child("MobileEditorPlay-editBtnTxt")
  self.txtEditBtnTxt:SetText(Lang:toText("g2052.gui.tendering.editor_tips"))
end

function WinMobileEditorPlay:initEvent()
  self:subscribe(self.btnEditBtn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_PLAY_BACK_EDIT_MODE)
    Lib.emitEvent(Event.EVENT_ENTER_EDIT_MODE)
    UI:closeWnd(self)
  end)
end

function WinMobileEditorPlay:subscribeEvent()
end

function WinMobileEditorPlay:initView()
end

function WinMobileEditorPlay:onHide()
  UI:closeWnd("mobileEditorPlay")
end

function WinMobileEditorPlay:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorPlay")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorPlay:onOpen(modeData)
  self:initView()
  self:subscribeEvent()
end

function WinMobileEditorPlay:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinMobileEditorPlay
