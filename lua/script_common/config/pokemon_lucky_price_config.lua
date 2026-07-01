local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
local settings = {}

function PokemonLuckyPriceConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_lucky_price.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.n_id) or 0
    data.pool_id = tonumber(vConfig.n_pool_id) or 0
    data.take_type = tonumber(vConfig.n_take_type) or 0
    data.fullName = vConfig.s_fullName or ""
    data.ticket_count = tonumber(vConfig.n_ticket_count) or 0
    data.currencyType = tonumber(vConfig.n_currencyType) or 0
    if World.cfg.useFDiamonds and data.currencyType == 0 then
      data.currencyType = 4
    end
    if data.currencyType == 0 then
      data.isPay = true
    else
      data.isPay = false
    end
    data.currency_count = tonumber(vConfig.n_currency_count) or 0
    table.insert(settings, data)
  end
end

function PokemonLuckyPriceConfig:getDataByPoolIdAndTakeType(poolId, take_type)
  for _, config in pairs(settings) do
    if config.pool_id == poolId and config.take_type == take_type then
      return config
    end
  end
end

function PokemonLuckyPriceConfig:getDataByPoolId(poolId)
  local item = {}
  for _, config in pairs(settings) do
    if config.pool_id == poolId then
      if config.take_type == 0 then
        item[1] = config
      else
        item[10] = config
      end
    end
  end
  return item
end

return PokemonLuckyPriceConfig
