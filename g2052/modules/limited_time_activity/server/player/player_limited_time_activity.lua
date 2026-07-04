local MustWinLotteryConfig = T(Config, "MustWinLotteryConfig")
local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local LimitedTimeDrawConfig = T(Config, "LimitedTimeDrawConfig")
local LimitedTimeDrawAwardsConfig = T(Config, "LimitedTimeDrawAwardsConfig")
local LimitedTimeCardConfig = T(Config, "LimitedTimeCardConfig")
local LimitedTimeGoldWheelAwardsConfig = T(Config, "LimitedTimeGoldWheelAwardsConfig")
local LimitedTimeGoldWheelConfig = T(Config, "LimitedTimeGoldWheelConfig")
local Player = _ENV.Player

local function getMustWinLotteryAwards(mustWinLotteryData, params, awards, range)
  local pool = {}
  local items = {}
  for _, award in pairs(awards) do
    local isNeed = true
    for _, awardId in pairs(mustWinLotteryData[params.id]) do
      if award.id == awardId then
        isNeed = false
        break
      end
    end
    if isNeed then
      table.insert(items, award)
    end
  end
  if 0 < #range then
    for _, item in pairs(items) do
      for _, awardId in pairs(range) do
        if item.id == awardId then
          table.insert(pool, item)
          break
        end
      end
    end
  end
  if #pool == 0 then
    pool = items
  end
  return pool
end

function Player:onMustWinLottery(activityId, params, callback)
  local mustWinLotteryData = self:getMustWinLotteryData()
  if not mustWinLotteryData[params.id] then
    mustWinLotteryData[params.id] = {}
  end
  local completeNumber = #mustWinLotteryData[params.id]
  local newCounts = completeNumber + 1
  local info = MustWinLotteryConfig:getCfgByCount(newCounts)
  if not info then
    if callback then
      callback(false)
    end
    return
  end
  local range = info.range
  local awards = MustWinLotteryAwardConfig:getCfgByActivityIdAndCounts(activityId, newCounts)
  local pool = getMustWinLotteryAwards(mustWinLotteryData, params, awards, range)
  local itemInfo = Lib.randomItemByWeight(1, pool, false) or {}
  local item = itemInfo[1] and Lib.copy(itemInfo[1])
  item.price = info.price
  item.activityId = params.id
  LimitedTimeActivityGameMgr:operationBuy(self, item, function(isSucceed, item)
    if isSucceed then
      local curMustWinLotteryData = self:getMustWinLotteryData()
      if not curMustWinLotteryData[item.activityId] then
        curMustWinLotteryData[item.activityId] = {}
      end
      table.insert(curMustWinLotteryData[item.activityId], item.id)
      self:setMustWinLotteryData(curMustWinLotteryData)
      if item.price <= 0 then
        local reportData = {limit_activityId = activityId}
        Plugins.CallTargetPluginFunc("report", "report", "fish_event_freedraw", reportData, self)
      else
        local reportData = {limit_activityId = activityId, draw_count = newCounts}
        Plugins.CallTargetPluginFunc("report", "report", "fish_event_buy", reportData, self)
      end
    end
    if callback then
      callback(isSucceed, item)
    end
  end)
end

local function getLimitedTimeDrawAward(pondId, alreadyUsedCount, guaranteeCount, luckyDrawType)
  local awards = {}
  local count = luckyDrawType == Define.LUCKY_DRAW_TYPE.SINGLE and 1 or 10
  local pond = LimitedTimeDrawAwardsConfig:getCfgByPondId(pondId)
  local userCount = alreadyUsedCount
  for i = 1, count do
    local curCount = userCount + 1
    if guaranteeCount < curCount then
      curCount = curCount - guaranteeCount
    end
    local infallibleInfo = LimitedTimeDrawAwardsConfig:getPondInfallibleByPondIdAndCount(pondId, curCount)
    local item
    if infallibleInfo then
      item = Lib.randomItemByWeight(1, infallibleInfo, false) or {}
    else
      item = Lib.randomItemByWeight(1, pond, false) or {}
    end
    local giftContent
    if item[1] then
      curCount = item[1].isBigPrize and 0 or curCount
      giftContent = item[1].giftContent
    end
    for _, v in pairs(giftContent or {}) do
      table.insert(awards, v)
    end
    userCount = curCount
  end
  return awards, userCount
end

