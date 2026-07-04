local GameTimes = T(Lib, "GameTimes")
local LuaTimer = T(Lib, "LuaTimer")

function GameTimes:Init()
  self.curTimeMin = 0
  self.curTimeHour = World.cfg.initTime or 0
  self.curDay = 1
  self.totalMinutes = self.curDay * 24 * 60 + self.curTimeHour * 60 + self.curTimeMin
  if self.timer then
    LuaTimer:cancel(self.timer)
  end
  self.timer = LuaTimer:schedule(function()
    self:_OnTick()
  end, 0, World.cfg.timeSpeedRate * 1000)
end

function GameTimes:_OnTick()
  self.curTimeMin = self.curTimeMin + 1
  self.totalMinutes = self.totalMinutes + 1
  if self.curTimeMin == 60 then
    self.curTimeMin = 0
    self.curTimeHour = self.curTimeHour + 1
    if self.curTimeHour == 24 then
      self.curTimeHour = 0
      self.curDay = self.curDay + 1
      if self.curDay > 7 then
        self.curDay = 1
      end
    end
    if not World.isClient then
      self:adjustGameTime()
    end
  end
  if World.isClient then
    if Me.model == "MobileEditor" then
      return
    end
  else
    local TimingSoundMgr = T(Lib, "TimingSoundMgr")
    TimingSoundMgr:updateTime(self.curDay, self.curTimeHour, self.curTimeMin)
  end
  World.CurWorld:setWorldTime(self.curTimeHour * 1000 + self.curTimeMin / 60 * 1000)
end

function GameTimes:GetTime()
  local time = {
    day = self.curDay,
    hour = self.curTimeHour,
    min = self.curTimeMin
  }
  if World.isClient and Me.model == "MobileEditor" then
    time.hour = 12
    time.min = 0
  end
  return time
end

function GameTimes:AddMinutes(t, minutes)
  t.min = t.min + minutes
  if t.min < 60 then
    return
  end
  t.hour = t.hour + math.floor(t.min / 60)
  t.min = t.min % 60
  if t.hour < 24 then
    return
  end
  t.day = t.day + math.floor(t.hour / 24)
  t.hour = t.hour % 24
  if t.day < 8 then
    return
  end
  t.day = (t.day - 1) % 7 + 1
end

function GameTimes:GetTotalMinutes()
  return self.totalMinutes
end

function GameTimes:setTime(hour, min)
  self.curTimeHour = hour
  self.curTimeMin = min
  if not World.isClient then
    self:adjustGameTime()
  end
end

function GameTimes:onPlayerLogin(player)
  if not World.isClient then
    self:adjustGameTime()
  end
end

function GameTimes:adjustGameTime(data)
  if World.isClient then
    if data then
      self.curDay = data.curDay or self.curDay
      self.curTimeHour = data.curTimeHour or self.curTimeHour
      self.curTimeMin = data.curTimeMin or self.curTimeMin
    end
  else
    WorldServer.BroadcastPacket({
      pid = "adjustGameTime",
      curDay = self.curDay,
      curTimeHour = self.curTimeHour,
      curTimeMin = self.curTimeMin
    })
    local TimingSoundMgr = T(Lib, "TimingSoundMgr")
    TimingSoundMgr:updateTime({
      day = self.curDay,
      hour = self.curTimeHour,
      min = self.curTimeMin
    })
  end
end

GameTimes:Init()
return GameTimes
