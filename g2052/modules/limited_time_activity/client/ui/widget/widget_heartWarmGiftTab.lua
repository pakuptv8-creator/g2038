local widget_base = require("ui.widget.widget_base")
local WidgetHeartWarmGiftTab = Lib.derive(widget_base)
local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")

function WidgetHeartWarmGiftTab:init()
  widget_base.init(self, "HeartWarmGiftTab.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHeartWarmGiftTab:initUI()
  self.imgNormalBg = self:child("HeartWarmGiftTab-normalBg")
  self.txtNormalTxt = self:child("HeartWarmGiftTab-normalTxt")
  self.imgSelectBg = self:child("HeartWarmGiftTab-selectBg")
  self.txtSelectTxt = self:child("HeartWarmGiftTab-selectTxt")
  self.imgLockBg = self:child("HeartWarmGiftTab-lockBg")
  self.imgRedIcon = self:child("HeartWarmGiftTab-redIcon")
  self.imgRedIcon:SetVisible(false)
end

function WidgetHeartWarmGiftTab:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.imgLockBg:IsVisible() then
      return
    end
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetHeartWarmGiftTab:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.select = data.select
  self.imgNormalBg:SetVisible(not self.select)
  self.imgSelectBg:SetVisible(self.select)
  if self.info then
    self.txtNormalTxt:SetText(Lang:toText(self.info.tabName))
    self.txtSelectTxt:SetText(Lang:toText(self.info.tabName))
    local heartWarmStart = Me:getHeartWarmStart()
    local curStartData = heartWarmStart[self.info.activityId] or {}
    if curStartData[data.index] then
      self.imgLockBg:SetVisible(false)
      self.imgRedIcon:SetVisible(false)
      local heartWarmTask = Me:getHeartWarmTask()[self.info.activityId] or {}
      local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityIdAndDay(self.info.activityId, data.index)
      for _, val in pairs(activityTaskData) do
        if heartWarmTask[val.taskId] and heartWarmTask[val.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
          self.imgRedIcon:SetVisible(true)
          break
        end
      end
    else
      self.imgRedIcon:SetVisible(false)
      self.imgLockBg:SetVisible(true)
    end
  else
    self.imgRedIcon:SetVisible(false)
    self.imgLockBg:SetVisible(false)
  end
end

function WidgetHeartWarmGiftTab:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHeartWarmGiftTab
