local setting = require("common.setting")
local PartCfg = setting:mod("part")
local CW = World.CurWorld
local CarConfig = T(Config, "CarConfig")
local VehicleManager = T(Lib, "VehicleManager")
local OperationManager = T(Lib, "OperationManager")
local Player = _ENV.Player

local function checkCanUse(player, carConf, isCancel)
  if isCancel then
    return true
  end
  if carConf.carType == Define.VEHICLE_TYPE.Advanced then
    local info = player:getPlayerCurArea()
    if info.name == "house_area" and not isCancel then
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, "g2052.gui.car.player.in.forbid.area")
      return false
    end
  end
  
  local function isInHelicopter()
    if player.rideOnId and player.rideOnId > 0 then
      local target = World.CurWorld:getEntity(player.rideOnId)
      if target and target:cfg().isAircraft == true then
        return true
      end
    end
    return false
  end
  
  if player:isSwimming() or isInHelicopter() then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, "g2052.gui.car.forbid.use")
    return false
  end
  if player:isCatchAsRobber() then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, "g2052.gui.car.forbid.use")
    return false
  end
  if player.rideFixedPointVehicleId and player.rideFixedPointVehicleId ~= "" then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, "g2052.gui.car.forbid.use")
    return false
  end
  return true
end

function Player:onOperationCar(params)
  if params and params.id then
    local carConf = CarConfig:getCfgById(params.id)
    if carConf then
      local isCancel = false
      local useCarInfo = self:getInUseCar()
      local oldCarPos, oldCarRot
      if useCarInfo then
        if self.rideOnInstanceId then
          local inst = Instance.getByInstanceId(self.rideOnInstanceId)
          if inst and inst.isRiding then
            return false
          end
          if inst then
            oldCarPos = inst:getPosition()
            oldCarRot = inst:getRotation()
          end
        end
        if useCarInfo.id == params.id then
          isCancel = true
        end
      end
      if carConf.needBuy and carConf.needBuy > 0 then
        local freeCount = params.id and Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", self, Define.BUSINESS_ITEM_TYPE.Car, params.id) or 0
        if not isCancel and not self:getIsWatchedAd() and freeCount <= 0 and not self:checkCarUnlock(carConf) then
          return
        end
      elseif not self:checkCarUnlock(carConf) then
        return
      end
      local canUse = checkCanUse(self, carConf, isCancel)
      if not canUse then
        return
      end
      if not isCancel then
        local can, tip = self:canPutVehicle(carConf)
        if not can then
          if tip then
            Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, tip)
          end
          return
        end
      end
      local rideOnObjId = self.rideOnId
      local rideOnInstanceId = self.rideOnInstanceId
      if useCarInfo then
        if rideOnObjId == useCarInfo.objId or rideOnInstanceId == useCarInfo.objId then
          self:removeCurVehicle(useCarInfo)
        else
          local ownerId = VehicleManager:getVehicleOwner(useCarInfo.objId)
          if ownerId and ownerId == self.platformUserId then
            self:removeCurVehicle(useCarInfo)
          end
        end
      end
      if not isCancel then
        if self.rideOnInstanceId then
          Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.car.forbid.use")
          return
        end
        if carConf.carType == Define.VEHICLE_TYPE.Primary then
          self:cancelVehicleItemUse(true)
          local interactPlayerHorseID = self:getInteractPlayerHorseID()
          if 0 < interactPlayerHorseID and 0 < self.rideOnId then
            self:onlyClearPlayerHorse()
          end
          local carryPetId = self:getCurCarryPetId()
          if carryPetId ~= 0 then
            self:rideOffPet()
          end
        else
          self:rideOffPet()
        end
        local autoRide = false
        if useCarInfo and not self.isClearingCar then
          autoRide = rideOnObjId == useCarInfo.objId or rideOnInstanceId == useCarInfo.objId
        end
        self:useVehicle(carConf, oldCarPos, oldCarRot, autoRide)
        if carConf.needBuy and carConf.needBuy > 0 then
          if self:getIsWatchedAd() and not self:checkCarUnlock(carConf) then
            self:setIsWatchedAd(false)
          elseif carConf.id and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", self, Define.BUSINESS_ITEM_TYPE.Car, carConf.id) and not self:checkCarUnlock(carConf) then
            Plugins.CallTargetPluginFunc("advertisement_module", "costFreeItem", self, Define.BUSINESS_ITEM_TYPE.Car, carConf.id)
          end
        end
      end
    end
  end
