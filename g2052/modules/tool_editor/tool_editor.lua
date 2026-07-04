require("common.entity_tool_editor")
require("common.event_tool_editor")
require("common.define_tool_editor")
require("common.config.interact_event_readme_config")
if World.isClient then
  require("client.player.player_tool_editor")
  require("client.player.packet_tool_editor")
  require("client.entity.entity_tool_editor")
  require("client.entity.entity_value_func_tool_editor")
  require("client.gate_tool_editor")
  require("client.gm_tool_editor")
else
  require("server.player.player_tool_editor")
  require("server.player.packet_tool_editor")
  require("server.entity.entity_tool_editor")
  require("server.gate_tool_editor")
  require("server.gm_tool_editor")
end
local handlers = {}

function handlers.PART_CLICKED(context)
  local part = context.part1
  local from = context.from
  if not part or not part:isValid() then
    return
  end
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  Lib.emitEvent(Event.EVENT_PART_CLICK, part, from)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
