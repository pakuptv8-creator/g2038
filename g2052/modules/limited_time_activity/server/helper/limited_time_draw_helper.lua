local base = require("server.helper.limited_time_activity_helper")
local LimitedTimeDrawHelper = Lib.class("LimitedTimeDrawHelper", base)
local LimitedTimeDrawConfig = T(Config, "LimitedTimeDrawConfig")

function LimitedTimeDrawHelper:onNotStart()
end

function LimitedTimeDrawHelper:onStart()
end

function LimitedTimeDrawHelper:onEnd()
end

function LimitedTimeDrawHelper:resetPlayerActivityData(player)
  if player and player:isValid() then
    player:setLimitedTimeDrawData({})
  end
end

function LimitedTimeDrawHelper:playActivity(player, params, buyInfo)
  if player.inPlayLimitedTimeDraw then
    return
  end
  player.inPlayLimitedTimeDraw = true
  player:onLimitedTimeDraw(Lib.copy(self.params), buyInfo, function(isSucceed, item)
    local addition = {isSucceed = isSucceed, item = item}
    self:syncActivityInfo(player, "SyncPlayLimitedTimeDrawResult", addition)
    player.inPlayLimitedTimeDraw = false
  end)
end

function LimitedTimeDrawHelper:syncActivityInfo(player, tip, addition)
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
      pid = tip or "SyncLimitedTimeDrawActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  else
    WorldServer.BroadcastPacket({
      pid = tip or "SyncLimitedTimeDrawActivity",
      params = self.params,
      status = self.status,
      addition = addition,
      serverTime = os.time()
    })
  end
end

function LimitedTimeDrawHelper:onUpdateActivity()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() then
      self:updateActivityData(player)
    end
  end
  self.params.cfgId = nil
  local sameActivityInfo = LimitedTimeDrawConfig:getSameActivityCfgByActivityId(self.params.id)
  if sameActivityInfo and 0 < #sameActivityInfo then
    local surplus = self.params.updateCount % #sameActivityInfo
    for _, v in pairs(sameActivityInfo) do
      if v.sequence == surplus + 1 then
        self.params.cfgId = v.id
        break
      end
    end
  end
end

function LimitedTimeDrawHelper:updateActivityData(player)
  local limitedTimeDrawData = player:getLimitedTimeDrawData()
  if Lib.table_is_empty(limitedTimeDrawData) then
    limitedTimeDrawData[self.params.contentStartTime] = 0
    player:setLimitedTimeDrawData(limitedTimeDrawData)
  elseif not limitedTimeDrawData[self.params.contentStartTime] then
    limitedTimeDrawData = {}
    limitedTimeDrawData[self.params.contentStartTime] = 0
    player:setLimitedTimeDrawData(limitedTimeDrawData)
  end
end

return LimitedTimeDrawHelper
