require("common.entity_timing_sound")
require("common.event_timing_sound")
require("common.config.timing_sound_config")
require("common.define_timing_sound")
if World.isClient then
  require("client.player.player_timing_sound")
  require("client.player.packet_timing_sound")
  require("client.entity.entity_timing_sound")
  require("client.entity.entity_value_func_timing_sound")
  require("client.gm_timing_sound")
else
  require("server.player.player_timing_sound")
  require("server.player.packet_timing_sound")
  require("server.entity.entity_timing_sound")
  require("server.gm_timing_sound")
  require("server.timing_sound_mgr")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