end

function Player:removeCurVehicle(useCarInfo)
  local target = World.CurWorld:getEntity(useCarInfo.objId)
  self:setInUseCar(nil)
  if target then
    self.isClearingCar = true
    local packet = {
      pid = "SCRemoveVehicleAction",
      fromID = self.objID,
      carID = useCarInfo.objId,
      isAdd = false
    }
    self:sendPacketToTracking(packet, true)
    if self.rideOnInstanceId then
      self:rideOffFromPartVehicle()
    end
    target:destroy()
    self.isClearingCar = nil
    if self:getInteractionPartID() ~= "" then
      local posInfo = self:getSitPartPosInfo()
      if posInfo.newPos then
        self:setPos(posInfo.newPos, posInfo.yaw, nil, true)
      end
    end
    return true
  else
    local inst = Instance.getByInstanceId(useCarInfo.objId)
    if inst and inst:isValid() then
      if inst.isRiding then
        return false
      end
      self.isClearingCar = true
      VehicleManager:removeSummonedVehicle(self.platformUserId)
      self.isClearingCar = nil
      return true
    end
  end
  return false
end

function Player:removeUsingVehicle()
  local useCarInfo = self:getInUseCar()
  local rideOnObjId = self.rideOnId
  local rideOnInstanceId = self.rideOnInstanceId
  if useCarInfo and not self.isClearingCar then
    if rideOnObjId == useCarInfo.objId or rideOnInstanceId == useCarInfo.objId then
      return self:removeCurVehicle(useCarInfo)
    end
  elseif rideOnInstanceId then
    self:rideOffFromPartVehicle()
    return true
  end
  return false
end

function Player:removeUsingVehicleByFullName(fullName)
  local isCar = CarConfig:isCar(fullName)
  if isCar then
    self:removeUsingVehicle()
  end
end

function Player:removePrimaryVehicle()
  local useCarInfo = self:getInUseCar()
  if not useCarInfo then
    return
  end
  local id = useCarInfo.id
  if CarConfig:isPrimaryCar(id) then
    self:removeCurVehicle(useCarInfo)
  end
end

function Player:canPutVehicle(carConf)
  if carConf.carType ~= Define.VEHICLE_TYPE.Advanced then
    return true
  end
  local cfgName = carConf.throwCfgName
  local throwPos = carConf.throwPos
  if cfgName == "" then
    return false
  end
  local dis = throwPos[1] or 0
  local offset = Lib.v3(throwPos[2] or 0, throwPos[3] or 0, throwPos[4] or 0)
  local pos = self:getFrontPos(dis, true, false) + offset
  local playerPos = self:getPosition()
  if VehicleManager:isPointInForbidArea(playerPos) then
    return false, "g2052.gui.car.player.in.forbid.area"
  end
  if VehicleManager:isPointInForbidArea(pos) then
    return false, "g2052.gui.car.in.forbid.area"
  end
  if VehicleManager:hasCarInArea(pos, self) then
    return false, "g2052.gui.car.no.room"
  end
  return true
end

