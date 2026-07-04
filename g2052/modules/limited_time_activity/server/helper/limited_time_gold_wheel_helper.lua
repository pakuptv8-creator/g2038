local base = require("server.helper.limited_time_activity_helper")
local LimitedTimeGoldWheelHelper = Lib.class("LimitedTimeGoldWheelHelper", base)

function LimitedTimeGoldWheelHelper:onNotStart()
end

function LimitedTimeGoldWheelHelper:onStart()
end

function LimitedTimeGoldWheelHelper:onEnd()
end

function LimitedTimeGoldWheelHelper:playActivity(player, params, buyInfo)
  if player.inPlayLimitedTimeGoldWheel then
    return
  end
  player.inPlayLimitedTimeGoldWheel = true
  player:onLimitedTimeGoldWheel(self.params, function(isSucceed, item)
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayLimitedTimeGoldWheelResult", addition)
    player.inPlayLimitedTimeGoldWheel = false
  end)
end

function LimitedTimeGoldWheelHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncLimitedTimeGoldWheelActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncLimitedTimeGoldWheelActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

return LimitedTimeGoldWheelHelper
