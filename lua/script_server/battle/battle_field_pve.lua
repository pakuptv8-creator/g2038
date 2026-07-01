local BattleFieldPVE = Lib.class("BattleFieldPVE", require("script_server.battle.battle_field"))
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local LuaTimer = T(Lib, "LuaTimer")
local queue = require("common.stl.queue")
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")

function BattleFieldPVE:init(param, uid)
  Lib.logInfo("BattleFieldPVE:init")
  self.enemyList = {}
  self.enemyQueue = {}
  self.npcId = param.npcId
  if param.enemy then
    for _, pokemonList in pairs(param.enemy) do
      for _, pokemon in pairs(pokemonList) do
        self.battleLevel = pokemon:getLevel()
        return
      end
    end
  end
end

function BattleFieldPVE:getCurEnemyNameList(enemyList)
  local ret = {}
  for _, enemy in pairs(self.enemyList or {}) do
    if enemy and enemy:isValid() then
      table.insert(ret, enemy:getPokemon():getName())
    end
  end
  return ret
end

function BattleFieldPVE:isWin(player)
  local win = true
  for _, enemy in pairs(self.enemyList) do
    if enemy and enemy:isValid() and not (enemy.curHp <= 0) then
      win = false
      break
    end
  end
  return win
end

function BattleFieldPVE:isLose(player)
  for _, _player in pairs(self.playerList) do
    if _player and _player:isValid() and _player:canBattle() then
      return false
    end
  end
  return true
end

function BattleFieldPVE:notifyStateReady(player, packet)
  if self.battleState then
    self.battleState:notifyStateReady(player, packet)
  end
  if packet.type == Define.READY_TYPE.CATCH and player.curCmdType == Define.BATTLE_ACTION.BALL and player.cmdResult then
    local entity = player:getCatchTarget()
    if entity and entity:isValid() then
      local pokemon = entity:getPokemon()
      pokemon:setCaptured(true)
      entity:destroy()
    end
  end
  player:setStateReady(true)
end

function BattleFieldPVE:getNPCId()
  return self.npcId
end

function BattleFieldPVE:getEnemyDataList(entity)
  if entity and entity.isEnemy then
    return self.playerList or {}
  end
  return self.enemyList or {}
end

function BattleFieldPVE:isMaxRoundWin(player)
  local playerLiveNum = 0
  for _, _player in pairs(self.playerList) do
    for _, battlePetId in pairs(_player:getValue("battlePetList") or {}) do
      local battlePet = PokemonManager:getPokemon(battlePetId)
      if battlePet and 0 < battlePet:getCurHp() then
        playerLiveNum = playerLiveNum + 1
      end
    end
  end
  local enemyLiveNum = 0
  for i = 1, #self.enemyList do
    local enemy = self.enemyList[i]
    if enemy and enemy:isValid() and 0 < enemy.curHp then
      enemyLiveNum = enemyLiveNum + 1
    end
  end
  for i = 1, #self.enemyQueue do
    for j = 1, #self.enemyQueue[i]._data do
      local enemy = self.enemyQueue[i]._data[j]
      if enemy and 0 < enemy:getCurHp() then
        enemyLiveNum = enemyLiveNum + 1
      end
    end
  end
  if playerLiveNum == enemyLiveNum then
    return math.random() < 0.5 and true or false
  else
    return playerLiveNum > enemyLiveNum
  end
end

function BattleFieldPVE:getEnemyQueueLiveCount()
  local ret = {}
  for i = 1, #self.enemyQueue do
    ret[i] = {}
    for j = 1, #self.enemyQueue[i]._data do
      local enemy = self.enemyQueue[i]._data[j]
      if enemy then
        table.insert(ret[i], enemy:getObjId())
      end
    end
  end
  return ret
end

local super_onPokemonDead = BattleFieldPVE.onPokemonDead

function BattleFieldPVE:onPokemonDead(entity)
  super_onPokemonDead(self, entity)
  if entity.isEnemy then
    local queueIndex = entity:getBpIndex() - 10
    if queueIndex == 0 then
      queueIndex = 1
    end
    self:doEnemyReplace(entity.posIndex, queueIndex, entity:getBpIndex(), entity:getMaster())
  end
end

function BattleFieldPVE:doEnemyReplace(posIndex, queueIndex, index, master)
end

function BattleFieldPVE:enemyReplaceFinish(posIndex, queueIndex, pokemon)
end

function BattleFieldPVE:onEnter(player, index, campId)
  index = index or 1
  player:setBpIndex(index)
  self.entityList[player:getBpIndex()] = player
  local _selfPos = self:getPosByIndex(player:getBpIndex())
  player:setMapPos(self.map, Lib.v3(_selfPos.x, _selfPos.y, _selfPos.z), _selfPos.yaw, _selfPos.pitch)
  player:setInNpcBattle(self.npcId or false)
  player:setCampId(Define.CAMP.CAMP_NONE)
  Lib.logDebug("BattleFieldPVE:onEnter", player.name, player:getBpIndex(), _selfPos.x, _selfPos.y, _selfPos.z)
end

function BattleFieldPVE:onLeave(player)
end

local super_onPlayerReady = BattleFieldPVE.onPlayerReady

