local WinCommonWaitWnd = M

function WinCommonWaitWnd:init()
  WinBase.init(self, "CommonWaitWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCommonWaitWnd:initUI()
end

function WinCommonWaitWnd:initEvent()
end

function WinCommonWaitWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    self:onHide()
  end)
end

function WinCommonWaitWnd:initView()
  self:startAutoRefreshTimer()
end

function WinCommonWaitWnd:startAutoRefreshTimer()
  self:stopAutoRefreshTimer()
  self.refreshTimer = World.Timer(400, function()
    self:onHide()
    return false
  end)
end

function WinCommonWaitWnd:stopAutoRefreshTimer()
  if self.refreshTimer then
    self.refreshTimer()
    self.refreshTimer = nil
  end
end

function WinCommonWaitWnd:onHide()
  UI:closeWnd("commonWaitWnd")
end

function WinCommonWaitWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("commonWaitWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinCommonWaitWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinCommonWaitWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopAutoRefreshTimer()
end

return WinCommonWaitWnd
