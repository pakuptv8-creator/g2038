local encounterBrightPkm = L("encounterBrightPkm", {})

function encounterBrightPkm:init()
  self.brightPoolList = {}
  World.Timer(20, function()
    self:updateBrightPool()
    return true
  end)
end

function encounterBrightPkm:updateBrightPool()
  for regionId, regionData in pairs(self.brightPoolList) do
    if regionData.lastRefreshTime == nil then
      self:refreshCurRegion(regionId)
      regionData.lastRefreshTime = os.time()
    elseif os.time() - regionData.lastRefreshTime >= regionData.regionCfg.refreshTime then
      self:refreshCurRegion(regionId)
      regionData.lastRefreshTime = os.time()
    end
  end
end

function encounterBrightPkm:pushTheBrightList(regionCfg)
  self.brightPoolList[regionCfg.regionId] = {}
  self.brightPoolList[regionCfg.regionId].regionCfg = regionCfg
  self.brightPoolList[regionCfg.regionId].pkmList = {}
end

function encounterBrightPkm:refreshCurRegion(regionId)
  local curPkmNum = 0
  for objID, monsterInfo in pairs(self.brightPoolList[regionId].pkmList) do
    if os.time() - monsterInfo.birthTime >= self.brightPoolList[regionId].regionCfg.surviveTime then
      local entity = World.CurWorld:getObject(objID)
      if entity.isPreBattleState then
        curPkmNum = curPkmNum + 1
      else
        entity:stopAI()
        entity:destroy()
        self.brightPoolList[regionId].pkmList[objID] = nil
      end
    else
      curPkmNum = curPkmNum + 1
    end
  end
  for i = curPkmNum, self.brightPoolList[regionId].regionCfg.brightNum - 1 do
    self:createOneBrightPkm(regionId)
  end
end

function encounterBrightPkm:createOneBrightPkm(regionId)
  local monsterList = self:getOnceBrightBattleMonster(self.brightPoolList[regionId].regionCfg)
  local params = {
    map = self.brightPoolList[regionId].regionCfg.map,
    cfgName = monsterList[1].cfgName,
    pos = monsterList[1].pos,
    ry = 0,
    rp = 0
  }
  local entity = EntityServer.Create(params)
  self.brightPoolList[regionId].pkmList[entity.objID] = {}
  self.brightPoolList[regionId].pkmList[entity.objID].birthTime = os.time()
  self.brightPoolList[regionId].pkmList[entity.objID].monsterList = monsterList
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

function encounterBrightPkm:getMonsterIDAndCfgName(monsterList)
  local weightList = {}
  for key, val in pairs(monsterList) do
    local temp = {}
    temp.key = val.monsterID
    temp.weightNum = val.monsterWeight
    temp.cfgName = val.cfgName
    temp.starWeight = val.starWeight or {}
    table.insert(weightList, temp)
  end
  local minNum = 1
  local maxNum = 0
  for key, val in ipairs(weightList) do
    maxNum = maxNum + val.weightNum
  end
  local num = math.random(minNum, maxNum)
  local curWeight = 0
  for k, val in ipairs(weightList) do
    curWeight = curWeight + val.weightNum
    if num <= curWeight then
      local star = 0
      if val.starWeight and next(val.starWeight) then
        star = randomStar(val.starWeight)
      end
      return val.key, val.cfgName, star
    end
  end
  return false
end

function encounterBrightPkm:getOneBrightRegionMonster(regionCfg)
  local monsterData = {}
  monsterData.monsterID, monsterData.cfgName, monsterData.monsterStar = self:getMonsterIDAndCfgName(regionCfg.monsterList)
  local flashNum = math.random(1, 100)
  monsterData.isFlash = flashNum <= regionCfg.flashRate
  monsterData.level = math.random(regionCfg.minMonsterLevel, regionCfg.maxMonsterLevel)
  monsterData.pos = {
    x = math.random(regionCfg.birthMinX, regionCfg.birthMaxX),
    y = regionCfg.birthY,
    z = math.random(regionCfg.birthMinZ, regionCfg.birthMaxZ)
  }
  monsterData.battleMapName = regionCfg.battleMapName
  return monsterData
end

function encounterBrightPkm:getOnceBrightBattleMonster(regionCfg)
  local monsterList = {}
  table.insert(monsterList, self:getOneBrightRegionMonster(regionCfg))
  return monsterList
end

function encounterBrightPkm:startBrightPkmBattle(objID, player)
  for regionId, regionData in pairs(self.brightPoolList) do
    for monsterObjID, monsterInfo in pairs(self.brightPoolList[regionId].pkmList) do
      if objID == monsterObjID then
        local entity = World.CurWorld:getObject(objID)
        entity:stopAI()
        entity.isPreBattleState = true
        local monsterList = self.brightPoolList[regionId].pkmList[objID].monsterList
        monsterList[1].brightObjID = objID
        monsterList[1].brightRegionId = regionId
        if player:isJoinTeam() then
          table.insert(monsterList, self:getOneBrightRegionMonster(self.brightPoolList[regionId].regionCfg))
        end
        EncounterMgr:encounterTrigger(player, Define.MEET_PKM_TYPE.BRIGHT_PKM, monsterList)
      end
    end
  end
end

function encounterBrightPkm:destroyOneBrightPkm(objID, regionId)
  local entity = World.CurWorld:getObject(objID)
  entity.isPreBattleState = false
  entity:destroy()
  self.brightPoolList[regionId].pkmList[objID] = nil
end

return encounterBrightPkm
