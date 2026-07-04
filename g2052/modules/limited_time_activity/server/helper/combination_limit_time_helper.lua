local base = require("server.helper.limited_time_activity_helper")
local CombinationLimitTimeHelper = Lib.class("CombinationLimitTimeHelper", base)
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")

function CombinationLimitTimeHelper:onNotStart()
end

function CombinationLimitTimeHelper:onStart()
end

function CombinationLimitTimeHelper:onEnd()
end

function CombinationLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setCombinedGiftData({})
  end
end

function CombinationLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncCombinationLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncCombinationLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function CombinationLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isCombinationGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeGiftCombinedConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  local combinedGiftData = player:getCombinedGiftData()
  if combinedGiftData[item.giftKey] then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  player.isCombinationGiftBuying = true
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addCombinedGiftData(item.giftKey)
      local addition = {isSucceed = isSucceed, item = item}
      self:syncActivityInfo(player, "SyncCombinationLimitTimeResult", addition)
    else
      LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    end
    player.isCombinationGiftBuying = false
  end)
end

return CombinationLimitTimeHelper
