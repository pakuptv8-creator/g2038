local ConditionCheckUtils = T(Lib, "ConditionCheckUtils")
local InteractionHelper = T(Lib, "InteractionHelper")
local DanceConfig = T(Config, "DanceConfig")
local PlayerInteractiveConfig = T(Config, "PlayerInteractiveConfig")
local PropsConfig = T(Config, "PropsConfig")

function InteractionHelper:init()
end

function InteractionHelper:checkEntityIsCanInteraction(fromEntity, interactionType, actionId)
  if not fromEntity or not fromEntity:isValid() then
    return false
  end
  if interactionType == Define.InteractionActionType.FurnitureAction then
    if fromEntity.lastInteractionTime and os.time() < fromEntity.lastInteractionTime + 2 then
      return false
    end
    local interactiveId = fromEntity:getInteractPlayerHorseID()
    if 0 < interactiveId then
      return false
    end
    if fromEntity.rideOnInstanceId then
      return false
    end
    if not fromEntity:getInUseCar() and 0 < (fromEntity.rideOnId or 0) then
      return false
    end
    if 0 < fromEntity.rideOnId then
      local rideOnEntity = World.CurWorld:getEntity(fromEntity.rideOnId)
      if rideOnEntity and rideOnEntity:isValid() and rideOnEntity:cfg().forbidFurnitureAction == true then
        return false
      end
    end
    local oldEnterId = fromEntity:getInteractCarEnterID()
    if oldEnterId ~= "" then
      return false
    end
  elseif interactionType == Define.InteractionActionType.DanceAction then
  elseif interactionType == Define.InteractionActionType.InteractiveOthers then
    if fromEntity.forceSwimMode then
      return false
    end
    if fromEntity.map.name ~= World.cfg.defaultMap then
      return false
    end
    if fromEntity:getOnSlideState() == 1 then
      return false
    end
    if fromEntity:getOnSwingState() == 1 then
      return false
    end
  elseif interactionType == Define.InteractionActionType.OthersInteractiveMe then
    if fromEntity.forceSwimMode then
      return false
    end
    if fromEntity.map.name ~= World.cfg.defaultMap then
      return false
    end
    local rideOnId = fromEntity.rideOnId
    local rideOnEntity = World.CurWorld:getEntity(rideOnId)
    if rideOnEntity and rideOnEntity:isValid() then
      return false
    end
    local rideOnInstanceId = fromEntity.rideOnInstanceId
    if rideOnInstanceId then
      local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
      if vehicleInst and vehicleInst:isValid() then
        return false
      end
    end
    if fromEntity:getOnSlideState() == 1 then
      return false
    end
    if fromEntity:getOnSwingState() == 1 then
      return false
    end
    local oldPartId = fromEntity:getInteractionPartID()
    if oldPartId ~= "" then
      return false
    end
    local oldEnterId = fromEntity:getInteractCarEnterID()
    if oldEnterId ~= "" then
      return false
    end
  elseif interactionType == Define.InteractionActionType.CatchRobber then
    if fromEntity.forceSwimMode then
      return false
    end
    if fromEntity:getOnSlideState() == 1 then
      return false
    end
    if fromEntity:getOnSwingState() == 1 then
      return false
    end
    local oldPartId = fromEntity:getInteractionPartID()
    if oldPartId ~= "" then
      return false
    end
    local oldEnterId = fromEntity:getInteractCarEnterID()
    if oldEnterId ~= "" then
      return false
    end
  elseif interactionType == Define.InteractionActionType.NormalInteract then
    return true
  end
  return true
end

function InteractionHelper:doFurnitureAction(part, fromEntity, sitIdx)
  if not part or not part:isValid() then
    return false
  end
  fromEntity:SetForceClimb(false, 0, 0)
  fromEntity:rideOffPet()
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  PartManagerHelper:updatePartEntityInfo(part, sitIdx, fromEntity.objID)
  fromEntity.lastInteractionTime = os.time()
  if not fromEntity.interactionPrePos then
    fromEntity.interactionPrePos = fromEntity:getPosition()
    fromEntity.interactionPreYaw = fromEntity:getRotationYaw()
    fromEntity.interactionPrePitch = fromEntity:getRotationPitch()
  end
  local partID = part:getInstanceID()
  local rideInfo = PartManagerHelper:getPartRideInfoWithSitIdx(part, sitIdx)
  local yaw = -part:getRotation().y
  local newPos = self:getSitPosition(part:getPosition(), rideInfo, yaw, fromEntity)
  if fromEntity.isPlayer then
    local curPos = fromEntity:getPosition()
    fromEntity:sendPacket({
      pid = "StartCameraSmoothMovement",
      params = {
        curPos = curPos,
        targetPos = newPos,
        time = 3
      }
    })
  end
  if 0 < fromEntity.rideOnId then
    fromEntity:setRotationYaw(yaw)
    local carEntity = World.CurWorld:getEntity(fromEntity.rideOnId)
    carEntity:setPos(newPos, yaw, nil, true)
  else
    fromEntity:setPos(newPos, yaw, nil, true)
  end
  fromEntity:setInteractionPartID(partID)
  local posInfo = {newPos = newPos, yaw = yaw}
  fromEntity:setSitPartPosInfo(posInfo)
  fromEntity:setSitPartIdx(sitIdx)
  fromEntity:setSitPartAction(rideInfo.passengerAction)
  self:updateFurnitureActionState(fromEntity.objID, rideInfo.passengerAction, partID, true)
  return true
