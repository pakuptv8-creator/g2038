require("common.define_interact")
require("common.entity_event")
require("common.packet_interact")
require("common.config.interact_event_config")
require("common.region")
require("common.entity_interact")
require("common.condition_check_utils")
require("common.helper_interact")
local Interact = T(World, "Interact")
if World.isClient then
  require("client.entity.helper_interact")
  require("client.entity.entity_interact")
  require("client.gm_interact")
  require("client.player.player_interact")
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity or not entity:isValid() then
      return
    end
    entity:setDistanceDynamicInfo()
    entity.isCanMouseHit = entity:cfg().canClick
  end)
  Lib.lightSubscribeEvent("error!!!!! : Interact lib event : EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
    Me:startScanningSurroundingParts()
  end)
else
  require("server.entity.helper_interact")
  require("server.helper.entity_helper")
  require("server.helper.part_helper")
  require("server.entity.entity_interact")
  require("server.player.player_interact")
end
local handlers = {}

function handlers.ENTITY_CLICK(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  Interact.tryInteract(entity, entity:cfg().clickProps, context.obj2)
end

function handlers.PART_CLICKED(context)
  local part = context.part1
  local from = context.from
  Lib.logDebug("----PART_CLICKED--", part.name)
  if not part or not part:isValid() then
    return
  end
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  Interact.tryPartInteract(Define.PART_INTERACT_TYPE.CLICKED, part, from)
end

function handlers.PART_POP_CLICKED(context)
  local part = context.part1
  local from = context.from
  if not part or not part:isValid() then
    return
  end
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  if not World.isClient then
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.POP_CLICKED, part, from)
  end
end

function handlers.PART_TOUCH_ENTITY_BEGIN(context)
  local part = context.part1
  local from = context.obj2
  if not part or not part:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  local partName = part:getProperty("name")
  if not partName then
    return
  end
  local InteractEventConfig = T(Config, "InteractEventConfig")
  local prop = InteractEventConfig:getCfgById(partName)
  if not prop then
    return
  end
  if prop.func == "onFurnitureInteract" then
    if from.isPlayer then
      if from.rideOnId > 0 then
        return
      else
        Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, from)
      end
    elseif World.cfg.singleRideCanFurniture then
      local passengerNum = 0
      local passengerId
      for _, id in pairs(from:data("passengers")) do
        passengerNum = passengerNum + 1
        passengerId = id
      end
      if passengerNum == 1 then
        local target = World.CurWorld:getEntity(passengerId)
        if target and target:isValid() and target.isPlayer then
          Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, target)
        end
      end
    end
  elseif prop.func == "triggerSpringBed" then
    if from.isPlayer and from.rideOnId > 0 then
      return
    end
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, from)
  elseif prop.func == "onTouchWater" then
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, from)
  else
    if not from.isPlayer then
      return
    end
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, from)
  end
end

function handlers.PART_TOUCH_ENTITY_END(context)
  local part = context.part1
  local from = context.obj2
  if not part or not part:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  local partName = part:getProperty("name")
  if not partName then
    return
  end
  local InteractEventConfig = T(Config, "InteractEventConfig")
  local prop = InteractEventConfig:getCfgById(partName)
  if not prop then
    return
  end
  if prop.func == "onTouchWater" then
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_END, part, from)
  else
    if not from.isPlayer then
      return
    end
    Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_END, part, from)
  end
end

function handlers.PART_TOUCH_PART_BEGIN(context)
  local part1 = context.part1
  local part2 = context.part2
  if not part1 or not part1:isValid() then
    return
  end
  if not part2 or not part2:isValid() then
    return
  end
  Interact.partWithPartInteract(Define.PART_INTERACT_TYPE.PART_TOUCH_PART_BEGIN, part1, part2)
end

function handlers.PART_TOUCH_PART_END(data)
end

function handlers.PART_TOUCH_PART_END(context)
  local part1 = context.part1
  local part2 = context.part2
  if not part1 or not part1:isValid() then
    return
  end
  if not part2 or not part2:isValid() then
    return
  end
  Interact.partWithPartInteract(Define.PART_INTERACT_TYPE.PART_TOUCH_PART_END, part1, part2)
end

function handlers.diy(props, target, from, params)
  if not from and World.isClient then
    from = Me
  end
  Interact.tryInteract(target, props, from, params)
end

function handlers.getInteractCfgByKey(key)
  local InteractEventConfig = T(Config, "InteractEventConfig")
  return InteractEventConfig:getCfgById(key)
end

function handlers.tryPartInteract(type, target, from, isTrigger, isBreak)
  return Interact.tryPartInteract(type, target, from, isTrigger, isBreak)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
