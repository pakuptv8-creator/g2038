local LimitedTimeDrawAwardsConfig = T(Config, "LimitedTimeDrawAwardsConfig")
local settings = {}
local infallible = {}

function LimitedTimeDrawAwardsConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/limited_time_draw_awards.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/limited_time_draw_awards.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      pondId = tonumber(vConfig.n_pondId) or 0,
      infallible = Lib.splitString(vConfig.s_infallible or "", "#", true),
      giftContent = Lib.splitString(vConfig.s_giftContent, "#", true),
      weight = tonumber(vConfig.n_weight) or 0,
      quality = tonumber(vConfig.n_quality) or 0,
      isBigPrize = tonumber(vConfig.n_isBigPrize) == 1
    }
    if not settings[data.pondId] then
      settings[data.pondId] = {}
    end
    table.insert(settings[data.pondId], data)
    if not infallible[data.pondId] then
      infallible[data.pondId] = {}
    end
    if 0 < #data.infallible then
      local info = Lib.copy(data)
      info.weight = 1
      for _, v in pairs(data.infallible) do
        if not infallible[data.pondId][v] then
          infallible[data.pondId][v] = {}
        end
        table.insert(infallible[data.pondId][v], info)
      end
    end
  end
end

function LimitedTimeDrawAwardsConfig:getCfgByPondId(pondId)
  if not settings[pondId] then
    Lib.logError("can not find cfgLimitedTimeDrawAwardsConfig, pondId:", pondId)
    return
  end
  return Lib.copy(settings[pondId])
end

function LimitedTimeDrawAwardsConfig:getAllCfgs()
  return Lib.copy(settings)
end

function LimitedTimeDrawAwardsConfig:getPondInfallibleByPondIdAndCount(pondId, count)
  if not infallible[pondId] or not infallible[pondId][count] then
    return
  end
  return Lib.copy(infallible[pondId][count])
end

LimitedTimeDrawAwardsConfig:init()
return LimitedTimeDrawAwardsConfig
