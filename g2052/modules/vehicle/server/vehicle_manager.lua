local CarConfig = T(Config, "CarConfig")
local OperationManager = T(Lib, "OperationManager")
local VehicleManager = T(Lib, "VehicleManager")
local destroyDistance = World.cfg.vehicleDestroyDistance

function VehicleManager:init()
  self.summonedVehicles = {}
  self.networkOwnerChangeList = {}
end

function VehicleManager:getAllSummonedVehicles()
  return self.summonedVehicles
end

function VehicleManager:addNetworkOwnerChange(vehicleInst)
  local instanceId = vehicleInst:getInstanceID()
  if not self.networkOwnerChangeList[instanceId] then
    self.networkOwnerChangeList[instanceId] = vehicleInst
    vehicleInst:connect("on_destroy", function(instance)
      if instance == vehicleInst then
        local instanceId = vehicleInst:getInstanceID()
        self.networkOwnerChangeList[instanceId] = nil
      end
    end)
  end
end

function VehicleManager:executeNetworkOwnerChange(instanceId)
  if not instanceId or not self.networkOwnerChangeList[instanceId] then
    return
  end
  local vehicle = self.networkOwnerChangeList[instanceId]
  local ownerId = self:getVehicleOwner(instanceId)
  local player = Game.GetPlayerByUserId(ownerId)
  if player and player:isValid() then
    vehicle:setNetworkOwner(player:getRaknetID())
    local cheLunAndSeat = {}
    for _, name in ipairs(World.cfg.vehicleSetting.clientControlParts or {}) do
      Lib.getInstanceAllChild(vehicle, cheLunAndSeat, Define.ABILITY.AABB, name)
    end
    for _, lun in pairs(cheLunAndSeat) do
      lun:setNetworkOwner(player:getRaknetID())
    end
    self.networkOwnerChangeList[instanceId] = nil
    return true
  end
end

function VehicleManager:isInNetworkOwnerChangeList(instanceId)
  return self.networkOwnerChangeList[instanceId] ~= nil
end

function VehicleManager:checkVehicleStatus()
  for ownerId, car in pairs(self.summonedVehicles) do
    local player = Game.GetPlayerByUserId(ownerId)
    if player and player:isValid() then
      local distance = Lib.getPosDistance(car:getPosition(), player:getPosition())
      if distance >= destroyDistance then
        self:removeSummonedVehicle(ownerId)
      end
    else
      self:removeSummonedVehicle(ownerId)
    end
  end
end

function VehicleManager:addSummonedVehicle(inst, ownerId)
  if not ownerId then
    return
  end
  self:removeSummonedVehicle(ownerId)
  self.summonedVehicles[ownerId] = inst
end

function VehicleManager:isVehicleOwner(vehicleInst, ownerId)
  if not vehicleInst or not vehicleInst:isValid() then
    return false
  end
  for oid, inst in pairs(self.summonedVehicles) do
    if inst and inst:isValid() and vehicleInst:getInstanceID() == inst:getInstanceID() then
      return ownerId == oid
    end
  end
  return false
end

