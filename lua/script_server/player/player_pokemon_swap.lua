local handles = T(Player, "PackageHandlers")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local LuaTimer = T(Lib, "LuaTimer")

local function sendShowApplySwap(self, targetId)
  self:sendPacket({
    pid = "showApplySwap",
    targetId = targetId
  })
end

local function sendStartSwap(self, targetId)
  self:sendPacket({pid = "swapStart", targetId = targetId})
end

local function sendQuitSwap(self, targetId, code)
  self:sendPacket({
    pid = "quitSwap",
    targetId = targetId,
    code = code or Define.SWAP_END_CODE.CANCEL
  })
end

local function sendSwapResult(self, pokemonObjId)
  self:sendPacket({pid = "swapResult", objId = pokemonObjId})
end

local function givePokemon(fromPlayer, toPlayer, pokemon)
  local function removePacketPokemon(player, swapObjId)
    local packetPetList = player:getValue("packetPetList")
    
    for index, objId in pairs(packetPetList) do
      if objId == swapObjId then
        table.remove(packetPetList, index)
      end
    end
    player:setPacketPetList(packetPetList)
  end
  
  removePacketPokemon(fromPlayer, pokemon:getObjId())
  toPlayer:gainPokemon(pokemon)
  GameAnalytics.Design(toPlayer.platformUserId, 1, {
    "business_pet",
    pokemon:getCfgId()
  })
  sendSwapResult(toPlayer, pokemon:getObjId())
end

local function swapPokemon(player1, player2)
  local swapObjId1 = player1:getValue("swapPokemonObjId")
  local swapObjId2 = player2:getValue("swapPokemonObjId")
  local pokemon1 = player1:getSelfPokemon(swapObjId1)
  local pokemon2 = player2:getSelfPokemon(swapObjId2)
  if swapObjId1 ~= 0 and not pokemon1 then
    return Define.SWAP_END_CODE.ERROR
  end
  if swapObjId2 ~= 0 and not pokemon2 then
    return Define.SWAP_END_CODE.ERROR
  end
  if pokemon1 and pokemon1:getQuality() == Define.POKEMON_QUALITY.MYTHICAL then
    return Define.SWAP_END_CODE.ERROR
  end
  if pokemon2 and pokemon2:getQuality() == Define.POKEMON_QUALITY.MYTHICAL then
    return Define.SWAP_END_CODE.ERROR
  end
  if pokemon1 and player2:isPokemonPacketFull() then
    return Define.SWAP_END_CODE.FULL
  end
  if pokemon2 and player1:isPokemonPacketFull() then
    return Define.SWAP_END_CODE.FULL
  end
  if pokemon1 then
    givePokemon(player1, player2, pokemon1)
  else
    sendSwapResult(player2, 0)
  end
  if pokemon2 then
    givePokemon(player2, player1, pokemon2)
  else
    sendSwapResult(player1, 0)
  end
  GameAnalytics.Design(player1.platformUserId, 1, {
    "business_success"
  })
  GameAnalytics.Design(player2.platformUserId, 1, {
    "business_success"
  })
  return Define.SWAP_END_CODE.SUCCESS
end

function handles:applySwap(packet)
  local otherPlayer = World.CurWorld:getObject(packet.targetId)
  if not otherPlayer or not otherPlayer:isValid() then
    return 1
  end
  if self:getSwapTargetId() == otherPlayer.objID then
    handles.playerSwap(self, packet)
    return 0
  end
end

function handles:playerSwap(packet)
  local otherPlayer = World.CurWorld:getObject(packet.targetId)
  self:setValue("swapPokemonObjId", 0)
  otherPlayer:setValue("swapPokemonObjId", 0)
  GameAnalytics.Design(otherPlayer.platformUserId, 1, {
    "business_enter"
  })
  GameAnalytics.Design(self.platformUserId, 1, {
    "business_enter"
  })
  sendStartSwap(otherPlayer, self.objID)
  sendStartSwap(self, otherPlayer.objID)
end

function handles:quitSwap(packet)
  local otherPlayer = World.CurWorld:getObject(self:getSwapTargetId())
  if not otherPlayer or not otherPlayer:isValid() then
    return
  end
  handles.finishPlayerAction(otherPlayer)
  handles.finishPlayerAction(self)
  self:setValue("swapSure", false)
  otherPlayer:setValue("swapSure", false)
  sendQuitSwap(self, otherPlayer.objID, packet.code)
  sendQuitSwap(otherPlayer, self.objID, packet.code)
  self:setSwapTargetId(0)
  otherPlayer:setSwapTargetId(0)
end

function handles:sureSwap(packet)
  local otherPlayer = World.CurWorld:getObject(self:getSwapTargetId())
  if not otherPlayer or not otherPlayer:isValid() then
    return
  end
  if otherPlayer:getValue("swapSure") then
    local code = swapPokemon(self, otherPlayer)
    handles.quitSwap(self, {pid = "quitSwap", code = code})
  else
    self:setValue("swapSure", true)
  end
end

function handles:banSwap(packet)
  self:setBanSwap(true)
  LuaTimer:schedule(function()
    self:setBanSwap(false)
  end, World.cfg.swapBanTime * 1000)
end

function handles:selectSwapPokemon(packet)
  local otherPlayer = World.CurWorld:getObject(self:getSwapTargetId())
  if not otherPlayer or not otherPlayer:isValid() then
    return {success = true}
  end
  if self:getValue("swapSure") then
    return {
      success = false,
      lang = "gui.swap.pokemon.already.lock"
    }
  end
  if packet.objId ~= 0 then
    local pokemon = self:getSelfPokemon(packet.objId)
    if not pokemon then
      return {
        success = false,
        lang = "gui.swap.pokemon.not.exist"
      }
    end
    if pokemon:getMasterId() ~= self.platformUserId then
      return {
        success = false,
        lang = "gui.swap.pokemon.not.me"
      }
    end
    local battlePetList = self:getValue("battlePetList")
    for _, objId in pairs(battlePetList) do
      if objId == packet.objId then
        return {
          success = false,
          lang = "gui.swap.pokemon.in.battle"
        }
      end
    end
    if pokemon:getQuality() == Define.POKEMON_QUALITY.MYTHICAL then
      return {
        success = false,
        lang = "gui.swap.pokemon.is.epic"
      }
    end
  end
  self:setValue("swapPokemonObjId", packet.objId)
  if otherPlayer:getValue("swapSure") then
    otherPlayer:setValue("swapSure", false)
  end
  return {success = true}
end
