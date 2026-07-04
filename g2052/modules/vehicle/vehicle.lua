require("common.entity_vehicle")
require("common.event_vehicle")
require("common.config.car_config")
require("common.config.carBgm_config")
require("common.define_vehicle")
if World.isClient then
  require("client.player.player_vehicle")
  require("client.player.packet_vehicle")
  require("client.entity.entity_vehicle")
  require("client.entity.entity_value_func_vehicle")
  require("client.vehicle_virtual_camera")
  require("client.gate_vehicle")
  require("client.gm_vehicle")
  require("client.control_helper.fixed_point_vehicle_control")
  require("client.control_helper.flight_vehicle_control")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity or not entity:isValid() then
      return
    end
    local cfg = entity:cfg()
    local isOnGround = entity.onGround
    if cfg.isAircraft then
      if isOnGround then
        Me:sendPacket({
          pid = "getFlyStatus",
          objID = objID
        })
      else
        entity:setAlwaysAction("fly3")
      end
    end
    if entity.isPlayer and Me and entity ~= Me and not entity.rideOnInstanceId then
      Me:sendPacket({
        pid = "checkVehicleRideStatus",
        userId = entity.platformUserId
      })
    end
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.objID ~= Me.objID then
      return
    end
    Me:loadNewVehicleRecord()
    Me:updateVehicleRedDotStatus()
  end)
else
  require("server.player.player_vehicle")
  require("server.player.packet_vehicle")
  require("server.entity.entity_vehicle")
  require("server.entity.entity_vehicle_interact")
  require("server.trigger_handlers")
  require("server.gate_vehicle")
  require("server.gm_vehicle")
  require("server.ship_manager_helper")
  require("server.helicopter_manager_helper")
  require("server.vehicle_manager")
  require("server.operation_manager")
  require("server.operation.command_factory")
end
local handlers = {}

function handlers.checkCanDoRideOn(player)
  if player:isInFloatState() then
    return false
  end
  if player:getInteractionPartID() ~= "" then
    return false
  end
  if player:getInteractCarEnterID() ~= "" then
    return false
  end
  local rideOnInstanceId = player.rideOnInstanceId
  if rideOnInstanceId then
    local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
    if vehicleInst and vehicleInst:isValid() then
      return false
    end
  end
  if player.rideFixedPointVehicleId and player.rideFixedPointVehicleId ~= "" then
    return false
  end
  return true
end

function handlers.ENTITY_LEAVE(context)
  local player = context.obj1
  if not player.isPlayer then
    return
  end
  local gunId = player:getInUseOilGunID()
  if gunId then
    local gunInst = Instance.getByInstanceId(gunId)
    if gunInst and gunInst:isValid() then
      if gunInst.restoreFunc then
        gunInst.restoreFunc()
        gunInst.restoreFunc = nil
      end
      gunInst.isUsing = nil
    end
  end
  player:removePrimaryVehicle()
  local VehicleManager = T(Lib, "VehicleManager")
  VehicleManager:removeSummonedVehicle(player.platformUserId)
  if player.rideOnId and player.rideOnId > 0 then
    local target = World.CurWorld:getEntity(player.rideOnId)
    if target then
      local cfg = target:cfg()
      local isOnGround = target.onGround
      if cfg.isAircraft then
        player:rideOn()
        if not isOnGround then
          target:removeTypeBuff("fullName", "myplugin/aircraft_control_up")
          target:removeTypeBuff("fullName", "myplugin/zhishengji_run_buff")
          local gravity = cfg.gravity or 0.08
          target:setProp("gravity", gravity)
          target.isFlying = false
          local packet = {
            pid = "helicopterStop",
            objID = target.objID,
            gravity = gravity
          }
          WorldServer.BroadcastPacket(packet)
        end
      end
    end
  end
  local passengers = player:data("passengers")
  for _, objId in pairs(passengers) do
    local entity = World.CurWorld:getEntity(objId)
    if entity and entity:isValid() and not entity.isPlayer then
      entity:destroy()
    end
  end
end

function handlers.OnPlayerLogin(player)
  local ShipManagerHelper = T(Lib, "ShipManagerHelper")
  ShipManagerHelper:updatePlayerLoginState(true)
  if not World.isClient then
    local flag = player:getAllVehicleFlag()
    if flag == -1 then
      player:updateAllVehicleFlag()
    end
  end
end

function handlers.ENTITY_STATUS_CHANGE(context)
  local newState = context.newState
  local oldState = context.oldState
  local entity = context.obj1
  if entity and entity:isValid() then
    local cfg = entity:cfg()
    if cfg and cfg.isShip then
      entity.shipMoveState = newState
      entity:updateShipWaterMoveSound()
    end
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
