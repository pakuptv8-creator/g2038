require("common.entity_graffiti")
require("common.event_graffiti")
require("common.config.graffiti_config")
require("common.define_graffiti")
if World.isClient then
  require("client.graffiti_mgr")
  require("client.player.player_graffiti")
  require("client.player.packet_graffiti")
  require("client.entity.entity_graffiti")
  require("client.entity.entity_value_func_graffiti")
  require("client.gm_graffiti")
else
  require("server.player.player_graffiti")
  require("server.player.packet_graffiti")
  require("server.entity.entity_graffiti")
  require("server.gm_graffiti")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