function VehicleManager:getVehicleOwner(instanceId)
  local owner
  local inValidOwners = {}
  for oid, inst in pairs(self.summonedVehicles) do
    if inst and inst:isValid() then
      if instanceId == inst:getInstanceID() then
        owner = oid
        break
      end
    else
      inValidOwners[#inValidOwners + 1] = oid
    end
  end
  if 0 < #inValidOwners then
    for _, oid in ipairs(inValidOwners) do
      self.summonedVehicles[oid] = nil
    end
  end
  return owner
end

function VehicleManager:getVehicleDriver(vehicleInst)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local count = vehicleInst:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicleInst:getChildAt(i)
    if n:getName() == "mp_driver" and n.mountId ~= 0 then
      return Instance.getByInstanceId(n.mountId)
    end
  end
end

function VehicleManager:getVehicleDriverAndPassenger(vehicleInst)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local riders = {}
  local count = vehicleInst:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicleInst:getChildAt(i)
    if (n:getName() == "mp_driver" or n:getName() == "mp_passenger") and n.mountId ~= 0 then
      table.insert(riders, Instance.getByInstanceId(n.mountId))
    end
  end
  return riders
end

function VehicleManager:removeSummonedVehicle(ownerId)
  if self.summonedVehicles[ownerId] then
    local inst = self.summonedVehicles[ownerId]
    if not inst or not inst:isValid() then
      return
    end
    local instID = inst:getInstanceID()
    self:clearRide(inst, nil, true)
    OperationManager:removeCommands(instID)
    self.summonedVehicles[ownerId] = nil
    local player = Game.GetPlayerByUserId(ownerId)
    if player and player:isValid() then
      local useCarInfo = player:getInUseCar()
      if useCarInfo and useCarInfo.objId == instID then
        player:setInUseCar(nil)
      end
    end
    World.Timer(1, function()
      if inst and inst:isValid() then
        Plugins.CallTargetPluginFunc("part_manager", "destroyPart", inst)
      end
    end)
  end
end

function VehicleManager:clearRide(vehicle, excludedIDs, isDestroyVehicle)
  if not vehicle or not vehicle:isValid() then
    return
  end
  
  local function isIdExcluded(instanceId)
    if excludedIDs then
      for _, id in pairs(excludedIDs) do
        if id == instanceId then
          return true
        end
      end
    end
    return false
  end
  
  local count = vehicle:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicle:getChildAt(i)
    if (n:getName() == "mp_driver" or n:getName() == "mp_passenger") and n.mountId ~= 0 and not isIdExcluded(n.mountId) then
      local entity = Instance.getByInstanceId(n.mountId)
      if entity and entity:isValid() and entity:isA("Entity") then
        if not entity.isPlayer then
          local passengers = entity:data("passengers")
          for _, objId in pairs(passengers) do
            local player = World.CurWorld:getEntity(objId)
            if player and player:isValid() and player.isPlayer and player.rideOnInstanceId then
              entity = player
            end
          end
        end
        if entity.isPlayer then
          entity:rideOffFromPartVehicle(isDestroyVehicle)
        end
      end
    end
  end
end

function VehicleManager:isCarLocked(inst)
  if not inst or not inst:isValid() then
    return false
  end
  return OperationManager:getCommandStatus(inst:getInstanceID(), Define.OPERATION_TYPE.LOCK)
end

function VehicleManager:destroyCarsInArea(pos, size)
  local from = pos - size / 2
  local to = pos + size / 2
  for ownerId, car in pairs(self.summonedVehicles) do
    if car and car:isValid() then
      local carPos = car:getPosition()
      if carPos.x <= to.x and carPos.x >= from.x and carPos.z <= to.z and carPos.z >= from.z then
        self:removeSummonedVehicle(ownerId)
      end
    else
      self:removeSummonedVehicle(ownerId)
    end
  end
end

function VehicleManager:primaryVehicleRideOnReport(player, entity)
  if not player.isPlayer then
    return
  end
  local sitIdx
  local passengers = entity:data("passengers")
  for i, objId in pairs(passengers) do
    if objId == player.objID then
      sitIdx = i
      break
    end
  end
  if not sitIdx then
    return
  end
  if sitIdx == 1 then
    local useCarInfo = player:getInUseCar()
    if not useCarInfo then
      return
    end
    if not CarConfig:isPrimaryCar(useCarInfo.id) then
      return
    end
    player:recordCarUseTime(useCarInfo.id, "drive", player.platformUserId)
    local reportData = {
      car_id = useCarInfo.id,
      is_Ad_free = player:getCarUseIsAdFree(useCarInfo.id, nil)
    }
    Plugins.CallTargetPluginFunc("report", "report", "car_drive", reportData, player)
  else
    local driverObjId = passengers[1]
    local driver = World.CurWorld:getEntity(driverObjId)
    if not driver or not driver:isValid() then
      return
    end
    local useCarInfo = driver:getInUseCar()
    if not useCarInfo then
      return
    end
    if not CarConfig:isPrimaryCar(useCarInfo.id) then
      return
    end
    player:recordCarUseTime(useCarInfo.id, "ride", driver.platformUserId)
    local reportData = {
      car_id = useCarInfo.id,
      is_Ad_free = driver:getCarUseIsAdFree(useCarInfo.id, nil)
    }
    Plugins.CallTargetPluginFunc("report", "report", "car_ride", reportData, player)
  end
end

function VehicleManager:primaryVehicleRideOffReport(player, car)
  if not player.isPlayer then
    return
  end
  local useCarTime = player:getValue("useCarTime")
  if next(useCarTime) ~= nil then
    local now = os.time()
    if useCarTime.action == "drive" then
      local reportData = {
        car_id = useCarTime.id or 0,
        car_time = useCarTime.time and now - useCarTime.time or 0,
        is_Ad_free = player:getCarUseIsAdFree(useCarTime.id)
      }
      Plugins.CallTargetPluginFunc("report", "report", "car_drive_cancel", reportData, player)
    else
      local reportData = {
        car_id = useCarTime.id or 0,
        car_time = useCarTime.time and now - useCarTime.time or 0,
        is_Ad_free = player:getCarUseIsAdFree(useCarTime.id)
      }
      if useCarTime.driverUserId then
        local owner = Game.GetPlayerByUserId(useCarTime.driverUserId)
        if owner then
          reportData.is_Ad_free = owner:getCarUseIsAdFree(useCarTime.id)
        end
      end
      Plugins.CallTargetPluginFunc("report", "report", "car_ride_cancel", reportData, player)
    end
    player:clearCarUseTime()
  end
end

function VehicleManager:advancedVehicleRideOnReport(player, vehicleInst, isDriver)
  if not player.isPlayer then
    return
  end
  local carName = vehicleInst:getName()
  local carCfg = CarConfig:getCfgByName("myplugin/" .. carName)
  if not carCfg then
    return
  end
  if isDriver then
    player:recordCarUseTime(carCfg.id, "drive")
    local reportData = {
      car_id = carCfg.id,
      is_Ad_free = player:getCarUseIsAdFree(carCfg.id, vehicleInst:getInstanceID())
    }
    Plugins.CallTargetPluginFunc("report", "report", "car_drive", reportData, player)
  else
    player:recordCarUseTime(carCfg.id, "ride")
    local reportData = {
      car_id = carCfg.id,
      is_Ad_free = player:getCarUseIsAdFree(carCfg.id, vehicleInst:getInstanceID())
    }
    Plugins.CallTargetPluginFunc("report", "report", "car_ride", reportData, player)
  end
end

function VehicleManager:advancedVehicleRideOffReport(player, vehicleInst, isDriver)
  if not player.isPlayer then
    return
  end
  local carName = vehicleInst:getName()
  local carCfg = CarConfig:getCfgByName("myplugin/" .. carName)
  if not carCfg then
    return
  end
  local useCarTime = player:getValue("useCarTime")
  if next(useCarTime) ~= nil then
    local now = os.time()
    local reportData = {
      car_id = carCfg.id or 0,
      car_time = useCarTime.time and now - useCarTime.time or 0,
      is_Ad_free = player:getCarUseIsAdFree(carCfg.id, vehicleInst:getInstanceID())
    }
    if isDriver then
      Plugins.CallTargetPluginFunc("report", "report", "car_drive_cancel", reportData, player)
    else
      Plugins.CallTargetPluginFunc("report", "report", "car_ride_cancel", reportData, player)
    end
    player:clearCarUseTime()
  end
end

VehicleManager.forbidAreaBox = {}

function VehicleManager:onPartCreated(instance, name)
  if not instance or not instance:isValid() then
    return
  end
  if not World.cfg.vehicleSetting.forbidArea[name] then
    return
  end
  local rot = instance:getRotation()
  local pos = instance:getPosition()
  local size = instance:getSize()
  if math.floor(rot.y / 90) % 2 ~= 0 then
    size.x, size.z = size.z, size.x
  end
  local id = instance:getInstanceID()
  self.forbidAreaBox[id] = {
    pos - size / 2,
    pos + size / 2
  }
end

function VehicleManager:onPartDestroyed(instance)
  if not instance or not instance:isValid() then
    return
  end
  local id = instance:getInstanceID()
  if not self.forbidAreaBox[id] then
    return
  end
  self.forbidAreaBox[id] = nil
end

function VehicleManager:isPointInForbidArea(point)
  if DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Flight) then
    return false
  end
  for _, tb in pairs(self.forbidAreaBox) do
    local from, to = tb[1], tb[2]
    if point.x <= to.x and point.x >= from.x and point.z <= to.z and point.z >= from.z then
      return true
    end
  end
  return false
end

local carSize

function VehicleManager:hasCarInArea(pos, player)
  if not carSize then
    local totalSize = Lib.v3(0, 0, 0)
    local count = 0
    for _, car in pairs(self.summonedVehicles) do
      totalSize = totalSize + car:getSize()
      count = count + 1
    end
    if 0 < count then
      carSize = totalSize / count
    end
  end
  if not carSize then
    return false
  end
  local from = pos - carSize / 2
  local to = pos + carSize / 2
  for _, car in pairs(self.summonedVehicles) do
    if car and car:isValid() then
      local carPos = car:getPosition()
      if carPos.x <= to.x and carPos.x >= from.x and carPos.z <= to.z and carPos.z >= from.z and not self:isVehicleOwner(car, player.platformUserId) then
        return true
      end
    end
  end
  return false
end

function VehicleManager:removeSounds(instanceID)
  if not instanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local driver = VehicleManager:getVehicleDriver(vehicleInst)
  if driver then
    local carName = vehicleInst:getName()
    local carCfg = CarConfig:getCfgByName("myplugin/" .. carName)
    if not carCfg then
      return
    end
    driver:removeTypeBuff("fullName", CarConfig:getStartedSound(carCfg.id))
    driver:removeTypeBuff("fullName", CarConfig:getStandbySound(carCfg.id))
  end
end

VehicleManager:init()
return VehicleManager
