local LimitedTimeActivityHelper = Lib.class("LimitedTimeActivityHelper")
local LimitedTimeRoundsConfig = T(Config, "LimitedTimeRoundsConfig")

function LimitedTimeActivityHelper:ctor()
  self:init()
end

function LimitedTimeActivityHelper:init()
  self.params = {}
  self.status = nil
end

function LimitedTimeActivityHelper:onOperate(status, params)
  self.params = params
  self.status = status
  if status == Define.LIMITED_TIME_ACTIVITY_STATUS.NOT_START then
    self:onNotStart()
  elseif status == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
    self:startCheckResetActivityData()
    self:onStart()
  elseif status == Define.LIMITED_TIME_ACTIVITY_STATUS.END then
    self:onEnd()
  end
  self:syncActivityInfo()
end

function LimitedTimeActivityHelper:startCheckResetActivityData()
  local cfg = LimitedTimeRoundsConfig:getCfgByActivityId(self.params.id)
  if cfg and not cfg.notResetData and self.params.startNumTime then
    for _, player in pairs(Game.GetAllPlayers()) do
      self:resetRoundActivityData(player)
    end
  end
end

function LimitedTimeActivityHelper:loginCheckResetActivityData(player)
  if player and player:isValid() and self.status == Define.LIMITED_TIME_ACTIVITY_STATUS.START then
    local cfg = LimitedTimeRoundsConfig:getCfgByActivityId(self.params.id)
    if cfg and not cfg.notResetData and self.params.startNumTime then
      self:resetRoundActivityData(player)
    end
  end
end

function LimitedTimeActivityHelper:resetPlayerActivityData(player)
end

function LimitedTimeActivityHelper:resetRoundActivityData(player)
  if player and player:isValid() then
    local roundsTimes = player:getLimitedTimeRoundsTimes()
    if self.params.id and self.params.startNumTime and roundsTimes[self.params.id] ~= self.params.startNumTime then
      self:resetPlayerActivityData(player)
      roundsTimes[self.params.id] = self.params.startNumTime
      player:setLimitedTimeRoundsTimes(roundsTimes)
    end
  end
end

function LimitedTimeActivityHelper:getStatus()
  return self.status
end

function LimitedTimeActivityHelper:onNotStart()
end

function LimitedTimeActivityHelper:onStart()
end

function LimitedTimeActivityHelper:onEnd()
end

function LimitedTimeActivityHelper:syncActivityInfo(player)
end

function LimitedTimeActivityHelper:playActivity(player, params)
end

function LimitedTimeActivityHelper:refreshActivityTick(curUpdateCount)
  if curUpdateCount ~= self.params.updateCount then
    self.params.updateCount = curUpdateCount
    self:updateContentStartAndEndTime()
    self:onUpdateActivity()
    self:syncActivityInfo()
  end
end

function LimitedTimeActivityHelper:updateContentStartAndEndTime()
  if Lib.table_is_empty(self.params) then
    return
  end
  local startTime = self.params.startNumTime or Lib.getTimeByArray(self.params.startTime)
  local updateTime = Lib.getSecondsByArray(self.params.updateTime)
  local endTime = self.params.endNumTime or Lib.getTimeByArray(self.params.endTime)
  self.params.contentStartTime = startTime + updateTime * self.params.updateCount
  local contentEndTime = self.params.contentStartTime + updateTime
  if endTime <= contentEndTime then
    self.params.contentEndTime = endTime
  else
    self.params.contentEndTime = contentEndTime
  end
end

function LimitedTimeActivityHelper:onUpdateActivity()
end

function LimitedTimeActivityHelper:onUpdateDayTime()
end

function LimitedTimeActivityHelper:destroy()
  self:onDestroy()
end

function LimitedTimeActivityHelper:onDestroy()
end

return LimitedTimeActivityHelper
