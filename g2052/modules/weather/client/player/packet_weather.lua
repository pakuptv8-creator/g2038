local WeatherConfig = T(Config, "WeatherConfig")
local WeatherMgr = T(Lib, "WeatherMgr")
local TimeLight = T(Lib, "TimeLight")
local LuaTimer = T(Lib, "LuaTimer")
local handles = T(Player, "PackageHandlers")

local function showParts(show, ids, delay)
  LuaTimer:scheduleTimer(function()
    for _, id in ipairs(ids) do
      local node = Instance.getByInstanceId(id)
      if node then
        node.isVisible = not not show
      end
    end
  end, delay * 1000, 1)
end

local function showFloodParts(show)
  showParts(show, World.cfg.weatherSetting.floodPartIds, World.cfg.weatherSetting.floodDelay)
end

local function showSnowParts(show)
  showParts(show, World.cfg.weatherSetting.snowPartIds, World.cfg.weatherSetting.snowDelay)
end

local function showSandParts(show)
  showParts(show, World.cfg.weatherSetting.sandPartIds, World.cfg.weatherSetting.sandDelay)
end

function handles:switchWeather(packet)
  local weatherIndex = packet.weatherIndex
  WeatherMgr:switchWeather(weatherIndex)
  self:setInIndoor(false)
  TimeLight:SetAmbientIntensityInc(weatherIndex == Define.Weather.hot and World.cfg.weatherSetting.hotLightIntensityInc or 0.0)
  PlayerControl.enableInertance(weatherIndex == Define.Weather.snow, World.cfg.weatherSetting.slideDuration)
  if weatherIndex == Define.Weather.storm then
    UI:openWnd("quickitem", 1005)
  else
    UI:closeWnd("quickitem")
  end
  showFloodParts(weatherIndex == Define.Weather.storm)
  showSnowParts(weatherIndex == Define.Weather.snow)
  showSandParts(weatherIndex == Define.Weather.sand)
  if weatherIndex == Define.Weather.snow and packet.duration > 0 and World.cfg.weatherSetting.snowHeavyEffect then
    LuaTimer:scheduleTimer(function()
      WeatherMgr:SetAdditionalEffect(World.cfg.weatherSetting.snowHeavyEffect)
    end, World.cfg.weatherSetting.snowHeavyEffectDelay * 1000, 1)
    LuaTimer:scheduleTimer(function()
      WeatherMgr:SetAdditionalEffect()
    end, (packet.duration - World.cfg.weatherSetting.snowHeavyEffectDelay) * 1000, 1)
  end
end

function handles:weatherBigTornadoCreated(packet)
  WeatherMgr:setBigTornado(packet.id)
end
