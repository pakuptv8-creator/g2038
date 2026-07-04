local TimeLightConfig = T(Config, "TimeLightConfig")
local settings = {}

function TimeLightConfig:init()
  local data = {}
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/time_light.csv", 2)
  for _, vConfig in ipairs(config) do
    local time = Lib.splitString(vConfig.time, "#", true)
    data = {
      second = Lib.time2Seconds(time[1], time[2]),
      ambientSkyColor = Lib.changeCfgStringColor(vConfig.ambientSkyColor),
      ambientEquatorColor = Lib.changeCfgStringColor(vConfig.ambientEquatorColor),
      dirLightColor = Lib.changeCfgStringColor(vConfig.dirLightColor),
      dirLightRotation = Lib.changeCfgStringCoord(vConfig.dirLightRotation),
      ambientIntensity = vConfig.ambientIntensity or 0,
      dirLightIntensity = vConfig.dirLightIntensity or 0,
      fogData = Lib.splitString(vConfig.fogData or "", "#", true),
      fogColor = Lib.changeCfgStringColor(vConfig.fogColor),
      weather = tonumber(vConfig.weather) or 1
    }
    if not settings[data.weather] then
      settings[data.weather] = {}
    end
    table.insert(settings[data.weather], data)
  end
end

function TimeLightConfig:getByTime(sec, weather)
  if not settings[weather] then
    weather = Define.Weather.sunny
    if not settings[weather] then
      return
    end
  end
  local fromIndex, toIndex
  local data = settings[weather]
  for i, v in ipairs(data) do
    if sec < v.second then
      toIndex = i
      break
    end
  end
  if not toIndex then
    fromIndex = #data
    toIndex = 1
  else
    fromIndex = toIndex - 1
    if fromIndex < 1 then
      fromIndex = #data
    end
  end
  return data[fromIndex], data[toIndex]
end

TimeLightConfig:init()
