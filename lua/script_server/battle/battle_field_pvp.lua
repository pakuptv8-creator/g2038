local BattleFieldPVP = Lib.class("BattleFieldPVP", require("script_server.battle.battle_field"))
local PokemonManager = require("script_server.pokemon.pokemon_manager")

function BattleFieldPVP:onEnter(player, index, campId)
  campId = campId or Define.CAMP.CAMP_A
  player:setBpIndex(index)
  self.entityList[player:getBpIndex()] = player
  local _selfPos = self:getPosByIndex(player:getBpIndex())
  player:setMapPos(self.map, Lib.v3(_selfPos.x, _selfPos.y, _selfPos.z), _selfPos.yaw, _selfPos.pitch)
  player:setInNpcBattle(false)
  player:setCampId(campId)
  Lib.logDebug("BattleFieldPVP:onEnter", player.name, index, campId)
end

function BattleFieldPVP:getCurEnemyNameList(enemyList)
  local ret = {}
  for _, enemy in pairs(enemyList or {}) do
    if enemy and enemy:isValid() then
      table.insert(ret, enemy.name)
    end
  end
  return ret
end

function BattleFieldPVP:getCurEnemyIdList(enemyList)
  local ret = {}
  for _, enemy in pairs(enemyList or {}) do
    if enemy and enemy:isValid() then
      table.insert(ret, enemy.objID)
    end
  end
  return ret
end

function BattleFieldPVP:checkBattleEnd()
  local campALose = true
  local campBLose = true
  for _, player in pairs(self.playerList) do
    if player and player:isValid() and player:canBattle() then
      if player:getCampId() == Define.CAMP.CAMP_A then
        campALose = false
      else
        campBLose = false
      end
    end
  end
  return campALose or campBLose
end

function BattleFieldPVP:getEnemyDataList(entity)
  if not entity then
    return {}
  end
  local list = {}
  for i, p in pairs(self.playerList) do
    if p:getCampId() ~= entity:getCampId() then
      table.insert(list, p)
    end
  end
  return list
end

function BattleFieldPVP:isWin(player)
  local win = true
  for _, enemy in pairs(self:getEnemyDataList(player)) do
    if enemy and enemy:isValid() and enemy:canBattle() then
      win = false
      break
    end
  end
  return win
end

function BattleFieldPVP:isLose(player)
  for _, _player in pairs(self.playerList) do
    if _player and _player:isValid() and _player:getCampId() == player:getCampId() and _player:canBattle() then
      return false
    end
  end
  return true
end

function BattleFieldPVP:isMaxRoundWin(player)
  local playerLiveNum = 0
  local enemyLiveNum = 0
  for _, _player in pairs(self.playerList) do
    for _, battlePetId in pairs(_player:getValue("battlePetList") or {}) do
      local battlePet = PokemonManager:getPokemon(battlePetId)
      if battlePet and 0 < battlePet:getCurHp() then
        if _player:getCampId() == player:getCampId() then
          playerLiveNum = playerLiveNum + 1
        else
          enemyLiveNum = enemyLiveNum + 1
        end
      end
    end
  end
  if playerLiveNum == enemyLiveNum then
    self.maxRoundWinCamp = self.maxRoundWinCamp or math.random(2)
    return player:getCampId() == self.maxRoundWinCamp
  else
    return playerLiveNum > enemyLiveNum
  end
end

function BattleFieldPVP:reSelectTarget(pokemon, entity)
  if not pokemon then
    for _, enemy in pairs(self:getEnemyDataList(entity)) do
      if enemy and enemy:isValid() and enemy:getBattlePet() and enemy:getBattlePet():isValid() then
        return enemy.isPlayer and enemy:getBattlePet() or enemy
      end
    end
    return nil
  end
  local target = pokemon:getEntity()
  if target and target:isValid() then
    return target
  end
  local index = pokemon.bpIndex or -1
  if pokemon:getEntity() and pokemon:getEntity().getBpIndex then
    index = pokemon:getEntity():getBpIndex() or -1
  end
  target = self:getEntityByIndex(index)
  if target and target:isValid() then
    return target.isPlayer and target:getBattlePet() or target
  end
  for _, enemy in pairs(self:getEnemyDataList(entity)) do
    if enemy and enemy:isValid() and enemy:getBattlePet() and enemy:getBattlePet():isValid() then
      return enemy.isPlayer and enemy:getBattlePet() or enemy
    end
  end
  return nil
end

local super_onPokemonDead = BattleFieldPVP.onPokemonDead

function BattleFieldPVP:onPokemonDead(entity)
  super_onPokemonDead(self, entity)
end

local super_onCreatePet = BattleFieldPVP.onCreatePet

function BattleFieldPVP:onCreatePet(player, pokemon, pet)
  super_onCreatePet(self, player, pokemon, pet)
  for _, enemy in pairs(self:getEnemyDataList(player)) do
    if enemy and enemy:isValid() then
      local arr = enemy:getValue("curEnemyPetList")
      arr[pet:getBpIndex()] = pokemon.objId
      enemy:setValue("curEnemyPetList", arr)
      Lib.logDebug("curEnemyPetList Add", enemy.name, pokemon.objId)
    end
  end
end

local super_onPlayerReady = BattleFieldPVP.onPlayerReady

function BattleFieldPVP:onPlayerReady()
  super_onPlayerReady(self)
  for _, player in pairs(self.playerList) do
    local petList = {}
    for _, other in pairs(self.playerList) do
      if player and player:isValid() and other and other:isValid() then
        if player:getCampId() == other:getCampId() then
          local arr = player:getValue("curBattlePetList")
          arr[other:getBpIndex() + 3] = other:getFirstBattlePokemon().objId
          player:setValue("curBattlePetList", arr)
          petList[other.platformUserId] = other:getValue("battlePetList")
          Lib.logDebug("curBattlePetList Add", player.name, other:getFirstBattlePokemon().objId)
        else
          local arr = player:getValue("curEnemyPetList")
          arr[other:getBpIndex() + 3] = other:getFirstBattlePokemon().objId
          player:setValue("curEnemyPetList", arr)
          petList[other.platformUserId] = other:getValue("battlePetList")
          Lib.logDebug("curEnemyPetList Add", player.name, other:getFirstBattlePokemon().objId)
        end
      end
    end
    player:sendPacket({
      pid = "syncBattleQueue",
      enemyPetList = petList
    })
  end
end

return BattleFieldPVP
