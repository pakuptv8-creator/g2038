local Player = _ENV.Player

function Player:updatePlayerNewPos()
  local pos = self:getPosition()
  local yaw = self:getRotationYaw()
  local newPos = self:getNewWithShapeScale(pos, yaw)
  self:setPos(newPos)
end

function Player:canReleaseRobber()
  return self.clReleaseRobber ~= nil
end

function Player:releaseRobber()
  if not self:canReleaseRobber() then
    return
  end
  self.clReleaseRobber()
  self.clReleaseRobber = nil
  self:sendPacket({
    pid = "UpdateInteractiveControlShow",
    isShow = false
  })
end

function Player:forceClearRobber()
  if self.clForceClearRobber then
    self.clForceClearRobber()
    self.clForceClearRobber = nil
  end
end

function Player:clientDoJumpEvent()
  if self:isCatchAsRobber() then
    return
  end
  local oldEnterId = self:getInteractCarEnterID()
  if oldEnterId ~= "" then
    local enterPart = Instance.getByInstanceId(oldEnterId)
    if enterPart and enterPart:isValid() then
      if enterPart.jumpBackFunc then
        enterPart.jumpBackFunc()
      end
      return
    end
  end
  local oldPartId = self:getInteractionPartID()
  if oldPartId ~= "" then
    self:doStopPlayerFurniture()
    return
  end
  local interactPlayerHorseID = self:getInteractPlayerHorseID()
  if 0 < interactPlayerHorseID then
    self:onlyClearPlayerHorse()
  elseif self.rideOnInstanceId then
    self:rideOffFromPartVehicle()
  elseif self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
    self:leaveFixedPointVehicle()
  elseif 0 < self.rideOnId then
    local rideOnId = self.rideOnId
    local rideOnEntity = World.CurWorld:getEntity(rideOnId)
    if rideOnEntity and rideOnEntity:isValid() then
      local cfg = rideOnEntity:cfg()
      local passengers = rideOnEntity:data("passengers")
      local objId = self.objID
      if cfg.jumpToRideOff == nil or cfg.jumpToRideOff ~= false or passengers[1] ~= objId then
        self:tryClearRide()
        if 0 >= rideOnEntity.rideOnId then
          local oldPos = rideOnEntity:getPosition()
          rideOnEntity:setMapPos(nil, oldPos)
        end
        if cfg and cfg.isShip and cfg.waterMoveBuff and cfg.waterMoveBuff[1] then
          rideOnEntity:updateShipWaterMoveSound()
          local buffName = cfg.waterMoveBuff[1]
          local isHas = self:getTypeBuff("fullName", buffName)
          if isHas then
            self:removeTypeBuff("fullName", buffName)
          end
        end
      end
    end
    self:stopSlideLadderInteract()
  end
end
