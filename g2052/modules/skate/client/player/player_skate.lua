Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(riderObjId, rideOnId)
  if riderObjId ~= Me.objID then
    return
  end
  local target = World.CurWorld:getEntity(rideOnId)
  if target and target:isValid() and target:cfg().isSkate == true then
    print("enter skate mode-------------------1111111")
    Plugins.CallTargetPluginFunc("skate", "ENTER_SKATE_MODE", rideOnId)
  end
end)
Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_OFF, function(riderObjId, rideOnId)
  if riderObjId ~= Me.objID then
    return
  end
  local target = World.CurWorld:getEntity(rideOnId)
  if target and target:isValid() and target:cfg().isSkate == true then
    print("leave skate mode-------------------22222222")
    Lib.emitEvent(Event.EVENT_SKATE_STEP_DOWN)
  end
end)
local Player = _ENV.Player

function Player:cancelSkate()
  local isSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_MODE")
  if isSkateMode then
    Plugins.CallTargetPluginFunc("skate", "LEAVE_SKATE_MODE")
    Lib.emitEvent(Event.EVENT_CANCEL_SKATE)
  end
end

function Player:useSkate(skateId)
  self:setRideOnMoveStatue(self.isMoving)
  self.lockUseSkate = true
  Me:sendPacket({
    pid = "setSkateMode",
    enterSkateMode = true,
    skateId = skateId
  }, function()
    self.lockUseSkate = false
  end)
end

function Player:switchSkate(skateId)
  self:cancelSkate()
  self:useSkate(skateId)
end

function Player:setRideOnMoveStatue(isMoving)
  self.rideOnMoveStatus = isMoving
end

function Player:getRideOnMoveStatue()
  return self.rideOnMoveStatus
end
