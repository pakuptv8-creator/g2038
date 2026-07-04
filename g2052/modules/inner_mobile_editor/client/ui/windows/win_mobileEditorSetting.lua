local WinMobileEditorSetting = M

function WinMobileEditorSetting:init()
  WinBase.init(self, "MobileEditorSetting.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorSetting:initUI()
  self.imgMobileEditorSettingBg = self:child("MobileEditorSetting-bg")
  self.btnMobileEditorSettingUploadBtn = self:child("MobileEditorSetting-uploadBtn")
  self.txtMobileEditorSettingUploadBtnText = self:child("MobileEditorSetting-uploadBtnText")
  self.btnMobileEditorSettingMapResetBtn = self:child("MobileEditorSetting-mapResetBtn")
  self.txtMobileEditorSettingMapResetBtnText = self:child("MobileEditorSetting-mapResetBtnText")
  self.btnMobileEditorSettingExitBtn = self:child("MobileEditorSetting-exitBtn")
  self.txtMobileEditorSettingExitBtnText = self:child("MobileEditorSetting-exitBtnText")
  self.txtMobileEditorSettingUploadBtnText:SetText(Lang:toText("ui.setting.upload.push"))
  self.txtMobileEditorSettingMapResetBtnText:SetText(Lang:toText("ui.setting.map.reset"))
  self.txtMobileEditorSettingExitBtnText:SetText(Lang:toText("ui.setting.exit.edit"))
end

function WinMobileEditorSetting:initEvent()
  self:subscribe(self.btnMobileEditorSettingUploadBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("mobileEditorUploadMapWnd")
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnMobileEditorSettingMapResetBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("mobileEditorMapReset")
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnMobileEditorSettingExitBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("mobileEditorExit")
    UI:closeWnd(self)
  end)
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    UI:closeWnd(self)
  end)
end

function WinMobileEditorSetting:subscribeEvent()
end

function WinMobileEditorSetting:initView()
end

function WinMobileEditorSetting:onHide()
  UI:closeWnd("mobileEditorSetting")
end

function WinMobileEditorSetting:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorSetting")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorSetting:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinMobileEditorSetting:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinMobileEditorSetting
