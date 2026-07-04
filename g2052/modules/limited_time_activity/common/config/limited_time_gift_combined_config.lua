local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")
local settings = {}

function LimitedTimeGiftCombinedConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_gift_combined.csv", 3)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_gift_combined.csv", 3) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      giftName = vConfig.s_giftName or "",
      initPrice = tonumber(vConfig.n_initPrice) or 0,
      finalPrice = tonumber(vConfig.n_finalPrice) or 0,
      percent = vConfig.s_percent or ""
    }
    data.giftKey = data.activityId .. "-" .. data.id
    data.giftContent = Lib.splitString(vConfig.s_giftContent or "", "#", true)
    settings[data.id] = data
  end
end

function LimitedTimeGiftCombinedConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeGiftCombinedConfig, id:", id)
    return
  end
  return settings[id]
end

function LimitedTimeGiftCombinedConfig:getAllCfgs()
  return settings
end

function LimitedTimeGiftCombinedConfig:getCfgByActivityId(activityId)
  for _, val in pairs(settings) do
    if val.activityId == activityId then
      return val
    end
  end
end

LimitedTimeGiftCombinedConfig:init()
return LimitedTimeGiftCombinedConfig