function Player:useVehicle(carConf, targetPos, targetRot, autoDrive)
  local cfgName = carConf.throwCfgName
  local throwPos = carConf.throwPos
  local isFlight = DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Flight)
  if cfgName ~= "" then
    self:SetForceClimb(false, 0, 0)
    self:SetForceSwim(false)
    local dis = throwPos[1] or 0
    local offset = Lib.v3(throwPos[2] or 0, throwPos[3] or 0, throwPos[4] or 0)
    targetPos = targetPos and targetPos + offset
    local pos = self:getFrontPos(dis, true, false) + offset
    if carConf.carType == Define.VEHICLE_TYPE.Primary then
      local params = {
        cfgName = cfgName,
        map = self.map,
        pos = pos,
        ry = self:getRotationYaw()
      }
      local entity = EntityServer.Create(params)
      if entity then
        self:setInUseCar({
          id = carConf.id,
          objId = entity.objID
        })
        Plugins.CallTargetPluginFunc("garbage_collector", "register", "entity", entity.objID, self.platformUserId)
        self:addUseCarCountOnce()
        local passengers = entity:data("passengers")
        if next(passengers) == nil then
          self:rideOn(entity, nil, 1)
        end
      end
    elseif carConf.carType == Define.VEHICLE_TYPE.Advanced then
      if not self:canPutVehicle(carConf) then
        return
      end
      local cfg = PartCfg:get(cfgName)
      local manager = CW:getSceneManager()
      local scene = manager:getOrCreateScene(self.map.obj)
      cfg.scene = scene
      local inst = Instance.newInstance(cfg, self.map)
      if inst then
        do
          local nodes = {}
          Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
          local initPos = pos
          scene.move(nodes, targetPos or initPos, true)
          if targetRot then
            scene.rotate(nodes, targetRot)
          end
          if isFlight then
            inst:setProperty("useGravity", "false")
          end
          inst:setParent(scene:getRoot())
          if carConf.defaultColor then
            local function foreachNode(node)
              local scriptName = node:getScriptName()
              
              if (scriptName == "Part" or scriptName == "MeshPart") and node:getName() == "colorchange" then
                node:setColor(carConf.defaultColor)
              end
              for k, v in pairs(node:getAllChild()) do
                foreachNode(v)
              end
            end
            
            foreachNode(inst)
          end
          local instanceId = inst:getInstanceID()
          self:setInUseCar({
            id = carConf.id,
            objId = instanceId
          })
          Plugins.CallTargetPluginFunc("garbage_collector", "register", "instance", instanceId, self.platformUserId)
          local partCheckS2C = {
            parent = inst:getInstanceID(),
            children = {}
          }
          VehicleManager:addSummonedVehicle(inst, self.platformUserId)
          inst:setNetworkOwner(self:getRaknetID())
          local cheLunAndSeat = {}
          for _, name in ipairs(World.cfg.vehicleSetting.clientControlParts or {}) do
            Lib.getInstanceAllChild(inst, cheLunAndSeat, Define.ABILITY.AABB, name)
          end
          for _, name in ipairs(World.cfg.vehicleSetting.clientOwnerControlParts or {}) do
            Lib.getInstanceAllChild(inst, cheLunAndSeat, Define.ABILITY.AABB, name)
          end
          local driverSeat
          for _, lun in pairs(cheLunAndSeat) do
            if lun.name == "driverSeat" then
              driverSeat = lun
            end
            lun:setNetworkOwner(self:getRaknetID())
            table.insert(partCheckS2C.children, lun:getInstanceID())
          end
          World.Timer(1, function()
            if inst and inst:isValid() then
              self:sendPacket({
                pid = "initVehicleControl",
                vehicleId = inst:getInstanceID(),
                partCheck = partCheckS2C
              })
              if autoDrive and driverSeat then
                self:onRideOnPartVehicle(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, driverSeat)
              end
            end
          end)
        end
      end
    end
  end
end

local function isInPartVehicle(vehicleInst, player)
  local count = vehicleInst:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicleInst:getChildAt(i)
    if n:getName() == "mp_driver" or n:getName() == "mp_passenger" then
      if n.mountId == player:getInstanceID() then
        return true
      elseif n.mountId ~= 0 then
        local entity = Instance.getByInstanceId(n.mountId)
        if entity and entity:isValid() and not entity.isPlayer and entity:isA("Entity") then
          local passengers = entity:data("passengers")
          for _, objId in pairs(passengers) do
            if objId == player.objID then
              return true
            end
          end
        end
      end
    end
  end
  return false
end

