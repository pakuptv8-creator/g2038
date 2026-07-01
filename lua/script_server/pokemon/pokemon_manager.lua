local PokemonManager = require("script_common.pokemon.pokemon_manager")
local LuaTimer = T(Lib, "LuaTimer")
local MaxObjId = 0
local common_init = PokemonManager.init

function PokemonManager:init()
  common_init(self)
  Lib.subscribeEvent(Event.EVENT_POKEMON_DESTROY, function(objId)
    PokemonManager:removePokemon(objId)
  end)
  LuaTimer:scheduleTimer(function()
    local userIdMap = {}
    local playerList = Game.GetAllPlayers()
    for _, player in pairs(playerList) do
      userIdMap[tostring(player.platformUserId)] = true
    end
    print("--------------------Check PokemonManager Cache Start-----------------------------------")
    local curTime = os.time()
    local printCount = 0
    local checkCount = 0
    for _, pokemon in pairs(PokemonManager:getAllPokemon()) do
      checkCount = checkCount + 1
      if printCount < 5 then
        local masterId = pokemon:getMasterId()
        if (masterId == 0 or not userIdMap[tostring(masterId)]) and pokemon.createTime and curTime - pokemon.createTime > 1800 then
          print("--------------------------------------------------------------------------------")
          print("pokemonObjId = " .. pokemon:getObjId(), "masterId = " .. masterId)
          print(pokemon.traceback)
          printCount = printCount + 1
        end
      end
    end
    print("--------------------Check PokemonManager Cache End-----------------------------------")
    print("checkCount =", checkCount)
    local playerTotalCount = 0
    local captureTotalCount = 0
    for _, player in pairs(Game.GetAllPlayers()) do
      playerTotalCount = playerTotalCount + #player:getValue("battlePetList") + #player:getValue("packetPetList")
      captureTotalCount = captureTotalCount + #player:getValue("capturePetList")
    end
    print("playerTotalCount =", playerTotalCount)
    print("captureTotalCount =", captureTotalCount)
  end, 1800000)
end

local common_createPokemon = PokemonManager.createPokemon

function PokemonManager:createPokemon(pokemonId, level, star)
  local pokemon = common_createPokemon(self, pokemonId, level, star or 0)
  self:putPokemon(pokemon)
  return pokemon
end

local common_initPokemon = PokemonManager.initPokemon

function PokemonManager:initPokemon(info)
  local pokemon = common_initPokemon(self, info)
  self:putPokemon(pokemon)
  return pokemon
end

local common_createNPCPokemon = PokemonManager.createNPCPokemon

function PokemonManager:createNPCPokemon(id, strength, playerLevel)
  local pokemon = common_createNPCPokemon(self, id, strength, playerLevel)
  self:putPokemon(pokemon)
  return pokemon
end

local common_putPokemon = PokemonManager.putPokemon

function PokemonManager:putPokemon(pokemon)
  MaxObjId = MaxObjId + 1
  local curObjId = MaxObjId
  common_putPokemon(self, pokemon, tostring(curObjId))
end

local common_removePokemon = PokemonManager.removePokemon

function PokemonManager:removePokemon(objId)
  local pokemon = self:getPokemon(objId)
  if pokemon then
    pokemon:removeAllPlayer()
  end
  common_removePokemon(self, objId)
end

function PokemonManager:subscribePokemonList(objIds, player)
  local infoList = {}
  for _, pokemon in pairs(PokemonManager:getPokemonList(objIds)) do
    pokemon:putPlayer(player.platformUserId)
    infoList[pokemon:getObjId()] = pokemon:getClientInfo()
  end
  return infoList
end

return PokemonManager
