local ConditionCheckUtils = T(Lib, "ConditionCheckUtils")
local InteractEventConfig = T(Config, "InteractEventConfig")
local CONDITION_INDEX_CALLBACK = {
  [1] = "checkHold",
  [2] = "checkProfession",
  [3] = "checkOpen",
  [4] = "checkPrivate",
  [5] = "checkHoldAndConsumeProp",
  [6] = "checkIsHouseOwner"
}

function ConditionCheckUtils.checkIsHouseOwner(from, target, param)
  if World.isClient then
    return
  end
  return HouseManager:verifyingOperationRights(from.platformUserId, target)
end

function ConditionCheckUtils.checkHoldAndConsumeProp(from, target, param)
  local inUseProp = from:getInUseProp()
  if inUseProp then
    for i = 1, #param do
      local itemId = tonumber(param[i])
      if inUseProp.itemId == tonumber(itemId) then
        from:removeInUseHandItem()
        return true
      end
    end
  end
  return false
end

function ConditionCheckUtils.checkHold(from, target, param)
  local handBagsInfo = from:getHandbagsInfo()
  for _, v in pairs(handBagsInfo) do
    if v.inUse then
      for i = 1, #param do
        local itemId = tonumber(param[i])
        if v.itemId == itemId then
          return true
        end
      end
    end
  end
  return false
end

function ConditionCheckUtils.checkOpen(from, target, param)
  local partName = param[1]
  local parent = target:getParent()
  local nodes = {}
  Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, partName)
  if #nodes < 1 then
    return false
  end
  local checkPart = nodes[1]
  if checkPart.operationRotateInfo then
    return true
  end
  return false
end

function ConditionCheckUtils.checkPrivate(from, target, param)
  local houseModel = target:findFirstAncestor("house")
  if houseModel then
    local instanceId = houseModel:getInstanceID()
    local locationList
    if HouseManager then
      locationList = HouseManager:getLocationList()
    else
      locationList = from.allHouseInfo
    end
    if not locationList then
      return true
    end
    for _, v in pairs(locationList) do
      if v.houseId == instanceId then
        if v.ownerId ~= from.platformUserId then
          return false
        else
          return true
        end
      end
    end
  end
  return true
end

function ConditionCheckUtils.isMeetPrecondition(condition, from, target)
  local idx = condition.index
  if not CONDITION_INDEX_CALLBACK[idx] then
    return true
  end
  local func = ConditionCheckUtils[CONDITION_INDEX_CALLBACK[idx]]
  if not func then
    return true
  end
  return func(from, target, condition.paramArr)
end

function ConditionCheckUtils.canCatchRobber(police, robber)
  local catchRobberInfo = ConditionCheckUtils.getCatchRobberInfo(police)
  if not catchRobberInfo then
    return false
  end
  local inUseProp = police:getInUseProp()
  if not inUseProp or inUseProp.itemId ~= catchRobberInfo.handcuffsID then
    return false
  end
  local pProfId = police:getProfessionId()
  if (pProfId == Define.CareerType.Police or pProfId == Define.CareerType.Police) and robber:getProfessionId() == Define.CareerType.Robber then
    return true
  end
  return false
end

function ConditionCheckUtils.getCatchRobberInfo(e)
  if e and e.isPlayer then
    return e:cfg().catchRobberInfo
  end
  return nil
end

local function checkObstacle(part, from)
  local world = from.map:getPhysicsWorld()
  local origin = from:getEyePos()
  local desPos = part:getPosition()
  desPos.y = origin.y
  local dir = desPos - origin
  local len = dir:len()
  if len <= 0.01 then
    return false
  end
  local result = world:raycast(origin, dir, len)
  if result and result.target and result.target.isInsteance and result.target.properties then
    local targetId = result.target.properties.id or result.target.properties.templateId
    local targetPartId = result.target:getInstanceID()
    local partID = part:getInstanceID()
    if tonumber(targetPartId) ~= tonumber(partID) and result.target and result.target.isCameraCollideEnable and result.target:isCameraCollideEnable() then
      return true
    end
  end
  return false
end

local function examinePartState(target)
  if target.partRotateTimer or target.partRestoreTimer or target.restoreRotateTimer then
    return false
  end
  if target.partSmoothMovementTimer or target.restoreMoveTimer then
    return false
  end
  return true
end

