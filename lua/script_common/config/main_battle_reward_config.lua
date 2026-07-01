local MainBattleRewardConfig = T(Config, "MainBattleRewardConfig")
local settings = {}

function MainBattleRewardConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/main_battle_reward.csv", 2)
  for _, vConfig in pairs(config) do
    local data = {}
    data.battle_id = tonumber(vConfig.n_battle_id) or 0
    data.player_exp = tonumber(vConfig.n_pkm_exp) or 0
    data.coins = tonumber(vConfig.n_pkm_coins) or 0
    data.items = {}
    local itemsList = Lib.split(vConfig.items, ",")
    for _, item in pairs(itemsList) do
      local content = Lib.split(tostring(item), "#")
      content[1] = "myplugin/" .. content[1]
      table.insert(data.items, content)
    end
    data.pokemons = {}
    local pokemonList = Lib.split(vConfig.pokemons, ",")
    for _, pokemon in pairs(pokemonList) do
      local content = Lib.split(tostring(pokemon), "#")
      table.insert(data.pokemons, content)
    end
    settings[data.battle_id] = data
  end
end

function MainBattleRewardConfig:getRewardById(id)
  local data = settings[id]
  if data then
    return data.player_exp, data.coins, data.items, data.pokemons
  else
    if 0 < id then
      Lib.logError("MainBattleRewardConfig:getRewardById fail,id is:", id)
    end
    return 0, 0, {}, {}
  end
end

return MainBattleRewardConfig
