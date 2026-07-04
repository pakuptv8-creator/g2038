local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local settings = {}
local activityCfg = {}

function MustWinLotteryAwardConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/must_win_lottery_award.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/must_win_lottery_award.csv", 2) or {}
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      sortId = tonumber(vConfig.n_sortId) or 0,
      activityId = tonumber(vConfig.n_activityId) or 0,
      giftContent = Lib.splitString(vConfig.s_giftContent, "#", true),
      icon = vConfig.s_icon,
      dec = vConfig.s_dec,
      name = vConfig.s_name,
      quality = tonumber(vConfig.n_quality) or 0
    }
    data.weightList = {}
    local weightList = Lib.splitString(vConfig.s_weight, "|")
    for i, v in pairs(weightList) do
      local weightTemp = Lib.splitString(v, "#", true)
      table.insert(data.weightList, {
        counts = weightTemp[1],
        weight = weightTemp[2]
      })
    end
    table.sort(data.weightList, function(a, b)
      return a.counts < b.counts
    end)
    if not activityCfg[data.activityId] then
      activityCfg[data.activityId] = {}
    end
    table.insert(activityCfg[data.activityId], data)
    table.insert(settings, data)
  end
  for activityId, v in pairs(activityCfg) do
    table.sort(activityCfg[activityId], function(a, b)
      return a.sortId < b.sortId
    end)
  end
end

function MustWinLotteryAwardConfig:getCfgById(id)
  local data = {}
  for _, v in pairs(settings) do
    if v.id == id then
      data = v
      break
    end
  end
  return Lib.copy(data)
end

function MustWinLotteryAwardConfig:getAllCfgs()
  return Lib.copy(settings)
end

function MustWinLotteryAwardConfig:getCfgByActivityId(activityId)
  return Lib.copy(activityCfg[activityId] or {})
end

function MustWinLotteryAwardConfig:getCfgByActivityIdAndCounts(activityId, counts)
  if activityCfg[activityId] then
    local result = Lib.copy(activityCfg[activityId])
    for key, val in pairs(result) do
      result[key].weight = 0
      for i, v in pairs(val.weightList) do
        if counts >= v.counts then
          result[key].weight = v.weight
        end
      end
    end
    return result
  else
    return {}
  end
end

MustWinLotteryAwardConfig:init()
return MustWinLotteryAwardConfig
