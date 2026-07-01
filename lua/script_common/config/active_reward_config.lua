local ActiveRewardConfig = T(Config, "ActiveRewardConfig")
local settings = {}

function ActiveRewardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/active_reward.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.min_level = tonumber(vConfig.min_level) or 0
    data.max_level = tonumber(vConfig.max_level) or 0
    data.active = tonumber(vConfig.active) or 0
    data.reward = {}
    local reward = Lib.split(vConfig.reward, "#")
    data.reward[1] = "myplugin/" .. reward[1] or ""
    data.reward[2] = tonumber(reward[2]) or 0
    settings[data.id] = data
  end
end

function ActiveRewardConfig:getRewards(level)
  local datas = {}
  for _, data in pairs(settings) do
    if level >= data.min_level and level <= data.max_level then
      table.insert(datas, data)
    end
  end
  return datas
end

function ActiveRewardConfig:getSpeicifcRewards(level, active, curIndex)
  local datas = {}
  for _, data in pairs(settings) do
    if level >= data.min_level and level <= data.max_level and active >= data.active then
      local index = data.id % 6
      if index == 0 then
        index = 6
      end
      Lib.logInfo("getSpeicifcRewards index = ", index)
      if index - curIndex == 1 then
        Lib.logInfo("getSpeicifcRewards curIndex = ", curIndex)
        table.insert(datas, data)
      end
    end
  end
  return datas
end

return ActiveRewardConfig
