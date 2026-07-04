local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")

function HalloweenHelperCommon:init()
  self:_initHalloweenDay()
  if not World.isClient and self:isHalloweenDay() then
    self.lastCheckResetCandyDayCountStamp = 0
    World.Timer(20, function()
      self:checkHalloweenIsEnd()
      self:checkResetCandyDayCount()
      return self:isHalloweenDay()
    end)
  end
end

function HalloweenHelperCommon:checkResetCandyDayCount()
  local date = os.date("*t")
  if date.hour == 0 and date.min == 0 then
    local time = os.time()
    if time - self.lastCheckResetCandyDayCountStamp >= 86400 then
      print("*****************  checkResetCandyDayCount ", date.year, date.month, date.day, date.sec, self.lastCheckResetCandyDayCountStamp)
      self.lastCheckResetCandyDayCountStamp = time
      local allPlayer = Game.GetAllPlayers()
      for _, player in pairs(allPlayer) do
        if player and player:isValid() then
          player:clearCandyDayCountAll()
          player:cleanHalloweenCandyDayPlayer()
        end
      end
    end
  end
end

function HalloweenHelperCommon:checkHalloweenIsEnd()
  local curTime = os.time(os.date("*t"))
  local endTime = os.time(self.halloweenEndDate)
  if curTime > endTime then
    self.halloweenOpen = false
    Lib.emitEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, self.halloweenOpen)
    local packet = {
      pid = "setHalloweenDayS2C",
      isOpen = self.halloweenOpen
    }
    local players = Game.GetAllPlayers()
    for _, player in pairs(players) do
      if player and player:isValid() then
        player:sendPacket(packet)
      end
    end
  end
end

function HalloweenHelperCommon:_initHalloweenDay()
  if not World.isClient then
    self.halloweenBeginDate, self.halloweenEndDate = self:_getConfigHalloweenDate()
    if self.halloweenBeginDate and self.halloweenEndDate then
      local curTime = os.time(os.date("*t"))
      local beginTime = os.time(self.halloweenBeginDate)
      local endTime = os.time(self.halloweenEndDate)
      self.halloweenOpen = curTime >= beginTime and curTime <= endTime
    else
      self.halloweenOpen = false
    end
    Lib.emitEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, self.halloweenOpen)
    print("---------------------------- HalloweenHelperCommon:_initHalloweenDay ", self.halloweenOpen)
  end
end

function HalloweenHelperCommon:setHalloweenDay(value)
  if World.isClient then
    self.halloweenOpen = value
    Lib.emitEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, self.halloweenOpen)
  end
end

function HalloweenHelperCommon:_getConfigHalloweenDate()
  local beginDateStr = World.cfg.halloweenSetting.halloweenBeginDate
  local endDateStr = World.cfg.halloweenSetting.halloweenEndDate
  if beginDateStr and endDateStr then
    local function getDate(dateStr)
      local dateArray = Lib.splitString(dateStr, ".")
      
      local year = tonumber(dateArray[1])
      local month = tonumber(dateArray[2])
      local day = tonumber(dateArray[3])
      if year and month and day then
        return {
          year = year,
          month = month,
          day = day,
          hour = 0
        }
      end
      return nil
    end
    
    local beginDate = getDate(beginDateStr)
    local endDate = getDate(endDateStr)
    return beginDate, endDate
  end
  return nil, nil
end

function HalloweenHelperCommon:isHalloweenDay()
  return self.halloweenOpen
end

HalloweenHelperCommon:init()
