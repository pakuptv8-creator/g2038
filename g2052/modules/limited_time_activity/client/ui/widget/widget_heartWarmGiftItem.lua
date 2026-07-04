local widget_base = require("ui.widget.widget_base")
local WidgetHeartWarmGiftItem = Lib.derive(widget_base)

function WidgetHeartWarmGiftItem:init()
  widget_base.init(self, "HeartWarmGiftItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetHeartWarmGiftItem:initUI()
  self.imgBg = self:child("HeartWarmGiftItem-bg")
  self.txtItemTitle = self:child("HeartWarmGiftItem-itemTitle")
  self.btnGotoBtn = self:child("HeartWarmGiftItem-GotoBtn")
  self.btnGetBtn = self:child("HeartWarmGiftItem-GetBtn")
  self.imgRewardBg = self:child("HeartWarmGiftItem-rewardBg")
  self.imgRewardIcon = self:child("HeartWarmGiftItem-rewardIcon")
  self.txtRewardText = self:child("HeartWarmGiftItem-rewardText")
  self.imgMaskIcon = self:child("HeartWarmGiftItem-maskIcon")
end

function WidgetHeartWarmGiftItem:initEvent()
  self:subscribe(self.btnGotoBtn, UIEvent.EventButtonClick, function()
    Me:clientHeartWarmGoTo(self.info.taskId)
    UI:closeWnd("limitedTimeActivityWnd")
  end)
  self:subscribe(self.btnGetBtn, UIEvent.EventButtonClick, function()
    local data = {}
    data.taskId = self.info.taskId
    data.activityId = self.info.activityId
    data.giftId = nil
    Me:clientReceiveHeartWarm(data)
  end)
end

function WidgetHeartWarmGiftItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  if self.info then
    local heartWarmTask = Me:getHeartWarmTask()[self.info.activityId] or {}
    local curProgress = heartWarmTask[self.info.taskId].taskProgress
    if curProgress > self.info.targetNum then
      curProgress = self.info.targetNum
    end
    local progressStr = "(" .. curProgress .. "/" .. self.info.targetNum .. ")"
    self.txtItemTitle:SetText(Lang:toText(self.info.taskTitle) .. progressStr)
    self.txtRewardText:SetText(self.info.rewardNum)
    self.btnGotoBtn:SetVisible(false)
    self.btnGetBtn:SetVisible(false)
    self.imgMaskIcon:SetVisible(false)
    if heartWarmTask[self.info.taskId].taskState == Define.HEART_WARM_TASK_STATE.START then
      if self.info.taskType ~= Define.HEART_WARM_TASK_TYPE.ALL_FINISH then
        self.btnGotoBtn:SetVisible(true)
      end
    elseif heartWarmTask[self.info.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
      self.btnGetBtn:SetVisible(true)
    elseif heartWarmTask[self.info.taskId].taskState == Define.HEART_WARM_TASK_STATE.END then
      self.imgMaskIcon:SetVisible(true)
    end
  end
end

function WidgetHeartWarmGiftItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetHeartWarmGiftItem
