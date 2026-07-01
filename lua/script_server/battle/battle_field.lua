local BattleField = Lib.class("BattleField")
local World = _ENV.World
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local queue = require("common.stl.queue")
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")
local SkillConfig = T(Config, "SkillConfig")
local NPCConfig = T(Config, "NPCConfig")
local battleStateMap = {
  WaitReady = require("script_server.battle.state.battle_state_wait_ready"),
  WaitStart = require("script_server.battle.state.battle_state_wait_start"),
  Feature = require("script_server.battle.state.battle_state_feature"),
  WaitCommand = require("script_server.battle.state.battle_state_wait_command"),
  ExecuteCommand = require("script_server.battle.state.battle_state_execute_command"),
  DeBuff = require("script_server.battle.state.battle_state_debuff"),
  End = require("script_server.battle.state.battle_state_end")
}
local CMD_PRIORITY = {
  [Define.BATTLE_ACTION.NONE] = 0,
  [Define.BATTLE_ACTION.RUNAWAY_ENEMY] = 10,
  [Define.BATTLE_ACTION.REPLACE_ENEMY] = 20,
  [Define.BATTLE_ACTION.FEATURE] = 30,
  [Define.BATTLE_ACTION.BALL] = 40,
  [Define.BATTLE_ACTION.RUNAWAY] = 50,
  [Define.BATTLE_ACTION.REPLACE] = 60,
  [Define.BATTLE_ACTION.REPLACE_HOST] = 61,
  [Define.BATTLE_ACTION.ITEM] = 70,
  [Define.BATTLE_ACTION.SKILL] = 80,
  [Define.BATTLE_ACTION.DEBUFF] = 90
}
Lib.setDefault(CMD_PRIORITY, 0)

local function getActionSpeed(cmd)
  local caster = cmd.caster
  if not caster or not caster:isValid() then
    return 1
  end
  caster = caster.isPlayer and caster:getBattlePet() or caster
  if not caster or not caster:isValid() then
    return 1
  end
  local speed = caster:getEffectiveSpeed()
  if cmd.type == Define.BATTLE_ACTION.SKILL then
    speed = speed + SkillConfig:getSkillSpeedById(cmd.param)
  end
  return speed
end

function BattleField:ctor(param, uid)
  self.uid = uid
  self.enemyData = {}
  for _, pokemonQueue in pairs(param.enemy or {}) do
    for _, pokemon in pairs(pokemonQueue) do
      table.insert(self.enemyData, pokemon)
    end
  end
  self.param = param
  self.mode = param.mode
  self.endCallBack = param.endCallBack
  self.maxPlayerNum = param.playerNum
  self.entityList = {}
  self.playerList = Lib.newWeakTable()
  self.hostList = {}
  for _, player in pairs(param.playerList or {}) do
    self.playerList[player.objID] = player
  end
  self.removed = false
  self.map = World.CurWorld:createDynamicMap(param.map, true)
  self.battleState = nil
  self.battleActionQueue = queue.new()
  self.rounds = 0
  self.isMaxRound = false
  self.firstExecuteCommand = true
  self.waitFlag = false
  self.curCmd = nil
  self.roundStartTime = os.time()
  self:init(param, uid)
  if self.maxPlayerNum > 1 then
    self:changeBattleState("WaitReady")
  else
    self:changeBattleState("WaitStart")
  end
end

function BattleField:init(param, uid)
end

function BattleField:isPlayerFull()
  return Lib.getTableSize(self.playerList) == self.maxPlayerNum
end

function BattleField:isValid()
  return not self.removed
end

function BattleField:getEnemyPokemonList(player)
  if self.mode == Define.BATTLE_MODE.PVP then
    local ret = {}
    for _, enemy in pairs(self:getEnemyDataList(player)) do
      for _, battlePetId in pairs(enemy:getValue("battlePetList") or {}) do
        local battlePet = PokemonManager:getPokemon(battlePetId)
        if battlePet then
          table.insert(ret, battlePet)
        end
      end
    end
    return ret
  else
    return self.enemyData
  end
end

function BattleField:checkStateReady()
  if self.waitFlag then
    return false
  end
  for _, player in pairs(self.playerList or {}) do
    if not player.stateReady then
      return false
    end
  end
  return true
end

function BattleField:checkCmdReady()
  for _, player in pairs(self.playerList or {}) do
    if not player.cmdReady then
      return false
    end
  end
  return true
end

