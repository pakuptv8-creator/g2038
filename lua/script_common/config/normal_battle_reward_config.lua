local NormalBattleRewardConfig = T(Config, "NormalBattleRewardConfig")
local settings = {}

function NormalBattleRewardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/normal_battle_reward.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.pkm_id = tonumber(vConfig.n_pkm_id) or 0
    data.pkm_exp = tonumber(vConfig.n_pkm_exp) or 0
    data.pkm_coins = tonumber(vConfig.n_pkm_coins) or 0
    data.items = {}
    local itemsList = Lib.split(vConfig.items, ",")
    for _, item in pairs(itemsList) do
      local content = Lib.split(tostring(item), "#")
      content[1] = "myplugin/" .. content[1]
      table.insert(data.items, content)
    end
    settings[data.pkm_id] = data
  end
end

function NormalBattleRewardConfig:getRewardById(id)
  local data = settings[id]
  if data then
    return data.pkm_exp, data.pkm_coins, data.items
  else
    perror("NormalBattleRewardConfig:getRewardById fail,id is:", id)
    return 0, 0, {}
  end
end

return NormalBattleRewardConfig
