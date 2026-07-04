local LimitedTimeGoldWheelConfig = T(Config, "LimitedTimeGoldWheelConfig")
local settings = {}
local activityCfg = {}

function LimitedTimeGoldWheelConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_gold_wheel.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_gold_wheel.csv", 2) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      sequence = tonumber(vConfig.n_sequence) or 0,
      pondId = tonumber(vConfig.n_pondId) or 0,
      price = tonumber(vConfig.n_price) or 0,
      dailyDeals = tonumber(vConfig.n_dailyDeals) or 0,
      radius = tonumber(vConfig.n_radius) or 188,
      aSpeed = tonumber(vConfig.n_aSpeed) or 3,
      maxSpeed = tonumber(vConfig.n_maxSpeed) or 30,
      highSpeedWhirl = tonumber(vConfig.n_highSpeedWhirl) or 5,
      minSpeed = tonumber(vConfig.n_minSpeed) or 3
    }
    settings[data.id] = data
    if not activityCfg[data.activityId] then
      activityCfg[data.activityId] = {}
    end
    table.insert(activityCfg[data.activityId], data)
  end
end

function LimitedTimeGoldWheelConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeGoldWheelConfig, id:", id)
    return
  end
  return Lib.copy(settings[id])
end

function LimitedTimeGoldWheelConfig:getCfgByActivityId(activityId)
  if not activityCfg[activityId] then
    Lib.logError("can not find cfgLimitedTimeGoldWheelConfig, activityId:", activityId)
    return
  end
  return Lib.copy(activityCfg[activityId])
end

function LimitedTimeGoldWheelConfig:getAllCfgs()
  return Lib.copy(settings)
end

LimitedTimeGoldWheelConfig:init()
return LimitedTimeGoldWheelConfig
