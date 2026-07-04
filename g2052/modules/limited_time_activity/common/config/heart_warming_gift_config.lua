local HeartWarmingGiftConfig = T(Config, "HeartWarmingGiftConfig")
local settings = {}
local activityCfg = {}

function HeartWarmingGiftConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/heart_warming_gift.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      needPoints = tonumber(vConfig.n_needPoints) or 0,
      giftContent = Lib.splitString(vConfig.s_giftContent, "#", true)
    }
    data.giftKey = data.activityId .. "-" .. data.id
    settings[data.id] = data
    if not activityCfg[data.activityId] then
      activityCfg[data.activityId] = {}
    end
    table.insert(activityCfg[data.activityId], data)
  end
  for activityId, v in pairs(activityCfg) do
    table.sort(activityCfg[activityId], function(a, b)
      return a.needPoints < b.needPoints
    end)
  end
end

function HeartWarmingGiftConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgHeartWarmingGiftConfig, id:", id)
    return
  end
  return settings[id]
end

function HeartWarmingGiftConfig:getAllCfgs()
  return settings
end

function HeartWarmingGiftConfig:getCfgByActivityId(activityId)
  return Lib.copy(activityCfg[activityId] or {})
end

HeartWarmingGiftConfig:init()
return HeartWarmingGiftConfig
