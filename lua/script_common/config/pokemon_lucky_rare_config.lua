local PokemonLuckyRareConfig = T(Config, "PokemonLuckyRareConfig")
local settings = {}

function PokemonLuckyRareConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_lucky_rare.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.pool_id = tonumber(vConfig.n_pool_id) or 0
    data.rare_id = tonumber(vConfig.n_rare_id) or 0
    data.effect_id = tonumber(vConfig.n_effect_id) or 0
    data.weight_num = tonumber(vConfig.n_weight_num) or 0
    data.end_count = tonumber(vConfig.n_end_count) or 0
    data.take_must_tips = tonumber(vConfig.n_take_must_tips) or 0
    table.insert(settings, data)
  end
end

function PokemonLuckyRareConfig:getDataByPoolId(poolId)
  local items = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId then
      table.insert(items, config)
    end
  end
  table.sort(items, function(item1, item2)
    return item1.rare_id < item2.rare_id
  end)
  return items
end

function PokemonLuckyRareConfig:getDataByPoolIdAndRareId(poolId, rareId)
  local item = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId and config.rare_id == rareId then
      return config
    end
  end
  return item
end

function PokemonLuckyRareConfig:getMustDataByPoolId(poolId)
  for _, config in pairs(settings) do
    if config.pool_id == poolId and config.take_must_tips > 0 then
      return config
    end
  end
  return nil
end

return PokemonLuckyRareConfig
