local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")
local settings = {}

function PokemonRotaryTableConfig:init()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_rotary_table.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {
      id = tonumber(vConfig.n_id) or 0,
      rotary_type = tonumber(vConfig.n_rotary_type) or 0,
      fullName = vConfig.s_fullName or "",
      goldIcon = vConfig.s_goldIcon or "",
      pkm_id = tonumber(vConfig.n_pkm_id) or 0,
      award_num = tonumber(vConfig.n_award_num) or 0,
      award_pos = tonumber(vConfig.n_award_pos) or 0,
      ratio_num = tonumber(vConfig.n_ratio_num) or 0,
      ratio_pos = tonumber(vConfig.n_ratio_pos) or 0,
      first_weight = tonumber(vConfig.n_first_weight) or 0,
      normal_weight = tonumber(vConfig.n_normal_weight) or 0,
      currencyType = tonumber(vConfig.n_currencyType) or 0,
      price_num = tonumber(vConfig.n_price_num) or 0
    }
    if World.cfg.useFDiamonds and data.currencyType == 0 then
      data.currencyType = 4
    end
    if data.currencyType == 0 then
      data.isPay = true
    else
      data.isPay = false
    end
    settings[data.id] = data
  end
end

function PokemonRotaryTableConfig:getCfgById(id)
  if not settings[id] then
    Lib.logError("can not find cfgPokemonRotaryTableConfig, id:", id)
    return
  end
  return settings[id]
end

function PokemonRotaryTableConfig:getAllCfgs()
  return settings
end

function PokemonRotaryTableConfig:getCfgByRotaryType(rotary_type)
  local items = {}
  for _, val in pairs(settings) do
    if val.rotary_type == rotary_type then
      table.insert(items, val)
    end
  end
  return items
end

function PokemonRotaryTableConfig:getAwardByRotaryType(rotary_type)
  local items = {}
  for _, val in pairs(settings) do
    if val.rotary_type == rotary_type and not items[val.award_pos] then
      items[val.award_pos] = val
    end
  end
  return items
end

function PokemonRotaryTableConfig:getRatioByRotaryType(rotary_type)
  local items = {}
  for _, val in pairs(settings) do
    if val.rotary_type == rotary_type and not items[val.ratio_pos] then
      items[val.ratio_pos] = val
    end
  end
  return items
end

return PokemonRotaryTableConfig
