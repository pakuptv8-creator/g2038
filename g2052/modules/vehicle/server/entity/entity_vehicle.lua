local PropsConfig = T(Config, "PropsConfig")
local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local ShipManagerHelper = T(Lib, "ShipManagerHelper")

function Entity.EntityProp:rideOffFrom(value, add, buff)
  if add and self.rideOnId > 0 then
    local rideOnObj = self.world:getEntity(self.rideOnId)
    if rideOnObj and rideOnObj:isValid() then
      local cfg = rideOnObj:cfg()
      local fullName = cfg.fullName
      if fullName == value then
        self:rideOn()
      end
    end
  end
end

function Entity.EntityProp:rideOnNull(value, add, buff)
  if not add then
    local throwEntity = self:data("main").throwEntity
    if not throwEntity or not throwEntity:isValid() then
      return
    end
    local throwOBJID = throwEntity.objID
    if self.rideOnId > 0 and self.rideOnId == throwOBJID then
      self:rideOn()
      self:data("main").throwEntity = nil
    else
      local passengers = self:data("passengers")
      for _, objId in pairs(passengers) do
        if objId == throwOBJID then
          local entity = self.world:getEntity(objId)
          if entity and entity:isValid() then
            entity:destroy()
            self:data("main").throwEntity = nil
          end
        end
      end
    end
    self:sendPacket({
      pid = "UpdateUseTrolley",
      inUse = false
    })
  end
end

function Entity:onShipMonitoring(type, target, params)
  if self.isPlayer then
  elseif target.properties then
    local cfg = self:cfg()
    if cfg and cfg.isShip then
      if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
        ShipManagerHelper:enterShipRegion(self, target.name)
      elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
        ShipManagerHelper:leaveShipRegion(self, target.name)
      end
    end
  end
end

local function calculateRideShipIndex(player, ship)
  local collisionPos = player:getPosition()
  local shipPos = ship:getPosition()
  local passengers = ship:data("passengers")
  local rps = ship:cfg().ridePos
  if #rps == 1 then
    return 1
  end
  local index, disMin
  for i, v in ipairs(rps) do
    if 1 < i and not passengers[i] then
      local posOffset = Lib.v3(v.pos.x, v.pos.y, v.pos.z)
      local pos
      pos = shipPos + ship:getRotationQ() * posOffset
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

function Entity:rideOnShipEntity(target, _, from, isEnabled, params)
  if not target or not target:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  local cfg_target = target:cfg()
  local oldPartId = from:getInteractionPartID()
  if oldPartId ~= "" then
    return
  end
  local oldEnterId = from:getInteractCarEnterID()
  if oldEnterId ~= "" then
    return false
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
  local targetIndex
  if params and params.ridePosIndex then
    targetIndex = params.ridePosIndex
  end
  local passengers = target:data("passengers")
  if from.rideOnId > 0 then
    if params.rideShipBtn then
      if passengers[1] then
        return
      end
      if from.rideOnId == target.objID then
        from:rideOn()
        World.Timer(1, function()
          if from and from:isValid() then
            from:rideOnShipEntity(target, _, from, true, params)
          end
          return false
        end)
      end
      return
    else
      return
    end
  end
  if not isEnabled then
    from:rideOn()
  else
    targetIndex = targetIndex or calculateRideShipIndex(from, target)
    Lib.logDebug("ride index: ", targetIndex)
    local passengers = target:data("passengers")
    if passengers[targetIndex] then
      return
    end
    from:rideOn(target, nil, targetIndex)
    if from.forceSwimMode then
      from:SetForceSwim(false)
    end
  end
end
