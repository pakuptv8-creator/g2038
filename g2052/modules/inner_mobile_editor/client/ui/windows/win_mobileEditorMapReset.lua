local WinMobileEditorMapReset = M
local EditorCommonUI = T(Lib, "EditorCommonUI")
local util = require("common.util.util")

function WinMobileEditorMapReset:init()
  WinBase.init(self, "MobileEditorMapReset.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorMapReset:initUI()
  self.imgBg = self:child("MobileEditorMapReset-bg")
  self.btnCloseBtn = self:child("MobileEditorMapReset-closeBtn")
  self.txtContentText = self:child("MobileEditorMapReset-contentText")
  self.btnTemplateBtn = self:child("MobileEditorMapReset-templateBtn")
  self.txtTemplateBtnText = self:child("MobileEditorMapReset-templateBtnText")
  self.btnRemoteBtn = self:child("MobileEditorMapReset-remoteBtn")
  self.txtRemoteBtnText = self:child("MobileEditorMapReset-remoteBtnText")
  self.imgDownloadingImg = self:child("MobileEditorMapReset-downloadingImg")
  self.txtContentText:SetText(Lang:toText("ui.setting.map_reset_tips"))
  self.txtTemplateBtnText:SetText(Lang:toText("ui.setting.map_reset_template"))
  self.txtRemoteBtnText:SetText(Lang:toText("ui.setting.map_reset_remote"))
end

function WinMobileEditorMapReset:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnTemplateBtn, UIEvent.EventButtonClick, function()
    Lib.emitEvent(Event.EVENT_EDITOR_RELOAD_MAP)
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnRemoteBtn, UIEvent.EventButtonClick, function()
    if self.downloading then
      return
    end
    self.downloading = true
    self.imgDownloadingImg:SetVisible(true)
    self.txtRemoteBtnText:SetVisible(false)
    if self.loadingAnimTimer then
      self.loadingAnimTimer()
    end
    self.loadingAnimTimer = EditorCommonUI:playLoadingAnim(self.imgDownloadingImg)
    Lib.emitEvent(Event.EVENT_EDITOR_RELOAD_MAP, true)
  end)
end

function WinMobileEditorMapReset:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REENTER_MAP, function()
    self.downloading = false
    self.imgDownloadingImg:SetVisible(false)
    self.txtRemoteBtnText:SetVisible(true)
    UI:closeWnd(self)
  end)
end

function WinMobileEditorMapReset:initView()
  self.downloading = false
  self.imgDownloadingImg:SetVisible(false)
  self.txtRemoteBtnText:SetVisible(true)
end

function WinMobileEditorMapReset:onHide()
  UI:closeWnd("mobileEditorMapReset")
end

function WinMobileEditorMapReset:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorMapReset")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorMapReset:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinMobileEditorMapReset:onClose()
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

return WinMobileEditorMapReset
