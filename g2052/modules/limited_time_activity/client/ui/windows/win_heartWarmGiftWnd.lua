local WinHeartWarmGiftWnd = M
local HeartWarmingGiftConfig = T(Config, "HeartWarmingGiftConfig")
local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WinHeartWarmGiftWnd:init()
  WinBase.init(self, "HeartWarmGiftWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinHeartWarmGiftWnd:initUI()
  self.btnHelp = self:child("HeartWarmGiftWnd-help")
  self.txtTitle = self:child("HeartWarmGiftWnd-title")
  self.lytRightPanel = self:child("HeartWarmGiftWnd-RightPanel")
  self.lytTopPanel = self:child("HeartWarmGiftWnd-TopPanel")
  self.imgIntegralIcon = self:child("HeartWarmGiftWnd-integralIcon")
  self.txtIntegralText = self:child("HeartWarmGiftWnd-integralText")
  self.grdIntegralBar = self:child("HeartWarmGiftWnd-integralBar")
  self.lytContentPanel = self:child("HeartWarmGiftWnd-ContentPanel")
  self.lytTabPanel = self:child("HeartWarmGiftWnd-tabPanel")
  self.lytItemPanel = self:child("HeartWarmGiftWnd-itemPanel")
  self.lytRewardPanel = {}
  self.imgRewardBg = {}
  self.txtRewardNum = {}
  self.imgStateBg = {}
  self.imgRewardIcon = {}
  self.imgStateGet = {}
  self.imgStateHas = {}
  self.totalGiftNum = 4
  for i = 1, self.totalGiftNum do
    self.lytRewardPanel[i] = self:child("HeartWarmGiftWnd-rewardPanel" .. i)
    self.imgRewardBg[i] = self:child("HeartWarmGiftWnd-rewardBg" .. i)
    self.txtRewardNum[i] = self:child("HeartWarmGiftWnd-rewardNum" .. i)
    self.imgStateBg[i] = self:child("HeartWarmGiftWnd-stateBg" .. i)
    self.imgRewardIcon[i] = self:child("HeartWarmGiftWnd-rewardIcon" .. i)
    self.imgStateGet[i] = self:child("HeartWarmGiftWnd-stateGet" .. i)
    self.imgStateHas[i] = self:child("HeartWarmGiftWnd-stateHas" .. i)
  end
  self.txtTitle:SetText(Lang:toText("gui.limit.time.heart.warming.title"))
  self.btnHelp:SetVisible(false)
  self:initItemGridView()
  self:initTopTabGridView()
end

function WinHeartWarmGiftWnd:initTopTabGridView()
  self.gvTopTab = GridViewHelper.new({
    name = "gvHeartWarmTab",
    xCellNum = 3,
    yDis = 0,
    xDis = 14,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = false,
    vScorllMoveAble = false,
    widgetWidth = 237,
    widgetHeight = 56,
    widgetJson = "HeartWarmGiftTab.json",
    widgetName = "heartWarmGiftTab",
    gvParent = self.lytTabPanel,
    cellSelectedCb = function(data, dx, dy, index)
      self:onTopTabBtnClick(index)
    end
  })
end

function WinHeartWarmGiftWnd:onTopTabBtnClick(index)
  if not index then
    return
  end
  self.curSelectTab = index
  for i = 1, 3 do
    local itemGridView = self.gvItem[i]:getGridView()
    if i == self.curSelectTab then
      itemGridView:SetVisible(true)
      itemGridView:SetScrollOffset(0)
    else
      itemGridView:SetVisible(false)
    end
  end
end

function WinHeartWarmGiftWnd:initItemGridView()
  self.gvItem = {}
  for i = 1, 3 do
    self.gvItem[i] = GridViewHelper.new({
      name = "gvG2052ShopItem",
      xCellNum = 1,
      yDis = 10,
      xDis = 0,
      area = {
        {0, 0},
        {0, 0},
        {1, 0},
        {1, 0}
      },
      autoColumnCount = false,
      moveAble = true,
      vScorllMoveAble = true,
      hScorllMoveAble = false,
      widgetWidth = 842,
      widgetHeight = 90,
      widgetJson = "HeartWarmGiftItem.json",
      widgetName = "heartWarmGiftItem",
      gvParent = self.lytItemPanel
    })
  end
end

function WinHeartWarmGiftWnd:initEvent()
  self:subscribe(self.btnHelp, UIEvent.EventButtonClick, function()
  end)
  for i, v in pairs(self.imgStateBg) do
    self:subscribe(v, UIEvent.EventWindowClick, function()
      if self.imgStateGet[i]:IsVisible() then
        return
      end
      if self.giftCfgList[i] then
        UI:openWnd("shopAwardPreview", self.giftCfgList[i])
        local reportData = {
          d3_gift_id = self.giftCfgList[i].id
        }
        Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_event_preview", reportData, Me)
      end
    end)
  end
  for i, v in pairs(self.imgStateGet) do
    self:subscribe(v, UIEvent.EventWindowClick, function()
      if self.giftCfgList[i] then
        local data = {}
        data.taskId = nil
        data.activityId = self.activityInfo.id
        data.giftId = self.giftCfgList[i].id
        Me:clientReceiveHeartWarm(data)
      end
    end)
  end
end

function WinHeartWarmGiftWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HEART_WARM_INTEGRAL_UPDATE, function()
    self:updateIntegralView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HEART_WARM_DAY_UPDATE, function()
    self.gvTopTab:getAdapter():notifyDataChange()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_HEART_WARM_TASK_UPDATE, function()
    for i = 1, 3 do
      self:updateItemShow(i)
    end
  end)