function Player:onRideOnPartVehicle(type, target, params)
  Lib.logDebug("onRideOn------------------")
  if not target:isValid() then
    return
  end
  local userId = self.platformUserId
  if target.CDTimer then
    local now = os.time()
    if userId == target.CDTimer.userId and now - target.CDTimer.time <= 2 then
      return
    end
    target.CDTimer = nil
  end
  if self:getInteractCarEnterID() ~= "" then
    return
  end
  if self.rideOnId > 0 then
    local entity = World.CurWorld:getEntity(self.rideOnId)
    if entity and entity:isValid() then
      if entity:cfg().forbidFurnitureAction == true then
        return
      end
      local passengers = entity:data("passengers") or {}
      for i, id in pairs(passengers) do
        if id == self.objID and i ~= 1 then
          return
        end
      end
      if entity:cfg().isSkate == true then
        return
      end
    end
  end
  local interactionPartId = self:getInteractionPartID()
  if interactionPartId ~= "" then
    return
  end
  local vehicleInst = target:getParent()
  if not vehicleInst then
    return
  end
  local isVehicleLocked = VehicleManager:isCarLocked(vehicleInst)
  if isVehicleLocked and not VehicleManager:isVehicleOwner(vehicleInst, self.platformUserId) then
    Lib.logDebug("vehicle has locked other else forbid")
    return
  end
  local isIn = VehicleManager:isInNetworkOwnerChangeList(vehicleInst:getInstanceID())
  if isIn then
    Lib.logDebug("vehicle is moving until stop")
    return
  end
  local isInCar = isInPartVehicle(vehicleInst, self)
  if isInCar then
    return
  end
  local mp
  local count = vehicleInst:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicleInst:getChildAt(i)
    if n:getName() == "mp_driver" then
      mp = n
      break
    end
  end
  if not mp then
    mp = Instance.Create("MountPoint")
    mp:setName("mp_driver")
    mp:setParent(vehicleInst)
    local rotation_target = target:getLocalRotation()
    if math.floor(rotation_target.y) ~= 0 then
      mp.rotation = Lib.v3(0, rotation_target.y, 0)
    end
    local pos_target = target:getLocalPosition()
    mp.pos = pos_target + Lib.v3(0, -0.52, -0.2)
    mp.attachInstanceId = target:getInstanceID()
  end
  if mp.mountId ~= 0 and type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    Lib.logDebug("has person in car")
    return
  end
  if 0 < self:getInteractPlayerHorseID() then
    self:onlyClearPlayerHorse()
  end
  local attributes = Lib.copyTable1(target.attributes or {})
  if 0 < self:getPlayDanceID() then
    attributes.alwaysAction = ""
  end
  local attachEntity = self
  if self.rideOnId > 0 then
    local entity = World.CurWorld:getEntity(self.rideOnId)
    if entity and entity:isValid() then
      attachEntity = entity
    end
  end
  mp:attach(attachEntity)
  self.rideOnInstanceId = vehicleInst:getInstanceID()
  vehicleInst:setNetworkOwner(self:getRaknetID())
  local partCheckS2C = {
    parent = vehicleInst:getInstanceID(),
    children = {}
  }
  local cheLunAndSeat = {}
  for _, name in ipairs(World.cfg.vehicleSetting.clientControlParts or {}) do
    Lib.getInstanceAllChild(vehicleInst, cheLunAndSeat, Define.ABILITY.AABB, name)
  end
  for _, lun in pairs(cheLunAndSeat) do
    lun:setNetworkOwner(self:getRaknetID())
    table.insert(partCheckS2C.children, lun:getInstanceID())
  end
  VehicleManager:advancedVehicleRideOnReport(self, vehicleInst, true)
  local isOwner = VehicleManager:isVehicleOwner(vehicleInst, self.platformUserId)
  vehicleInst.isRiding = true
  World.Timer(2, function()
    if vehicleInst and vehicleInst:isValid() and self and self:isValid() and self.rideOnInstanceId then
      local vehicleId = vehicleInst:getInstanceID()
      local vehicleStatus = OperationManager:getAllCommandStatus(vehicleId)
      local packet = {
        pid = "rideOnPartVehicle",
        vehicleId = vehicleId,
        objID = self.objID,
        isDriver = true,
        isOwner = isOwner,
        vehicleStatus = vehicleStatus,
        partCheck = partCheckS2C,
        alwaysAction = attributes.alwaysAction
      }
      self.alwaysAction = packet.alwaysAction
      if not self:isInWaterArea() then
        WorldServer.BroadcastPacket(packet)
      end
      local isActive, command = OperationManager:getCommandStatus(vehicleInst:getInstanceID(), Define.OPERATION_TYPE.MUSIC)
      if isActive and command.playMusicForPlayer then
        command:playMusicForPlayer(self)
      end
      local isActive, command = OperationManager:getCommandStatus(vehicleInst:getInstanceID(), Define.OPERATION_TYPE.ALARM)
      if isActive and command.playSoundForDriver then
        command:playSoundForDriver(self)
      end
      local isActive, command = OperationManager:getCommandStatus(vehicleInst:getInstanceID(), Define.OPERATION_TYPE.DOUBLE_FLASH)
      if isActive and command.playSoundForDriver then
        command:playSoundForDriver(self)
      end
      vehicleInst.isRiding = nil
      self:addBuff("myplugin/player_idle_buff")
    end
  end)
