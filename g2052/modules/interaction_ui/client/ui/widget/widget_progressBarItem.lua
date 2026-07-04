local widget_base = require("ui.widget.widget_base")
local WidgetProgressBarItem = Lib.derive(widget_base)

function WidgetProgressBarItem:init(frameTime, callback, interruptCheckFunc)
  widget_base.init(self, "ProgressBarItem.json")
  self._allEvent = {}
  self._callback = callback
  self._interruptCheckFunc = interruptCheckFunc
  self:initUI()
  self:initEvent()
  self:initView(frameTime)
end

function WidgetProgressBarItem:initUI()
  self.grdProgress = self:child("ProgressBarItem-Progress")
  self.grdProgress:SetProgress(0)
end

function WidgetProgressBarItem:initEvent()
end

function WidgetProgressBarItem:initView(frameTime)
  local cur = 0
  local delta = 100 / frameTime
  World.LightTimer("play progress time", 1, function()
    cur = cur + delta
    if 100 < cur then
      cur = 100
    end
    self.grdProgress:SetProgress(cur / 100)
    if cur == 100 then
      if self._callback then
        self._callback()
      end
    elseif self._interruptCheckFunc then
      local canInterrupt = self._interruptCheckFunc()
      if canInterrupt then
        if self._callback then
          self._callback()
        end
        return
      end
    end
    return cur < 100
  end)
end

function WidgetProgressBarItem:onDestroy()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetProgressBarItem
