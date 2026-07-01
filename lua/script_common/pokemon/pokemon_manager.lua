local PokemonManager = L("PokemonManager", {})
local Pokemon
if World.isClient then
  Pokemon = require("script_client.pokemon.pokemon")
else
  Pokemon = require("script_server.pokemon.pokemon")
end
local TotalPokemonPool = {}

function PokemonManager:init()
  TotalPokemonPool = {}
end

function PokemonManager:createPokemon(pokemonId, level, star)
  return Pokemon.randomCreate(pokemonId, level, star)
end

function PokemonManager:createNPCPokemon(id, strength, playerLevel)
  return Pokemon.npcCreate(id, strength, playerLevel)
end

function PokemonManager:initPokemon(info)
  return Pokemon.new(info)
end

function PokemonManager:putPokemon(pokemon, objId)
  if classof(pokemon) ~= "Pokemon" then
    return
  end
  TotalPokemonPool[tostring(objId)] = pokemon
  pokemon.objId = objId
end

function PokemonManager:getPokemon(objId, owner_userId)
  local pokemon = TotalPokemonPool[tostring(objId)]
  if pokemon and owner_userId and pokemon:getMasterId() ~= owner_userId then
    return
  end
  return pokemon
end

function PokemonManager:getPokemonList(objIds, owner_userId)
  local list = {}
  for _, objId in pairs(objIds) do
    local pokemon = TotalPokemonPool[tostring(objId)]
    if not pokemon or owner_userId and pokemon:getMasterId() ~= owner_userId then
    else
      table.insert(list, pokemon)
    end
  end
  return list
end

function PokemonManager:removePokemon(objId)
  TotalPokemonPool[tostring(objId)] = nil
end

function PokemonManager:removePokemonList(objIds)
  for _, objId in pairs(objIds) do
    PokemonManager:removePokemon(objId)
  end
end

function PokemonManager:getAllPokemon()
  return TotalPokemonPool
end

return PokemonManager