function Player:onLimitedTimeDraw(params, buyInfo, callback)
  local LimitedTimeDrawData = self:getLimitedTimeDrawData()
  if not LimitedTimeDrawData[params.contentStartTime] then
    if callback then
      callback(false)
    end
    return
  end
  local alreadyUsedCount = LimitedTimeDrawData[params.contentStartTime]
  local item = {}
  item.luckyDrawType = buyInfo.type or Define.LUCKY_DRAW_TYPE.SINGLE
  local cfg = LimitedTimeDrawConfig:getCfgById(params.cfgId)
  if not cfg then
    if callback then
      callback(false)
    end
    return
  end
  local needRecordPurchase = false
  local purchaseData = self:getFirstPurchaseData()
  if item.luckyDrawType == Define.LUCKY_DRAW_TYPE.SINGLE then
    if purchaseData[cfg.pondId] then
      needRecordPurchase = os.time() - purchaseData[cfg.pondId] > 86400
    else
      needRecordPurchase = true
    end
    item.price = needRecordPurchase and cfg.dailyDeals or cfg.singlePrice
  elseif item.luckyDrawType == Define.LUCKY_DRAW_TYPE.TEN then
    item.price = cfg.tenPrice
  else
    if callback then
      callback(false)
    end
    return
  end
  item.id = cfg.pondId
  item.activityId = cfg.activityId
  item.type = Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW
  item.giftContent, alreadyUsedCount = getLimitedTimeDrawAward(cfg.pondId, alreadyUsedCount, cfg.guaranteeCount, item.luckyDrawType)
  LimitedTimeActivityGameMgr:operationBuy(self, item, function(isSucceed, item)
    if isSucceed then
      local curLimitedTimeDrawData = self:getLimitedTimeDrawData()
      if curLimitedTimeDrawData[params.contentStartTime] then
        curLimitedTimeDrawData[params.contentStartTime] = alreadyUsedCount
        self:setLimitedTimeDrawData(curLimitedTimeDrawData)
      end
      if needRecordPurchase then
        local curPurchaseData = self:getFirstPurchaseData()
        curPurchaseData[item.id] = os.time()
        self:setFirstPurchaseData(curPurchaseData)
      end
    end
    if callback then
      callback(isSucceed, item)
    end
  end)
end

function Player:rechargeLimitedTimeCard(params, buyInfo, callback)
  local type = buyInfo.type
  local cfg = LimitedTimeCardConfig:getCfgByActivityIdAndType(params.id, type)
  if not cfg then
    if callback then
      callback(false)
    end
    return
  end
  local awardCount = cfg.awardCount
  local LimitedTimeCardData = self:getLimitedTimeCardData()
  if LimitedTimeCardData[cfg.id] then
    if callback then
      callback(false)
    end
    return
  end
  local item = {}
  item.type = params.type
  item.activityId = params.id
  item.id = cfg.id
  item.giftContent = {}
  item.price = cfg.price
  LimitedTimeActivityGameMgr:operationBuy(self, item, function(isSucceed, item)
    if isSucceed then
      local curLimitedTimeCardData = self:getLimitedTimeCardData()
      if not curLimitedTimeCardData[item.id] then
        curLimitedTimeCardData[item.id] = {count = awardCount}
      end
      self:setLimitedTimeCardData(curLimitedTimeCardData)
    end
    if callback then
      callback(isSucceed, item)
    end
  end)
end

function Player:grantLimitedTimeCardAward()
  local limitedTimeCardData = self:getLimitedTimeCardData()
  for id, data in pairs(limitedTimeCardData) do
    local cfg = LimitedTimeCardConfig:getCfgById(id)
    if cfg then
      local needGrantNum = 1
      if data.timeNow then
        needGrantNum = Lib.getDifferDayNum(data.timeNow, os.time())
      end
      if 0 < needGrantNum then
        local curLimitedTimeCardData = self:getLimitedTimeCardData()
        local count = data.count - needGrantNum
        local needCount = 1
        if 0 < count then
          curLimitedTimeCardData[id] = {
            timeNow = os.time(),
            count = count
          }
          needCount = needGrantNum
        else
          needCount = data.count
          curLimitedTimeCardData[id] = nil
        end
        local isSucceed = LimitedTimeActivityGameMgr:onPlayerGetReward(self, {
          giftContent = cfg.giftContent,
          giftNum = needCount,
          cardType = cfg.type
        })
        if isSucceed then
          self:setLimitedTimeCardData(curLimitedTimeCardData)
        end
      end
    end
  end
end

function Player:onLimitedTimeGoldWheel(params, callback)
  local cfg = LimitedTimeGoldWheelConfig:getCfgByActivityId(params.id)
  if not cfg or not cfg[1] then
    if callback then
      callback(false)
    end
    return
  end
  local info = cfg[1]
  local pond = LimitedTimeGoldWheelAwardsConfig:getCfgByPondId(info.pondId)
  if not pond then
    if callback then
      callback(false)
    end
    return
  end
  local needRecordPurchase = false
  local purchaseData = self:getFirstPurchaseData()
  if purchaseData[info.pondId] then
    needRecordPurchase = os.time() - purchaseData[info.pondId] > 86400
  else
    needRecordPurchase = true
  end
  local item = {}
  item.price = needRecordPurchase and info.dailyDeals or info.price
  item.id = info.pondId
  item.activityId = info.activityId
  local award = Lib.randomItemByWeight(1, pond, false) or {}
  item.giftContent = award[1] and award[1].giftContent or {}
  item.sortId = award[1].sortId
  LimitedTimeActivityGameMgr:operationBuy(self, item, function(isSucceed, item)
    if isSucceed and needRecordPurchase then
      local curPurchaseData = self:getFirstPurchaseData()
      curPurchaseData[item.id] = os.time()
      self:setFirstPurchaseData(curPurchaseData)
    end
    if callback then
      callback(isSucceed, item)
    end
  end)
end
