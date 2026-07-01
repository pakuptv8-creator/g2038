local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
local settings = {}

function PokemonLuckyExtraConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_lucky_extra.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.pool_id = tonumber(vConfig.n_pool_id) or 0
    data.take_count = tonumber(vConfig.n_take_count) or 0
    data.fullName = vConfig.s_fullName or ""
    data.award_count = tonumber(vConfig.n_award_count) or 0
    data.pkm_id = tonumber(vConfig.n_pkm_id) or 0
    table.insert(settings, data)
  end
end

function PokemonLuckyExtraConfig:getDataByPoolId(poolId)
  local items = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId then
      table.insert(items, config)
    end
  end
  table.sort(items, function(item1, item2)
    return item1.take_count < item2.take_count
  end)
  return items
end

function PokemonLuckyExtraConfig:getDataById(extraId)
  for _, config in pairs(settings) do
    if config.id == extraId then
      return config
    end
  end
end

return PokemonLuckyExtraConfig
