local Interact = T(World, "Interact")

function Interact.lift_up_pet(target, eventParams, from, isEnabled, params)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  local ridePosIndex = tonumber(eventParams[1])
  from:liftUpPet(ridePosIndex)
end

function Interact.play_with_pet(target, eventParams, from, isEnabled, params)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  local ridePosIndex = tonumber(eventParams[1])
  from:playWithPet(ridePosIndex)
end

function Interact.feed_pet(target, _, from, isEnabled, params)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  from:feedPet()
end

function Interact.ride_pet(target, _, from, isEnabled, params)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  if not Plugins.CallTargetPluginFunc("vehicle", "checkCanDoRideOn", from) then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", from, "g2052.gui.car.forbid.use")
    return
  end
  if from.rideOnId > 0 then
    local target = World.CurWorld:getEntity(from.rideOnId)
    if target and target:cfg().isShip then
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", from, "g2052.gui.car.forbid.use")
      return
    end
  end
  local inUseCar = from:getInUseCar()
  if inUseCar then
    local params = {
      id = inUseCar.id
    }
    from:onOperationCar(params)
  end
  local oldPartId = from:getInteractionPartID()
  if oldPartId ~= "" then
    from:doStopPlayerFurniture()
  end
  from:ridePet()
end
