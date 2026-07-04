local PartFloatAreaManager = T(Lib, "PartFloatAreaManager")

function PartFloatAreaManager:init()
  self.areaPlayerList = {}
  self.waitePlayerList = {}
  World.Timer(2, function()
    self:updateHeightInfo()
    return true
  end)
end

function PartFloatAreaManager:checkPartIsCanWork(part, entity, params)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  if params[6] and params[6] ~= "" then
    local parent = part:getParent()
    local nameList = Lib.splitString(params[6], "#")
    for _, name in pairs(nameList) do
      local nodes = {}
      Lib.getInstanceAllChild(parent or part, nodes, Define.ABILITY.AABB, name)
      if nodes[1].isInteracting then
        return true
      end
    end
    return false
  end
  return true
end

function PartFloatAreaManager:enterGravityPreDeal(entity)
  if entity.isPlayer then
    if entity.rideOnInstanceId then
      entity:rideOffFromPartVehicle()
    end
    if entity.rideOnId > 0 then
      local target = World.CurWorld:getEntity(entity.rideOnId)
      if target and target:isValid() and target:cfg().isSkate == true then
        entity:removeUsingVehicle()
      end
    end
  end
end

function PartFloatAreaManager:enterAreaUpdate(part, entity, params)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  if self:checkPartIsCanWork(part, entity, params) then
    self:enterGravityPreDeal(entity)
    self:enterGravityUpdate(part, entity, params)
  else
    if not self.waitePlayerList[partId] then
      self.waitePlayerList[partId] = {}
    end
    self.waitePlayerList[partId][entity.objID] = {
      part = part,
      entity = entity,
      params = params
    }
  end
end

function PartFloatAreaManager:exitAreaUpdate(part, entity, params)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  if self.waitePlayerList[partId] then
    self.waitePlayerList[partId][entity.objID] = nil
  end
  self:exitGravityUpdate(part, entity, params)
end

function PartFloatAreaManager:enterGravityUpdate(part, entity, params)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  if not self.areaPlayerList[partId] then
    self.areaPlayerList[partId] = {}
  end
  local objID = entity.objID
  local disInfo = Lib.splitString(params[3], "#", true)
  local upInfo = Lib.splitString(params[4], "#", true)
  local downInfo = Lib.splitString(params[5], "#", true)
  self.areaPlayerList[partId][objID] = {
    offsetDir = 0,
    objID = objID,
    entity = entity,
    minPosY = disInfo[1],
    maxPosY = disInfo[2],
    midPosY = disInfo[3],
    maxUp = upInfo[2],
    minUp = upInfo[1],
    maxDown = downInfo[2],
    minDown = downInfo[1],
    params = params,
    part = part
  }
  entity:setProp("moveSpeed", tonumber(params[2]))
  entity:setProp("walkSpeedRate", 1)
  entity:setProp("sprintUpRate", 1)
  entity:setFloatState(true)
  if entity.isPlayer then
    entity:addBuff(params[1])
  end
end

function PartFloatAreaManager:exitGravityUpdate(part, entity, params)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  if not self.areaPlayerList[partId] then
    return
  end
  if self.areaPlayerList[partId][entity.objID] then
    entity:setFloatState(false)
    entity:setProp("antiGravity", 0)
    entity:resetInitGravity()
    entity:resetInitMoveSpeed()
    if entity.isPlayer then
      entity:removeTypeBuff("fullName", params[1])
      entity:addBuff("myplugin/walk_move_buff")
    end
  end
  self.areaPlayerList[partId][entity.objID] = nil
end

function PartFloatAreaManager:removePartInteractState(part)
  local partID = part:getInstanceID()
  if self.waitePlayerList[partID] then
    self.waitePlayerList[partID] = nil
  end
  if self.areaPlayerList[partID] then
    for objID, val in pairs(self.areaPlayerList[partID]) do
      local entity = World.CurWorld:getEntity(objID)
      if entity and entity:isValid() then
        entity:setFloatState(false)
        entity:setProp("antiGravity", 0)
        entity:resetInitGravity()
        entity:resetInitMoveSpeed()
        if entity.isPlayer then
          entity:removeTypeBuff("fullName", val.params[1])
          entity:addBuff("myplugin/walk_move_buff")
        end
      end
    end
    self.areaPlayerList[partID] = nil
  end
end

function PartFloatAreaManager:updateHeightInfo()
  for partId, pList in pairs(self.waitePlayerList) do
    for objID, info in pairs(pList) do
      if self:checkPartIsCanWork(info.part, info.entity, info.params) then
        self:enterGravityPreDeal(info.entity)
        self:enterGravityUpdate(info.part, info.entity, info.params)
        self.waitePlayerList[partId][objID] = nil
      end
    end
  end
  for partId, pList in pairs(self.areaPlayerList) do
    for objID, info in pairs(pList) do
      if info.entity and info.entity:isValid() then
        if self:checkPartIsCanWork(info.part, info.entity, info.params) then
          self:updateEntityAreaHeight(partId, objID)
        else
          self:exitGravityUpdate(info.part, info.entity, info.params)
          self:enterAreaUpdate(info.part, info.entity, info.params)
        end
      else
        self.areaPlayerList[partId][objID] = nil
      end
    end
  end
end

function PartFloatAreaManager:updateEntityAreaHeight(partId, objID)
  local curPos = self.areaPlayerList[partId][objID].entity:getPosition()
  if curPos.y >= self.areaPlayerList[partId][objID].maxPosY then
    self.areaPlayerList[partId][objID].offsetDir = -1
  elseif curPos.y <= self.areaPlayerList[partId][objID].minPosY then
    self.areaPlayerList[partId][objID].offsetDir = 1
  elseif self.areaPlayerList[partId][objID].offsetDir == 0 then
    self.areaPlayerList[partId][objID].offsetDir = 1
  end
  local info = self.areaPlayerList[partId][objID]
  local newGravity = 0
  local newAntiGravity = 0
  if info.offsetDir > 0 then
    newGravity = 0
    newAntiGravity = self:calNewPowerVal(info.minUp, info.maxUp, info.minPosY, info.midPosY, info.maxPosY, curPos)
  else
    newAntiGravity = 0
    newGravity = self:calNewPowerVal(info.minDown, info.maxDown, info.minPosY, info.midPosY, info.maxPosY, curPos)
  end
  if info.entity:data("prop").gravity ~= newGravity then
    info.entity:setProp("gravity", newGravity)
  end
  if info.entity:data("prop").antiGravity ~= newAntiGravity then
    info.entity:setProp("antiGravity", newAntiGravity)
  end
end

function PartFloatAreaManager:calNewPowerVal(minVal, maxVal, minPosY, midPosY, maxPosY, curPos)
  local result
  if midPosY < curPos.y then
    result = minVal + (maxVal - minVal) * (curPos.y - midPosY) / (maxPosY - midPosY)
  elseif midPosY > curPos.y then
    result = minVal + (maxVal - minVal) * (midPosY - curPos.y) / (midPosY - minPosY)
  else
    result = minVal
  end
  return math.floor(result * 100000000) / 100000000
end
