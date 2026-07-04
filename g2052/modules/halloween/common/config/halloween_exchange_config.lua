local HalloweenExchangeConfig = T(Config, "HalloweenExchangeConfig")
local settings = {}

function HalloweenExchangeConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/halloween_exchange.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      partPathName = vConfig.s_partPathName or "",
      partMapPos = vConfig.s_partMapPos or "",
      costNum = tonumber(vConfig.n_costNum) or 0,
      awardType = tonumber(vConfig.n_awardType) or 0,
      awardId = tonumber(vConfig.n_awardId) or 0,
      showOffset = Lib.createV3ByString(vConfig.s_showOffset),
      showRange = tonumber(vConfig.n_showRange) or 0,
      minScale = tonumber(vConfig.n_minScale) or 0,
      maxScale = tonumber(vConfig.n_maxScale) or 0,
      stadia = Lib.splitString(vConfig.s_stadia or "", "#", true)
    }
    local times = Lib.splitString(vConfig.s_startTime or "", "_", true)
    data.startTime = {
      year = times[1] or 0,
      month = times[2] or 0,
      day = times[3] or 0,
      hour = times[4] or 0,
      min = times[5] or 0,
      sec = times[3] or 0
    }
    settings[data.id] = data
  end
end

function HalloweenExchangeConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgHalloweenExchangeConfig, id:", id)
    return
  end
  return settings[id]
end

function HalloweenExchangeConfig:getAllCfgs()
  return settings
end

HalloweenExchangeConfig:init()
return HalloweenExchangeConfig
