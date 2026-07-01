local encounterHidePkm = L("encounterHidePkm", {})

function encounterHidePkm:init()
  self.playerQueue = {}
  self.theyQueue = {}
end

function encounterHidePkm:getAnimationTime()
  local animationList = {
    Define.PRE_BATTLE_ANIMATION.WARNING_SIGN,
    Define.PRE_BATTLE_ANIMATION.BLACK_AND_WHITE,
    Define.PRE_BATTLE_ANIMATION.SHOW_BLOCK
  }
  local totalTime = 0
  for key, val in pairs(animationList) do
    totalTime = totalTime + Define.PRE_ANIMATION_TIME[val]
  end
  return totalTime
end

local function mathAbs(a, b)
  if b < a then
    return a - b
  else
    return b - a
  end
end

function encounterHidePkm:updateHideQueue()
  for key, val in pairs(self.playerQueue) do
    if val.curRemainThey > 0 then
      local player = Game.GetPlayerByUserId(val.userId)
      if not player or not player:isValid() then
        self:cleanPlayerQueueInfo(val.userId)
      else
        local curPos = player:curBlockPos()
        if (curPos.x ~= val.lastPos.x or curPos.z ~= val.lastPos.z) and player:isCanStartNewBattle() and player:getValue("sprayEndTime") < os.time() then
          local passThey = mathAbs(curPos.x, val.lastPos.x) + mathAbs(curPos.z, val.lastPos.z)
          val.curRemainThey = val.curRemainThey - passThey
          val.lastPos = curPos
          if val.curRemainThey <= 0 then
            local monsterList = self:getOnceBattleMonster(player, val.regionCfg)
            EncounterMgr:encounterTrigger(player, Define.MEET_PKM_TYPE.HIDE_PKM, monsterList)
          end
        end
      end
    end
  end
end

function encounterHidePkm:getMonsterRareIDWeight(player, rarePoolList)
  local weightList = {}
  for key, val in pairs(rarePoolList) do
    local temp = {}
    temp.key = val.rareID
    temp.weightNum = val.rareWeight
    table.insert(weightList, temp)
  end
  return EncounterMgr:getOneKeyWithWeight(weightList)
end

function encounterHidePkm:getMonsterIDWeight(monsterList)
  local weightList = {}
  for key, val in pairs(monsterList) do
    local temp = {}
    temp.key = val.monsterID
    temp.weightNum = val.monsterWeight
    temp.starWeight = val.starWeight or {}
    table.insert(weightList, temp)
  end
  return EncounterMgr:getOneKeyWithWeight(weightList)
end

function encounterHidePkm:getOneHideRegionMonster(player, regionCfg)
  local monsterData = {}
  monsterData.rareID = self:getMonsterRareIDWeight(player, regionCfg.rarePoolList)
  local curRarePoolData
  for key, val in pairs(regionCfg.rarePoolList) do
    if val.rareID == monsterData.rareID then
      curRarePoolData = val
    end
  end
  monsterData.monsterID, monsterData.monsterStar = self:getMonsterIDWeight(curRarePoolData.monsterList)
  local flashNum = math.random(1, 100)
  monsterData.isFlash = flashNum <= regionCfg.flashRate
  monsterData.level = math.random(regionCfg.minMonsterLevel, regionCfg.maxMonsterLevel)
  monsterData.battleMapName = regionCfg.battleMapName
  return monsterData
end

function encounterHidePkm:getOnceBattleMonster(player, regionCfg)
  local monsterList = {}
  table.insert(monsterList, self:getOneHideRegionMonster(player, regionCfg))
  if player:isJoinTeam() then
    table.insert(monsterList, self:getOneHideRegionMonster(player, regionCfg))
  end
  return monsterList
end

function encounterHidePkm:getTheTheyCount(player)
  if not player:isGuideFinish() and player:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO then
    Lib.logDebug("CAPTURE_POKEMON_GOTO getTheTheyCount 1")
    player:setAvoidBattle(false)
    return 1
  end
  if World.cfg.hidePKMThey then
    local weightList = {}
    for key, val in pairs(World.cfg.hidePKMThey) do
      local temp = {}
      temp.weightNum = val.probability
      temp.key = val.theyNum
      if val.probability > 0 then
        table.insert(weightList, temp)
      end
    end
    return EncounterMgr:getOneKeyWithWeight(weightList)
  else
    return 20
  end
end

function encounterHidePkm:pushTheHideQueue(player, regionCfg)
  local curUserId = player.platformUserId
  self.playerQueue[curUserId] = {}
  self.playerQueue[curUserId].userId = curUserId
  self.playerQueue[curUserId].regionCfg = regionCfg
  self.playerQueue[curUserId].lastPos = player:curBlockPos()
  if self.theyQueue[curUserId] and self.theyQueue[curUserId] > 0 then
    self.playerQueue[curUserId].curRemainThey = self.theyQueue[curUserId]
    self.theyQueue[curUserId] = nil
  else
    self.playerQueue[curUserId].curRemainThey = player.disenableEncounter or self:getTheTheyCount(player)
    self.theyQueue[curUserId] = nil
  end
end

function encounterHidePkm:popTheHideQueue(player)
  local curUserId = player.platformUserId
  if self.playerQueue[curUserId] then
    self.theyQueue[curUserId] = self.playerQueue[curUserId].curRemainThey
    self.playerQueue[curUserId] = nil
  else
    self.theyQueue[curUserId] = nil
  end
end

function encounterHidePkm:resetPlayerThey(player)
  local curUserId = player.platformUserId
  if self.playerQueue[curUserId] and self.playerQueue[curUserId].curRemainThey <= 0 then
    self.playerQueue[curUserId].curRemainThey = self:getTheTheyCount(player)
  end
end

function encounterHidePkm:cleanPlayerQueueInfo(curUserId)
  self.playerQueue[curUserId] = nil
  self.theyQueue[curUserId] = nil
end

return encounterHidePkm
