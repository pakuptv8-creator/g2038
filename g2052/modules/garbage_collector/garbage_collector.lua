require("common.entity_garbage_collector")
require("common.event_garbage_collector")
require("common.define_garbage_collector")
if World.isClient then
  require("client.player.player_garbage_collector")
  require("client.player.packet_garbage_collector")
  require("client.entity.entity_garbage_collector")
  require("client.entity.entity_value_func_garbage_collector")
  require("client.gm_garbage_collector")
else
  require("server.player.player_garbage_collector")
  require("server.player.packet_garbage_collector")
  require("server.entity.entity_garbage_collector")
  require("server.gm_garbage_collector")
end
local mapping = {
  entity = {},
  instance = {}
}

local function checkDestroyEntity(id, ownerId)
  local entity = World.CurWorld:getEntity(id)
  if entity and Game.GetPlayerByUserId(ownerId) then
    return
  end
  mapping.entity[id] = nil
  if entity then
    entity:destroy()
    print("garbage_collector:checkDestroyEntity", id, ownerId)
  end
end

local function checkDestroyInstance(id, ownerId)
  local instance = Instance.getByInstanceId(id)
  if instance and Game.GetPlayerByUserId(ownerId) then
    return
  end
  mapping.instance[id] = nil
  if instance then
    instance:destroy()
    print("garbage_collector:checkDestroyInstance", id, ownerId)
  end
end

local LuaTimer = T(Lib, "LuaTimer")
LuaTimer:schedule(function()
  for id, ownerId in pairs(mapping.entity) do
    checkDestroyEntity(id, ownerId)
  end
  for id, ownerId in pairs(mapping.instance) do
    checkDestroyInstance(id, ownerId)
  end
end, 0, World.cfg.garbage_collectorSetting.GCInterval * 1000)
local handlers = {}

function handlers.register(typeName, id, ownerId)
  local tb = mapping[typeName]
  if not tb then
    print("garbage_collector:register: invalid type", typeName, id, ownerId)
    return
  end
  tb[id] = ownerId
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
