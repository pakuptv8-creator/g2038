local PartFurnitureHelper = T(Lib, "PartFurnitureHelper")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function PartFurnitureHelper:init()
  self.furniturePartList = {}
end

function PartFurnitureHelper:initChairsPartData(partID)
  self.furniturePartList[partID] = {
    partID = partID,
    passengers = {},
    startTime = {},
    entityCDList = {},
    totalSitNum = 1
  }
end

function PartFurnitureHelper:getPartInteractEntity(part)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  if self.furniturePartList[partID] then
    return self.furniturePartList[partID].passengers
  end
  return
end

function PartFurnitureHelper:checkPartIsCanInteraction(part, fromEntity, params, isBreak)
  local entityPos = fromEntity:getPosition()
  local maxLen = 5
  if maxLen < (Lib.v3(entityPos.x, entityPos.y, entityPos.z) - part:getPosition()):len() then
    return false
  end
  local partID = part:getInstanceID()
  if not self.furniturePartList[partID] then
    self:initChairsPartData(partID)
  end
  if isBreak then
    for sitIdx, objId in pairs(self.furniturePartList[partID].passengers) do
      if objId == fromEntity.objID then
        return sitIdx
      end
    end
  end
  if self.furniturePartList[partID].entityCDList[fromEntity.objID] and not isBreak and os.time() - self.furniturePartList[partID].entityCDList[fromEntity.objID] <= 0 then
    return false
  end
  if params then
    self:updatePartParamsInfo(partID, params)
  end
  if not self.furniturePartList[partID].params then
    return 1
  end
  local chairCfg = self.furniturePartList[partID]
  local rideInfo = self:getPartRideInfoData(part)
  local maxIndex = #rideInfo
  local idx = 0
  for i = 1, maxIndex do
    if not chairCfg.passengers[i] then
      idx = i
    end
  end
  if idx <= 0 then
    return false
  end
  return idx
end

function PartFurnitureHelper:getPartFurnitureSitIdx(part)
  local partID = part:getInstanceID()
  local chairCfg = self.furniturePartList[partID]
  if not chairCfg then
    return false
  end
  if not chairCfg.params then
    return false
  end
  local rideInfo = self:getPartRideInfoData(part)
  local maxIndex = #rideInfo
  local idx = 0
  for i = 1, maxIndex do
    if not chairCfg.passengers[i] then
      idx = i
    end
  end
  if idx <= 0 then
    return false
  end
  return idx
end

function PartFurnitureHelper:updatePartParamsInfo(partID, params)
  if not self.furniturePartList[partID] then
    self:initChairsPartData(partID)
  end
  self.furniturePartList[partID].params = params
  self.furniturePartList[partID].totalSitNum = 1
end

function PartFurnitureHelper:updatePartEntityInfo(part, sitIdx, objID)
  local partID = part:getInstanceID()
  if self.furniturePartList[partID] and sitIdx then
    if self.furniturePartList[partID].initCollide == nil and not next(self.furniturePartList[partID].passengers) then
      self.furniturePartList[partID].initCollide = part:getProperty("useCollide")
    end
    self.furniturePartList[partID].passengers[sitIdx] = objID
    self.furniturePartList[partID].entityCDList[objID] = os.time()
    self.furniturePartList[partID].startTime[sitIdx] = os.time()
    part:setProperty("useCollide", "false")
    local entity = World.CurWorld:getObject(objID)
    if entity and entity:isValid() then
      entity:setProp("gravity", 0)
      entity:setProp("collision", "false")
      WorldServer.BroadcastPacket({
        pid = "SCPushFurnitureInteractState",
        partID = partID,
        sitIdx = sitIdx,
        userId = entity.platformUserId or 0,
        totalSitNum = self.furniturePartList[partID].totalSitNum,
        isSitDown = true
      })
    end
  end
end

function PartFurnitureHelper:cleanPartEntityInfo(partID, sitIdx)
  if self.furniturePartList[partID] and sitIdx and self.furniturePartList[partID].passengers[sitIdx] then
    local entity = World.CurWorld:getObject(self.furniturePartList[partID].passengers[sitIdx])
    if entity and entity:isValid() then
      entity:resetInitGravity()
      entity:setProp("collision", "true")
      local startTime = self.furniturePartList[partID].startTime[sitIdx] or 0
      local part = Instance.getByInstanceId(partID)
      local defaultData = {
        event_name = part and part.name,
        event_time = os.time() - startTime
      }
      Plugins.CallTargetPluginFunc("report", "report", "event_ride_end", defaultData, entity)
      WorldServer.BroadcastPacket({
        pid = "SCPushFurnitureInteractState",
        partID = partID,
        sitIdx = sitIdx,
        userId = entity.platformUserId or 0,
        isSitDown = false
      })
    end
    self.furniturePartList[partID].passengers[sitIdx] = nil
    self.furniturePartList[partID].startTime[sitIdx] = nil
    local part = Instance.getByInstanceId(partID)
    if not part or not part:isValid() then
      return
    end
    if not next(self.furniturePartList[partID].passengers) then
      part:setProperty("useCollide", self.furniturePartList[partID].initCollide or "false")
    end
  end
end

function PartFurnitureHelper:getPartRideInfoData(part)
  local partID = part:getInstanceID()
  local params = self.furniturePartList[partID].params or {}
  local rideInfo = {}
  if params[1] and params[1] ~= "" then
    local content = Lib.splitString(params[1], "#")
    local temp = {
      passengerAction = content[1],
      offsetPosX = tonumber(content[2]),
      offsetPosY = tonumber(content[3]),
      offsetPosZ = tonumber(content[4]),
      underOffsetX = tonumber(content[5]) or 0,
      underOffsetY = tonumber(content[6]) or 0,
      underOffsetZ = tonumber(content[7]) or 0
    }
    if params[2] and params[2] ~= "" then
      temp.shapeOffset = Lib.createV3ByString(params[2], "#")
    end
    table.insert(rideInfo, temp)
  end
  return rideInfo
end

function PartFurnitureHelper:getPartRideInfoWithSitIdx(part, sitIdx)
  local partID = part:getInstanceID()
  if self.furniturePartList[partID] then
    local rideInfo = self:getPartRideInfoData(part)
    if sitIdx and rideInfo and rideInfo[sitIdx] then
      return rideInfo[sitIdx]
    end
  end
end

function PartFurnitureHelper:removePartInteractState(part)
  local partID = part:getInstanceID()
  if self.furniturePartList[partID] then
    for _, objID in pairs(self.furniturePartList[partID].passengers) do
      local targetEntity = World.CurWorld:getEntity(objID)
      if targetEntity and targetEntity:isValid() then
        targetEntity:doStopPlayerFurniture()
      end
    end
    self.furniturePartList[partID] = nil
  end
end

function PartFurnitureHelper:loginSyncFurnitureInteractState(player)
  local dataList = {}
  for partID, partInfo in pairs(self.furniturePartList) do
    if next(partInfo.passengers) then
      dataList[partID] = {
        partID = partID,
        passengers = {},
        totalSitNum = partInfo.totalSitNum or 1,
        curSitNum = 0
      }
      for sitIdx, objID in pairs(partInfo.passengers) do
        local entity = World.CurWorld:getEntity(objID)
        if entity and entity:isValid() then
          dataList[partID].curSitNum = dataList[partID].curSitNum + 1
          dataList[partID].passengers[entity.platformUserId] = sitIdx
        end
      end
    end
  end
  local packet = {
    pid = "SyncFurnitureInteractState",
    dataList = dataList
  }
  player:sendPacket(packet)
end
