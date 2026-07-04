local base = require("server.helper.limited_time_activity_helper")
local LimitedTimeCardHelper = Lib.class("LimitedTimeCardHelper", base)

function LimitedTimeCardHelper:onNotStart()
end

function LimitedTimeCardHelper:onStart()
end

function LimitedTimeCardHelper:onEnd()
end

function LimitedTimeCardHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeCardData({})
  end
end

function LimitedTimeCardHelper:playActivity(player, params, buyInfo)
  if player.inPayWeekMonthCard then
    return
  end
  player.inPayWeekMonthCard = true
  player:rechargeLimitedTimeCard(params, buyInfo, function(isSucceed, item)
    if isSucceed then
      player:grantLimitedTimeCardAward()
    end
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayLimitedTimeCardResult", addition)
    player.inPayWeekMonthCard = false
  end)
end

function LimitedTimeCardHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncLimitedTimeCardActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncLimitedTimeCardActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function LimitedTimeCardHelper:onUpdateDayTime()
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

function LimitedTimeCardHelper:onUpdateActivity()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() then
      player:grantLimitedTimeCardAward()
    end
  end
end

return LimitedTimeCardHelper
