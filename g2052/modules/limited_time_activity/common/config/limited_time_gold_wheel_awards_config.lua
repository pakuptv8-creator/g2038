local LimitedTimeGoldWheelAwardsConfig = T(Config, "LimitedTimeGoldWheelAwardsConfig")
local settings = {}

function LimitedTimeGoldWheelAwardsConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_gold_wheel_awards.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_gold_wheel_awards.csv", 2) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      pondId = tonumber(vConfig.n_pondId) or 0,
      giftContent = Lib.splitString(vConfig.s_giftContent, "#", true),
      weight = tonumber(vConfig.n_weight) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      tag = vConfig.s_tag ~= "" and vConfig.s_tag
    }
    if not settings[data.pondId] then
      settings[data.pondId] = {}
    end
    table.insert(settings[data.pondId], data)
  end
  for pondId, v in pairs(settings) do
    table.sort(settings[pondId], function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function LimitedTimeGoldWheelAwardsConfig:getCfgByPondId(pondId)
  if not settings[pondId] then
    Lib.logError("can not find cfgLimitedTimeGoldWheelAwardsConfig, pondId:", pondId)
    return
  end
  return Lib.copy(settings[pondId])
end

function LimitedTimeGoldWheelAwardsConfig:getAllCfgs()
  return Lib.copy(settings)
end

LimitedTimeGoldWheelAwardsConfig:init()
return LimitedTimeGoldWheelAwardsConfig