function BattleField:getEntityByIndex(index)
  for _, entity in pairs(self.entityList or {}) do
    if entity and entity:isValid() and entity:getBpIndex() == index then
      return entity
    end
  end
  Lib.logError("BattleField getEntityByIndex nil", index)
  return nil
end

function BattleField:getBattleFieldLevel()
  return self.battleLevel or 0
end

function BattleField:getPosByIndex(index)
  if 1 <= index and index <= 3 then
    return self:getBattleFieldPos("selfPos")[index]
  elseif 4 <= index and index <= 6 then
    return self:getBattleFieldPos("selfPetPos")[index - 3]
  elseif 7 <= index and index <= 9 then
    return self:getBattleFieldPos("enemyPos")[index - 6]
  elseif 10 <= index and index <= 12 then
    return self:getBattleFieldPos("enemyPetPos")[index - 9]
  end
  Lib.logError("getPosByIndex return nil", index)
  return nil
end

function BattleField:processCommand(cmd)
  self.curCmd = cmd
  cmd.executeStartTime = os.time()
  local result = cmd:execute(self)
  local player = cmd.caster
  if player and player:isValid() and player.isPlayer then
    player.curCmdType = cmd.type
    player.cmdResult = result
  end
end

function BattleField:isMaxRoundWin(player)
  return false
end

function BattleField:doAIPolicy()
end

function BattleField:doHostingPolicy()
  for _, npc in pairs(self.hostList or {}) do
    if npc:canBattle() then
      if not npc:getBattlePet() or not npc:getBattlePet():isValid() then
        self.battleActionQueue:push(BattleActionCmdFactory.create({
          caster = npc,
          target = nil,
          type = Define.BATTLE_ACTION.REPLACE_HOST
        }))
        Lib.logDebug("doHostingPolicy REPLACE_HOST")
      else
        local skillId = npc:getRandomCanUseSkillId()
        if skillId ~= -1 then
          self.battleActionQueue:push(BattleActionCmdFactory.create({
            caster = npc,
            target = nil,
            type = Define.BATTLE_ACTION.SKILL,
            param = skillId
          }))
          Lib.logDebug("doHostingPolicy SKILL", skillId)
        end
      end
    end
  end
end

function BattleField:autoReplacePet()
  for _, player in pairs(self.playerList) do
    local pet = player:getBattlePet()
    if pet and not pet:isValid() and player:canBattle() then
      player:resetBattleState()
      player:sendPacket({pid = "replacePet"})
    end
  end
  self:sendPlayerReadyInfo()
end

function BattleField:checkPetValid()
  for _, player in pairs(self.playerList) do
    local pet = player:getBattlePet()
    if pet and (not pet:isValid() or pet.curHp <= 0) and player and player:isValid() and player:canBattle() then
      return false
    end
  end
  return true
end

function BattleField:checkBattleEnd()
  return false
end

