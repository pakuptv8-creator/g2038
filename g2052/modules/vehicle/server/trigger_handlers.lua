local VehicleManager = T(Lib, "VehicleManager")
local Handlers = T(Trigger, "Handlers")
local interactionWithMovementEventMap = {
  WindowTouchDown = {
    startHorn = "START_HORN",
    forward = "START_FORWARD",
    back = "START_BACK"
  },
  WindowTouchUp = {
    debark = "DEBARK",
    stopHorn = "STOP_HORN",
    forward = "STOP_FORWARD",
    back = "STOP_BACK"
  },
  MotionRelease = {
    forward = "STOP_FORWARD",
    back = "STOP_BACK"
  }
}

function Handlers.ENTITY_RIDE_ON(context)
  local car = context.obj1
  local player = context.obj2
  if not (car and car:isValid() and player) or not player:isValid() then
    return
  end
  local updateActorFun = car:cfg().updateActorFun
  if updateActorFun and car[updateActorFun] then
    car[updateActorFun](car)
  end
  if car:cfg().isAircraft == true then
    player.startRideTime = os.time()
  end
  VehicleManager:primaryVehicleRideOnReport(player, car)
end

function Handlers.ENTITY_RIDE_OFF(context)
  local car = context.obj1
  local player = context.obj2
  if not (car and car:isValid() and player and player:isValid()) or not player.isPlayer then
    return
  end
  local updateActorFun = car:cfg().updateActorFun
  if updateActorFun and car[updateActorFun] then
    car[updateActorFun](car)
  end
  player:removeTypeBuff("fullName", "myplugin/drive_hide_buff")
  if player.startRideTime then
    local defaultData = {
      event_name = car:cfg().reportName,
      event_time = os.time() - player.startRideTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "event_ride_end", defaultData, player)
  end
  VehicleManager:primaryVehicleRideOffReport(player, car)
  Plugins.CallTargetPluginFunc("interaction_ui", "updatePlayerInteractiveUI", player)
  World.Timer(5, function()
    if not car or not car:isValid() then
      return
    end
    local obj = car
    local event = "REMOVE_ALL_CAR_MOVEMENT_BUFF"
    local params = {
      obj1 = obj,
      object = nil,
      event = event
    }
    Trigger.CheckTriggers(obj and obj:cfg(), params.event, params)
  end)
end

function Handlers.INTERACTION_WITH_MOVEMENT_EVENT(context)
  local interactionType = context.interactionType
  local interactionName = context.interactionName
  local player = context.obj1
  local event = interactionWithMovementEventMap[interactionType][interactionName]
  if not event then
    return
  end
  local obj = player
  local targetObjID = context.targetObjId
  local target = World.CurWorld:getObject(targetObjID)
  if target and target:isValid() then
    obj = target
  end
  local params = {
    obj1 = obj,
    object = nil,
    event = event
  }
  Trigger.CheckTriggers(obj and obj:cfg(), params.event, params)
end

function Handlers.DEBARK(context)
  local player = context.obj1
  if not player or not player:isValid() then
    return
  end
  player:rideOn()
end
