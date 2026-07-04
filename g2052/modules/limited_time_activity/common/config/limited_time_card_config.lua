local LimitedTimeCardConfig = T(Config, "LimitedTimeCardConfig")
local settings = {}
local sameActivitySettings = {}

function LimitedTimeCardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_card.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_card.csv", 2) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      type = tonumber(vConfig.n_type) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      giftContent = Lib.splitString(vConfig.s_giftContent, "#", true),
      price = tonumber(vConfig.n_price) or 0,
      awardCount = tonumber(vConfig.n_awardCount) or 0,
      bgFrame = vConfig.s_bgFrame or "",
      icon = vConfig.s_icon or "",
      buyIcon = vConfig.s_buyIcon or "",
      title = vConfig.s_title or "",
      dec = vConfig.s_dec or "",
      tag = vConfig.s_tag or ""
    }
    settings[data.id] = data
    if not sameActivitySettings[data.activityId] then
      sameActivitySettings[data.activityId] = {}
    end
    table.insert(sameActivitySettings[data.activityId], data)
    table.sort(sameActivitySettings[data.activityId], function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function LimitedTimeCardConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgLimitedTimeWeekMonthCardConfig, id:", id)
    return
  end
  return Lib.copy(settings[id])
end

function LimitedTimeCardConfig:getAllCfgs()
  return Lib.copy(settings)
end

function LimitedTimeCardConfig:getAllSameActivitySettings()
  return Lib.copy(sameActivitySettings)
end

function LimitedTimeCardConfig:getSameActivityCfgByActivityId(activityId)
  if not sameActivitySettings[activityId] then
    return {}
  end
  return Lib.copy(sameActivitySettings[activityId])
end

function LimitedTimeCardConfig:getCfgByActivityIdAndType(activityId, type)
  local data
  for _, v in pairs(sameActivitySettings[activityId] or {}) do
    if v.type == type then
      data = Lib.copy(v)
    end
  end
  return data
end

LimitedTimeCardConfig:init()
return LimitedTimeCardConfig
