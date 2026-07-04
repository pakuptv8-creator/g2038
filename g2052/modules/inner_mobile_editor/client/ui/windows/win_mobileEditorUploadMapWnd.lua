local WinMobileEditorUploadMapWnd = M
local ModeManager = T(MobileEditor, "ModeManager")
local EditorCommonUI = T(Lib, "EditorCommonUI")

function WinMobileEditorUploadMapWnd:init()
  WinBase.init(self, "MobileEditorUploadMapWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorUploadMapWnd:initUI()
  self.imgBg = self:child("MobileEditorUploadMapWnd-bg")
  self.btnCloseBtn = self:child("MobileEditorUploadMapWnd-closeBtn")
  self.txtContentText = self:child("MobileEditorUploadMapWnd-contentText")
  self.lytBiddingLyt = self:child("MobileEditorUploadMapWnd-biddingLyt")
  self.imgBtnBg = self:child("MobileEditorUploadMapWnd-btnBg")
  self.imgSelectImg = self:child("MobileEditorUploadMapWnd-selectImg")
  self.txtBiddingText = self:child("MobileEditorUploadMapWnd-biddingText")
  self.btnUploadBtn = self:child("MobileEditorUploadMapWnd-uploadBtn")
  self.txtUploadBtnText = self:child("MobileEditorUploadMapWnd-uploadBtnText")
  self.imgUploading = self:child("MobileEditorUploadMapWnd-uploadingImg")
  self.txtContentText:SetText(Lang:toText("ui.setting.upload.map.tips"))
  self.txtBiddingText:SetText(Lang:toText("ui.setting.join.bidding"))
  self.txtUploadBtnText:SetText(Lang:toText("ui.setting.upload"))
end

function WinMobileEditorUploadMapWnd:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnUploadBtn, UIEvent.EventButtonClick, function()
    if self.uploading then
      return
    end
    self.uploading = true
    self.imgUploading:SetVisible(true)
    if self.loadingAnimTimer then
      self.loadingAnimTimer()
    end
    self.loadingAnimTimer = EditorCommonUI:playLoadingAnim(self.imgUploading)
    self.txtUploadBtnText:SetVisible(false)
    Lib.emitEvent(Event.EVENT_UPLOAD_MAP_DATA, true, self.needBidding)
  end)
  self:subscribe(self.imgBtnBg, UIEvent.EventWindowClick, function()
    self.needBidding = not self.needBidding
    self.imgSelectImg:SetVisible(self.needBidding)
  end)
end

function WinMobileEditorUploadMapWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPLOAD_MAP_DATA_FINISH, function(updateType, isSuccess)
    self.imgUploading:SetVisible(false)
    self.txtUploadBtnText:SetVisible(true)
    self.uploading = false
    UI:closeWnd(self)
  end)
end

function WinMobileEditorUploadMapWnd:initView()
  self.uploading = false
  local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", ModeManager:instance():getBlockId())
  if blockStatus == Define.BIDDING_STATUS.BIDDING then
    self.lytBiddingLyt:SetVisible(true)
    self.needBidding = true
  else
    self.needBidding = false
    self.lytBiddingLyt:SetVisible(false)
  end
  self.imgSelectImg:SetVisible(self.needBidding)
  self.imgUploading:SetVisible(false)
  self.txtUploadBtnText:SetVisible(true)
end

function WinMobileEditorUploadMapWnd:onHide()
  UI:closeWnd("mobileEditorUploadMapWnd")
end

function WinMobileEditorUploadMapWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorUploadMapWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorUploadMapWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinMobileEditorUploadMapWnd:onClose()
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

return WinMobileEditorUploadMapWnd
