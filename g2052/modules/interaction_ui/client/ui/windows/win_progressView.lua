local WinProgressView = M

function WinProgressView:init()
  WinBase.init(self, "ProgressView.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinProgressView:initUI()
  self.grdProgress = self:child("ProgressView-Progress")
  self.grdProgress:SetProgress(0)
end

function WinProgressView:initEvent()
end

function WinProgressView:subscribeEvent()
end

function WinProgressView:initView(frameTime)
  local cur = 0
  local delta = 100 / frameTime
  World.LightTimer("play progress time", 1, function()
    cur = cur + delta
    if 100 < cur then
      cur = 100
    end
    self.grdProgress:SetProgress(cur / 100)
    if cur == 100 then
      UI:closeWnd(self)
      if self._callback then
        self._callback()
      end
    elseif self._interruptCheckFunc then
      local canInterrupt = self._interruptCheckFunc()
      if canInterrupt then
        UI:closeWnd(self)
        if self._callback then
          self._callback()
        end
        return
      end
    end
    return cur < 100
  end)
end

function WinProgressView:onOpen(frameTime, callback, interruptCheckFunc)
  self._callback = callback
  self._interruptCheckFunc = interruptCheckFunc
  self:initView(frameTime)
  self:subscribeEvent()
end

function WinProgressView:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinProgressView
