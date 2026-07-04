local OperationManager = T(Lib, "OperationManager")
local VehicleManager = T(Lib, "VehicleManager")
local handles = T(Player, "PackageHandlers")
local CarConfig = T(Config, "CarConfig")

function handles:startHelicopter(packet)
  if self.rideOnId then
    local helicopter = World.CurWorld:getEntity(self.rideOnId)
    if helicopter and helicopter:isValid() then
      helicopter:setProp("gravity", 0)
      helicopter.isFlying = true
      helicopter:addBuff("myplugin/zhishengji_run_buff")
      local packet = {
        pid = "helicopterTakeOff",
        objID = self.rideOnId,
        driverUid = self.platformUserId
      }
      WorldServer.BroadcastPacket(packet)
    end
  end
end

function handles:stopHelicopter(packet)
  local objId = packet.objId
  local gravity = packet.gravity
  local helicopter = World.CurWorld:getEntity(objId)
  if helicopter and helicopter:isValid() then
    if gravity then
      helicopter:setProp("gravity", gravity)
    end
    helicopter.isFlying = false
    helicopter:removeTypeBuff("fullName", "myplugin/zhishengji_run_buff")
    local packet = {
      pid = "helicopterStop",
      objID = objId,
      gravity = gravity
    }
    WorldServer.BroadcastPacket(packet)
  end
end

function handles:vehicleAddBuff(packet)
  local objId = packet.objId
  print("vehicleAddBuff-------- ", objId, packet.buffName)
  local buffName = packet.buffName
  local target = World.CurWorld:getEntity(objId)
  if target and target:isValid() then
    target:addBuff(buffName)
  end
end

function handles:vehicleRemoveBuff(packet)
  local objId = packet.objId
  local buffName = packet.buffName
  local target = World.CurWorld:getEntity(objId)
  if target and target:isValid() then
    target:removeTypeBuff("fullName", buffName)
  end
end

function handles:getFlyStatus(packet)
  local objId = packet.objID
  local target = World.CurWorld:getEntity(objId)
  if target and target:isValid() and (target.isFlying or not target.onGround) then
    if not target.isFlying then
      return
    end
    self:sendPacket({
      pid = "setFlyStatus",
      objID = objId
    })
  end
end

function handles:OnOperationCar(packet)
  self:onOperationCar(packet.params)
end

function handles:sendCarCommand(packet)
  local act = packet.act
  local instanceID = packet.instanceID
  local params = packet.params
  local target = Instance.getByInstanceId(instanceID)
  if target and target:isValid() then
    local status = OperationManager:addOperation(instanceID, act, params, self)
    if status ~= nil then
      self:sendPacket({
        pid = "vehicleStatusChange",
        act = act,
        status = status
      })
    end
  end
end

function handles:playCarBgm(packet)
  local instanceID = packet.instanceID
  local bgmKey = packet.key
  local target = Instance.getByInstanceId(instanceID)
  if target and target:isValid() then
    local command = OperationManager:getCommand(instanceID, Define.OPERATION_TYPE.MUSIC)
    if not command then
      local status = OperationManager:addOperation(instanceID, Define.OPERATION_TYPE.MUSIC, {key = bgmKey}, self)
      if status ~= nil then
        self:sendPacket({
          pid = "vehicleStatusChange",
          act = Define.OPERATION_TYPE.MUSIC,
          status = status
        })
      end
    else
      command:execute({key = bgmKey}, self)
      self:sendPacket({
        pid = "vehicleStatusChange",
        act = Define.OPERATION_TYPE.MUSIC,
        status = true
      })
    end
  end
end

function handles:stopCarBgm(packet)
  local instanceID = packet.instanceID
  local target = Instance.getByInstanceId(instanceID)
  if target and target:isValid() then
    local command = OperationManager:getCommand(instanceID, Define.OPERATION_TYPE.MUSIC)
    if command and command:getActiveStatus() then
      local status = OperationManager:addOperation(instanceID, Define.OPERATION_TYPE.MUSIC, {}, self)
      if status ~= nil then
        self:sendPacket({
          pid = "vehicleStatusChange",
          act = Define.OPERATION_TYPE.MUSIC,
          status = status
        })
      end
    end
  end
end

function handles:vehicleMove(packet)
  local instanceID = packet.instanceID
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    driver:removeTypeBuff("fullName", CarConfig:getStandbySound(packet.tid, self.platformUserId))
    local started = CarConfig:getStartedSound(packet.tid)
    local buff = driver:getTypeBuff("fullName", started)
    if not buff then
      driver:addBuff(started)
    end
  end
end

function handles:vehicleMoveCancel(packet)
  VehicleManager:removeSounds(packet.instanceID)
end

function handles:vehicleStop(packet)
  local instanceID = packet.instanceID
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    driver:removeTypeBuff("fullName", CarConfig:getStartedSound(packet.tid))
    local standby = CarConfig:getStandbySound(packet.tid)
    local buff = driver:getTypeBuff("fullName", standby)
    if not buff then
      driver:addBuff(standby)
    end
  end
end

function handles:vehicleStopCancel(packet)
  local instanceID = packet.instanceID
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    driver:removeTypeBuff("fullName", CarConfig:getStandbySound(packet.tid))
  end
end

function handles:vehicleSpeedUp(packet)
  local instanceID = packet.instanceID
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    driver:removeTypeBuff("fullName", CarConfig:getStandbySound(packet.tid, self.platformUserId))
    local sound = CarConfig:getStartedSound(packet.tid)
    local buff = driver:getTypeBuff("fullName", sound)
    if not buff then
      driver:addBuff(sound)
    end
  end
end

function handles:vehicleSpeedDown(packet)
  local instanceID = packet.instanceID
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    driver:removeTypeBuff("fullName", CarConfig:getStandbySound(packet.tid, self.platformUserId))
    local sound = CarConfig:getStartedSound(packet.tid)
    local buff = driver:getTypeBuff("fullName", sound)
    if not buff then
      driver:addBuff(sound)
    end
  end
end

function handles:vehicleSpeedUpOrDownCancel(packet)
end

function handles:networkOwnerChange(packet)
  local instanceId = packet.instanceId
  if not instanceId then
    return
  end
  local res = VehicleManager:executeNetworkOwnerChange(instanceId)
  if res then
    World.Timer(2, function()
      local packet = {
        pid = "resetVehicleController",
        instanceId = instanceId
      }
      WorldServer.BroadcastPacket(packet)
    end)
  end
end

function handles:checkVehicleRideStatus(packet)
  local userId = packet.userId
  if not userId then
    return
  end
  local player = Game.GetPlayerByUserId(userId)
  if player and player:isValid() and player.rideOnInstanceId then
    local vehicleInst = Instance.getByInstanceId(player.rideOnInstanceId)
    if vehicleInst and vehicleInst:isValid() then
      local driver = VehicleManager:getVehicleDriver(vehicleInst)
      local isDriver = driver == player
      local ownerId = VehicleManager:getVehicleOwner(player.rideOnInstanceId)
      local isOwner = player.platformUserId == ownerId
      local packet = {
        pid = "rideOnPartVehicle",
        vehicleId = player.rideOnInstanceId,
        objID = player.objID,
        isDriver = isDriver,
        isOwner = isOwner
      }
      if driver and driver.alwaysAction ~= "" then
        packet.alwaysAction = driver.alwaysAction
      end
      self:sendPacket(packet)
    end
  end
end

function handles:overRefuelVehicle(packet)
  local instanceId = self:getInUseOilGunID()
  if not instanceId then
    return
  end
  local part = Instance.getByInstanceId(instanceId)
  if not part or not part:isValid() then
    return
  end
  if part.restoreFunc then
    part.restoreFunc()
    part.restoreFunc = nil
  end
  part.isUsing = nil
end

function handles:reqPaintVehicle(packet)
  local id = self.rideOnInstanceId
  local instance = Instance.getByInstanceId(id)
  if not instance then
    return
  end
  
  local function foreachNode(node)
    local scriptName = node:getScriptName()
    if (scriptName == "Part" or scriptName == "MeshPart") and node:getName() == "colorchange" then
      node:setColor(packet.color)
    end
    for k, v in pairs(node:getAllChild()) do
      foreachNode(v)
    end
  end
  
  foreachNode(instance)
end
