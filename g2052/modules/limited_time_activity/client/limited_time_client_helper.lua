local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")
local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")
local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local LimitedTimeWeekGiftConfig = T(Config, "LimitedTimeWeekGiftConfig")
local LimitedTimeMonthGiftConfig = T(Config, "LimitedTimeMonthGiftConfig")
local LimitedTimeDiscountGiftConfig = T(Config, "LimitedTimeDiscountGiftConfig")
local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local HeartWarmingGiftConfig = T(Config, "HeartWarmingGiftConfig")
local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")

function LimitTimeClientHelper:init()
  self.activeInfo = {}
  self.activityClass = {}
  self.activityRedInfo = {}
  self.limitMustFishClick = false
end

function LimitTimeClientHelper:updateActiveData(activeType, status, params)
  if not self.activityClass[activeType] then
    self.activityClass[activeType] = {}
  end
  self.activityClass[activeType][params.id] = {status = status, params = params}
  for activityId, val in pairs(self.activityClass[activeType]) do
    if val.status == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
      self.activeInfo[activeType] = val
      return
    end
  end
  self.activeInfo[activeType] = {status = status, params = params}
end

function LimitTimeClientHelper:getStatusByActiveType(activeType)
  if self.activeInfo[activeType] then
    return self.activeInfo[activeType].status
  end
  return Define.LIMITED_TIME_ACTIVITY_STATUS.NOT_START
end

function LimitTimeClientHelper:getParamsByActiveType(activeType)
  if self.activeInfo[activeType] then
    return self.activeInfo[activeType].params
  end
  return false
end

function LimitTimeClientHelper:getActivitiesInCommonWnd(activityWndType)
  return LimitedTimeActivityConfig:getSameGroupByCommonWnd(activityWndType)
end

function LimitTimeClientHelper:checkActiveIsOpen(activeType)
  if not LimitedTimeActivityGameMgr:checkLimitTimeActivityIsUnlock(activeType) then
    return false
  end
  if self.activeInfo[activeType] and self.activeInfo[activeType].status == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
    if activeType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
      local activityData = LimitedTimeGiftCombinedConfig:getCfgByActivityId(self.activeInfo[activeType].params.id)
      local giftKey = activityData.giftKey
      local combinedGiftData = Me:getCombinedGiftData()
      if combinedGiftData[giftKey] then
        return false
      else
        return true
      end
    elseif activeType == Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT then
      local activityData = LimitedTimeGiftSignalConfig:getCfgByActivityId(self.activeInfo[activeType].params.id)
      local isAllHave = true
      local signalGiftData = Me:getSignalLimitGiftData()
      for _, val in pairs(activityData) do
        if val.limitCounts < 0 then
          return true
        end
        local giftKey = val.giftKey
        if not signalGiftData[giftKey] then
          isAllHave = false
        else
          local boughtNum = 0
          if signalGiftData[giftKey] == true then
            boughtNum = 1
          else
            boughtNum = signalGiftData[giftKey] or 0
          end
          if boughtNum < val.limitCounts then
            isAllHave = false
          end
        end
      end
      return not isAllHave
    elseif activeType == Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
      local activityData = HeartWarmingGiftConfig:getCfgByActivityId(self.activeInfo[activeType].params.id)
      local isAllHave = true
      local heartWarmReward = Me:getHeartWarmReward()
      for _, val in pairs(activityData) do
        local giftKey = val.giftKey
        if not heartWarmReward[giftKey] then
          isAllHave = false
        end
      end
      return not isAllHave
    else
      return true
    end
  end
  return false
end

function LimitTimeClientHelper:updateMustFishClick(value)
  self.limitMustFishClick = value
  self:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
end

