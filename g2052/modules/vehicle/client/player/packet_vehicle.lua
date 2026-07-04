local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local CarConfig = T(Config, "CarConfig")
local VehicleVirtualCamera = T(Lib, "VehicleVirtualCamera")
local FixedPointVehicleControl = T(Lib, "FixedPointVehicleControl")
local InteractEventConfig = T(Config, "InteractEventConfig")
local InteractionHelper = T(Lib, "InteractionHelper")
local FlightVehicleControl = T(Lib, "FlightVehicleControl")
local DramaClientHelper = T(Lib, "DramaClientHelper")
local SkateControl = T(Lib, "SkateControl")
local handles = T(Player, "PackageHandlers")

function handles:debugDrawPutOutFire(packet)
  local debugDraw = DebugDraw.instance
  debugDraw:setEnabled(true)
  debugDraw.addEntry("drawMesh", function()
    debugDraw:drawSphere(packet.pos, 0.2, 4278190335)
    debugDraw:drawLine(packet.minPos, packet.maxPos, 65535)
  end)
  debugDraw:setDrawMeshEnabled(true)
end

function handles:helicopterTakeOff(packet)
  local objId = packet.objID
  local driverUid = packet.driverUid
  local helicopter = World.CurWorld:getEntity(objId)
  if helicopter then
    local isOnGround = helicopter.onGround
    local maxFlyHigh = helicopter:cfg().maxFlyHigh or 50
    local takeOffHigh = helicopter:cfg().takeOffHigh or 5
    if isOnGround then
      helicopter:setAlwaysAction("fly3")
      do
        local prepareTime = helicopter:updateUpperAction("fly0", -1, true)
        helicopter:setProp("gravity", 0)
        helicopter.isFlying = true
        helicopter:setFlyMode(1)
        if driverUid == Me.platformUserId then
          World.Timer(prepareTime + 5, function()
            Me:sendPacket({
              pid = "vehicleAddBuff",
              buffName = "myplugin/aircraft_control_up",
              objId = Me.rideOnId
            })
            if not helicopter or not helicopter:isValid() then
              return
            end
            local curY = helicopter:getPosition().y
            World.Timer(1, function()
              if not helicopter or not helicopter:isValid() then
                return
              end
              local pos = helicopter:getPosition()
              if pos.y >= maxFlyHigh then
                Lib.emitEvent(Event.EVENT_HELICOPTER_UP_LIFT_OVER)
              elseif pos.y - curY >= takeOffHigh then
                Lib.emitEvent(Event.EVENT_HELICOPTER_UP_LIFT_OVER)
                Me:sendPacket({
                  pid = "vehicleRemoveBuff",
                  buffName = "myplugin/aircraft_control_up",
                  objId = Me.rideOnId
                })
              else
                return true
              end
            end)
          end)
        end
      end
    end
  end
end

function handles:helicopterStop(packet)
  local objId = packet.objID
  local gravity = packet.gravity
  local helicopter = World.CurWorld:getEntity(objId)
  if helicopter then
    if gravity then
      helicopter:setProp("gravity", gravity)
    end
    helicopter:setAlwaysAction("idle")
    helicopter.isFlying = false
    helicopter:setFlyMode(0)
  end
end

function handles:setFlyStatus(packet)
  local objId = packet.objID
  local target = World.CurWorld:getEntity(objId)
  if target then
    target:setAlwaysAction("fly3")
  end
end

local function partParentCheck(partCheckTab)
  if not (partCheckTab and partCheckTab.parent) or not partCheckTab.children then
    return
  end
  local parentId = partCheckTab.parent
  local parentInst = Instance.getByInstanceId(parentId)
  if not parentInst or not parentInst:isValid() then
    Lib.logDebug("[partParentCheck] no parent instance")
    return
  end
  for _, iid in ipairs(partCheckTab.children) do
    local inst = Instance.getByInstanceId(iid)
    if inst and inst:isValid() then
      local parent = inst:getParent()
      if not parent then
        Lib.logDebug("[partParentCheck] child no parent name is: ", inst:getName())
        inst:setParent(parentInst)
      elseif parent ~= parentInst then
        Lib.logDebug("[partParentCheck] child parent error name is: ", inst:getName())
        inst:setParent(parentInst)
      end
    else
      Lib.logDebug("[partParentCheck] no child instance instance id is ", iid)
    end
  end
end

local function getControl(inst)
  local count = inst:getChildrenCount()
  for i = 0, count - 1 do
    local n = inst:getChildAt(i)
    if n:getName() == "controller" then
      return n
    end
  end
end

function handles:initVehicleControl(packet)
  local vehicleId = packet.vehicleId
  if not vehicleId then
    return
  end
  local isFlight = DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Flight)
  
  local function initControl(vehicleInst)
    vehicleInst.gear = 3
    local name = vehicleInst:getProperty("name")
    Lib.logDebug("VehicleControl create(init) ", vehicleId, name)
    local cfg = CarConfig:getCfgByName("myplugin/" .. name) or {}
    if not isFlight then
      local control = Instance.Create("VehicleControl")
      control:setProperty("engineAcc", cfg.engineAcc or "15")
      control:setProperty("speedMax", cfg.speedMax[vehicleInst.gear] or "30")
      control:setProperty("brakeDec", cfg.brakeDec or "-40")
      control:setProperty("brakeSpeedMax", cfg.brakeSpeedMax or "-10")
      control:setProperty("steerMaxAnglePer", cfg.steerMaxAnglePer or "30")
      control:setProperty("needMulPartSize", cfg.needMulPartSize or "false")
      control:setProperty("wheelRelPos", cfg.wheelRelPos or "x:1.6 y:-1.6 z:2")
      control:setProperty("groundDis", cfg.groundDis or "0.4")
      control:setProperty("suspensionTravel", cfg.suspensionTravel or "0.2")
      control:setProperty("steerVaildStart", cfg.steerVaildStart or "0.17")
      control:setProperty("steerVaildEnd", cfg.steerVaildEnd or "0.985")
      control:setProperty("enableMove", "true")
      control:setProperty("collisionFilterGroup", "4")
      control:setProperty("collisionFilterMask", "1")
      control:setName("controller")
      control:setParent(vehicleInst)
    else
      local control = Instance.Create("Model")
      control:setName("controller")
      control:setParent(vehicleInst)
    end
    VehicleVirtualCamera:init(vehicleInst)
    vehicleInst.gears = cfg.speedMax
    Lib.emitEvent(Event.EVENT_CAR_CREATED)
  end
  
  local vehicleInst = Instance.getByInstanceId(vehicleId)
  if vehicleInst and vehicleInst:isValid() then
    initControl(vehicleInst)
  else
    local waitFrameMax = 10
    local curFrame = 0
    World.Timer(1, function()
      local vehicleInst = Instance.getByInstanceId(vehicleId)
      if vehicleInst and vehicleInst:isValid() then
        local control = getControl(vehicleInst)
        if not control then
          initControl(vehicleInst)
        end
        return
      end
      curFrame = curFrame + 1
      if curFrame < waitFrameMax then
        return true
      end
    end)
  end
end

local playerDanceRecord = {}
Lib.subscribeEvent(Event.EVENT_DANCE_ACTION_CANCEL, function(objID)
  if not playerDanceRecord[objID] then
    return
  end
  local player = World.CurWorld:getEntity(objID)
  if player and player:isValid() and player.isPlayer then
    player:setAlwaysAction(playerDanceRecord[objID])
  end
  playerDanceRecord[objID] = nil
end)

function handles:rideOnPartVehicle(packet)
  Lib.logDebug("rideOnPartVehicle ", Lib.v2s(packet))
  local vehicleId = packet.vehicleId
  if not vehicleId then
    return
  end
  local isFlight = DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Flight)
  local isDriver = packet.isDriver
  local isOwner = packet.isOwner
  local vehicleInst = Instance.getByInstanceId(vehicleId)
  local cfg
  if vehicleInst and vehicleInst:isValid() then
    local control = getControl(vehicleInst)
    local name = vehicleInst:getProperty("name")
    cfg = CarConfig:getCfgByName("myplugin/" .. name) or {}
    if not control then
      vehicleInst.gear = 3
      Lib.logDebug("VehicleControl create ", vehicleId, name)
      if not isFlight then
        control = Instance.Create("VehicleControl")
        control:setProperty("engineAcc", cfg.engineAcc or "15")
        control:setProperty("speedMax", cfg.speedMax[vehicleInst.gear] or "30")
        control:setProperty("brakeDec", cfg.brakeDec or "-40")
        control:setProperty("brakeSpeedMax", cfg.brakeSpeedMax or "-10")
        control:setProperty("steerMaxAnglePer", cfg.steerMaxAnglePer or "30")
        control:setProperty("needMulPartSize", cfg.needMulPartSize or "false")
        control:setProperty("wheelRelPos", cfg.wheelRelPos or "x:1.6 y:-1.6 z:2")
        control:setProperty("groundDis", cfg.groundDis or "0.4")
        control:setProperty("suspensionTravel", cfg.suspensionTravel or "0.2")
        control:setProperty("steerVaildStart", cfg.steerVaildStart or "0.17")
        control:setProperty("steerVaildEnd", cfg.steerVaildEnd or "0.985")
        control:setProperty("enableMove", "true")
        control:setProperty("collisionFilterGroup", "4")
        control:setProperty("collisionFilterMask", "1")
        control:setName("controller")
        control:setParent(vehicleInst)
      else
        control = Instance.Create("Model")
        control:setName("controller")
        control:setParent(vehicleInst)
      end
      vehicleInst.gears = cfg.speedMax
    elseif isDriver and not isOwner then
      control:setParent(nil)
      if not isFlight then
        control:setParent(vehicleInst)
      end
    end
    partParentCheck(packet.partCheck)
    local objID = packet.objID
    local target = World.CurWorld:getEntity(objID)
    if target and target:isValid() then
      do
        local alwaysAction = packet.alwaysAction
        if isDriver then
          if alwaysAction then
            if alwaysAction ~= "" then
              target:setAlwaysAction(alwaysAction)
            else
              playerDanceRecord[objID] = "g2052_drive"
            end
          else
            target:setAlwaysAction("g2052_drive")
          end
          if target == Me and target.rideOnId <= 0 then
            local vehicleStatus = packet.vehicleStatus
            Lib.emitEvent(Event.EVENT_SHOW_OPERATION_PANEL, "car", {
              controller = control,
              car = vehicleInst,
              isOwner = isOwner,
              vehicleStatus = vehicleStatus
            })
            local inUseProp = Me:getInUseProp()
            if inUseProp and inUseProp.inUse == true and inUseProp.itemId == 1004 and inUseProp.index == 2 then
              Me:sendPacket({
                pid = "CancelHandItem",
                itemId = inUseProp.itemId
              })
            end
            if not isFlight then
              VehicleVirtualCamera:activateVehicleCamera(vehicleInst:getInstanceID())
            end
          end
        elseif alwaysAction then
          if alwaysAction ~= "" then
            target:setAlwaysAction(alwaysAction)
          else
            playerDanceRecord[objID] = "sit1"
          end
          target:setAlwaysAction(alwaysAction)
        else
          target:setAlwaysAction("sit1")
        end
        if not target.posUpdateTimer then
          target.posUpdateTimer = World.Timer(2, function()
            if target:isValid() then
              target:resetHitchingInfo()
              return true
            end
          end)
        end
        if target == Me then
          if isDriver then
            if isFlight then
              control:setProperty("enableMove", "false")
              FlightVehicleControl:init(vehicleInst, cfg)
            else
              control:setProperty("enableMove", "true")
            end
          else
            control:setProperty("enableMove", "false")
          end
          if target.rideOnId > 0 then
            control:setProperty("enableMove", "false")
            local isSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_MODE")
            if isSkateMode then
              SkateControl:pause()
            end
          end
        end
        target.rideOnInstanceId = vehicleId
      end
    end
  end
end

function handles:vehicleStatusChange(packet)
  local status = packet.status
  local act = packet.act
  Lib.emitEvent(Event.EVENT_CAR_STATUS_CHANGE, {act = act, status = status})
end

