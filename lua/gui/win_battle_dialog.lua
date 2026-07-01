local LuaTimer = T(Lib, "LuaTimer")
local M = _ENV.M

function M:init()
  WinBase.init(self, "battle_dialog.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytcanvas = self:child("canvas")
  self.lytcanvasMask = self:child("canvas-mask")
  self.imgcanvasDialog = self:child("canvas-dialog")
  self.txtcanvasText = self:child("canvas-text")
  self.btnYes = self:child("canvas-Yes")
  self.btnNo = self:child("canvas-No")
end

function M:initEvent()
  self:subscribe(self.lytcanvasMask, UIEvent.EventWindowTouchDown, function()
    if self.maskEquateYes then
      if self.yesCb then
        self:yesCb()
      end
      LuaTimer:cancel(self.closeTimer)
      UI:closeWnd("battle_dialog")
      return
    end
    if not self.isHideMask then
      LuaTimer:cancel(self.closeTimer)
      UI:closeWnd("battle_dialog")
    end
  end)
  self:subscribe(self.btnYes, UIEvent.EventButtonClick, function()
    if self.yesCb then
      self:yesCb()
    end
    LuaTimer:cancel(self.closeTimer)
    UI:closeWnd("battle_dialog")
  end)
  self:subscribe(self.btnNo, UIEvent.EventButtonClick, function()
    if self.noCb then
      self:noCb()
    end
    LuaTimer:cancel(self.closeTimer)
    UI:closeWnd("battle_dialog")
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:showDialogText(parma)
  if UI:isOpen(self) then
    self:onHide()
  end
  local textOffset = -156
  self.isHideMask = parma.isHideMask
  self.lytcanvasMask:SetVisible(not self.isHideMask)
  if parma.yesCb then
    textOffset = textOffset - 195
    self.btnYes:SetVisible(true)
    self.yesCb = parma.yesCb
    self.maskEquateYes = parma.maskEquateYes
  else
    self.btnYes:SetVisible(false)
    self.yesCb = nil
  end
  if parma.noCb then
    textOffset = textOffset - 195
    self.btnNo:SetVisible(true)
    self.noCb = parma.noCb
  else
    self.btnNo:SetVisible(false)
    self.noCb = nil
  end
  if parma.closeFunc then
    self.closeFunc = parma.closeFunc
  end
  self.txtcanvasText:SetWidth({1, textOffset})
  self.txtcanvasText:SetText(parma.text)
  self.autoCloseTime = parma.autoCloseTime
  UI:openWnd("battle_dialog")
end

function M:onHide()
  UI:closeWnd("battle_dialog")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_dialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
  if self.autoCloseTime then
    self.closeTimer = LuaTimer:scheduleTimer(function()
      UI:closeWnd("battle_dialog")
    end, self.autoCloseTime, 1)
  end
end

function M:setCloseFunc(func)
  self.closeFunc = func
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.closeFunc then
    self.closeFunc()
    self.closeFunc = nil
  end
  Lib.logDebug("battle_dialog onClose")
end

return M
