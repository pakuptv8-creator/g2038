local base = require("server.helper.limited_time_activity_helper")
local OptionalLimitTimeHelper = Lib.class("OptionalLimitTimeHelper", base)
local LimitedTimeOptionalGiftConfig = T(Config, "LimitedTimeOptionalGiftConfig")

function OptionalLimitTimeHelper:onNotStart()
end

function OptionalLimitTimeHelper:onStart()
end

function OptionalLimitTimeHelper:onEnd()
end

function OptionalLimitTimeHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeOptionalData({})
    player:setLimitedTimeOptionalBuy({})
  end
end

function OptionalLimitTimeHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncOptionalLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncOptionalLimitTimeActivity",
      params = self.params,
      status = self.status,
      addition = addition
    })
  end
end

function OptionalLimitTimeHelper:playActivity(player, params, buyInfo)
  if player.isLimitOptionalGiftBuying then
    return
  end
  local item = Lib.copy(LimitedTimeOptionalGiftConfig:getCfgById(buyInfo.id))
  item.price = item.finalPrice
  local optionalData = player:getLimitedTimeOptionalData()
  local optionalBuy = player:getLimitedTimeOptionalBuy()
  if optionalBuy[item.giftKey] and item.limitCounts > 0 and optionalBuy[item.giftKey] >= item.limitCounts then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  if optionalBuy[item.giftKey] and 0 < item.limitDayNum and optionalBuy[item.giftKey] >= item.limitDayNum then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  if optionalData[item.giftKey] and #optionalData[item.giftKey] > item.optionalNum then
    LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
    return
  end
  if item.isBigAward == 1 then
    local count = 0
    local optionalCfg = LimitedTimeOptionalGiftConfig:getCfgByActivityId(self.params.id)
    for key, val in pairs(optionalCfg.normalList) do
      if val.limitCounts > 0 and optionalBuy[val.giftKey] then
        count = count + optionalBuy[val.giftKey]
      end
    end
    if count < item.bigLimit then
      LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, false)
      return
    end
  end
  player.isLimitOptionalGiftBuying = true
  for key, val in pairs(optionalData[item.giftKey] or {}) do
    table.insert(item.giftContent, val)
  end
  LimitedTimeActivityGameMgr:operationBuy(player, item, function(isSucceed, item)
    if isSucceed then
      player:addLimitedTimeOptionalBuy(item.giftKey, 1)
    end
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayOptionalLimitGiftResult", addition)
    player.isLimitOptionalGiftBuying = false
  end)
end

function OptionalLimitTimeHelper:onUpdateDayTime()
  if self.curTime then
    local isSameDay = Lib.isSameDay(self.curTime, os.time())
    if not isSameDay then
      self:onUpdateActivity()
      self.curTime = os.time()
    end
  else
    self.curTime = os.time()
  end
end

function OptionalLimitTimeHelper:onUpdateActivity()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() then
      self:resetPlayerOptionalDayInfo(player)
      local curTime = Lib.getDayStartTime(os.time())
      player:setLimitedLastLoginTime(curTime)
    end
  end
end

function OptionalLimitTimeHelper:resetPlayerOptionalDayInfo(player)
  local optionalData = player:getLimitedTimeOptionalData()
  local optionalBuy = player:getLimitedTimeOptionalBuy()
  local optionalCfg = LimitedTimeOptionalGiftConfig:getCfgByActivityId(self.params.id)
  for key, val in pairs(optionalCfg.normalList) do
    if val.limitDayNum > 0 then
      optionalData[val.giftKey] = {}
      optionalBuy[val.giftKey] = 0
    end
  end
  if optionalCfg.bigAward and 0 < optionalCfg.bigAward.limitDayNum then
    optionalData[optionalCfg.bigAward.giftKey] = {}
    optionalBuy[optionalCfg.bigAward.giftKey] = 0
  end
  player:setLimitedTimeOptionalData(optionalData)
  player:setLimitedTimeOptionalBuy(optionalBuy)
end

return OptionalLimitTimeHelper