function BattleField:getRandomAITarget()
  local tb = {}
  for _, player in pairs(self.playerList or {}) do
    table.insert(tb, player)
  end
  for _, host in pairs(self.hostList or {}) do
    table.insert(tb, host)
  end
  if 0 < #tb then
    local result = tb[math.random(#tb)]
    if result and result:isValid() and result:getBattlePet() and result:getBattlePet():isValid() then
      return result
    end
  end
  for _, player in pairs(self.playerList or {}) do
    if player and player:isValid() and player:getBattlePet() and player:getBattlePet():isValid() then
      return player
    end
  end
  return nil
end

function BattleField:setAllStateReady(value)
  Lib.logInfo("BattleField:setAllStateReady", value)
  for _, player in pairs(self.playerList or {}) do
    player:setStateReady(value)
  end
end

function BattleField:setAllCmdReady(value)
  for _, player in pairs(self.playerList or {}) do
    player:setCmdReady(value)
  end
end

function BattleField:changeBattleState(newState)
  Lib.logDebug("changeBattleState", newState)
  if self.battleState then
    self.battleState:leave()
    self.curCmd = nil
    self:setAllStateReady(false)
  end
  local class = battleStateMap[newState]
  if class then
    self.battleState = class.new(self)
    self:setAllStateReady(false)
    self.curCmd = nil
    self.battleState:enter()
  end
end

function BattleField:getPlayerSpeed(player)
  local result = 0
  for _, _player in pairs(self.playerList) do
    if _player and _player:isValid() and _player:getCampId() == player:getCampId() then
      local pet = _player:getBattlePet()
      result = math.max(pet:getEffectiveSpeed(), result)
    end
  end
  return result
end

function BattleField:getEnemySpeed(player)
  local result = 0
  for i, pet in pairs(self:getEnemyDataList(player)) do
    if pet and pet:isValid() then
      result = math.max(pet:getEffectiveSpeed(), result)
    end
  end
  return result
end

function BattleField:getEnemyDataList(entity)
  return {}
end

function BattleField:getBattleMode()
  return self.mode
end

function BattleField:isWin(player)
  return false
end

function BattleField:isLose(player)
  return false
end

function BattleField:notifyStateReady(player, packet)
  if self.battleState then
    self.battleState:notifyStateReady(player, packet)
  end
  player:setStateReady(true)
  self:sendPlayerReadyInfo()
end

function BattleField:getBattleFieldDoctorPos(player)
  local doctorPos
  if player.needKickedOutGloryHall and player._lastMap.name == World.cfg.gloryHallMap then
    player.needKickedOutGloryHall = false
    doctorPos = World.cfg.doctorPos
  else
    doctorPos = self.map.cfg.doctorPos or World.cfg.doctorPos
  end
  return doctorPos
end

function BattleField:getBattleFieldPos(key)
  local battleFieldPos = self.map.cfg.battleFieldPos or World.cfg.battleFieldPos
  return battleFieldPos[key]
end

function BattleField:isEnemy(entity, player)
  local master = entity:getMaster()
  if not master then
    return true
  end
  return master:getCampId() ~= player:getCampId()
end

function BattleField:createPet(player, pokemon, hide)
  hide = hide or false
  local lastPet = player:getBattlePet()
  if lastPet and lastPet:isValid() then
    Lib.logError("createPet lastPet isValid")
    return nil
  end
  pokemon = pokemon or player:getFirstBattlePokemon()
  if not pokemon then
    Lib.logError("BattleField:createPet not pokemon")
    return nil
  end
  local pos = self:getPosByIndex(player:getBpIndex() + 3)
  local pet = EntityServer.Create({
    pos = pos,
    ry = pos.yaw,
    rp = pos.pitch,
    map = self.map,
    cfgName = pokemon:getCfgFullName()
  }, function(entity)
    if entity and entity:isValid() then
      entity.needHide = hide
      player:setValue("curBattlePetObjID", entity.objID)
    end
  end)
  if not pet then
    return nil
  end
  pet.onGround = true
  pet:setInBattle(true)
  pet:stopAI()
  pet:setBattleAttr(pokemon, self)
  pet.battleField = self
  pet:setCampId(player:getCampId())
  pet:setBpIndex(player:getBpIndex() + 3)
  pet:setRotationYaw(pos.yaw or 0)
  pet:setRotationPitch(pos.pitch or 0)
  self.entityList[pet:getBpIndex()] = pet
  player:setBattlePet(pet)
  player:setCurBattlePetName(pokemon:getName())
  player:setValue("curBattlePetBallId", pokemon:getBallId())
  self:onCreatePet(player, pokemon, pet)
  Lib.logDebug("BattleField:createPet", player.name, player:getBpIndex(), pokemon:getObjId(), pokemon:getName(), pokemon:getCfgFullName(), pet:getBpIndex())
  return pet
end

function BattleField:onCreatePet(player, pokemon, pet)
  local arr = player:getValue("curBattlePetList")
  arr[pet:getBpIndex()] = pokemon.objId
  player:setValue("curBattlePetList", arr)
  local teamMate = player:getMyTeamMate()
  if teamMate then
    arr = teamMate:getValue("curBattlePetList")
    arr[pet:getBpIndex()] = pokemon.objId
    teamMate:setValue("curBattlePetList", arr)
  end
  if player and player.isHostAI then
    for _, other in pairs(self.playerList or {}) do
      if other:getCampId() == player:getCampId() then
        arr = other:getValue("curBattlePetList")
        arr[pet:getBpIndex()] = pokemon.objId
        other:setValue("curBattlePetList", arr)
      else
        local arr = other:getValue("curEnemyPetList")
        arr[pet:getBpIndex()] = pokemon.objId
        other:setValue("curEnemyPetList", arr)
      end
    end
  end
end

function BattleField:onPokemonDead(entity)
  self:addNoneCmd(1000)
  local master = entity:getMaster()
  if master and master:isValid() and master.isPlayer then
    master:setStateReady(true)
    master:setCmdReady(true)
  end
  if master and master.isHostAI and master:canBattle() then
    self.battleActionQueue:push(BattleActionCmdFactory.create({
      caster = master,
      target = nil,
      type = Define.BATTLE_ACTION.REPLACE_HOST
    }), 2)
  end
end

function BattleField:sortBattleActionQueue(sortFunc)
  sortFunc = sortFunc or function(a, b)
    a.extraPriority = a.extraPriority or 0
    b.extraPriority = b.extraPriority or 0
    if a.type == b.type then
      if a.param and b.param and type(a.param) == "table" and type(b.param) == "table" and a.param.addTime and b.param.addTime then
        return a.param.addTime + a.extraPriority < b.param.addTime + b.extraPriority
      else
        local priorityA = getActionSpeed(a) + a.extraPriority
        local priorityB = getActionSpeed(b) + b.extraPriority
        if priorityA == priorityB then
          return a.randomPriority > b.randomPriority
        else
          return priorityA > priorityB
        end
      end
    end
    return CMD_PRIORITY[a.type] + a.extraPriority < CMD_PRIORITY[b.type] + b.extraPriority
  end
  self.battleActionQueue:sort(sortFunc)
end

function BattleField:doThrowBall(index, pokemon, caster)
  local entity = self:getEntityByIndex(index) or caster
  if entity and entity:getPokemon() and entity:getPokemon():getCurHp() > 0 then
    self:setAllStateReady(true)
    Lib.logError("BattleField doThrowBall pokemon CurHp > 0", index)
    return
  end
  if not entity then
    self:setAllStateReady(true)
    Lib.logError("BattleField doThrowBall not entity", index)
    return
  end
  self:sendBattleFieldBroadcast({
    pid = "ThrowBall",
    objID = entity.objID,
    name = pokemon:getName(),
    ballId = pokemon:getBallId(),
    isHostAI = entity.isHostAI,
    bpIndex = index
  })
  Lib.logDebug("BattleField doThrowBall", index)
end

function BattleField:is2V2Mode()
  if self.mode == Define.BATTLE_MODE.PVE and self.maxPlayerNum == 2 then
    return true
  end
  if self.mode == Define.BATTLE_MODE.NPC and #self.param.enemy == 2 then
    return true
  end
  if self.mode == Define.BATTLE_MODE.PVP and self.maxPlayerNum == 4 then
    return true
  end
  return false
end

function BattleField:enemyReplaceFinish(posIndex, queueIndex, pokemon)
end

function BattleField:addNoneCmd(delayTime)
  if self.battleState then
    self.battleActionQueue:push(BattleActionCmdFactory.create({
      caster = nil,
      target = nil,
      type = Define.BATTLE_ACTION.NONE,
      param = delayTime
    }), 1)
    Lib.logDebug("addNoneCmd", delayTime)
  end
end

function BattleField:onBattleAction(player, packet)
  if not player.cmdReady then
    local pokemon = PokemonManager:getPokemon(packet.targetId)
    self.battleActionQueue:push(BattleActionCmdFactory.create({
      caster = player,
      target = self:reSelectTarget(pokemon, player),
      type = packet.type,
      param = packet.param
    }))
    player:setStateReady(true)
    player:setCmdReady(true)
    Lib.logInfo("BattleField:onBattleAction", tostring(self.uid), self.rounds, tostring(player.platformUserId), player.name, packet.type, Lib.v2s(packet.param))
    self:sendPlayerReadyInfo()
    Lib.reportOperatingTime(player, os.time() - self.roundStartTime, self:is2V2Mode())
  end
end

function BattleField:sendPlayerReadyInfo()
  local allReady = self:checkStateReady()
  for _, player in pairs(self.playerList) do
    if player and player:isValid() and player.stateReady then
      player:sendPacket({
        pid = "isPlayerReady",
        value = not allReady
      })
    end
  end
end

function BattleField:reSelectTarget(pokemon, entity)
  return nil
end

function BattleField:enter(player, index, campId, enemyList)
  if player:isInBattle() then
    Lib.logError("BattleField enter player isInBattle!", player and player:isValid() and player.name)
    return
  end
  player.lockEnterPVP = true
  player.isHosting = false
  player._lastMap = player.map
  player._lastPos = player:getPosition()
  player._lastRotationYaw = player:getRotationYaw()
  player._lastRotationPitch = player:getRotationPitch()
  player.catchFailCount = 0
  player:setStateReady(false)
  player:setBattlePet(nil)
  player:setValue("curBattlePetList", {}, true)
  player:setValue("curEnemyPetList", {}, true)
  player.enemyList = enemyList or {}
  self.playerList[player.objID] = player
  self:onEnter(player, index, campId)
  player.battleField = self
  self:createPet(player, nil, true)
  if Lib.getTableSize(self.playerList) == self.maxPlayerNum then
    self:onPlayerReady()
  end
end

function BattleField:onEnter(player, index, campId)
end

function BattleField:onPlayerReady()
  for _, player in pairs(self.playerList) do
    if player and player:isValid() then
      self:sendBattleFieldInfo(player, player.enemyList)
      player:setInBattle(true)
      player:setBattlePreType(Define.MEET_PKM_TYPE.NO_MEET_PKM)
    end
  end
end

function BattleField:sendBattleFieldInfo(player, enemyList)
  local packet = {
    pid = "BattleFieldInfo",
    mode = self.mode,
    maxPlayerNum = self.maxPlayerNum,
    npcId = self.npcId
  }
  packet.curEnemyNameList = self:getCurEnemyNameList(enemyList)
  packet.curEnemyIdList = self:getCurEnemyIdList(enemyList)
  packet.enemyQueueCount = self.param.enemy and #self.param.enemy or 0
  player:sendPacket(packet)
end

function BattleField:getCurEnemyNameList(enemyList)
  return nil
end

function BattleField:getCurEnemyIdList(enemyList)
  return nil
end

function BattleField:doHosting(player)
  if not self:checkBattleEnd() then
    self:createHostAI(player)
  end
end

function BattleField:createHostAI(player)
  local pos = self:getPosByIndex(player:getBpIndex())
  local npc = EntityServer.Create({
    pos = Lib.v3(pos.x, pos.y, pos.z),
    ry = pos.yaw,
    rp = pos.pitch,
    map = self.map,
    cfgName = "myplugin/player1",
    name = player.name
  }, function(entity)
    if entity then
      entity:data("main").actorName = player:data("main").actorName
    end
  end)
  npc:changeSkin(player:data("skin"))
  npc.isHostAI = true
  npc.onGround = true
  npc:setBpIndex(player:getBpIndex())
  npc:setCampId(player:getCampId())
  npc:setValue("battlePetList", player:getValue("battlePetList"), true)
  npc:setBattlePet(player:getBattlePet())
  player.isHosting = true
  self.hostList[player.objID] = npc
  self.entityList[player:getBpIndex()] = npc
end

function BattleField:leave(player, logout)
  if not player.battleField then
    return
  end
  self:sendPlayerReadyInfo()
  local battlePet = player:getBattlePet()
  if battlePet and battlePet:isValid() then
    self:sendBattleFieldBroadcast({
      pid = "EntityHide",
      objID = battlePet.objID,
      value = false
    })
  end
  if World.cfg.needHosting and logout then
    self:doHosting(player)
  end
  for _, battlePetId in pairs(player:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet then
      battlePet:setRunaway(false)
    end
  end
  local hasLifePet = player:checkHasLifePet()
  local needGoDoctor = false
  if self.npcId and player.curCmdType and self.npcId ~= 0 and player.curCmdType == Define.BATTLE_ACTION.RUNAWAY then
    needGoDoctor = true
  end
  if hasLifePet and not needGoDoctor then
    if player.needKickedOutGloryHall and player._lastMap.name == World.cfg.gloryHallMap then
      player.needKickedOutGloryHall = false
      player:doLeaveGloryHall()
      local packet = {
        pid = "pushGloryHallRefresh"
      }
      player:sendPacket(packet)
    else
      player.needKickedOutGloryHall = false
      player:setMapPos(player._lastMap, player._lastPos, player._lastRotationYaw, player._lastRotationPitch)
    end
  else
    local teamMate = player:getMyTeamMate()
    if teamMate and teamMate:checkHasLifePet() then
      TeamMgr:leaveTeam(player)
    end
    local doctorPos = self:getBattleFieldDoctorPos(player)
    local mapName = doctorPos.map
    local position = Lib.v3(tonumber(doctorPos.x), tonumber(doctorPos.y), tonumber(doctorPos.z))
    local map = World.CurWorld:getMap(mapName)
    player:setMapPos(map, position)
    player:recoveryBattlePokemon()
    player:sendPacket({
      pid = "showPokemonRecovery"
    })
    player:sendPacket({
      pid = "ClientAutoShowGiftWnd",
      showType = "dead"
    })
    if mapName ~= World.cfg.gloryHallMap and player:getCurGym() ~= 0 then
      player:setCurGym(0)
    end
  end
  player:setInBattle(false)
  player:setEnterBattle(false)
  player:setCanPK(1)
  player:setGymChallengeId(-1)
  player:setGymChallengeRank(-1)
  player:setGymChallengeName("")
  if self.npcId ~= 0 then
    Lib.logDebug("player setInNpc 0")
    local npc_config = NPCConfig:getNPCById(self.npcId)
    if npc_config and npc_config.gym_id and npc_config.is_pvp and npc_config.gym_id ~= 0 and npc_config.is_pvp == 1 then
      player:updatePVPGymStatus(npc_config.gym_id)
    end
    player:setInNpc(0)
  end
  if not player:isAvoidBattle() then
    player:setAvoidBattle(true)
  end
  player:setAvoidPVPBattle()
  SkillEffectMgr:clearPokemonSkillEffect(player)
  self.playerList[player.objID] = nil
  player:setValue("curBattlePetList", {}, true)
  player:setValue("curEnemyPetList", {}, true)
  player:setBattlePreType(Define.MEET_PKM_TYPE.NO_MEET_PKM)
  player:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.NO_MEET_PKM)
  self:onLeave(player)
  for _, pokemon in pairs(player:getBattlePokemon()) do
    pokemon:setFoughtCount(0)
  end
  if self:getValidPlayerCount() == 0 then
    self:onDestroy()
  end
  player.battleField = nil
  player.lockEnterPVP = false
end

function BattleField:getValidPlayerCount()
  local count = 0
  for _, player in pairs(self.playerList) do
    if player and player:isValid() then
      count = count + 1
    end
  end
  return count
end

function BattleField:onLeave(player)
end

function BattleField:onDestroy(player)
  for _, pokemon in pairs(self.enemyData) do
    pokemon:setFoughtCount(0)
  end
  local BattleFieldManager = require("script_server.battle.battle_field_manager")
  BattleFieldManager:remove(self.uid)
  self.removed = true
  if self.endCallBack then
    self.endCallBack()
  end
end

function BattleField:update_impl(tick)
  if self.battleState then
    if (self.battleState.__name == "BattleStateExecuteCommand" or self.battleState.__name == "BattleStateDeBuff") and self:checkStateReady() then
      if self:checkBattleEnd() then
        self:changeBattleState("End")
        return
      elseif not self.battleActionQueue:empty() then
        self:setAllStateReady(false)
        local cmd = self.battleActionQueue:front_pop()
        self:processCommand(cmd)
      end
    end
    self.battleState:update(tick)
  end
  local executeWaitTime = self.curCmd and World.cfg.executeWaitTimeMap[tostring(self.curCmd.type)]
  executeWaitTime = executeWaitTime or World.cfg.executeWaitTime or 10
  local curTime = os.time()
  if self.curCmd and executeWaitTime <= curTime - self.curCmd.executeStartTime then
    Lib.logError("BattleField execute Cmd Time too long!!!", tostring(self.uid), self.mode, self.rounds, self.battleState.__name, self.curCmd.type, Lib.v2s(self.curCmd.param))
    Lib.logError("*************** playerList State ***************")
    for _, player in pairs(self.playerList or {}) do
      Lib.logError(tostring(player.platformUserId), player.name, tostring(player.cmdReady), tostring(player.stateReady))
    end
    if self.curCmd.type == Define.BATTLE_ACTION.SKILL then
      self:setAllStateReady(true)
    end
    self.waitFlag = false
    self.curCmd.executeStartTime = curTime
  end
end

function BattleField:update(tick)
  if World.cfg.catchBattleFieldException then
    local func = self.update_impl
    local ok, ret = xpcall(func, debug.traceback, self, tick)
    if not ok then
      Lib.logError("[BattleField update]" .. ret)
    end
  else
    self:update_impl(tick)
  end
end

function BattleField:sendBattleFieldBroadcast(packet)
  for _, player in pairs(self.playerList) do
    player:sendPacket(packet)
  end
end

function BattleField:getNPCId()
  return nil
end

function BattleField:getEnemyQueueLiveCount()
  local ret = {}
  return ret
end

return BattleField