end

function InteractionHelper:getSitPosition(initPos, rideInfo, yaw, fromEntity)
  local offsetPosX = rideInfo.offsetPosX
  local offsetPosY = rideInfo.offsetPosY
  local offsetPosZ = rideInfo.offsetPosZ
  
  local function getAngele(yaw)
    local angle = yaw / 180 * math.pi
    return math.floor(angle * 100000) / 100000
  end
  
  local yaw = getAngele(yaw)
  local changeX = offsetPosX * math.cos(yaw) - offsetPosZ * math.sin(yaw)
  local changeZ = offsetPosZ * math.cos(yaw) + offsetPosX * math.sin(yaw)
  local targetPos = Lib.copy(initPos)
  targetPos.y = targetPos.y + offsetPosY
  targetPos.x = targetPos.x + changeX
  targetPos.z = targetPos.z + changeZ
  local resultPos = fromEntity:getNewWithShapeScale(targetPos, yaw, rideInfo.shapeOffset)
  return resultPos
end

function InteractionHelper:stopFurnitureAction(fromEntity)
  if not fromEntity or not fromEntity then
    return
  end
  local oldPartId = fromEntity:getInteractionPartID()
  if oldPartId == "" then
    return
  end
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  fromEntity:stopSwing()
  if oldPartId ~= "" then
    local oldSitIdx = fromEntity:getSitPartIdx()
    PartManagerHelper:cleanPartInteractData(fromEntity, oldSitIdx)
  end
  fromEntity.lastInteractionTime = os.time()
  local part = Instance.getByInstanceId(oldPartId)
  local sitIdx = fromEntity:getSitPartIdx(0)
  local rideInfo = PartManagerHelper:getPartRideInfoWithSitIdx(part, sitIdx)
  if rideInfo then
    local yaw = -part:getRotation().y
    local newPos = self:getSitPosition(part:getPosition(), rideInfo, yaw, fromEntity)
    if 0 < fromEntity.rideOnId then
      local carEntity = World.CurWorld:getEntity(fromEntity.rideOnId)
      carEntity:setPos(newPos, nil, nil, true)
    else
      fromEntity:setPos(newPos, nil, nil, true)
    end
  end
  fromEntity:setInteractionPartID("")
  fromEntity:setSitPartIdx(0)
  fromEntity:setSitPartAction("")
  self:updateFurnitureActionState(fromEntity.objID, "idle", oldPartId, false)
end

function InteractionHelper:updateFurnitureActionState(fromID, passengerAction, partID, isAdd)
  WorldServer.BroadcastPacket({
    pid = "CUpdateFurnitureState",
    fromID = fromID,
    passengerAction = passengerAction,
    partID = partID,
    isAdd = isAdd
  })
end

function InteractionHelper:doDanceAction(fromEntity, actionId, isAdd, isOnlyStop, isClientRequest)
  if not fromEntity or not fromEntity then
    return
  end
  if isAdd then
    if not self:checkEntityIsCanInteraction(fromEntity, Define.InteractionActionType.DanceAction, actionId) then
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
      return
    end
    fromEntity.lastInteractionTime = os.time()
    local oldDanceId = fromEntity:getPlayDanceID()
    fromEntity:setPlayDanceID(actionId)
    InteractionHelper:setDanceActionState(fromEntity.objID, actionId, true, oldDanceId, isOnlyStop, isClientRequest)
  else
    local oldDanceId = fromEntity:getPlayDanceID()
    if 0 < oldDanceId then
      fromEntity:setPlayDanceID(0)
      InteractionHelper:setDanceActionState(fromEntity.objID, 0, false, oldDanceId, isOnlyStop, isClientRequest)
    end
  end
end

function InteractionHelper:setDanceActionState(fromID, actionId, isAdd, oldDanceId, isOnlyStop, isClientRequest)
  WorldServer.BroadcastPacket({
    pid = "UpdateDanceActionState",
    fromID = fromID,
    actionId = actionId,
    isAdd = isAdd,
    oldDanceId = oldDanceId,
    isOnlyStop = isOnlyStop,
    isClientRequest = isClientRequest
  })
end

function InteractionHelper:requestInteractiveAction(fromEntity, targetID, interactiveID)
  local targetEntity = World.CurWorld:getEntity(targetID)
  if not (fromEntity and fromEntity:isValid() and targetEntity) or not targetEntity:isValid() then
    return
  end
  if targetEntity:getInteractPlayerHorseID() > 0 then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
    return
  end
  if 0 < fromEntity:getInteractPlayerUpID() then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
    return
  end
  if not self:checkEntityIsCanInteraction(fromEntity, Define.InteractionActionType.InteractiveOthers, interactiveID) then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
    return
  end
  targetEntity:sendPacket({
    pid = "PushInteractiveRequest",
    fromId = fromEntity.objID,
    interactiveID = interactiveID
  })
  Plugins.CallTargetPluginFunc("interaction_ui", "ShowOneInteractTips", "g2052.gui.interact.tips", fromEntity)
end

function InteractionHelper:agreeInteractiveAction(fromId, targetEntity, interactiveID)
  local fromEntity = World.CurWorld:getEntity(fromId)
  if not (fromEntity and fromEntity:isValid() and targetEntity) or not targetEntity:isValid() then
    return
  end
  if targetEntity:getInteractPlayerHorseID() > 0 then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
    return
  end
  if 0 < fromEntity:getInteractPlayerUpID() then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.interactive.fail")
    return
  end
  if not self:checkEntityIsCanInteraction(fromEntity, Define.InteractionActionType.InteractiveOthers, interactiveID) then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", targetEntity, "g2052.gui.interactive.fail")
    return
  end
  if not self:checkEntityIsCanInteraction(targetEntity, Define.InteractionActionType.OthersInteractiveMe, interactiveID) then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", targetEntity, "g2052.gui.interactive.fail")
    return
  end
  if self:checkHasInInteractionLine(fromEntity, targetEntity) then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", targetEntity, "g2052.gui.interactive.fail")
    return
  end
  fromEntity.lastInteractionTime = os.time()
  targetEntity.lastInteractionTime = os.time()
  local rideIndex = PlayerInteractiveConfig:getCfgById(interactiveID).ridePos
  self:doInteractiveAction(targetEntity, fromEntity, rideIndex)
  Plugins.CallTargetPluginFunc("interaction_ui", "HideOneInteractTips", fromEntity)
end

function InteractionHelper:doInteractiveAction(obj1, obj2, rideIndex)
  if not (obj1 and obj1:isValid() and obj2) or not obj2:isValid() then
    return
  end
  obj1:sendPacket({
    pid = "CleanPlayerInteractiveUI"
  })
  obj2:sendPacket({
    pid = "CleanPlayerInteractiveUI"
  })
  obj1:cancelPlayerPetInteractions()
  obj2:cancelPlayerPetInteractions()
  local rideOnId = obj1.rideOnId
  local rideOnEntity = World.CurWorld:getEntity(rideOnId)
  if rideOnEntity and rideOnEntity:isValid() and not obj1:tryClearRide() then
    return
  end
  obj1:rideOn(obj2, false, rideIndex)
  obj2:sendPacket({
    pid = "UpdateInteractiveControlShow",
    isShow = true
  })
  obj1:sendPacket({
    pid = "UpdateInteractiveControlShow",
    isShow = true
  })
  local carId = obj2.objID
  local upId = obj1.objID
  obj2:setInteractPlayerUpID(upId)
  obj1:setInteractPlayerHorseID(carId)
  Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", obj1, Define.HEART_WARM_TASK_TYPE.INTERACT)
  Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", obj2, Define.HEART_WARM_TASK_TYPE.INTERACT)
end

