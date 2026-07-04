local LimitedTimeDiscountGiftConfig = T(Config, "LimitedTimeDiscountGiftConfig")
local settings = {}
local roundCfg = {}

function LimitedTimeDiscountGiftConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_discount_gift.csv", 3)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_discount_gift.csv", 3) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      roundId = tonumber(vConfig.n_roundId) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      giftName = vConfig.s_giftName or "",
      initPrice = tonumber(vConfig.n_initPrice) or 0,
      finalPrice = tonumber(vConfig.n_finalPrice) or 0,
      percent = vConfig.s_percent or "",
      limitCounts = tonumber(vConfig.n_limitCounts) or 0,
      giftContent = vConfig.s_giftContent or ""
    }
    data.giftKey = data.activityId .. "-" .. data.id
    data.giftContent = Lib.splitString(vConfig.s_giftContent or "", "#", true)
    data.roundId = 1
    if vConfig.n_roundId then
      data.roundId = tonumber(vConfig.n_roundId)
    end
    if not roundCfg[data.activityId] then
      roundCfg[data.activityId] = {}
    end
    if not roundCfg[data.activityId][data.roundId] then
      roundCfg[data.activityId][data.roundId] = {}
    end
    table.insert(roundCfg[data.activityId][data.roundId], data)
    settings[data.id] = data
  end
  for activityId, val in pairs(roundCfg) do
    for roundId, _ in pairs(val) do
      table.sort(roundCfg[activityId][roundId], function(a, b)
        return a.sortId < b.sortId
      end)
    end
  end
end

function LimitedTimeDiscountGiftConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeDiscountGiftConfig, id:", id)
    return
  end
  return settings[id]
end

function LimitedTimeDiscountGiftConfig:getAllCfgs()
  return settings
end

function LimitedTimeDiscountGiftConfig:getCfgByRoundActivityId(activityId, roundId)
  if not roundCfg[activityId] then
    return {}
  end
  return roundCfg[activityId][roundId] or {}
end

function LimitedTimeDiscountGiftConfig:getCfgByActivityIdTotalRound(activityId)
  if not roundCfg[activityId] then
    return 1
  end
  local num = 0
  for _, val in pairs(roundCfg[activityId]) do
    num = num + 1
  end
  return num
end

LimitedTimeDiscountGiftConfig:init()
return LimitedTimeDiscountGiftConfig
