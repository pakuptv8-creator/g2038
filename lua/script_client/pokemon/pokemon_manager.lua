local PokemonManager = require("script_common.pokemon.pokemon_manager")
local common_getPokemon = PokemonManager.getPokemon
local common_getPokemonList = PokemonManager.getPokemonList

local function getAllPokemonFromServer(objIds, response)
  Me:sendPacket({
    pid = "getPokemonList",
    objIds = table.concat(objIds, ":")
  }, function(infoList)
    if type(infoList) == "table" then
      for objId, info in pairs(infoList) do
        if not common_getPokemon(nil, objId) then
          local pokemon = PokemonManager:initPokemon(info)
          PokemonManager:putPokemon(pokemon, objId)
        end
      end
    end
    response()
  end)
end

function PokemonManager:getPokemon(objId, callBack)
  local pokemon = common_getPokemon(self, objId)
  if pokemon then
    callBack(pokemon)
    return
  end
  getAllPokemonFromServer({objId}, function()
    callBack(common_getPokemon(self, objId))
  end)
end

function PokemonManager:getPokemonList(objIds, callBack)
  local syncIds = {}
  for _, objId in pairs(objIds) do
    if not common_getPokemon(self, objId) then
      table.insert(syncIds, objId)
    end
  end
  if #syncIds == 0 then
    callBack(common_getPokemonList(self, objIds))
    return
  end
  getAllPokemonFromServer(syncIds, function()
    callBack(common_getPokemonList(self, objIds))
  end)
end

function PokemonManager:copyPokemon(pokemon)
  if pokemon then
    local copy_pokemon = self:initPokemon(pokemon:getClientInfo())
    copy_pokemon.objId = 0
    return copy_pokemon
  end
end

return PokemonManager
