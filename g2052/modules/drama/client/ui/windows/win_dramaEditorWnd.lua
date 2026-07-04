local WinDramaEditorWnd = M

function WinDramaEditorWnd:init()
  WinBase.init(self, "DramaEditorWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaEditorWnd:initUI()
  self.imgPanel = self:child("DramaEditorWnd-Panel")
  self.imgBg = self:child("DramaEditorWnd-bg")
  self.imgTitleBg = self:child("DramaEditorWnd-titleBg")
  self.txtTitle = self:child("DramaEditorWnd-title")
  self.btnClose = self:child("DramaEditorWnd-Close")
  self.btnConfirm = self:child("DramaEditorWnd-Confirm")
  self.btnCancel = self:child("DramaEditorWnd-Cancel")
  self.editEditTitle = self:child("DramaEditorWnd-EditTitle")
  self.txtTipsTitle = self:child("DramaEditorWnd-TipsTitle")
  self.editEditContent = self:child("DramaEditorWnd-EditContent")
  self.txtTipsContent = self:child("DramaEditorWnd-TipsContent")
  self.btnConfirm:SetText(Lang:toText("g2052.gui.confirm"))
  self.btnCancel:SetText(Lang:toText("g2052.gui.cancel"))
  self.editEditTitle:getEditBoxImpl():setInputMode(0)
  self.editEditTitle:SetTextHorzAlign(0)
  self.editEditTitle:SetTextVertAlign(1)
  self.editEditTitle:SetMaxLength(100)
  self.editEditContent:getEditBoxImpl():setInputMode(0)
  self.editEditContent:SetTextHorzAlign(0)
  self.editEditContent:SetTextVertAlign(0)
  self.editEditContent:SetMaxLength(200)
end

function WinDramaEditorWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    if self.callBackFunc then
      self.callBackFunc(self.sendTitleText, self.sendDescText)
    end
    self:onHide()
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.editEditTitle, UIEvent.EventEditTextInput, function()
    local text = self.editEditTitle:GetPropertyString("Text", "") or ""
    self.sendTitleText = self:getOneShortContent(text, true)
    self.editEditTitle:SetProperty("Text", self.sendTitleText)
    self.txtTipsTitle:SetVisible(false)
  end)
  self:subscribe(self.editEditTitle, UIEvent.EventWindowTouchUp, function()
    self.txtTipsTitle:SetVisible(false)
  end)
  self:subscribe(self.editEditContent, UIEvent.EventEditTextInput, function()
    local text = self.editEditContent:GetPropertyString("Text", "") or ""
    self.sendDescText = self:getOneShortContent(text, false)
    self.txtTipsContent:SetText(self.sendDescText)
    self.editEditContent:SetProperty("Text", "")
    self.firstIntoDescUp = false
  end)
  self:subscribe(self.editEditContent, UIEvent.EventWindowTouchUp, function()
    if self.firstIntoDescUp then
      self.editEditContent:SetProperty("Text", self.sendDescText)
      self.firstIntoDescUp = false
    else
      self.editEditContent:SetProperty("Text", "")
      self.firstIntoDescUp = true
    end
  end)
  self:subscribe(self.editEditContent, UIEvent.EventMotionRelease, function()
    self.editEditContent:SetProperty("Text", "")
    self.firstIntoDescUp = true
  end)
end

function WinDramaEditorWnd:subscribeEvent()
end

function WinDramaEditorWnd:getOneShortContent(inputText, isTitle)
  local content = World.CurWorld:filterWord(inputText)
  local endIndex = Lib.subStringGetTotalIndex(content)
  local maxLen = 10
  if isTitle then
    maxLen = 10
  else
    maxLen = 20
  end
  if self.showType == "drama" then
    if isTitle then
      maxLen = World.cfg.dramaSetting.dramaNameMaxLen
    else
      maxLen = World.cfg.dramaSetting.dramaDescMaxLen
    end
  elseif self.showType == "role" then
    if isTitle then
      maxLen = World.cfg.dramaSetting.roleNameMaxLen
    else
      maxLen = World.cfg.dramaSetting.roleDescMaxLen
    end
  end
  if endIndex > maxLen then
    local content = Lib.subStringUTF8(content, 1, maxLen)
    return content .. "..."
  end
  return content
end

function WinDramaEditorWnd:initView(showType, initName, initDesc, backFunc)
  self.showType = showType
  if showType == "drama" then
    self.txtTitle:SetText(Lang:toText("g2052.gui.drama.editor.drama"))
  elseif showType == "role" then
    self.txtTitle:SetText(Lang:toText("g2052.gui.drama.editor.role"))
  end
  self.sendTitleText = initName or ""
  self.sendDescText = initDesc or ""
  self.editEditTitle:SetProperty("Text", self.sendTitleText)
  self.editEditContent:SetProperty("Text", "")
  self.txtTipsTitle:SetText(Lang:toText("ui.chat.click.chat"))
  self.txtTipsTitle:SetVisible(false)
  self.txtTipsContent:SetText(self.sendDescText)
  self.txtTipsContent:SetVisible(true)
  self.firstIntoDescUp = true
  self.callBackFunc = backFunc
end

function WinDramaEditorWnd:onHide()
  UI:closeWnd("dramaEditorWnd")
end

function WinDramaEditorWnd:onShow(isShow, showType, initName, initDesc, backFunc)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaEditorWnd", showType, initName, initDesc, backFunc)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaEditorWnd:onOpen(showType, initName, initDesc, backFunc)
  self:initView(showType, initName, initDesc, backFunc)
  self:subscribeEvent()
end

function WinDramaEditorWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDramaEditorWnd
