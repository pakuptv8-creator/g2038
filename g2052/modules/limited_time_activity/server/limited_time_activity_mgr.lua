local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local LimitedTimeRoundsConfig = T(Config, "LimitedTimeRoundsConfig")
local LimitedTimeActivityMgr = _ENV.LimitedTimeActivityMgr
LimitedTimeActivityMgr.activityStatus = {}
local ActivityHelper = {
  [Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW] = require("server.helper.limited_time_draw_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY] = require("server.helper.must_win_lottery_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT] = require("server.helper.combination_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT] = require("server.helper.signal_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT] = require("server.helper.month_gift_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT] = require("server.helper.week_gift_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT] = require("server.helper.discount_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD] = require("server.helper.limited_time_card_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT] = require("server.helper.optional_limit_time_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL] = require("server.helper.limited_time_gold_wheel_helper"),
  [Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT] = require("server.helper.heart_warming_gift_helper")
}

function LimitedTimeActivityMgr:init()
  self.activityInfo = LimitedTimeActivityConfig:getAllCfgs()
  self.roundsInfo = LimitedTimeRoundsConfig:getAllCfgs()
  self.activityClass = {}
  self.notOpenList = {}
  for activityType, _ in pairs(ActivityHelper) do
    self.activityClass[activityType] = {}
  end
  self:updateActivityOpenTime()
  World.Timer(20, function()
    self:updateActivityOpenTime()
    return true
  end)
end

function LimitedTimeActivityMgr:updateActivityOpenTime()
  local time = os.time()
  for key, val in pairs(self.activityInfo or {}) do
    local startTime = Lib.getTimeByArray(val.startTime)
    local endTime = Lib.getTimeByArray(val.endTime)
    local act = LimitedTimeRoundsConfig:getCfgByActivityId(key)
    if (time < startTime or time >= endTime) and act then
      self.notOpenList[key] = true
    end
  end
  local effectRounds = {}
  local roundTime = 0
  local startTime = 0
  for _, v in pairs(self.roundsInfo or {}) do
    startTime = Lib.getTimeByArray(v.roundsTime)
    if time >= startTime and self.notOpenList[v.activityId] then
      local continueTime = Lib.getSecondsByArray(v.continueTime)
      roundTime = roundTime + continueTime
      table.insert(effectRounds, v)
    end
  end
  local diff = time - startTime
  if 0 < diff then
    local roundCount = math.floor(diff / roundTime)
    local startNumTime = startTime + roundCount * roundTime
    if self.curRoundStartTime ~= startNumTime then
      self.curRoundStartTime = startNumTime
      for i, v in pairs(effectRounds) do
        local continueTime = Lib.getSecondsByArray(v.continueTime)
        local endNumTime = startNumTime + continueTime
        for key, val in pairs(self.activityInfo or {}) do
          if val.id == v.activityId then
            self.activityInfo[key].startNumTime = startNumTime
            self.activityInfo[key].endNumTime = endNumTime
            break
          end
        end
        startNumTime = endNumTime
      end
    end
  end
  self:updateActivityStatus()
end

function LimitedTimeActivityMgr:updateActivityStatus()
  local time = os.time()
  for id, v in pairs(self.activityInfo or {}) do
    local startTime, endTime
    if self.notOpenList[id] then
      startTime = v.startNumTime
      endTime = v.endNumTime
    else
      startTime = Lib.getTimeByArray(v.startTime)
      endTime = Lib.getTimeByArray(v.endTime)
    end
    v.startTimeID = v.id .. "_" .. startTime
    local updateTime = Lib.getSecondsByArray(v.updateTime)
    local status = Define.LIMITED_TIME_ACTIVITY_STATUS.START
    local curUpdateCount
    if time < startTime then
      status = Define.LIMITED_TIME_ACTIVITY_STATUS.NOT_START
    elseif time >= endTime then
      status = Define.LIMITED_TIME_ACTIVITY_STATUS.END
    elseif 0 < updateTime then
      curUpdateCount = math.floor((time - startTime) / updateTime)
    end
    local haveAChange = false
    if not self.activityStatus[v.id] then
      haveAChange = true
    elseif self.activityStatus[v.id] ~= status then
      haveAChange = true
    end
    if haveAChange then
      self.activityStatus[v.id] = status
      if status == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
        if not self.activityClass[v.type][v.id] then
          self:createOneActivityClass(v.type, v.id)
        end
        self.activityClass[v.type][v.id]:onOperate(status, v)
      elseif (status == Define.LIMITED_TIME_ACTIVITY_STATUS.END or status == Define.LIMITED_TIME_ACTIVITY_STATUS.NOT_START) and self.activityClass[v.type] and self.activityClass[v.type][v.id] then
        self.activityClass[v.type][v.id]:onOperate(status, v)
        self:destroyOneActivityClass(v.type, v.id)
      end
    end
    if curUpdateCount and self.activityClass[v.type] and self.activityClass[v.type][v.id] then
      self.activityClass[v.type][v.id]:refreshActivityTick(curUpdateCount)
    end
    self:updateOneActivityClass(v.type, v.id)
  end
end

function LimitedTimeActivityMgr:createOneActivityClass(activityType, activityId)
  self.activityClass[activityType][activityId] = ActivityHelper[activityType].new()
end

function LimitedTimeActivityMgr:destroyOneActivityClass(activityType, activityId)
  if self.activityClass[activityType] and self.activityClass[activityType][activityId] then
    self.activityClass[activityType][activityId]:destroy()
    self.activityClass[activityType][activityId] = nil
  end
end

function LimitedTimeActivityMgr:updateOneActivityClass(activityType, activityId)
  if self.activityClass[activityType] and self.activityClass[activityType][activityId] then
    self.activityClass[activityType][activityId]:onUpdateDayTime()
  end
end

function LimitedTimeActivityMgr:syncActivityToPlayer(player)
  if not player or not player:isValid() then
    return
  end
  for activityType, val in pairs(self.activityClass) do
    for activityId, helper in pairs(val) do
      helper:loginCheckResetActivityData(player)
      helper:syncActivityInfo(player)
    end
  end
end

function LimitedTimeActivityMgr:playActivity(player, params, buyInfo)
  if not player or not player:isValid() then
    return
  end
  if params and params.id and params.type and self.activityStatus[params.id] and self.activityStatus[params.id] == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
    if self.activityClass[params.type] and self.activityClass[params.type][params.id] then
      self.activityClass[params.type][params.id]:playActivity(player, params, buyInfo)
    end
  else
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, buyInfo, false)
  end
end

function LimitedTimeActivityMgr:checkWeekMonthRounds(player)
  if not player or not player:isValid() then
    return
  end
  for activityId, helper in pairs(self.activityClass[Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT]) do
    helper:checkRefreshGiftState(player)
  end
  for activityId, helper in pairs(self.activityClass[Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT]) do
    helper:checkRefreshGiftState(player)
  end
end

function LimitedTimeActivityMgr:checkPlayerIsNextDayLogin(player)
  if not player or not player:isValid() then
    return
  end
  local lastTime = player:getLimitedLastLoginTime()
  local curTime = Lib.getDayStartTime(os.time())
  if lastTime ~= curTime then
    for activityId, helper in pairs(self.activityClass[Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT]) do
      helper:resetPlayerOptionalDayInfo(player)
    end
    player:setLimitedLastLoginTime(curTime)
  end
end

function LimitedTimeActivityMgr:checkHeartWarmData(player)
  if not player or not player:isValid() then
    return
  end
  for activityId, helper in pairs(self.activityClass[Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT]) do
    helper:initHeartWarmData(player)
    helper:checkHeartWarmDayInfo(player)
    helper:updateDayTaskState(player)
  end
end

function LimitedTimeActivityMgr:updateHeartWarmTaskProgress(player, taskType)
  if not player or not player:isValid() then
    return
  end
  for activityId, helper in pairs(self.activityClass[Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT]) do
    helper:updateTaskProgress(player, taskType)
  end
end

LimitedTimeActivityMgr:init()
return LimitedTimeActivityMgr
