local ACTIVITY_STATUS = {
  NotOpen = 1,
  InProgress = 2,
  Expired = 3
}
local GET_STATUS = {NotReceived = 1, Received = 2}
local activityConf = World.cfg.peakDayPetGetActivity
local WinPeakDay = M

function WinPeakDay:init()
  WinBase.init(self, "PeakDay.json")
  self._allEvent = {}
  self._getStatus = GET_STATUS.NotReceived
  self._activityStatus = ACTIVITY_STATUS.NotOpen
  self._selectIdx = 0
  self:initUI()
  self:initEvent()
end

function WinPeakDay:initUI()
  self.txtCountDownTip = self:child("PeakDay-CountDownTip")
  self.txtCountDownTip:SetText(Lang:toText("g2052.gui.peakday.text1"))
  self.txtCountDown = self:child("PeakDay-CountDown")
  self.txtSelectTip = self:child("PeakDay-SelectTip")
  self.txtSelectTip:SetText(Lang:toText("g2052.gui.peakday.text3"))
  self.lytListContainer = self:child("PeakDay-ListContainer")
  self.btnGet = self:child("PeakDay-GetBtn")
  self.txtGet = self:child("PeakDay-GetTxt")
  self.btnClose = self:child("PeakDay-CloseBtn")
  self.txtTitle1 = self:child("PeakDay-Title1")
  self.txtTitle1:SetText(Lang:toText("g2052.gui.peakday.title"))
  self.txtTitle2 = self:child("PeakDay-Title2")
  self.txtTitle2:SetText(Lang:toText("g2052.gui.peakday.title2"))
  self.txtActivityTime = self:child("PeakDay-ActivityTime")
  if activityConf and activityConf.activityTimeInUI then
    self.txtActivityTime:SetText(activityConf.activityTimeInUI)
  end
  self:initItemList()
end

function WinPeakDay:initItemList()
  self.itemGridView = GridViewHelper.new({
    name = "peakDayItemGridView",
    xCellNum = 3,
    yDis = 6,
    xDis = 23,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = false,
    vScorllMoveAble = false,
    autoColumnCount = false,
    widgetWidth = 146,
    widgetHeight = 171,
    widgetJson = "PeakDayItem.json",
    widgetName = "peakDayItem",
    gvParent = self.lytListContainer,
    cellSelectedCb = function(data, dx, dy, index)
      self._selectIdx = index
    end
  })
end

function WinPeakDay:updateRewardItems()
  local rewardItemIds = activityConf.rewardItemIds
  self.itemGridView:setData(rewardItemIds, -1, nil, false)
end

function WinPeakDay:initEvent()
  self:subscribe(self.btnGet, UIEvent.EventButtonClick, function()
    local hasReceived = Me:hasPeakDayPetReceived()
    if hasReceived then
      return
    end
    if self._btnLock then
      return
    end
    if self._selectIdx == 0 then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.peakday.no.select.item"))
      return
    end
    Me:sendPacket({
      pid = "reqReceivePeakDayReward",
      index = self._selectIdx
    }, function(ret)
      if not ret then
        Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.interactive.fail"))
      end
    end)
    self._btnLock = true
    World.Timer(2, function()
      self._btnLock = nil
    end)
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
end

function WinPeakDay:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PEAK_DAY_PET_RECEIVED, function()
    self:updateReceivedStatus(true)
  end)
end

function WinPeakDay:updateReceivedStatus(isStatusChange)
  local hasReceived = Me:hasPeakDayPetReceived()
  if hasReceived then
    self._getStatus = GET_STATUS.Received
    self.txtGet:SetText(Lang:toText("g2052.gui.peakday.button2"))
    self.btnGet:SetEnabled(false)
    self.btnGet:SetTouchable(false)
    if isStatusChange then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.peakday.get.reward.success"))
      Lib.emitEvent(Event.EVENT_UPDATE_PEAK_DAY_BTN, false)
    end
  else
    self._getStatus = GET_STATUS.NotReceived
    self.txtGet:SetText(Lang:toText("g2052.gui.peakday.button1"))
    self.btnGet:SetEnabled(true)
    self.btnGet:SetTouchable(true)
  end
end

function WinPeakDay:updateActivityStatus()
  local now = os.time()
  local beginTime = activityConf.beginTime
  local dayDuration = activityConf.dayDuration
  local endTime = beginTime + dayDuration * 86400
  if now < beginTime then
    self._activityStatus = ACTIVITY_STATUS.NotOpen
    self:updateCountDownTime()
  elseif now >= endTime then
    self._activityStatus = ACTIVITY_STATUS.Expired
  else
    self._activityStatus = ACTIVITY_STATUS.InProgress
  end
  self.txtCountDownTip:SetVisible(self._activityStatus == ACTIVITY_STATUS.NotOpen)
  self.btnGet:SetVisible(self._activityStatus == ACTIVITY_STATUS.InProgress)
end

function WinPeakDay:updateCountDownTime()
  if self.countdownTimer then
    self.countdownTimer()
    self.countdownTimer = nil
  end
  self.countdownTimer = World.Timer(20, function()
    local nowTime = os.time()
    local beginTime = activityConf.beginTime
    if nowTime >= beginTime then
      self.countdownTimer()
      self.countdownTimer = nil
      self:updateActivityStatus()
      return
    end
    local left = beginTime - nowTime
    if left >= Lib.getDaySeconds() then
      local day = math.floor(left / Lib.getDaySeconds())
      local hour = math.floor((left - day * Lib.getDaySeconds()) / 3600)
      self.txtCountDown:SetText(Lang:toText({
        "g2052.gui.activity.day",
        tostring(day),
        tostring(hour)
      }))
    else
      local timeStr = Lib.getFormatTime(left)
      self.txtCountDown:SetText(timeStr)
    end
    return true
  end)
end

function WinPeakDay:initView()
  self:updateActivityStatus()
  self:updateReceivedStatus()
  self:updateRewardItems()
end

function WinPeakDay:onHide()
  UI:closeWnd(self)
end

function WinPeakDay:onShow()
  if UI:isOpen(self) then
    return
  end
  if not activityConf then
    Lib.logWarning("no peak day activity config, check main setting")
    return
  end
  UI:openWnd("peakDay")
end

function WinPeakDay:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinPeakDay:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.countdownTimer then
    self.countdownTimer()
    self.countdownTimer = nil
  end
end

return WinPeakDay