function LimitTimeClientHelper:getMustWinLotteryRedState()
  local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
  if not params then
    return false
  end
  local mustWinLotteryAwards = MustWinLotteryAwardConfig:getCfgByActivityId(params.id)
  local giftItemCfgs = LimitedTimeGiftItemConfig:getAllCfgs() or {}
  local allCanUse = true
  for i, v in pairs(mustWinLotteryAwards) do
    local awardId = v.giftContent[1]
    local goodsCfg = giftItemCfgs[awardId]
    local canUse = Me:checkBusinessItemUnlock(goodsCfg.awardType, goodsCfg.itemId)
    if not canUse then
      allCanUse = false
    end
  end
  if allCanUse then
    return false
  else
    local mustWinLotteryData = Me:getMustWinLotteryData()
    local haveData = {}
    if params and params.id then
      haveData = mustWinLotteryData[params.id] or {}
    end
    if #haveData == 0 then
      return true
    end
    local isDayFirstLogin = Me:getIsDayFirstLogin()
    if isDayFirstLogin then
      if self.limitMustFishClick then
        return false
      else
        return true
      end
    end
  end
  return false
end

function LimitTimeClientHelper:checkLimitedTimeActivityRedDot(activityType)
  if LimitTimeClientHelper:checkActiveIsOpen(activityType) then
    if activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY then
      self.activityRedInfo[activityType] = self:getMustWinLotteryRedState()
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT then
      local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT)
      if not params then
        return
      end
      local monthCfg = Lib.copy(LimitedTimeMonthGiftConfig:getCfgByRoundActivityId(params.id, params.curRoundId))
      local monthData = Me:getLimitedTimeMonthData()
      local hasFree = false
      for key, val in pairs(monthCfg) do
        if val.finalPrice <= 0 then
          local counts = monthData[val.giftKey] or 0
          if counts < val.limitCounts then
            hasFree = true
          end
        end
      end
      self.activityRedInfo[activityType] = hasFree
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT then
      local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT)
      if not params then
        return
      end
      local weekCfg = Lib.copy(LimitedTimeWeekGiftConfig:getCfgByRoundActivityId(params.id, params.curRoundId))
      local weekData = Me:getLimitedTimeWeekData()
      local hasFree = false
      for key, val in pairs(weekCfg) do
        if val.finalPrice <= 0 then
          local counts = weekData[val.giftKey] or 0
          if counts < val.limitCounts then
            hasFree = true
          end
        end
      end
      self.activityRedInfo[activityType] = hasFree
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT then
      local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT)
      if not params then
        return
      end
      local discountCfg = Lib.copy(LimitedTimeDiscountGiftConfig:getCfgByRoundActivityId(params.id, params.curRoundId))
      local discountData = Me:getLimitedTimeDiscountData()
      local hasFree = false
      for key, val in pairs(discountCfg) do
        if val.finalPrice <= 0 then
          local counts = discountData[val.giftKey] or 0
          if counts < val.limitCounts then
            hasFree = true
          end
        end
      end
      self.activityRedInfo[activityType] = hasFree
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD then
      self.activityRedInfo[activityType] = not Me.haveOpenLimitedTimeCardWnd
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
      local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
      if not params then
        return
      end
      self.activityRedInfo[activityType] = false
      local activityGiftData = HeartWarmingGiftConfig:getCfgByActivityId(params.id)
      local heartWarmReward = Me:getHeartWarmReward()
      local heartWarmIntegral = Me:getHeartWarmIntegral()
      local curIntegral = heartWarmIntegral[params.id] or 0
      for _, val in pairs(activityGiftData) do
        if curIntegral >= val.needPoints then
          local giftKey = val.giftKey
          if not heartWarmReward[giftKey] then
            self.activityRedInfo[activityType] = true
            break
          end
        end
      end
      local heartWarmTask = Me:getHeartWarmTask()[params.id] or {}
      local activityTaskData = HeartWarmingTaskConfig:getCfgByActivityId(params.id)
      for _, val in pairs(activityTaskData) do
        if heartWarmTask[val.taskId] and heartWarmTask[val.taskId].taskState == Define.HEART_WARM_TASK_STATE.FINISH then
          self.activityRedInfo[activityType] = true
          break
        end
      end
    end
  else
    self.activityRedInfo[activityType] = false
  end
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_TAB_RED, activityType, self.activityRedInfo[activityType])
  local haveRed = false
  for _, val in pairs(self.activityRedInfo) do
    if val then
      haveRed = true
    end
  end
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnRedDot(haveRed)
end

LimitTimeClientHelper:init()
