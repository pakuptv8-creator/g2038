require("common.define_emergency")
require("common.event_emergency")
require("common.config.emergency_config")
require("common.entity_emergency")
if World.isClient then
  require("client.player.player_emergency")
  require("client.player.packet_emergency")
  require("client.entity.entity_emergency")
  require("client.entity.entity_value_func_emergency")
  require("client.gate_emergency")
  require("client.gm_emergency")
  require("client.emergency_effect_mgr")
else
  require("server.player.player_emergency")
  require("server.player.packet_emergency")
  require("server.entity.entity_emergency")
  require("server.gate_emergency")
  require("server.gm_emergency")
  require("server.emergency_helper")
end
local EmergencyHelper = T(Lib, "EmergencyHelper")
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
  end
end

function handlers.removeEmergencyEffect(locationId)
  if World.isClient then
    return
  end
  EmergencyHelper:removeEmergencyEffect(locationId)
  EmergencyHelper:removeHouseKindling(locationId)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