function handles:rideOffFromPartVehicleS2C(packet)
  local isOwner = packet.isOwner
  local isDriver = packet.isDriver
  local objID = packet.objID
  local player = World.CurWorld:getEntity(objID)
  if player and player:isValid() then
    playerDanceRecord[objID] = nil
    player:setAlwaysAction("")
    if player == Me then
      Lib.emitEvent(Event.EVENT_REMOVE_OPERATION_PANEL, "car")
      if isDriver then
        VehicleVirtualCamera:deactivateVehicleCamera()
        FlightVehicleControl:stop()
      end
      local isSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_MODE")
      if isSkateMode then
        SkateControl:resume()
      end
    end
    if player.posUpdateTimer then
      player.posUpdateTimer()
      player.posUpdateTimer = nil
    end
    if player.rideOnInstanceId then
      player.rideOnInstanceId = nil
    end
  end
  if isDriver then
    local instanceId = packet.instanceId
    if not isOwner and DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Flight) then
      Me:sendPacket({
        pid = "networkOwnerChange",
        instanceId = instanceId
      })
      return
    end
    local vehicleInst = Instance.getByInstanceId(instanceId)
    if vehicleInst and vehicleInst:isValid() then
      do
        local count = vehicleInst:getChildrenCount()
        for i = 0, count - 1 do
          local n = vehicleInst:getChildAt(i)
          if n:getName() == "controller" then
            n:setProperty("enableMove", "false")
            if not isOwner then
              do
                local curSpeed = math.floor(n:getCurSpeed() + 0.5)
                if curSpeed == 0 then
                  if player == Me then
                    local count = 0
                    local curY = vehicleInst:getPosition().y
                    World.Timer(1, function()
                      if not vehicleInst or not vehicleInst:isValid() then
                        Me:sendPacket({
                          pid = "networkOwnerChange",
                          instanceId = instanceId
                        })
                        return
                      end
                      local y = vehicleInst:getPosition().y
                      if math.abs(y - curY) < 0.01 then
                        count = count + 1
                      else
                        curY = y
                        count = 0
                      end
                      if 5 <= count then
                        Me:sendPacket({
                          pid = "networkOwnerChange",
                          instanceId = instanceId
                        })
                        return
                      end
                      return true
                    end)
                  end
                elseif player == Me then
                  local speedTimer
                  speedTimer = World.Timer(1, function()
                    local curSpeed = math.floor(n:getCurSpeed() + 0.5)
                    if curSpeed == 0 then
                      Me:sendPacket({
                        pid = "networkOwnerChange",
                        instanceId = instanceId
                      })
                      return
                    end
                    return true
                  end)
                  n:connect("on_destroy", function(instance)
                    if instance == n and speedTimer then
                      speedTimer()
                      speedTimer = nil
                    end
                  end)
                end
              end
            end
          end
        end
      end
    end
  end
end

function handles:resetVehicleController(packet)
  local instanceId = packet.instanceId
  local vehicleInst = Instance.getByInstanceId(instanceId)
  if vehicleInst and vehicleInst:isValid() then
    local count = vehicleInst:getChildrenCount()
    for i = 0, count - 1 do
      local n = vehicleInst:getChildAt(i)
      if n:getName() == "controller" then
        n:setParent(nil)
        n:setParent(vehicleInst)
        return
      end
    end
  end
end

function handles:onRideFixedPointVehicle(packet)
  if packet.instanceId then
    local ins = Instance.getByInstanceId(packet.instanceId)
    if not ins or not ins:isValid() then
      return
    end
    local cfg = InteractEventConfig:getCfgById(ins.name) or {}
    Blockman.Instance():control():setMove(0, 0)
    if cfg.params and cfg.params[5] ~= "" then
      local actionData = {
        priority = Define.ActionMapPriority.furniturePriority,
        actionName = cfg.params[5],
        actionTime = -1,
        actionType = "fixedPointVehicle"
      }
      self:setAlwaysAction(cfg.params[5])
      InteractionHelper:updateEntityActionData(self.objID, "fixedPointVehicle", true, actionData)
    end
    FixedPointVehicleControl:init(ins, cfg)
  end
end

function handles:LeaveRideFixedPointVehicle(packet)
  FixedPointVehicleControl:stop()
  self:setAlwaysAction("")
  InteractionHelper:updateEntityActionData(self.objID, "fixedPointVehicle", false)
end

