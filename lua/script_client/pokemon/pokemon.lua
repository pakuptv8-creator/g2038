local PokemonClient = require("script_common.pokemon.pokemon")
local PokemonConfig = T(Config, "PokemonConfig")
local PokemonInfoKey = PokemonClient.getPokemonInfoKey()

local function initPokemonInfo(info)
  info = info or {}
  local new_info = {}
  for key, infoRule in pairs(PokemonInfoKey) do
    new_info[key] = info[key] or infoRule.default
  end
  return new_info
end

function PokemonClient.randomCreate(pokemonId, level)
  level = level or 1
  local info = initPokemonInfo({cfgId = pokemonId, level = level})
  local newPokemon = PokemonClient.new(info)
  newPokemon:setStar(newPokemon:getCfg().starLevel)
  local skillList = PokemonConfig:getUnlockActiveSkill(pokemonId, level)
  while 4 < #skillList do
    table.remove(skillList, #skillList)
  end
  newPokemon:setSkillList(skillList)
  return newPokemon
end

local common_setValue = PokemonClient.setValue

function PokemonClient:setValue(key, value)
  common_setValue(self, key, value)
end

function PokemonClient:getName(noColor)
  return PokemonConfig:getPokemonName(self:getCfgId(), self:getValue("curName"), noColor)
end

return PokemonClient
