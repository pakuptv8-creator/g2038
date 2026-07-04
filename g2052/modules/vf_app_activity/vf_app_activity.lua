if World.isClient then
  require("client.packet.vf_app_activity_pk_handler")
else
  require("server.vf_app_activity_gm")
  require("server.web.vf_app_activity_web")
  require("server.packet.vf_app_activity_pk_sender")
end
local handlers = {}

function handlers.addGameBadge(player)
  if World.isClient then
    return
  end
  local SVfAppActivity = require("server.s_vf_app_activity")
  SVfAppActivity:addGameBadge(player)
end

function handlers.removeGameBadge(player)
  if World.isClient then
    return
  end
  local SVfAppActivity = require("server.s_vf_app_activity")
  SVfAppActivity:removeGameBadge(player)
end

if World.isClient then
else
  function handlers.OnPlayerLogin(player)
    if not player.isAddGameBadge then
      Plugins.CallTargetPluginFunc("vf_app_activity", "addGameBadge", player)
      
      player.isAddGameBadge = true
    end
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