local function openRefuelProgressSceneUI(vehicleInstanceID, duration, overCB, interruptCB)
  if not vehicleInstanceID then
    return
  end
  local vehicleInst = Instance.getByInstanceId(vehicleInstanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  local pos = vehicleInst.getPosition and vehicleInst:getPosition() or Lib.v3(0, 0, 0)
  local offset = Lib.v3(0, 0, 0)
  local box = vehicleInst:getWorldAABB()
  if box then
    offset.y = (box[3].y - box[2].y) / 2
  end
  local removeFun
  
  local function finishCB()
    if overCB then
      overCB()
    end
    if removeFun then
      removeFun()
    end
  end
  
  local partPop = UIMgr:new_widget("progressBarItem", duration, finishCB, interruptCB)
  removeFun = UILib.uiFollowInstance(partPop, pos, {
    anchor = {x = 0.5, y = 0.5},
    offset = offset,
    minScale = 0.1,
    maxScale = 1,
    autoScale = true,
    autoAddDeskop = true,
    showRange = 5,
    canAroundYaw = false
  })
end

function handles:beginRefuelVehicle(packet)
  local duration = tonumber(packet.duration)
  if not duration then
    return
  end
  local gunInstanceID = packet.gunInstanceID
  local boxInstanceID = packet.boxInstanceID
  local vehicleInstanceID = packet.vehicleInstanceID
  local interruptCheck
  if gunInstanceID and boxInstanceID then
    local gun = Instance.getByInstanceId(gunInstanceID)
    local machine = Instance.getByInstanceId(boxInstanceID)
    if gun and gun:isValid() and machine and machine:isValid() then
      do
        local pos_gun = gun:getPosition()
        local pos_machine = machine:getPosition()
        local beginDis = Lib.getPosDistance(pos_gun, pos_machine)
        
        function interruptCheck()
          if not gun or not gun:isValid() then
            return true
          end
          if not machine or not machine:isValid() then
            return true
          end
          local pos_gun = gun:getPosition()
          local pos_machine = machine:getPosition()
          local dis = Lib.getPosDistance(pos_gun, pos_machine)
          if 1.5 < dis - beginDis then
            return true
          end
        end
      end
    end
  end
  openRefuelProgressSceneUI(vehicleInstanceID, duration, function()
    Me:sendPacket({
      pid = "overRefuelVehicle"
    })
  end, interruptCheck)
end

function handles:SCRemoveVehicleAction(packet)
  if not packet.isAdd then
    local actionKey = "skateAction_" .. packet.carID
    InteractionHelper:updateEntityActionData(packet.fromID, actionKey, false, nil, true)
  end
end

function handles:UpdateUseTrolley(packet)
  self.useTrolley = packet.inUse
  self:setProp("rotateCheckCollideProp", packet.inUse and 1 or 0)
end

function handles:operationPartLocalRotate(packet)
  local target = Instance.getByInstanceId(packet.targetInsId)
  self:operationPartLocalRotate(packet.type, target, packet.params)
  Plugins.CallTargetPluginFunc("report", "report", "car_shopopen", nil, Me)
end

function handles:showShopCarNameEditor(packet)
  UI:getWnd("headColorWnd"):onShow(true, Define.HeadEditType.ShopCarName)
end

function handles:SCWatchCarAdResult(packet)
  local type = packet.type
  local code = packet.code
  local params = packet.params
  if code == 1 then
    Me.lastWatchAdTime = os.time()
  else
    Me.lastWatchAdTime = 0
  end
  local adsId = ""
  if type == Define.AdvertisingType.Car then
    adsId = Define.AdvertisingAdsId.Car
  elseif type == Define.AdvertisingType.Dress then
    adsId = Define.AdvertisingAdsId.Dress
  elseif type == Define.AdvertisingType.Pet then
    adsId = Define.AdvertisingAdsId.Pet
  elseif type == Define.AdvertisingType.House then
    adsId = Define.AdvertisingAdsId.House
  elseif type == Define.AdvertisingType.AdvertisementDraw then
    adsId = Define.AdvertisingAdsId.AdvertisementDraw
  elseif type == Define.AdvertisingType.AdvertisementLockSlot then
    adsId = Define.AdvertisingAdsId.AdvertisementLockSlot
  elseif type == Define.AdvertisingType.AdvertisementScene then
    adsId = Define.AdvertisingAdsId.AdvertisementScene
  end
  local defaultData = {ad_id = adsId, g2052_ad_code = code}
  Plugins.CallTargetPluginFunc("report", "report", "g2052_vehicle_mAd_code_client", defaultData, Me)
end
