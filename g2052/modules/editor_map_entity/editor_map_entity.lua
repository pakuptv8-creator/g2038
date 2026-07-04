require("common.event_editor_map_entity")
require("common.define_editor_map_entity")
if World.isClient then
  require("client.player.player_editor_map_entity")
  require("client.async_process.async_process_editor_map_entity")
  require("client.entity.entity_editor_map_entity")
  require("client.entity.entity_value_func_editor_map_entity")
  require("client.gate_editor_map_entity")
  require("client.gm_editor_map_entity")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