function InteractionHelper:tryCatchRobber(police, robberObjId)
  if not robberObjId then
    return
  end
  local robber = World.CurWorld:getEntity(robberObjId)
  if not (police and police:isValid() and robber) or not robber:isValid() then
    return
  end
  if not self:checkEntityIsCanInteraction(police, Define.InteractionActionType.CatchRobber) then
    return
  end
  if not self:checkEntityIsCanInteraction(robber, Define.InteractionActionType.CatchRobber) then
    return
  end
  if not ConditionCheckUtils.canCatchRobber(police, robber) then
    return
  end
  local catchRobberInfo = ConditionCheckUtils.getCatchRobberInfo(police)
  if not catchRobberInfo then
    return
  end
  if not police:tryClearRide() then
    return
  end
  if not robber:tryClearRide() then
    return
  end
  self:tryClearCatchRobberRide(robber)
  for _, obj in pairs({police, robber}) do
    EntityServer.playAction({
      entity = obj,
      actionName = "idle",
      actionTime = 0,
      includeSelf = true
    })
  end
  if self.releaseRobberCounter then
    self.releaseRobberCounter()
  end
  
  function police.clReleaseRobber()
    if robber and robber:isValid() then
      self:tryClearCatchRobberRide(robber)
    end
    robber.clForceClearRobber = nil
  end
  
  function robber.clForceClearRobber()
    if police and police:isValid() then
      police:releaseRobber()
    end
    self.clForceClearRobber = nil
  end
  
  self.releaseRobberCounter = World.CurWorld.LightTimer("ReleaseRobberCounter", catchRobberInfo.releaseRobberTime, function()
    if police and police:isValid() then
      police:releaseRobber()
    end
  end)
  police:removeHandItem({
    itemId = catchRobberInfo.handcuffsID
  })
  local rideIndex = catchRobberInfo.catchRobberRideId or 3
  robber:setCatchAsRobber(true)
  robber:rideOn(police, false, rideIndex)
  local carId = police.objID
  local upId = robber.objID
  police:setInteractPlayerUpID(upId)
  robber:setInteractPlayerHorseID(carId)
  police:sendPacket({
    pid = "UpdateInteractiveControlShow",
    isShow = true
  })
end

function InteractionHelper:tryClearCatchRobberRide(player, isExcludeRideOnPlayer)
  if not player.isPlayer then
    return
  end
  local rideOnId = player.rideOnId
  local rideOnInstanceId = player.rideOnInstanceId
  local rideOnEntity = World.CurWorld:getEntity(rideOnId)
  local rideOnPart
  if rideOnInstanceId then
    rideOnPart = Instance.getByInstanceId(rideOnInstanceId)
  end
  local passengers = player:data("passengers") or {}
  if rideOnEntity and rideOnEntity:isValid() or rideOnPart and rideOnPart:isValid() or next(passengers) ~= nil then
    player:setCatchAsRobber(false)
    local isSuc = player:cancelVehicleItemUse(isExcludeRideOnPlayer)
    if rideOnPart then
      local useCarInfo = player:getInUseCar()
      if not useCarInfo or useCarInfo.objId ~= rideOnInstanceId then
        player:rideOffFromPartVehicle()
      end
    end
    local res = player:removeUsingVehicle()
    player:removeRidingPet()
    player:tryClearRide()
    player:removeInteractiveState()
  end
end

function InteractionHelper:cleanPlayerAllInteraction(player)
  local interactPlayerHorseID = player:getInteractPlayerHorseID()
  if 0 < interactPlayerHorseID then
    player:clearRide()
  end
  local oldPartId = player:getInteractionPartID()
  if oldPartId ~= "" then
    player:doStopPlayerFurniture()
  end
end

function InteractionHelper:checkHasInInteractionLine(fromEntity, targetEntity)
  local lines = {}
  
  local function checkUp(entity, tab)
    if not tab[entity.objID] then
      tab[entity.objID] = true
    end
    if entity.rideOnId >= 0 then
      local e = World.CurWorld:getEntity(entity.rideOnId)
      if e and e:isValid() then
        checkUp(e, tab)
      end
    end
  end
  
  local function checkDown(entity, tab)
    if not tab[entity.objID] then
      tab[entity.objID] = true
    end
    local passengers = entity:data("passengers") or {}
    for _, objID in pairs(passengers) do
      local e = World.CurWorld:getEntity(objID)
      if e and e:isValid() then
        checkDown(e, tab)
      end
    end
  end
  
  checkUp(fromEntity, lines)
  checkDown(fromEntity, lines)
  if lines[targetEntity.objID] then
    return true
  end
  return false
end

function InteractionHelper:updatePlayerInteractPart(player, partId, isInteracting)
  local interactPartList = player:getInteractPartList()
  interactPartList[partId] = isInteracting
  player:setInteractPartList(interactPartList)
end

InteractionHelper:init()
