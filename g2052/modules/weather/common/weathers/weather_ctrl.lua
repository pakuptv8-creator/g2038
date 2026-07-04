local WeatherCtrl = T(Lib, "WeatherCtrl")
local LuaTimer = T(Lib, "LuaTimer")
local WeatherConfig = T(Config, "WeatherConfig")
local GameTimes = T(Lib, "GameTimes")
local DramaCommonHelper = T(Lib, "DramaCommonHelper")

function WeatherCtrl:Init()
  local maps = WeatherConfig:getParticipantMaps()
  self.isCanCheckSwitch = {}
  self.coolingBegin = {}
  self.curWeather = {}
  self.curWeatherDuration = {}
  self.tick = {}
  self.lastSwitchTime = {}
  self.coolingBeginTime = {}
  for _, v in pairs(maps) do
    self.isCanCheckSwitch[v] = true
    self.coolingBegin[v] = false
    self.curWeather[v] = Define.Weather.sunny
    self.curWeatherDuration[v] = nil
    self.tick[v] = 0
    self.lastSwitchTime[v] = 0
  end
  if self.timer then
    LuaTimer:cancel(self.timer)
    self.timer = nil
  end
  self.nextWeatherTime = GameTimes:GetTotalMinutes()
  self.randomWeathers = self:genRandomWeathers(1000, maps[1])
  if not Lib.isGameDrama() then
    self:initWeatherTimer(maps)
  else
    Lib.subscribeEvent(Event.EVENT_INIT_DRAMA_TEMPLATE, function()
      print("++++++++++++++++++++++++++++ EVENT_INIT_DRAMA_TEMPLATE ,getStaticWeatherId():", DramaCommonHelper:getStaticWeatherId())
      if not DramaCommonHelper:banWeatherSwitch() then
        self:initWeatherTimer(maps)
      end
      local weatherId = DramaCommonHelper:getStaticWeatherId()
      if weatherId and 0 < weatherId then
        self:switchWeather(weatherId, maps[1])
      end
    end)
  end
end

function WeatherCtrl:initWeatherTimer(maps)
  if self.timer then
    return
  end
  self.timer = LuaTimer:schedule(function()
    for _, v in pairs(maps) do
      self:_OnTick(v)
    end
    self:checkNotice(maps[1])
  end, 0, 1000)
end

local lastCheckNoticeWeather

function WeatherCtrl:checkNotice(mapName)
  local nextWeather = self.randomWeathers[1]
  if self.nextWeatherTime - GameTimes:GetTotalMinutes() <= 60 and lastCheckNoticeWeather ~= nextWeather and 0 < (self.remainCount or 0) then
    lastCheckNoticeWeather = nextWeather
    local cfg = WeatherConfig:getCfgByIdAndMapName(nextWeather, mapName)
    if 0 < cfg.message then
      T(Lib, "MessageNoticeManager"):broadcastNotice(cfg.message)
    end
  end
end

function WeatherCtrl:_OnTick(mapName)
  self.tick[mapName] = self.tick[mapName] + 1
  if self.isCanCheckSwitch and self.isCanCheckSwitch[mapName] then
    self:checkSwitchWeather(mapName)
  end
  self:coolingTick(mapName)
  self:weatherTick(mapName)
end

function WeatherCtrl:coolingTick(mapName)
  if not self.coolingBegin or not self.coolingBegin[mapName] then
    return
  end
  if World.cfg.weatherSwitchCoolingTime * 60 <= self.tick[mapName] - self.coolingBeginTime[mapName] then
    self.isCanCheckSwitch[mapName] = true
    self.coolingBegin[mapName] = false
  end
end

function WeatherCtrl:weatherTick(mapName)
  if self.isCanCheckSwitch and self.isCanCheckSwitch[mapName] then
    return
  end
  if self.coolingBegin and self.coolingBegin[mapName] then
    return
  end
  if self.curWeather and self.curWeather[mapName] and self.curWeather[mapName] == Define.Weather.sunny then
    return
  end
  if not self.curWeatherDuration or not self.curWeatherDuration[mapName] then
    return
  end
  local cfg = WeatherConfig:getCfgByIdAndMapName(self.curWeather[mapName], mapName)
  if not cfg then
    return
  end
  if math.floor(self.curWeatherDuration[mapName] * 60) <= self.tick[mapName] - self.lastSwitchTime[mapName] then
    self:onWeatherTimeEnd(mapName)
  end
end

function WeatherCtrl:onWeatherTimeEnd(mapName)
  self.coolingBegin[mapName] = true
  self.coolingBeginTime[mapName] = self.tick[mapName]
  self:switchWeather(Define.Weather.sunny, mapName)
end

