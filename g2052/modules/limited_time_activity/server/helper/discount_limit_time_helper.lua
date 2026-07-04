local base = require("server.helper.limited_time_activity_helper")
local DiscountLimitTimeHelper = Lib.class("DiscountLimitTimeHelper", base)
local LimitedTimeDiscountGiftConfig = T(Config, "LimitedTimeDiscountGiftConfig")

function DiscountLimitTimeHelper:onNotStart()
end

function DiscountLimitTimeHelper:onStart()
end

function DiscountLimitTimeHelper:onEnd()
end

function DiscountLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeDiscountData({})
    player:setLimitedTimeDiscountKey(0)
  end
end

function DiscountLimitTimeHelper:refreshActivityTick(curUpdateCount)
  if curUpdateCount ~= self.params.updateCount then
    self.params.updateCount = curUpdateCount
    self:updateContentStartAndEndTime()
    self:onUpdateActivity()
    self:onUpdateRoundInfo()
    self:syncActivityInfo()
  else
    self:onUpdateRoundInfo(true)
  end
end

function DiscountLimitTimeHelper:onUpdateRoundInfo(needSync)
  if Lib.table_is_empty(self.params) then
    return
  end
  local passTime = os.time() - self.params.contentStartTime
  local newRound = math.floor(passTime / Lib.getDaySeconds()) + 1
  local maxRound = LimitedTimeDiscountGiftConfig:getCfgByActivityIdTotalRound(self.params.id)
  newRound = newRound % maxRound
  if newRound == 0 then
    newRound = maxRound
  end
  if self.params.curRoundId ~= newRound then
    self.params.curRoundId = newRound
    if needSync then
      self:syncActivityInfo()
    end
  end
end

function DiscountLimitTimeHelper:onUpdateActivity()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() then
      self:updateActivityData(player)
    end
  end
end

function DiscountLimitTimeHelper:updateActivityData(player)
  local limitedTimeDiscountKey = player:getLimitedTimeDiscountKey()
  if self.params and self.params.updateCount and limitedTimeDiscountKey ~= self.params.updateCount then
    player:setLimitedTimeDiscountKey(self.params.updateCount)
    player:setLimitedTimeDiscountData({})
  end
end

function DiscountLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    if not tip then
      self:updateActivityData(player)
    end
    player:sendPacket({
      pid = tip or "SyncDiscountLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncDiscountLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  end
end

function DiscountLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isLimitDiscountGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeDiscountGiftConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  local discountLimitGiftData = player:getLimitedTimeDiscountData()
  local counts = discountLimitGiftData[item.giftKey] or 0
  if counts >= item.limitCounts then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  player.isLimitDiscountGiftBuying = true
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addLimitedTimeDiscountData(item.giftKey, 1)
    end
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayDiscountLimitGiftResult", addition)
    player.isLimitDiscountGiftBuying = false
  end)
end

return DiscountLimitTimeHelper
