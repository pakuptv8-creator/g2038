local LimitedTimeOptionalGiftConfig = T(Config, "LimitedTimeOptionalGiftConfig")
local settings = {}
local activityCfg = {}

function LimitedTimeOptionalGiftConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_optional_gift.csv", 3)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_optional_gift.csv", 3) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      giftName = vConfig.s_giftName or "",
      finalPrice = tonumber(vConfig.n_finalPrice) or 0,
      limitCounts = tonumber(vConfig.n_limitCounts) or 0,
      limitDayNum = tonumber(vConfig.n_limitDayNum) or 0,
      optionalNum = tonumber(vConfig.n_optionalNum) or 0,
      isBigAward = tonumber(vConfig.n_isBigAward) or 0,
      bigLimit = tonumber(vConfig.n_bigLimit) or 0
    }
    data.giftKey = data.activityId .. "-" .. data.id
    data.giftContent = Lib.splitString(vConfig.s_giftContent or "", "#", true)
    data.optionalContent = {}
    if vConfig.s_optionalContent1 and vConfig.s_optionalContent1 ~= "" then
      table.insert(data.optionalContent, Lib.splitString(vConfig.s_optionalContent1, "#", true))
    end
    if vConfig.s_optionalContent2 and vConfig.s_optionalContent2 ~= "" then
      table.insert(data.optionalContent, Lib.splitString(vConfig.s_optionalContent2, "#", true))
    end
    if vConfig.s_optionalContent3 and vConfig.s_optionalContent3 ~= "" then
      table.insert(data.optionalContent, Lib.splitString(vConfig.s_optionalContent3, "#", true))
    end
    if vConfig.s_optionalContent4 and vConfig.s_optionalContent4 ~= "" then
      table.insert(data.optionalContent, Lib.splitString(vConfig.s_optionalContent4, "#", true))
    end
    if not activityCfg[data.activityId] then
      activityCfg[data.activityId] = {
        normalList = {}
      }
    end
    if data.isBigAward == 1 then
      activityCfg[data.activityId].bigAward = data
    else
      table.insert(activityCfg[data.activityId].normalList, data)
    end
    settings[data.id] = data
  end
  for activityId, val in pairs(activityCfg) do
    table.sort(activityCfg[activityId].normalList, function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function LimitedTimeOptionalGiftConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeOptionalGiftConfig, id:", id)
    return
  end
  return settings[id]
end

function LimitedTimeOptionalGiftConfig:getCfgByGiftKey(giftKey)
  for id, val in pairs(settings) do
    if val.giftKey == giftKey then
      return val
    end
  end
  return
end

function LimitedTimeOptionalGiftConfig:getAllCfgs()
  return settings
end

function LimitedTimeOptionalGiftConfig:getCfgByActivityId(activityId)
  if not activityCfg[activityId] then
    return {}
  end
  return activityCfg[activityId]
end

LimitedTimeOptionalGiftConfig:init()
return LimitedTimeOptionalGiftConfig
