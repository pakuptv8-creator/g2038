local BattleFieldNPC = Lib.class("BattleFieldNPC", require("script_server.battle.battle_field_pve"))
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")
local LuaTimer = T(Lib, "LuaTimer")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local super_init = BattleFieldNPC.init

function BattleFieldNPC:init(param, uid)
  Lib.logDebug("BattleFieldNPC:init")
  super_init(self, param, uid)
  self.npcList = {}
  self:createNpc(param.npcCfg)
end

function BattleFieldNPC:onEnter(player, index, campId)
  index = index or 1
  if World.cfg.enableNpcHost and not player:isJoinTeam() and #self.param.enemy == 2 then
    index = 2
    self:createHostNpc(player, index + 1, campId)
  end
  player:setBpIndex(index)
  self.entityList[player:getBpIndex()] = player
  local _selfPos = self:getPosByIndex(player:getBpIndex())
  player:setMapPos(self.map, Lib.v3(_selfPos.x, _selfPos.y, _selfPos.z), _selfPos.yaw, _selfPos.pitch)
  player:setInNpcBattle(self.npcId or false)
  player:setCampId(Define.CAMP.CAMP_NONE)
  Lib.logDebug("BattleFieldNPC:onEnter", player.name, player:getBpIndex(), _selfPos.x, _selfPos.y, _selfPos.z)
end

function BattleFieldNPC:createHostNpc(player, index, campId)
  local pos = self:getPosByIndex(index)
  local npc = EntityServer.Create({
    pos = Lib.v3(pos.x, pos.y, pos.z),
    ry = pos.yaw,
    rp = pos.pitch,
    map = self.map,
    cfgName = self.param.hostCfg.cfgName
  })
  npc.isHostAI = true
  npc.onGround = true
  npc:setBpIndex(index)
  npc:setCampId(campId)
  local tb = {}
  for i = 1, #self.param.hostCfg.pokemonList do
    table.insert(tb, self.param.hostCfg.pokemonList[i]:getObjId())
  end
  npc:setValue("battlePetList", tb, true)
  self:createPet(npc, self.param.hostCfg.pokemonList[1])
  player:setValue("hostTeamMateId", npc.objID)
  self.hostList[player.objID] = npc
  self.entityList[player:getBpIndex()] = npc
  self:sendBattleFieldBroadcast({
    pid = "syncEnemyQueue",
    type = "HOST",
    queue = tb
  })
  Lib.logDebug("BattleFieldNPC createHostNpc", index, campId)
end

function BattleFieldNPC:createNpc(npcCfg)
  if not npcCfg then
    return
  end
  if #npcCfg == 1 then
    self:createNpcByIndex(npcCfg[1], 7)
  else
    self:createNpcByIndex(npcCfg[1], 8)
    self:createNpcByIndex(npcCfg[2], 9)
  end
end

function BattleFieldNPC:createNpcByIndex(cfg, index)
  Lib.logDebug("createNpcByIndex self.param.npcName = ", self.param.npcName)
  local enemyPos = self:getPosByIndex(index)
  local npc = EntityServer.Create({
    pos = enemyPos,
    ry = enemyPos.yaw,
    rp = enemyPos.pitch,
    map = self.map,
    cfgName = cfg,
    name = self.param.npcName
  })
  if not npc then
    Lib.logError("BattleFieldNPC createNpcByIndex not npc", cfg)
    return
  end
  if self.param.actorName and self.param.skin then
    npc:changeActor(self.param.actorName, self.param.skin)
  end
  npc.onGround = true
  npc:setBpIndex(index)
  if npc:getBpIndex() == 7 or npc:getBpIndex() == 8 then
    npc.pokemonQueue = self.param.enemy[1] or {}
  else
    npc.pokemonQueue = self.param.enemy[2] or {}
  end
  npc:setCampId(Define.CAMP.CAMP_B)
  local tb = {}
  for i = 1, #npc.pokemonQueue do
    table.insert(tb, npc.pokemonQueue[i]:getObjId())
  end
  npc:setValue("battlePetList", tb, true)
  self.entityList[npc:getBpIndex()] = npc
  self.npcList[npc:getBpIndex()] = npc
end

function BattleFieldNPC:doEnemyReplace(posIndex, queueIndex, index, master)
  queueIndex = queueIndex or 1
  if not (master and master:isValid()) or not master:canBattle() then
    return
  end
  self.battleActionQueue:push(BattleActionCmdFactory.create({
    caster = master,
    target = nil,
    type = Define.BATTLE_ACTION.REPLACE_ENEMY,
    param = {
      posIndex = posIndex,
      queueIndex = queueIndex,
      bpIndex = index
    }
  }))
  self:sortBattleActionQueue()
  Lib.logDebug("BattleFieldNPC doEnemyReplace", posIndex, queueIndex, index)
end

function BattleFieldNPC:enemyReplaceFinish(posIndex, queueIndex, pokemon, master)
  queueIndex = queueIndex or 1
  self.enemyList[posIndex] = nil
  self:createEnemyByIndex(posIndex, pokemon)
end

function BattleFieldNPC:getLivePokemonCount(master)
  local ret = 0
  for _, battlePetId in pairs(master:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet and 0 < battlePet:getCurHp() then
      ret = ret + 1
    end
  end
  return ret
end

function BattleFieldNPC:isWin(player)
  for _, npc in pairs(self.npcList) do
    if npc and npc:isValid() and npc:canBattle() then
      return false
    end
  end
  return true
end

local super_onDestroy = BattleFieldNPC.onDestroy

function BattleFieldNPC:onDestroy(player)
  for i, npc in pairs(self.npcList) do
    LuaTimer:cancel(npc.enemyReplaceTimer)
  end
  super_onDestroy(self, player)
end

return BattleFieldNPC
