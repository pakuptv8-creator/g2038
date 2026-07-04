local WinLoseControlGlass = M

function WinLoseControlGlass:init()
  WinBase.init(self, "LoseControlGlass.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinLoseControlGlass:initUI()
  self.imgImage = self:child("LoseControlGlass-Image")
end

function WinLoseControlGlass:initEvent()
  Lib.subscribeEvent(Event.EVENT_UPDATE_LOSE_CONTROL_GLASSES_UI, function(isOpen)
    self:onShow(isOpen)
  end)
end

function WinLoseControlGlass:subscribeEvent()
end

function WinLoseControlGlass:initView()
end

function WinLoseControlGlass:onHide()
  UI:closeWnd("loseControlGlass")
end

function WinLoseControlGlass:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("loseControlGlass")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinLoseControlGlass:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinLoseControlGlass:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinLoseControlGlass
