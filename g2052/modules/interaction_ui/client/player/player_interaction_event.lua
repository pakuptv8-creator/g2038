local Player = _ENV.Player
local customCheckFuncs = {}

function Player:customCheckCond(checkCond, objID)
  local func = customCheckFuncs[checkCond.funcName]
  if not func then
    return false
  end
  return func(Me, checkCond, objID)
end

function customCheckFuncs.CheckShowSeesawInterruptUI(entity, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  return Lib.canMeetTheCondition(target, Me, checkCond.conditions)
end

function customCheckFuncs.CheckShowRockingcarInterruptUI(entity, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  return Lib.canMeetTheCondition(target, Me, checkCond.conditions)
end

function customCheckFuncs.CheckShowBoardInterruptUI(entity, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  return Lib.canMeetTheCondition(target, Me, checkCond.conditions)
end

function customCheckFuncs.CheckIsRideOnTarget(entity, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  local objID = entity.objID
  local passengers = target:data("passengers")
  for _, v in pairs(passengers) do
    if objID == v then
      return true
    end
  end
  return false
end

function customCheckFuncs.CheckIsIdleMoveStatus(player, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  if player:getInteractPlayerHorseID() > 0 or 0 < player:getInteractPlayerUpID() then
    return
  end
  if 0 < target.rideOnId then
    return false
  end
  local passengers = target:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  if player and player:isValid() and player.isPlayer and player.getCurCarryPetObjId then
    local petObjId = player:getCurCarryPetObjId()
    if petObjId == targetObjID then
      return true
    end
  end
  return false
end

function customCheckFuncs.isPetCanRide(player, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  if target.rideOnId > 0 then
    return false
  end
  local passengers = target:data("passengers")
  if next(passengers) ~= nil then
    return false
  end
  if player and player:isValid() and player.isPlayer and player.getCurCarryPetObjId then
    local petObjId = player:getCurCarryPetObjId()
    local rps = target:cfg().ridePos
    if petObjId == targetObjID and rps and 0 < #rps then
      return true
    end
  end
  return false
end

function customCheckFuncs.checkShipDriverIsNone(player, checkCond, targetObjID)
  local target = World.CurWorld:getObject(targetObjID)
  if not target then
    return false
  end
  local rps = target:cfg().ridePos
  if rps and #rps <= 0 then
    return false
  end
  local passengers = target:data("passengers")
  if passengers[1] then
    return false
  end
  if 0 < player.rideOnId and player.rideOnId ~= targetObjID then
    return false
  end
  return true
end