end

function Player:onTravelByPartVehicle(type, target, params)
  if not target:isValid() then
    return
  end
  local userId = self.platformUserId
  if target.CDTimer then
    local now = os.time()
    if userId == target.CDTimer.userId and now - target.CDTimer.time <= 2 then
      return
    end
    target.CDTimer = nil
  end
  if self.rideOnId > 0 then
    local entity = World.CurWorld:getEntity(self.rideOnId)
    if entity and entity:isValid() then
      if entity:cfg().forbidFurnitureAction == true then
        return
      end
      local passengers = entity:data("passengers") or {}
      for i, id in pairs(passengers) do
        if id == self.objID and i ~= 1 then
          return
        end
      end
      if entity:cfg().isSkate == true then
        return
      end
    end
  end
  local interactionPartId = self:getInteractionPartID()
  if interactionPartId ~= "" then
    return
  end
  local vehicleInst = target:getParent()
  if not vehicleInst then
    return
  end
  local isVehicleLocked = VehicleManager:isCarLocked(vehicleInst)
  if isVehicleLocked and not VehicleManager:isVehicleOwner(vehicleInst, self.platformUserId) then
    Lib.logDebug("vehicle has locked other else forbid")
    return
  end
  local isIn = VehicleManager:isInNetworkOwnerChangeList(vehicleInst:getInstanceID())
  if isIn then
    Lib.logDebug("vehicle is moving until stop")
    return
  end
  local isInCar = isInPartVehicle(vehicleInst, self)
  if isInCar then
    return
  end
  local carryPetId = self:getCurCarryPetId()
  if carryPetId ~= 0 then
    local objId_pet = self:getCurCarryPetObjId()
    if objId_pet ~= self.rideOnId then
      self:removePetFromWorld(true)
    end
  end
  local mpInst
  if not target.mpInstanceId then
    local mp = Instance.Create("MountPoint")
    mp:setName("mp_passenger")
    mp:setParent(vehicleInst)
    local rotation_target = target:getLocalRotation()
    if math.floor(rotation_target.y) ~= 0 then
      mp.rotation = Lib.v3(0, rotation_target.y, 0)
    end
    local pos_target = target:getLocalPosition()
    mp.pos = pos_target + Lib.v3(0, -0.52, -0.2)
    mp.attachInstanceId = target:getInstanceID()
    target.mpInstanceId = mp:getInstanceID()
    mpInst = mp
  end
  mpInst = mpInst or Instance.getByInstanceId(target.mpInstanceId)
  if mpInst.mountId ~= 0 then
    return
  end
  local attributes = Lib.copyTable1(target.attributes or {})
  if 0 < self:getPlayDanceID() then
    attributes.alwaysAction = ""
  end
  if 0 < self:getInteractPlayerHorseID() then
    self:tryClearRide()
  end
  local attachEntity = self
  if self.rideOnId > 0 then
    local entity = World.CurWorld:getEntity(self.rideOnId)
    if entity and entity:isValid() then
      attachEntity = entity
    end
  end
  mpInst:attach(attachEntity)
  self.rideOnInstanceId = vehicleInst:getInstanceID()
  VehicleManager:advancedVehicleRideOnReport(self, vehicleInst, false)
  local isOwner = VehicleManager:isVehicleOwner(vehicleInst, self.platformUserId)
  local packet = {
    pid = "rideOnPartVehicle",
    vehicleId = vehicleInst:getInstanceID(),
    objID = self.objID,
    isDriver = false,
    isOwner = isOwner,
    alwaysAction = attributes.alwaysAction
  }
  self.alwaysAction = attributes.alwaysAction
  WorldServer.BroadcastPacket(packet)
  local isActive, command = OperationManager:getCommandStatus(vehicleInst:getInstanceID(), Define.OPERATION_TYPE.MUSIC)
  if isActive and command.playMusicForPlayer then
    command:playMusicForPlayer(self)
  end
  self:addBuff("myplugin/player_idle_buff")