function WeatherCtrl:checkSwitchWeather(mapName)
  local now = GameTimes:GetTotalMinutes()
  if now < (self.nextWeatherTime or 0) then
    return
  end
  if self.coolingBegin and self.coolingBegin[mapName] then
    return
  end
  if self.curWeather and self.curWeather[mapName] ~= Define.Weather.sunny then
    return
  end
  local curTime = GameTimes:GetTime()
  local space = World.cfg.weatherSwitchSpaceTime
  if curTime.min % space ~= 0 then
    return
  end
  local weatherIndex = table.remove(self.randomWeathers, 1)
  if (self.lastChangeWeatherTime or {}).day ~= curTime.day then
    self.remainCount = World.cfg.weatherSetting.dailySwitchCount
  end
  if weatherIndex ~= Define.Weather.sunny and 0 >= self.remainCount then
    return
  end
  self:switchWeather(weatherIndex, mapName)
  self.nextWeatherTime = now + (self.curWeatherDuration[mapName] or 0) * 60 + World.cfg.weatherSwitchCoolingTime * 60
  self.nextWeatherTime = self.nextWeatherTime - self.nextWeatherTime % space + space
  lastCheckNoticeWeather = nil
  if weatherIndex ~= Define.Weather.sunny then
    self.remainCount = self.remainCount - 1
  end
  self.lastChangeWeatherTime = curTime
end

function WeatherCtrl:genRandomWeathers(count, mapName)
  local tbPool = {}
  local tbWeather = WeatherConfig:getCfgByMapName(mapName)
  for index, weatherData in pairs(tbWeather) do
    if weatherData.randomList == 1 then
      local data = {
        index = index,
        weight = weatherData.weight
      }
      table.insert(tbPool, data)
    end
  end
  local ret = {}
  for i = 1, count do
    local weatherIndex = Define.Weather.sunny
    if 0 < #tbPool then
      local randomData = Lib.randomItemByWeight(1, tbPool, false)
      if randomData and 0 < #randomData then
        weatherIndex = randomData[1].index
      end
    end
    table.insert(ret, weatherIndex)
  end
  return ret
end

function WeatherCtrl:switchWeather(index, mapName)
  print("weather:switchWeather", index, mapName)
  local now = GameTimes:GetTotalMinutes()
  self.lastSwitchTimeInMinutes = self.lastSwitchTimeInMinutes or now
  if self.curWeather[mapName] ~= index then
    self.lastSwitchTimeInMinutes = now
  end
  self.curWeather[mapName] = index
  self.curWeatherDuration[mapName] = nil
  if self.curWeather[mapName] ~= Define.Weather.sunny then
    self.lastSwitchTime[mapName] = self.tick[mapName]
    self.isCanCheckSwitch[mapName] = false
    local cfg = WeatherConfig:getCfgByIdAndMapName(index, mapName)
    if cfg then
      local min = cfg.duration[1] or 0
      local max = cfg.duration[2] or 0
      self.curWeatherDuration[mapName] = math.random(min * 10000, max * 10000) / 10000
      if now + self.curWeatherDuration[mapName] * 60 - self.lastSwitchTimeInMinutes > World.cfg.weatherSetting.mustSwitchTime then
        self.curWeatherDuration[mapName] = (World.cfg.weatherSetting.mustSwitchTime + self.lastSwitchTimeInMinutes - now) / 60
      end
    else
      self.curWeather[mapName] = Define.Weather.sunny
    end
  else
    self.isCanCheckSwitch[mapName] = true
  end
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and player:isValid() and player.map.name == mapName then
      player:sendPacket({
        pid = "switchWeather",
        weatherIndex = index,
        mapName = mapName,
        duration = (self.curWeatherDuration[mapName] or 0) * 60
      })
    end
  end
  
  local function cancelTornadoCreateTimers()
    self.bigTornadoCreateTimers = self.bigTornadoCreateTimers or {}
    for _, id in ipairs(self.bigTornadoCreateTimers) do
      LuaTimer:cancel(id)
    end
    self.bigTornadoCreateTimers = {}
  end
  
  for _, id in ipairs(World.cfg.weatherSetting.smallTornadoIds or {}) do
    local node = Instance.getByInstanceId(id)
    if node then
      node.isVisible = index == Define.Weather.sand
    end
  end
  if index ~= Define.Weather.sand then
    cancelTornadoCreateTimers()
    for id in pairs(World.cfg.weatherSetting.bigTornado or {}) do
      local node = Instance.getByInstanceId(id)
      if node then
        node.isVisible = false
      end
    end
  end
  if index == Define.Weather.sand then
    cancelTornadoCreateTimers()
    for id, tb in pairs(World.cfg.weatherSetting.bigTornado) do
      local timerId = LuaTimer:schedule(function()
        for _, player in pairs(Game.GetAllPlayers()) do
          if player and player:isValid() and player.map.name == mapName then
            player:sendPacket({
              pid = "weatherBigTornadoCreated",
              id = id
            })
          end
        end
      end, 0, tb.createInterval * 1000)
      table.insert(self.bigTornadoCreateTimers, timerId)
    end
  end
end

function WeatherCtrl:sendWeatherInfo(player)
  if player and player:isValid() then
    local mapName = player.map.name or "map001"
    local weatherIndex = self.curWeather[mapName] or Define.Weather.sunny
    player:sendPacket({
      pid = "switchWeather",
      weatherIndex = weatherIndex,
      mapName = mapName,
      duration = (self.curWeatherDuration[mapName] or 0) * 60
    })
  end
end

function WeatherCtrl:SwitchByPlayer(player, index)
  local mapName = "map001"
  self:switchWeather(index, mapName)
  local cfg = WeatherConfig:getCfgByIdAndMapName(index, mapName)
  if cfg.playerMsg > 0 then
    T(Lib, "MessageNoticeManager"):broadcastNotice(cfg.playerMsg, player.name)
  end
end

WeatherCtrl:Init()
return WeatherCtrl
