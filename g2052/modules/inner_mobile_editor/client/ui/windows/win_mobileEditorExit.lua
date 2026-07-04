local WinMobileEditorExit = M
local EditorCommonUI = T(Lib, "EditorCommonUI")

function WinMobileEditorExit:init()
  WinBase.init(self, "MobileEditorExit.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorExit:initUI()
  self.imgBg = self:child("MobileEditorExit-bg")
  self.btnCloseBtn = self:child("MobileEditorExit-closeBtn")
  self.txtContentText = self:child("MobileEditorExit-contentText")
  self.btnCancelBtn = self:child("MobileEditorExit-cancelBtn")
  self.txtCancelBtnText = self:child("MobileEditorExit-cancelBtnText")
  self.btnSaveBtn = self:child("MobileEditorExit-saveBtn")
  self.txtSaveBtnText = self:child("MobileEditorExit-saveBtnText")
  self.imgUploading = self:child("MobileEditorExit-uploadingImg")
  self.txtSaveBtnText:SetText(Lang:toText("ui.setting.save"))
  self.txtCancelBtnText:SetText(Lang:toText("ui.setting.not.save"))
  self.txtContentText:SetText(Lang:toText("ui.setting.exit_tips"))
end

function WinMobileEditorExit:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnCancelBtn, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("inner_mobile_editor", "leaveEditorMode")
    Lib.emitEvent(Event.EVENT_UPDATE_EDIT_PLAY_SHOW, false)
    Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true, 40)
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnSaveBtn, UIEvent.EventButtonClick, function()
    if self.uploading then
      return
    end
    self.uploading = true
    self.imgUploading:SetVisible(true)
    self.txtSaveBtnText:SetVisible(false)
    if self.loadingAnimTimer then
      self.loadingAnimTimer()
    end
    self.loadingAnimTimer = EditorCommonUI:playLoadingAnim(self.imgUploading)
    Lib.emitEvent(Event.EVENT_UPLOAD_MAP_DATA, true)
    Lib.emitEvent(Event.EVENT_UPDATE_EDIT_PLAY_SHOW, false)
    Lib.emitEvent(Event.EVENT_EDITOR_SET_CLICK_MASK, true, 40)
  end)
end

function WinMobileEditorExit:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPLOAD_MAP_DATA_FINISH, function(updateType, isSuccess)
    self.imgUploading:SetVisible(false)
    self.txtSaveBtnText:SetVisible(true)
    self.uploading = false
    UI:closeWnd(self)
    Plugins.CallTargetPluginFunc("inner_mobile_editor", "leaveEditorMode")
  end)
end

function WinMobileEditorExit:initView()
  self.uploading = false
end

function WinMobileEditorExit:onHide()
  UI:closeWnd("mobileEditorExit")
end

function WinMobileEditorExit:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorExit")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorExit:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinMobileEditorExit:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.loadingAnimTimer then
    self.loadingAnimTimer()
    self.loadingAnimTimer = nil
  end
end

return WinMobileEditorExit
