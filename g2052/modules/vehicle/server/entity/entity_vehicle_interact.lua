local Interact = T(World, "Interact")

local function checkCanRide(target, from)
  if not target.rideOnId then
    return true
  elseif target.rideOnId == from.objID then
    return false
  else
    local entity = World.CurWorld:getEntity(target.rideOnId)
    if entity and entity:isValid() then
      return checkCanRide(entity, from)
    else
      return true
    end
  end
end

local function calculateRideIndex(player, car)
  local collisionPos = player:getPosition()
  local carPos = car:getPosition()
  local passengers = car:data("passengers")
  local rps = car:cfg().ridePos
  if #rps == 1 then
    return 1
  end
  local index, disMin
  for i, v in ipairs(rps) do
    if not passengers[i] then
      local posOffset = Lib.v3(v.pos.x, v.pos.y, v.pos.z)
      Lib.pv(posOffset)
      local pos
      pos = carPos + car:getRotationQ() * posOffset
      pos.y = collisionPos.y
      if not disMin then
        disMin = Lib.getPosDistanceSqr(pos, collisionPos)
        index = i
      end
      if disMin > Lib.getPosDistanceSqr(pos, collisionPos) then
        disMin = Lib.getPosDistanceSqr(pos, collisionPos)
        index = i
      end
    end
  end
  return index
end

function Interact.ride_on(target, _, from, isEnabled, params)
  if not target or not target:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  local cfg_target = target:cfg()
  if cfg_target.isShip then
    from:rideOnShipEntity(target, _, from, isEnabled, params)
    return
  end
  local oldEnterId = from:getInteractCarEnterID()
  if oldEnterId ~= "" then
    return false
  end
  local passengers = target:data("passengers")
  for _, objId in pairs(passengers) do
    if objId == from.objID then
      return
    end
  end
  if not checkCanRide(target, from) then
    return
  end
  local oldPartId = from:getInteractionPartID()
  if oldPartId ~= "" then
    return
  end
  if from.rideOnInstanceId then
    return
  end
  if cfg_target.onlyPlayerCanRide and not from.isPlayer then
    return
  end
  if not isEnabled and from.rideOnId then
    local curRideTarget = World.CurWorld:getEntity(from.rideOnId)
    if curRideTarget and target ~= curRideTarget then
      return
    end
  end
  if not from:tryClearRide(true) then
    return
  end
  local targetIndex = calculateRideIndex(from, target)
  if params and params.ridePosIndex then
    targetIndex = params.ridePosIndex
  end
  Lib.logDebug("ride index: ", targetIndex)
  if not isEnabled then
    from:rideOn()
  else
    from:rideOn(target, nil, targetIndex)
  end
end
