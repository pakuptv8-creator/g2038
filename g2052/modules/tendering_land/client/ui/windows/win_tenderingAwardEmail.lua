local WinTenderingAwardEmail = M

function WinTenderingAwardEmail:init()
  WinBase.init(self, "TenderingAwardEmail.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinTenderingAwardEmail:initUI()
  self.imgContent = self:child("TenderingAwardEmail-Content")
  self.imgTopBar = self:child("TenderingAwardEmail-TopBar")
  self.txtTitle = self:child("TenderingAwardEmail-Title")
  self.btnBtnClose = self:child("TenderingAwardEmail-BtnClose")
  self.lytBody = self:child("TenderingAwardEmail-Body")
  self.lytEditPanel = self:child("TenderingAwardEmail-EditPanel")
  self.editEditTxt = self:child("TenderingAwardEmail-EditTxt")
  self.txtEditContent = self:child("TenderingAwardEmail-EditContent")
  self.btnSendBtn = self:child("TenderingAwardEmail-SendBtn")
  self.btnSendBtn:SetText(Lang:toText("g2052.gui.tendering.email.send_btn"))
  self.txtTitle:SetText(Lang:toText("g2052.gui.tendering.email.title"))
  self.editEditTxt:getEditBoxImpl():setInputMode(0)
  self.editEditTxt:SetMaxLength(World.cfg.tenderAwardSetting.emailLen)
  self.editEditTxt:SetMaxLength(200)
end

function WinTenderingAwardEmail:initEvent()
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnSendBtn, UIEvent.EventButtonClick, function()
    if self.sendDescText ~= "" then
      AsyncProcess.SendMayorEmail(Me.platformUserId, self.sendDescText, function(isSuccess)
        if isSuccess then
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.email.send_success")
        else
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.tendering.email.send_fail")
        end
        self:onHide()
      end)
    end
  end)
  self:subscribe(self.editEditTxt, UIEvent.EventEditTextInput, function()
    self.sendDescText = string.format(self.editEditTxt:GetPropertyString("Text", ""))
    self.txtEditContent:SetText(self.sendDescText)
    self.editEditTxt:SetProperty("Text", "")
    self.firstIntoDescUp = false
  end)
  self:subscribe(self.editEditTxt, UIEvent.EventWindowTouchUp, function()
    if self.firstIntoDescUp then
      self.editEditTxt:SetProperty("Text", self.sendDescText)
      self.firstIntoDescUp = false
    else
      self.editEditTxt:SetProperty("Text", "")
      self.firstIntoDescUp = true
    end
  end)
  self:subscribe(self.editEditTxt, UIEvent.EventMotionRelease, function()
    self.editEditTxt:SetProperty("Text", "")
    self.firstIntoDescUp = true
  end)
end

function WinTenderingAwardEmail:subscribeEvent()
end

function WinTenderingAwardEmail:initView()
  self.sendDescText = ""
  self.editEditTxt:SetProperty("Text", "")
  self.txtEditContent:SetText(Lang:toText("g2052.gui.tendering.email.tips"))
  self.txtEditContent:SetVisible(true)
  self.firstIntoDescUp = true
end

function WinTenderingAwardEmail:onHide()
  UI:closeWnd("tenderingAwardEmail")
end

function WinTenderingAwardEmail:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("tenderingAwardEmail")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinTenderingAwardEmail:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinTenderingAwardEmail:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinTenderingAwardEmail
