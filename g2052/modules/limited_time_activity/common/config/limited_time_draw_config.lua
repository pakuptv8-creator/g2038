local LimitedTimeDrawConfig = T(Config, "LimitedTimeDrawConfig")
local settings = {}
local sameActivitySettings = {}

function LimitedTimeDrawConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_draw.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_draw.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      sequence = tonumber(vConfig.n_sequence) or 0,
      pondId = tonumber(vConfig.n_pondId) or 0,
      awardsModel = vConfig.s_awardsModel ~= "" and vConfig.s_awardsModel,
      awardsIcon = vConfig.s_awardsIcon ~= "" and vConfig.s_awardsIcon,
      guaranteeCount = tonumber(vConfig.n_guaranteeCount) or 0,
      singlePrice = tonumber(vConfig.n_singlePrice) or 0,
      dailyDeals = tonumber(vConfig.n_dailyDeals) or 0,
      tenPrice = tonumber(vConfig.n_tenPrice) or 0
    }
    settings[data.id] = data
    if not sameActivitySettings[data.activityId] then
      sameActivitySettings[data.activityId] = {}
    end
    table.insert(sameActivitySettings[data.activityId], data)
  end
end

function LimitedTimeDrawConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeDrawConfig, id:", id)
    return
  end
  return Lib.copy(settings[id])
end

function LimitedTimeDrawConfig:getAllCfgs()
  return Lib.copy(settings)
end

function LimitedTimeDrawConfig:getSameActivityCfgByActivityId(activityId)
  if not sameActivitySettings[activityId] then
    Lib.logError("can not find getSameActivityCfgByActivityId, activityId:", activityId)
  end
  return Lib.copy(sameActivitySettings[activityId])
end

LimitedTimeDrawConfig:init()
return LimitedTimeDrawConfig
