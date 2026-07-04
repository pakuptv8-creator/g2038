local LimitedTimeRoundsConfig = T(Config, "LimitedTimeRoundsConfig")
local settings = {}
local actSetting = {}

function LimitedTimeRoundsConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_rounds.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_rounds.csv", 2)
  for _, vConfig in pairs(config or {}) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      roundsTime = Lib.splitString(vConfig.s_roundsTime or "", "-", true),
      continueTime = Lib.splitString(vConfig.s_continueTime or "", "-", true),
      notResetData = tonumber(vConfig.n_notResetData or "") == 1
    }
    table.insert(settings, data)
    actSetting[data.activityId] = data
  end
  table.sort(settings, function(a, b)
    return a.sortId < b.sortId
  end)
end

function LimitedTimeRoundsConfig:getCfgByActivityId(activityId)
  if not actSetting[activityId] then
    return
  end
  return actSetting[activityId]
end

function LimitedTimeRoundsConfig:getAllCfgs()
  return Lib.copy(settings)
end

LimitedTimeRoundsConfig:init()
return LimitedTimeRoundsConfig
