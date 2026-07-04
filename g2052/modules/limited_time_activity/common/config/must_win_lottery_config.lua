local MustWinLotteryConfig = T(Config, "MustWinLotteryConfig")
local settings = {}

function MustWinLotteryConfig:init()
  local config
  config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/commercialize/must_win_lottery.csv", 2)
  config = config or Lib.read_csv_file(Root.Instance():getGamePath() .. "config/must_win_lottery.csv", 2) or {}
  for _, vConfig in pairs(config) do
    local data = {
      count = tonumber(vConfig.n_count) or 0,
      price = tonumber(vConfig.n_price) or 0,
      range = Lib.splitString(vConfig.s_range, "#", true)
    }
    settings[data.count] = data
  end
end

function MustWinLotteryConfig:getCfgByCount(count)
  if not settings[count] then
    Lib.logError("can not find cfgMustWinLotteryConfig, count:", count)
    return
  end
  return settings[count]
end

function MustWinLotteryConfig:getAllCfgs()
  return settings
end

MustWinLotteryConfig:init()
return MustWinLotteryConfig