end

function WinHeartWarmGiftWnd:initView()
  self.activityInfo = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  self.totalIntegral = 1
  self.giftCfgList = {}
  self:initTopTabData()
  self:initIntegralView()
  for i = 1, 3 do
    self:updateItemShow(i)
  end
  Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_event_enter", nil, Me)
end

function WinHeartWarmGiftWnd:updateItemShow(dayIndex)
  local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityIdAndDay(self.activityInfo.id, dayIndex)
  local taskData = Lib.copyTable1(activityTaskData)
  local heartWarmTask = Me:getHeartWarmTask()[self.activityInfo.id]
  table.sort(taskData, function(a, b)
    if heartWarmTask[a.taskId].taskState == heartWarmTask[b.taskId].taskState then
      return a.taskId < b.taskId
    end
    if heartWarmTask[a.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
      return true
    end
    if heartWarmTask[b.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
      return false
    end
    return heartWarmTask[a.taskId].taskState < heartWarmTask[b.taskId].taskState
  end)
  self.gvItem[dayIndex]:setData(taskData)
  self.gvItem[dayIndex]:getGridView():SetScrollOffset(0)
end

function WinHeartWarmGiftWnd:initTopTabData()
  self.curSelectTab = 1
  local TopTabInfo = {
    [1] = {
      tabName = "gui.limit.time.heart.warming.day1",
      activityId = self.activityInfo.id
    },
    [2] = {
      tabName = "gui.limit.time.heart.warming.day2",
      activityId = self.activityInfo.id
    },
    [3] = {
      tabName = "gui.limit.time.heart.warming.day3",
      activityId = self.activityInfo.id
    }
  }
  self.gvTopTab:setData(TopTabInfo, self.curSelectTab, nil, true)
end

function WinHeartWarmGiftWnd:initIntegralView()
  self.giftCfgList = HeartWarmingGiftConfig:getCfgByActivityId(self.activityInfo.id)
  self.totalIntegral = self.giftCfgList[self.totalGiftNum].needPoints
  for i = 1, self.totalGiftNum do
    local giftCfg = self.giftCfgList[i]
    self.txtRewardNum[i]:SetText(giftCfg.needPoints)
    self.lytRewardPanel[i]:SetXPosition({
      giftCfg.needPoints / self.totalIntegral,
      -16
    })
    local goodData = LimitedTimeGiftItemConfig:getCfgById(giftCfg.giftContent[1])
    self.giftCfgList[i].icon = goodData.itemIcon
    self.giftCfgList[i].quality = goodData.quality
    self.giftCfgList[i].name = goodData.showName
    self.imgRewardIcon[i]:SetImage(self.giftCfgList[i].icon)
  end
  self:updateIntegralView()
end

function WinHeartWarmGiftWnd:updateIntegralView()
  local heartWarmIntegral = Me:getHeartWarmIntegral()
  local curIntegral = heartWarmIntegral[self.activityInfo.id] or 0
  self.txtIntegralText:SetText(Lang:toText({
    "gui.limit.time.heart.warming.integral",
    curIntegral
  }))
  self.grdIntegralBar:SetProgress(curIntegral / self.totalIntegral)
  local heartWarmReward = Me:getHeartWarmReward()
  for i = 1, self.totalGiftNum do
    local giftCfg = self.giftCfgList[i]
    local giftKey = giftCfg.giftKey
    if curIntegral >= giftCfg.needPoints then
      self.imgRewardBg[i]:SetImage("set:g2052_heart_gift.json image:img_0_round1")
      if heartWarmReward[giftKey] then
        self.imgStateHas[i]:SetVisible(true)
        self.imgStateGet[i]:SetVisible(false)
      else
        self.imgStateHas[i]:SetVisible(false)
        self.imgStateGet[i]:SetVisible(true)
      end
    else
      self.imgRewardBg[i]:SetImage("set:g2052_heart_gift.json image:img_0_round2")
      self.imgStateGet[i]:SetVisible(false)
      self.imgStateHas[i]:SetVisible(false)
    end
  end
end

function WinHeartWarmGiftWnd:onHide()
  UI:closeWnd("heartWarmGiftWnd")
end

function WinHeartWarmGiftWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("heartWarmGiftWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHeartWarmGiftWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinHeartWarmGiftWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinHeartWarmGiftWnd
