local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")
local settings = {}

function LimitedTimeGiftSignalConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_gift_signal.csv", 3)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_gift_signal.csv", 3) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      giftName = vConfig.s_giftName or "",
      initPrice = tonumber(vConfig.n_initPrice) or 0,
      finalPrice = tonumber(vConfig.n_finalPrice) or 0,
      percent = vConfig.s_percent or "",
      giftIcon = vConfig.s_giftIcon or "",
      giftNum = tonumber(vConfig.n_giftNum) or 0
    }
    data.giftKey = data.activityId .. "-" .. data.id
    data.giftContent = Lib.splitString(vConfig.s_giftContent or "", "#", true)
    if vConfig.n_sortId then
      data.sortId = tonumber(vConfig.n_sortId) or 0
    else
      data.sortId = data.id
    end
    if vConfig.n_limitCounts then
      data.limitCounts = tonumber(vConfig.n_limitCounts)
    else
      data.limitCounts = 1
    end
    settings[data.id] = data
  end
end

function LimitedTimeGiftSignalConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeGiftSignalConfig, id:", id)
    return
  end
  return settings[id]
end

function LimitedTimeGiftSignalConfig:getAllCfgs()
  return settings
end

function LimitedTimeGiftSignalConfig:getCfgByActivityId(activityId)
  local result = {}
  for _, val in pairs(settings) do
    if val.activityId == activityId then
      table.insert(result, val)
    end
  end
  return result
end

LimitedTimeGiftSignalConfig:init()
return LimitedTimeGiftSignalConfig