function BattleFieldPVE:onPlayerReady()
  self:initEnemy()
  self:createEnemy()
  super_onPlayerReady(self)
  for _, player in pairs(self.playerList) do
    local petList = {}
    for _, other in pairs(self.playerList) do
      if player and player:isValid() and other and other:isValid() and player:getCampId() == other:getCampId() then
        local arr = player:getValue("curBattlePetList")
        arr[other:getBpIndex() + 3] = other:getFirstBattlePokemon().objId
        player:setValue("curBattlePetList", arr)
        petList[other.platformUserId] = other:getValue("battlePetList")
        Lib.logDebug("curBattlePetList Add", player.name, other:getFirstBattlePokemon().objId)
      else
      end
    end
    player:sendPacket({
      pid = "syncBattleQueue",
      enemyPetList = petList
    })
  end
end

function BattleFieldPVE:checkBattleEnd()
  if self:isWin(nil) then
    return true
  end
  if self:isLose(nil) then
    return true
  end
  return false
end

function BattleFieldPVE:doAIPolicy()
  for _, enemy in pairs(self.enemyList or {}) do
    if enemy and enemy:isValid() then
      local skillId = enemy:getRandomCanUseSkillId()
      if skillId ~= -1 then
        self.battleActionQueue:push(BattleActionCmdFactory.create({
          caster = enemy,
          target = self:getRandomAITarget(),
          type = Define.BATTLE_ACTION.SKILL,
          param = skillId
        }))
      end
    end
  end
end

function BattleFieldPVE:initEnemy()
  if not self.param.enemy then
    return
  end
  self.enemyQueue = {}
  for i = 1, #self.param.enemy do
    table.insert(self.enemyQueue, queue.new(self.param.enemy[i]))
  end
  self:sendBattleFieldBroadcast({
    pid = "syncEnemyQueue",
    type = "ENEMY",
    queue = self:getEnemyQueueLiveCount()
  })
end

function BattleFieldPVE:createEnemy()
  if #self.enemyQueue == 1 then
    local pokemon = self.enemyQueue[1]:front()
    if self:createEnemyByIndex(1, pokemon) then
    end
  end
  if #self.enemyQueue == 2 then
    local pokemon = self.enemyQueue[1]:front()
    if self:createEnemyByIndex(2, pokemon) then
    end
    pokemon = self.enemyQueue[2]:front()
    if self:createEnemyByIndex(3, pokemon) then
    end
  end
  local tb = {}
  for _, enemy in pairs(self.enemyList or {}) do
    if enemy and enemy:getPokemon() then
      tb[enemy:getBpIndex()] = enemy:getPokemon().objId
    end
  end
  for _, player in pairs(self.playerList) do
    player:setValue("curEnemyPetList", tb)
  end
end

function BattleFieldPVE:createEnemyByIndex(index, pokemon)
  if not pokemon then
    Lib.logError("createEnemyByIndex not pokemon")
    return false
  end
  if self.enemyList[index] and self.enemyList[index]:isValid() then
    return false
  end
  local enemyPetPos = self:getBattleFieldPos("enemyPetPos")
  local enemy = EntityServer.Create({
    pos = enemyPetPos[index],
    ry = enemyPetPos[index].yaw,
    rp = enemyPetPos[index].pitch,
    map = self.map,
    cfgName = pokemon:getCfgFullName()
  })
  if not enemy then
    return false
  end
  enemy:setInBattle(true)
  enemy:setBattleAttr(pokemon, self)
  self.enemyList[index] = enemy
  enemy.battleField = self
  enemy.isEnemy = true
  enemy.posIndex = index
  enemy:setBpIndex(index + 9)
  pokemon.posIndex = index
  pokemon.bpIndex = index + 9
  self.entityList[enemy:getBpIndex()] = enemy
  enemy.onGround = true
  enemy:setRotationYaw(enemyPetPos[index].yaw)
  enemy:setRotationPitch(enemyPetPos[index].pitch)
  enemy:stopAI()
  local master = self:getEntityByIndex(enemy:getBpIndex() - 3)
  if master then
    master:setBattlePet(enemy)
    enemy:setCampId(master:getCampId())
  else
    enemy:setCampId(Define.CAMP.CAMP_B)
  end
  for _, player in pairs(self.playerList) do
    local arr = player:getValue("curEnemyPetList")
    arr[enemy:getBpIndex()] = pokemon.objId
    player:setValue("curEnemyPetList", arr)
  end
  self.battleActionQueue:push(BattleActionCmdFactory.create({
    caster = enemy,
    target = nil,
    type = Define.BATTLE_ACTION.FEATURE
  }))
  self:sortBattleActionQueue()
  Lib.logDebug("BattleFieldPVE:createEnemyByIndex", enemy.objID)
  return true
end

function BattleFieldPVE:reSelectTarget(pokemon, entity)
  if not pokemon then
    for _, enemy in pairs(self:getEnemyDataList(entity)) do
      if enemy and enemy:isValid() then
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
  target = self:getEnemyDataList(entity)[index]
  if target and target:isValid() then
    return target.isPlayer and target:getBattlePet() or target
  end
  for _, enemy in pairs(self:getEnemyDataList(entity)) do
    if enemy and enemy:isValid() then
      return enemy.isPlayer and enemy:getBattlePet() or enemy
    end
  end
  return nil
end

return BattleFieldPVE
