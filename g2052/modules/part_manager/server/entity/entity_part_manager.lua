local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local engine_version = EngineVersionSetting:getEngineVersion()
local PartFloatAreaManager = T(Lib, "PartFloatAreaManager")

function EntityServer:hideEntity()
  WorldServer.BroadcastPacket({
    pid = "hideEntity",
    objID = self.objID
  })
end

function Entity:onUpdateFloatArea(type, part, params)
  if self:cfg().isSkate == true then
    return
  end
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    PartFloatAreaManager:enterAreaUpdate(part, self, params)
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    PartFloatAreaManager:exitAreaUpdate(part, self, params)
  end
end

function Entity:onTouchWater(type, part, params)
  local isEnter = type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN
  local areasId = part:getInstanceID()
  if not self.onWaterAreas then
    self.onWaterAreas = {}
  end
  if self:cfg().isShip then
    if isEnter then
      self:addBuff(self:cfg().waterBuff)
    else
      self:addBuff(self:cfg().landBuff)
    end
    self.onWaterAreas[areasId] = isEnter or nil
    self:updateShipWaterMoveSound()
  else
    if not self.isPlayer then
      return
    end
    if self.rideOnId > 0 then
      local rideOnEntity = World.CurWorld:getEntity(self.rideOnId)
      if rideOnEntity and rideOnEntity:isValid() and rideOnEntity:cfg().isShip then
        self.onWaterAreas = {}
        return
      end
    end
    self.onWaterAreas[areasId] = isEnter or nil
    local isSwim = false
    for areasId, v in pairs(self.onWaterAreas) do
      local part = Instance.getByInstanceId(areasId)
      if part and part:isValid() then
        isSwim = v
        break
      else
        self.onWaterAreas[areasId] = nil
      end
    end
    self:SetForceSwim(isSwim)
    if isSwim then
      local rideOnId = self.rideOnId
      local rideOnEntity = World.CurWorld:getEntity(rideOnId)
      if rideOnEntity and rideOnEntity:isValid() then
        self:cancelVehicleItemUse()
        self:removeUsingVehicle()
        self:removeRidingPet()
      end
      if self.rideOnInstanceId then
        self:rideOffFromPartVehicle()
      end
      local passengers = self:data("passengers") or {}
      if next(passengers) ~= nil then
        self:cancelVehicleItemUse()
      end
      local interactPlayerHorseID = self:getInteractPlayerHorseID()
      local interactPlayerUpID = self:getInteractPlayerUpID()
      if 0 < interactPlayerUpID or 0 < interactPlayerHorseID then
        self:clearRide()
      else
        self:tryClearRide()
      end
      self.curSwimAABB = part:getWorldAABB()
    end
    if self.swimTimer then
      self.swimTimer()
      self.swimTimer = nil
    end
    self.swimTimer = World.Timer(20, function()
      if not self or not self:isValid() then
        return
      end
      if self.curSwimAABB then
        local playerAABB = self:getWorldAABB()
        local isInside = Lib.isIntersected(self.curSwimAABB, playerAABB)
        if self.forceSwimMode ~= isInside then
          self:SetForceSwim(isInside)
          self.swimTimer = nil
          return
        else
          self:SetForceSwim(isInside)
          self.swimTimer = nil
          return
        end
      else
        self.swimTimer = nil
        return
      end
    end)
  end
end

function Entity:isInWaterArea()
  if self.onWaterAreas then
    for areasId, v in pairs(self.onWaterAreas) do
      if v then
        return true
      end
    end
  end
  return false
end

function Entity:updateShipWaterMoveSound()
  local cfg = self:cfg()
  if cfg and cfg.isShip then
    local buffName = cfg.waterMoveBuff[1]
    local passengers = self:data("passengers")
    if passengers[1] then
      local player = World.CurWorld:getObject(passengers[1])
      if not player or not player:isValid() then
        return
      end
      local entity = self
      local isHas = self:getTypeBuff("fullName", buffName)
      if self.shipMoveState == Define.EntityMoveStatus[2] then
        if isHas then
          entity:removeTypeBuff("fullName", buffName)
        end
      elseif self:isInWaterArea() then
        if not isHas then
          entity:addBuff(buffName)
        end
      elseif isHas then
        entity:removeTypeBuff("fullName", buffName)
      end
    else
      local isHas = self:getTypeBuff("fullName", buffName)
      if isHas then
        self:removeTypeBuff("fullName", buffName)
      end
    end
  end
end
