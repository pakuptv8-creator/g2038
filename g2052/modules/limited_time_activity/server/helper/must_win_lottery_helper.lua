local base = require("server.helper.limited_time_activity_helper")
local MustWinLotteryHelper = Lib.class("MustWinLotteryHelper", base)

function MustWinLotteryHelper:onNotStart()
end

function MustWinLotteryHelper:onStart()
end

function MustWinLotteryHelper:onEnd()
end

function MustWinLotteryHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    local mustWinLotteryData = player:getMustWinLotteryData()
    mustWinLotteryData[self.params.id] = nil
    player:setMustWinLotteryData(mustWinLotteryData)
    player:setMustRoundFirstLogin(true)
  end
end

function MustWinLotteryHelper:playActivity(player, params)
  if player.inPlayMustWinLottery then
    return
  end
  player.inPlayMustWinLottery = true
  player:onMustWinLottery(self.params.id, params, function(isSucceed, item)
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayMustWinLotteryResult", addition)
    player.inPlayMustWinLottery = false
  end)
end

function MustWinLotteryHelper:syncActivityInfo(player, tip, addition)
  if not self.status then
    return
  end
  if player then
    if not player:isValid() then
      return
    end
    player:sendPacket({
      pid = tip or "SyncMustWinLotteryActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncMustWinLotteryActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

return MustWinLotteryHelper