function ConditionCheckUtils.checkEventCanInteract(type, from, part, prop, forceTrigger, isBreak)
  if not prop then
    return false
  end
  if World.isClient and prop.sync == "client" and Me:isCameraMode() then
    return false
  end
  if World.isClient and prop.sync == "client" then
    return true
  end
  if prop.controlBeCascade then
    local childPart = {}
    local parent = part:getParent()
    for _, name in pairs(prop.controlBeCascade) do
      local isCascade = InteractEventConfig:isCascadeRelation(part.name, name)
      if isCascade then
        Lib.getInstanceAllChild(parent, childPart, Define.ABILITY.AABB, name)
      end
    end
    if 0 < #childPart then
      local upState = false
      for _, v in pairs(childPart or {}) do
        if v and v:isValid() and not upState then
          upState = v.isInteracting
        end
      end
      return upState ~= part.isInteracting
    end
  end
  if not isBreak and part.lastTriggerInteractTime and part.interactEventCDTime then
    local passTime = os.time() - part.lastTriggerInteractTime
    if passTime < part.interactEventCDTime then
      return false
    end
  end
  if not examinePartState(part) then
    return false
  end
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  if not PartManagerHelper:checkIsCanBindInteraction(part, from) then
    return false
  end
  if forceTrigger then
    return true
  end
  if part.isInteractLock then
    return false
  end
  if not isBreak and part.isInteracting then
    return false
  end
  if prop.precondition and not ConditionCheckUtils.isMeetPrecondition(prop.precondition, from, part) then
    return false
  end
  if prop.isNeedCheckObstacle == 1 and checkObstacle(part, from) then
    return false
  end
  local InteractionHelper = T(Lib, "InteractionHelper")
  if prop.func == "onFurnitureInteract" or prop.func == "onSwingInteract" then
    if ConditionCheckUtils.checkFurnitureInteract(from, part, prop, isBreak) then
      return InteractionHelper:checkEntityIsCanInteraction(from, Define.InteractionActionType.FurnitureAction)
    else
      return false
    end
  elseif prop.func == "onTriggerAssociated" then
    if ConditionCheckUtils.checkTriggerAssociatedInteract(type, from, part, prop, isBreak) then
      return InteractionHelper:checkEntityIsCanInteraction(from, Define.InteractionActionType.NormalInteract)
    else
      return false
    end
  elseif prop.func == "rideFixedPointVehicle" then
    if from:isInFloatState() then
      return false
    end
    if 0 < from.rideOnId or from:getInteractionPartID() ~= "" or from.rideOnInstanceId or from.rideFixedPointVehicleId and from.rideFixedPointVehicleId ~= "" then
      return
    end
    if from.fixedPointVehicleDepartureTime and os.time() - from.fixedPointVehicleDepartureTime < 2 then
      return
    end
    if part.mount and part.mount.mountId and part.mount.mountId ~= 0 then
      return
    end
    return true
  elseif prop.func == "onCreateMovePart" or prop.func == "onVehicleToOnePart" or prop.func == "onTouchLadder" or prop.func == "onWithPartDirMove" then
    if from:isInFloatState() then
      return false
    end
    local rideOnInstanceId = from.rideOnInstanceId
    if rideOnInstanceId then
      local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
      if vehicleInst and vehicleInst:isValid() then
        return false
      end
    end
    if from.rideOnInstanceId or from.rideFixedPointVehicleId and from.rideFixedPointVehicleId ~= "" then
      return false
    end
    if 0 < from.rideOnId then
      return false
    end
    if prop.func == "onTouchLadder" and from:getInteractCarEnterID() ~= "" then
      return false
    end
    return true
  elseif prop.func == "onRideOnPartVehicle" or prop.func == "onTravelByPartVehicle" then
    if from:isInFloatState() then
      return false
    end
    if 0 < from.rideOnId and 0 < from:getInteractPlayerHorseID() then
      return false
    end
    if from:getInteractCarEnterID() ~= "" then
      return false
    end
    if from.rideOnInstanceId then
      return false
    end
    if from.rideFixedPointVehicleId and from.rideFixedPointVehicleId ~= "" then
      return false
    end
    return true
  else
    return InteractionHelper:checkEntityIsCanInteraction(from, Define.InteractionActionType.NormalInteract)
  end
end

function ConditionCheckUtils.checkFurnitureInteract(from, part, prop, isBreak)
  if from:isInFloatState() then
    return false
  end
  local moveStatus = from:getMoveStatus()
  if moveStatus == 8 then
    local oldPartId = from:getInteractionPartID()
    if oldPartId == "" then
      return false
    end
  end
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  local sitIdx = PartManagerHelper:checkPartIsCanInteraction(part, from, prop.params, isBreak)
  if sitIdx and 0 < sitIdx then
    return true
  end
  return false
end

function ConditionCheckUtils.checkTriggerAssociatedInteract(type, from, part, prop, isBreak)
  if from:isInFloatState() then
    return false
  end
  if not from:checkMultiplayerTrigger(type, part) then
    return false
  end
  local params = prop.params
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  if PartManagerHelper:checkPartIsCanInteraction(part, from, params, isBreak) then
    if not params[1] then
      return false
    end
    local targets = Lib.splitString(params[1], "#") or {}
    local parent = part
    local tier = tonumber(params[8]) or 1
    for i = 1, tier do
      if parent and parent:isValid() and parent.getParent then
        local node = parent:getParent()
        if node then
          parent = node
        else
          break
        end
      end
    end
    local nodes = {}
    for _, name in pairs(targets) do
      Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, name, true)
    end
    local allChildCan = true
    for _, target in pairs(nodes) do
      if target and target:isValid() then
        local partName = target:getProperty("name")
        local childProp = InteractEventConfig:getCfgById(partName)
        if not childProp then
          allChildCan = false
        end
        if not isBreak then
          if not target.isInteracting and not ConditionCheckUtils.checkEventCanInteract(type, from, target, childProp, false, isBreak) then
            allChildCan = false
          end
        elseif not ConditionCheckUtils.checkEventCanInteract(type, from, target, childProp, false, isBreak) then
          allChildCan = false
        end
      end
    end
    return allChildCan
  else
    return false
  end
end
