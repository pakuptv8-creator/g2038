local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function EntityServer:interact_seesaw_furniture(target, cfg)
  if not target or not target:isValid() then
    return
  end
  if target.rideOnId > 0 and not target:tryClearRide(true) then
    return
  end
  local oldPartId = target:getInteractionPartID()
  if oldPartId ~= "" then
    target:doStopPlayerFurniture()
  end
  local rideOnInstanceId = target.rideOnInstanceId
  if rideOnInstanceId then
    local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
    if vehicleInst and vehicleInst:isValid() then
      return false
    end
  end
  target:rideOn(self, false, cfg.site)
  target.startRideTime = os.time()
end

function EntityServer:interact_board_drawing(target, cfg)
  if not target and not target:isValid() then
    return
  end
  local owner = World.CurWorld:getEntity(self.ownerId)
  if owner then
    return
  end
  local rideOnId = target.rideOnId
  local rideOnEntity = World.CurWorld:getEntity(rideOnId)
  if rideOnEntity and rideOnEntity:isValid() or target.rideOnInstanceId then
    target:cancelVehicleItemUse()
    target:removeUsingVehicle()
    target:removeRidingPet()
  end
  local passengers = target:data("passengers") or {}
  if next(passengers) ~= nil then
    target:cancelVehicleItemUse()
  end
  local interactPlayerHorseID = target:getInteractPlayerHorseID()
  local interactPlayerUpID = target:getInteractPlayerUpID()
  if 0 < interactPlayerUpID or 0 < interactPlayerHorseID then
    target:clearRide()
  else
    target:tryClearRide()
  end
  local oldPartId = target:getInteractionPartID()
  if oldPartId ~= "" then
    target:doStopPlayerFurniture()
  end
  target:rideOn(self, false)
end

function EntityServer:interact_public_performer(target, cfg)
  if self.guijiaPlayerActionTime and os.time() - self.guijiaPlayerActionTime < self.guijiaPlayerActionDuration then
    return
  end
  local cfg = self:cfg()
  if cfg and cfg.performActions then
    local randomData = Lib.randomItemByWeight(1, cfg.performActions, false)
    if randomData and randomData[1] and randomData[1].action then
      EntityServer.playAction({
        entity = self,
        actionName = randomData[1].action,
        actionTime = -1
      })
      local soundKey = cfg.actionSoundKey
      if soundKey then
        local packet = {
          pid = "Play3dSoundByKey",
          params = {
            key = soundKey,
            pos = self:getPosition()
          }
        }
        self:sendPacketToTracking(packet, true)
      end
      self.guijiaPlayerActionTime = os.time()
      self.guijiaPlayerActionDuration = randomData[1].duration
    end
  end
end

function EntityServer:isRideOnState()
  if self.rideOnId > 0 then
    return true
  end
end

function Entity:onHelicopterMonitoring(type, target, params)
  if self.isPlayer then
  elseif target.properties then
    local cfg = self:cfg()
    if cfg and cfg.isHelicopter then
      local HelicopterManagerHelper = T(Lib, "HelicopterManagerHelper")
      if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
        HelicopterManagerHelper:enterPoliceRegion(self, target.name)
      elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
        HelicopterManagerHelper:leavePoliceRegion(self, target.name)
      end
    end
  end
end

function EntityServer:checkIsCarryOtherPlayer()
  if not self.isPlayer then
    return false
  end
  if self:getInteractPlayerUpID() > 0 then
    return true
  end
  local passengers1 = self:data("passengers")
  for idx1, objID1 in pairs(passengers1) do
    local cart = World.CurWorld:getObject(objID1)
    if cart and cart:isValid() and not cart.isPlayer then
      local passengers2 = cart:data("passengers")
      for idx2, objID2 in pairs(passengers2) do
        local fare = World.CurWorld:getObject(objID2)
        if fare and fare.isPlayer then
          return true
        end
      end
    end
  end
  if 0 < self.rideOnId then
    local car = World.CurWorld:getObject(self.rideOnId)
    if not car or not car:isValid() then
      return false
    end
    if car.isPlayer then
      return false
    end
    local passengers3 = car:data("passengers")
    local rps = car:cfg().ridePos
    local ctrlIdx
    for i, tb in ipairs(rps) do
      if rps[i].ctrl then
        ctrlIdx = i
        break
      end
    end
    if 1 < #passengers3 and passengers3[ctrlIdx] == self.objID then
      return true
    end
  end
  return false
end
