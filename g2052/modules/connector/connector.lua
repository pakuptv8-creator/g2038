if World.isClient then
  require("client.gm_connector")
  require("client.connector_center")
else
  require("server.gm_connector")
  require("server.connector_center")
end
local handlers = {}

function handlers.registerConnectorMsgHandlerSubCls(className)
  return class(className, require("common.i_connector_msg_handler"))
end

if World.isClient then
  function handlers.start()
    local CConnectorCenter = T(Lib, "ConnectorCenter")
    
    CConnectorCenter:start()
  end
else
  function handlers.start()
    local SConnectorCenter = T(Lib, "ConnectorCenter")
    
    SConnectorCenter:start()
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
