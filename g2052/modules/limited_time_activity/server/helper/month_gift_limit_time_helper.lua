local base = require("server.helper.limited_time_activity_helper")
local MonthLimitTimeHelper = Lib.class("MonthLimitTimeHelper", base)
local LimitedTimeMonthGiftConfig = T(Config, "LimitedTimeMonthGiftConfig")

function MonthLimitTimeHelper:getPassRoundNum(time)
  if not self.params then
    return 0
  end
  local startTime = self.params.startNumTime or Lib.getTimeByArray(self.params.startTime)
  if time < startTime then
    return 0
  end
  local startDate = os.date("*t", startTime)
  local curDate = os.date("*t", time)
  if curDate.year == startDate.year then
    return curDate.month - startDate.month
  else
    return curDate.month + (curDate.year - startDate.year - 1) * 12 + (12 - startDate.month)
  end
end

function MonthLimitTimeHelper:onNotStart()
end

function MonthLimitTimeHelper:onStart()
  local time = os.time()
  self.params.passRound = self:getPassRoundNum(time)
  self.params.totalRoundId = LimitedTimeMonthGiftConfig:getCfgByActivityIdTotalRound(self.params.id)
  self.params.curRoundId = self.params.passRound % self.params.totalRoundId + 1
end

function MonthLimitTimeHelper:onEnd()
end

function MonthLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeMonthData({})
    player:setLimitedTimeMonthKey(0)
  end
end

function MonthLimitTimeHelper:updateRoundKey()
  local time = os.time()
  self.params.passRound = self:getPassRoundNum(time)
  self.params.totalRoundId = LimitedTimeMonthGiftConfig:getCfgByActivityIdTotalRound(self.params.id)
  self.params.curRoundId = self.params.passRound % self.params.totalRoundId + 1
  self:syncActivityInfo()
end

function MonthLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isLimitMonthGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeMonthGiftConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  local monthLimitGiftData = player:getLimitedTimeMonthData()
  local counts = monthLimitGiftData[item.giftKey] or 0
  if counts >= item.limitCounts then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  player.isLimitMonthGiftBuying = true
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addLimitedTimeMonthData(item.giftKey, 1)
    end
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayMonthLimitGiftResult", addition)
    player.isLimitMonthGiftBuying = false
  end)
end

function MonthLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncMonthLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncMonthLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function MonthLimitTimeHelper:onUpdateDayTime()
  if not self.params then
    return
  end
  local passRound = self:getPassRoundNum(os.time())
  if passRound ~= self.params.passRound then
    self:updateRoundKey()
    for _, player in pairs(Game.GetAllPlayers()) do
      player:setLimitedTimeMonthData({})
      player:setLimitedTimeMonthKey(self.params.passRound)
    end
  end
end

function MonthLimitTimeHelper:checkRefreshGiftState(player)
  if not self.params then
    return
  end
  local lastKey = player:getLimitedTimeMonthKey()
  if lastKey ~= self.params.passRound then
    player:setLimitedTimeMonthData({})
    player:setLimitedTimeMonthKey(self.params.passRound)
  end
end

return MonthLimitTimeHelper
