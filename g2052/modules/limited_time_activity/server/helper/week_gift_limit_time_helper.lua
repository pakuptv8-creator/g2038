local base = require("server.helper.limited_time_activity_helper")
local WeekLimitTimeHelper = Lib.class("WeekLimitTimeHelper", base)
local LimitedTimeWeekGiftConfig = T(Config, "LimitedTimeWeekGiftConfig")

function WeekLimitTimeHelper:getPassRoundNum(time)
  if not self.params then
    return 0
  end
  local startTime = self.params.startNumTime or Lib.getTimeByArray(self.params.startTime)
  local startWeekTime = Lib.getActivityWeekStartTime(startTime)
  local updateTime = 604800
  return math.floor((time - startWeekTime) / updateTime)
end

function WeekLimitTimeHelper:onNotStart()
end

function WeekLimitTimeHelper:onStart()
  local time = os.time()
  self.params.passRound = self:getPassRoundNum(time)
  self.params.totalRoundId = LimitedTimeWeekGiftConfig:getCfgByActivityIdTotalRound(self.params.id)
  self.params.curRoundId = self.params.passRound % self.params.totalRoundId + 1
end

function WeekLimitTimeHelper:onEnd()
end

function WeekLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeWeekData({})
    player:setLimitedTimeWeekKey(0)
  end
end

function WeekLimitTimeHelper:updateRoundKey()
  local time = os.time()
  self.params.passRound = self:getPassRoundNum(time)
  self.params.totalRoundId = LimitedTimeWeekGiftConfig:getCfgByActivityIdTotalRound(self.params.id)
  self.params.curRoundId = self.params.passRound % self.params.totalRoundId + 1
  self:syncActivityInfo()
end

function WeekLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isLimitWeekGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeWeekGiftConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  local weekLimitGiftData = player:getLimitedTimeWeekData()
  local counts = weekLimitGiftData[item.giftKey] or 0
  if counts >= item.limitCounts then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  player.isLimitWeekGiftBuying = true
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addLimitedTimeWeekData(item.giftKey, 1)
    end
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayWeekLimitGiftResult", addition)
    player.isLimitWeekGiftBuying = false
  end)
end

function WeekLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncWeekLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncWeekLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function WeekLimitTimeHelper:onUpdateDayTime()
  if not self.params then
    return
  end
  local passRound = self:getPassRoundNum(os.time())
  if passRound ~= self.params.passRound then
    self:updateRoundKey()
    for _, player in pairs(Game.GetAllPlayers()) do
      player:setLimitedTimeWeekData({})
      player:setLimitedTimeWeekKey(self.params.passRound)
    end
  end
end

function WeekLimitTimeHelper:checkRefreshGiftState(player)
  if not self.params then
    return
  end
  local lastKey = player:getLimitedTimeWeekKey()
  if lastKey ~= self.params.passRound then
    player:setLimitedTimeWeekData({})
    player:setLimitedTimeWeekKey(self.params.passRound)
  end
end

return WeekLimitTimeHelper
