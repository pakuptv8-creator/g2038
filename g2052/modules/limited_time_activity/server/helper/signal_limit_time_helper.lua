local base = require("server.helper.limited_time_activity_helper")
local SignalLimitTimeHelper = Lib.class("SignalLimitTimeHelper", base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")

function SignalLimitTimeHelper:onNotStart()
end

function SignalLimitTimeHelper:onStart()
end

function SignalLimitTimeHelper:onEnd()
end

function SignalLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setSignalLimitGiftData({})
  end
end

function SignalLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncSignalLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncSignalLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function SignalLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isSignalGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeGiftSignalConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  if item.limitCounts > 0 then
    local signalLimitGiftData = player:getSignalLimitGiftData()
    local boughtNum = 0
    if signalLimitGiftData[item.giftKey] == true then
      boughtNum = 1
    else
      boughtNum = signalLimitGiftData[item.giftKey] or 0
    end
    if boughtNum >= item.limitCounts then
      LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
      return
    end
  end
  player.isSignalGiftBuying = true
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addSignalLimitGiftData(item.giftKey, 1)
      local addition = {isSucceed = isSucceed, item = item}
      self:syncActivityInfo(player, "SyncSignalLimitTimeResult", addition)
    else
      LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    end
    player.isSignalGiftBuying = false
  end)
end

return SignalLimitTimeHelper
