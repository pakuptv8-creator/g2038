local WeatherConfig = T(Config, "WeatherConfig")
local settings = {}

function WeatherConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/weather.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id),
      message = tonumber(vConfig.n_message) or 0,
      playerMsg = tonumber(vConfig.n_playerMsg) or 0,
      fogData = Lib.splitString(vConfig.s_fogData or "", "#", true),
      duration = Lib.splitString(vConfig.s_duration or "", "#", true),
      rainEffect = vConfig.s_rainEffect or "",
      rainSound = Lib.splitString(vConfig.s_rainSound or "", "#", false),
      lightEffect = vConfig.s_lightEffect or "",
      lightSound = Lib.splitString(vConfig.s_lightSound or "", "#"),
      lightFrequency = tonumber(vConfig.n_lightFrequency) or 0,
      lightRate = tonumber(vConfig.n_lightRate) or 0,
      lightPosX = Lib.splitString(vConfig.s_lightPosX or "", "#", true),
      lightPosZ = Lib.splitString(vConfig.s_lightPosZ or "", "#", true),
      lightPosY = tonumber(vConfig.n_lightPosY) or 0,
      weight = tonumber(vConfig.n_weight) or 0,
      fogColor = Lib.splitString(vConfig.s_fogColor or "", "#", true),
      bgm = vConfig.s_bgm ~= "" and vConfig.s_bgm,
      mapName = vConfig.s_mapName or "",
      skyBox = vConfig.s_skyBox or "",
      randomList = tonumber(vConfig.n_randomList) or 0
    }
    if not settings[data.mapName] then
      settings[data.mapName] = {}
    end
    settings[data.mapName][data.id] = data
  end
end

function WeatherConfig:getCfgByIdAndMapName(id, mapName)
  if not settings[mapName] or not settings[mapName][id] then
    Lib.logError("can not find WeatherConfig, id and mapName:", id, mapName)
    return
  end
  return settings[mapName][id]
end

function WeatherConfig:getAllCfg()
  return settings
end

function WeatherConfig:getCfgByMapName(mapName)
  if not settings[mapName] then
    Lib.logError("can not find WeatherConfig, mapName:", mapName)
    return
  end
  return settings[mapName]
end

function WeatherConfig:getParticipantMaps()
  local maps = {}
  for mapName, _ in pairs(settings) do
    table.insert(maps, mapName)
  end
  return maps
end

WeatherConfig:init()
return WeatherConfig
