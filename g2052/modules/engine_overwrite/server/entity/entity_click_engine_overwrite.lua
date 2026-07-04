local Entity = _ENV.Entity

function Entity.ClickProp:clickPublicSeesaw(params, from)
  from:rideOn(self, false)
  from.startRideTime = os.time()
end

function Entity.ClickProp:clickPublicDrawing(params, from)
  if not from and not from:isValid() then
    return
  end
  local owner = World.CurWorld:getEntity(self.ownerId)
  if owner then
    return
  end
  local rideOnId = from.rideOnId
  local rideOnEntity = World.CurWorld:getEntity(rideOnId)
  if rideOnEntity and rideOnEntity:isValid() or from.rideOnInstanceId then
    from:cancelVehicleItemUse()
    from:removeUsingVehicle()
    from:removeRidingPet()
  end
  local passengers = from:data("passengers") or {}
  if next(passengers) ~= nil then
    from:cancelVehicleItemUse()
  end
  local interactPlayerHorseID = from:getInteractPlayerHorseID()
  local interactPlayerUpID = from:getInteractPlayerUpID()
  if 0 < interactPlayerUpID or 0 < interactPlayerHorseID then
    from:clearRide()
  else
    from:tryClearRide()
  end
  local oldPartId = from:getInteractionPartID()
  if oldPartId ~= "" then
    from:doStopPlayerFurniture()
  end
  from:rideOn(self, false)
end

function Entity.ClickProp:clickPublicPerformer(params, from)
  local cfg = self:cfg()
  if cfg and cfg.performActions then
    local randomData = Lib.randomItemByWeight(1, cfg.performActions, false)
    if randomData and randomData[1] and randomData[1].action then
      EntityServer.playAction({
        entity = self,
        actionName = randomData[1].action,
        actionTime = -1
      })
    end
  end
end