end

function Player:rideOffFromPartVehicle(isDestroyVehicle)
  if not self.rideOnInstanceId then
    return
  end
  local vehicle = Instance.getByInstanceId(self.rideOnInstanceId)
  if not vehicle or not vehicle:isValid() then
    return
  end
  if vehicle.isRiding and not isDestroyVehicle then
    return
  end
  VehicleManager:removeSounds(self.rideOnInstanceId)
  
  local function getMyInstanceID(self)
    if self.rideOnId > 0 then
      local entity = World.CurWorld:getEntity(self.rideOnId)
      if entity and entity:isValid() then
        return entity:getInstanceID()
      end
    end
    return self:getInstanceID()
  end
  
  local count = vehicle:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicle:getChildAt(i)
    if (n:getName() == "mp_driver" or n:getName() == "mp_passenger") and n.mountId == getMyInstanceID(self) then
      do
        local seatInst = Instance.getByInstanceId(n.attachInstanceId)
        if seatInst then
          seatInst.CDTimer = {
            userId = self.platformUserId,
            time = os.time()
          }
        end
        n.mountId = 0
        local isOwner = VehicleManager:isVehicleOwner(vehicle, self.platformUserId)
        if n:getName() == "mp_driver" and not isOwner then
          VehicleManager:addNetworkOwnerChange(vehicle)
        end
        if n:getName() == "mp_driver" then
          self:removeTypeBuff("fullName", "myplugin/car_move_buff")
          self:removeTypeBuff("fullName", "myplugin/car_alarm_buff")
          self:removeTypeBuff("fullName", "myplugin/car_first_aid_buff")
          self:removeTypeBuff("fullName", "myplugin/car_double_flash_buff")
          self:removeTypeBuff("fullName", "myplugin/car_idle_buff")
          self:removeTypeBuff("fullName", "myplugin/car_speed_up_buff")
          self:removeTypeBuff("fullName", "myplugin/car_speed_down_buff")
        end
        VehicleManager:advancedVehicleRideOffReport(self, vehicle, n:getName() == "mp_driver")
        
        local function func()
          local packet = {
            pid = "rideOffFromPartVehicleS2C",
            instanceId = vehicle:getInstanceID(),
            objID = self.objID,
            isOwner = isOwner,
            isDriver = n:getName() == "mp_driver"
          }
          WorldServer.BroadcastPacket(packet)
          local isActive, command = OperationManager:getCommandStatus(vehicle:getInstanceID(), Define.OPERATION_TYPE.MUSIC)
          if isActive and command.stopMusicForPlayer then
            command:stopMusicForPlayer(self)
          end
          self:removeTypeBuff("fullName", "myplugin/player_idle_buff")
        end
        
        func()
        break
      end
    end
  end
  self.rideOnInstanceId = nil
end

function Player:getCarUseIsAdFree(carId, rideOnInstanceId)
  if not carId then
    return 0
  end
  local carCfg = CarConfig:getCfgById(carId)
  if carCfg and carCfg.needBuy and 0 < carCfg.needBuy then
    if rideOnInstanceId ~= nil then
      local ownerId = VehicleManager:getVehicleOwner(rideOnInstanceId)
      if not ownerId then
        return 0
      end
      local owner = Game.GetPlayerByUserId(ownerId)
      if owner and not owner:checkCarUnlock(carCfg) then
        return 1
      else
        return 0
      end
    elseif not self:checkCarUnlock(carCfg) then
      return 1
    else
      return 0
    end
  end
  return 0
end
