local WinMobileEditorClickMask = M

function WinMobileEditorClickMask:init()
  WinBase.init(self, "MobileEditorClickMask.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinMobileEditorClickMask:initUI()
end

function WinMobileEditorClickMask:initEvent()
end

function WinMobileEditorClickMask:subscribeEvent()
end

function WinMobileEditorClickMask:initView(showTime)
  if self.closeTimer then
    self.closeTimer()
  end
  self.closeTimer = World.Timer(showTime or 600, function()
    self.closeTimer = nil
    UI:closeWnd(self)
  end)
end

function WinMobileEditorClickMask:onHide()
  UI:closeWnd("mobileEditorClickMask")
end

function WinMobileEditorClickMask:onShow(isShow, showTime)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("mobileEditorClickMask", showTime)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinMobileEditorClickMask:onOpen(showTime)
  self:initView(showTime)
  self:subscribeEvent()
end

function WinMobileEditorClickMask:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.closeTimer then
    self.closeTimer()
    self.closeTimer = nil
  end
end

return WinMobileEditorClickMask
