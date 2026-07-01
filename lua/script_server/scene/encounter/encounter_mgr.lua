local EncounterMgr = _ENV.EncounterMgr
local BattleFieldManager = require("script_server.battle.battle_field_manager")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local encounterMap = {
  [Define.MEET_PKM_TYPE.HIDE_PKM] = require("script_server.scene.encounter.encounter_hide_pkm"),
  [Define.MEET_PKM_TYPE.BRIGHT_PKM] = require("script_server.scene.encounter.encounter_bright_pkm"),
  [Define.MEET_PKM_TYPE.AREA_NPC_PKM] = require("script_server.scene.encounter.encounter_region")
}

function EncounterMgr:init()
  encounterMap[Define.MEET_PKM_TYPE.HIDE_PKM]:init()
  encounterMap[Define.MEET_PKM_TYPE.BRIGHT_PKM]:init()
  self.animationList = {}
  World.Timer(2, function()
    encounterMap[Define.MEET_PKM_TYPE.HIDE_PKM]:updateHideQueue()
    self:updateAnimationList()
    return true
  end)
end

function EncounterMgr:updateAnimationList()
  for userId, val in pairs(self.animationList) do
    self.animationList[userId].remainTime = self.animationList[userId].remainTime - 1
    if self.animationList[userId].remainTime <= 0 then
      local player = Game.GetPlayerByUserId(userId)
      if not player or not player:isValid() then
        self.animationList[userId] = nil
      else
        EncounterMgr:encounterEnterBattle(player, self.animationList[userId].monsterData, self.animationList[userId].meetType)
        self.animationList[userId] = nil
      end
    end
  end
end

function EncounterMgr:getAnimationTime()
  local animationList = {
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  }
  local totalTime = 0
  for key, val in pairs(animationList) do
    totalTime = totalTime + Define.PRE_ANIMATION_TIME[val]
  end
  return totalTime
end

function EncounterMgr:encounterTrigger(player, type, monsterData)
  if not player or not player:isValid() then
    return
  end
  if player:isJoinTeam() and not player:isTeamCaptain() then
    return
  end
  if player:isInBattle() then
    return
  end
  local animationTime = 0
  if encounterMap[type] and encounterMap[type].getAnimationTime then
    animationTime = encounterMap[type].getAnimationTime()
  else
    animationTime = self.getAnimationTime()
  end
  local curUserId = player.platformUserId
  self.animationList[curUserId] = {}
  self.animationList[curUserId].remainTime = animationTime * 10
  self.animationList[curUserId].monsterData = monsterData
  self.animationList[curUserId].meetType = type
  player:setBattlePreType(type)
  player:sendStartPlayPreAnimation(type, monsterData[1].rareID)
  do
    local teamMate = player:getMyTeamMate()
    if teamMate then
      teamMate:setBattlePreType(type)
      teamMate:sendStartPlayPreAnimation(type, monsterData[1].rareID)
    end
  end
end

function EncounterMgr:encounterEnterBattle(player, monsterData, meetType)
  if not player or not player:isValid() then
    return
  end
  if not player:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon", player.name)
    return
  end
  if meetType == Define.MEET_PKM_TYPE.BRIGHT_PKM and monsterData[1].brightObjID then
    encounterMap[Define.MEET_PKM_TYPE.BRIGHT_PKM]:destroyOneBrightPkm(monsterData[1].brightObjID, monsterData[1].brightRegionId)
  end
  local isTeamBattle = false
  if player:isJoinTeam() and player:isTeamCaptain() then
    local teamMate = player:getMyTeamMate()
    if teamMate and teamMate:isValid() then
      isTeamBattle = true
    end
  end
  if isTeamBattle then
    local enemyList = {}
    for k = 1, #monsterData do
      local pokemon = PokemonManager:createPokemon(monsterData[k].monsterID, monsterData[k].level, monsterData[k].monsterStar or 0)
      local temp = {pokemon}
      table.insert(enemyList, temp)
    end
    local battleField = BattleFieldManager:create({
      map = monsterData[1].battleMapName or "map002",
      playerNum = player:getMyTeamMateId() and 2 or 1,
      enemy = enemyList,
      mode = Define.BATTLE_MODE.PVE,
      endCallBack = function()
        for key, val in pairs(enemyList) do
          local pokemon = val[1]
          if pokemon and pokemon:getMasterId() == 0 then
            pokemon:onDestroy()
          end
        end
      end
    })
    TeamMgr:enterBattleField(player, battleField)
  else
    local enemyList = {}
    local pokemon = PokemonManager:createPokemon(monsterData[1].monsterID, monsterData[1].level, monsterData[1].monsterStar or 0)
    local temp = {pokemon}
    table.insert(enemyList, temp)
    local battleField = BattleFieldManager:create({
      map = monsterData[1].battleMapName or "map002",
      playerNum = 1,
      enemy = enemyList,
      mode = Define.BATTLE_MODE.PVE,
      endCallBack = function()
        for key, val in pairs(enemyList) do
          local pokemon = val[1]
          if pokemon and pokemon:getMasterId() == 0 then
            pokemon:onDestroy()
          end
        end
      end
    })
    player:enterBattleField(battleField)
  end
end

local function randomStar(starWeight)
  local pool = {}
  for i, v in pairs(starWeight) do
    local item = {
      star = i,
      weight = tonumber(v)
    }
    table.insert(pool, item)
  end
  local item = Lib.randomItemByWeight(1, pool, false)
  if item and item[1] then
    return item[1].star
  end
  return 0
end

function EncounterMgr:getOneKeyWithWeight(weightList)
  local minNum = 1
  local maxNum = 0
  for key, val in ipairs(weightList) do
    maxNum = maxNum + val.weightNum
  end
  local num = math.random(minNum, maxNum)
  local curWeight = 0
  for k, val in ipairs(weightList) do
    curWeight = curWeight + val.weightNum
    local star = 0
    if num <= curWeight then
      if val.starWeight and next(val.starWeight) then
        star = randomStar(val.starWeight)
      end
      return val.key, star
    end
  end
  return false
end

function EncounterMgr:pushTheHideQueue(player, regionCfg)
  encounterMap[Define.MEET_PKM_TYPE.HIDE_PKM]:pushTheHideQueue(player, regionCfg)
end

function EncounterMgr:popTheHideQueue(player)
  encounterMap[Define.MEET_PKM_TYPE.HIDE_PKM]:popTheHideQueue(player)
end

function EncounterMgr:resetPlayerThey(player)
  encounterMap[Define.MEET_PKM_TYPE.HIDE_PKM]:resetPlayerThey(player)
end

function EncounterMgr:pushTheBrightList(regionCfg)
  encounterMap[Define.MEET_PKM_TYPE.BRIGHT_PKM]:pushTheBrightList(regionCfg)
end

function EncounterMgr:startBrightPkmBattle(objID, player)
  encounterMap[Define.MEET_PKM_TYPE.BRIGHT_PKM]:startBrightPkmBattle(objID, player)
end

return EncounterMgr
