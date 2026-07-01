local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
local settings = {}

function PokemonLuckyPkmConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_lucky_pkm.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.pool_id = tonumber(vConfig.n_pool_id) or 0
    data.rare_id = tonumber(vConfig.n_rare_id) or 0
    data.pkm_id = tonumber(vConfig.n_pkm_id) or 0
    data.weight_num = tonumber(vConfig.n_weight_num) or 0
    data.star = tonumber(vConfig.n_star) or 0
    table.insert(settings, data)
  end
end

function PokemonLuckyPkmConfig:getDataByPoolId(poolId)
  local item = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId then
      table.insert(item, config)
    end
  end
  return item
end

function PokemonLuckyPkmConfig:getDataByPoolIdAndRareId(poolId, rareId)
  local item = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId and config.rare_id == rareId then
      table.insert(item, config)
    end
  end
  return item
end

return PokemonLuckyPkmConfig
