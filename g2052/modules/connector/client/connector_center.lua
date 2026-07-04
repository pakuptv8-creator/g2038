require("client.connector_event")
require("client.connector_dispatch")
require("common.i_connector_center")
local v_type = type
local CConnectorCenter = T(Lib, "ConnectorCenter")
local cjson = require("cjson")

function CConnectorCenter:start()
  Lib.subscribeEvent(Event.EVENT_CONNECTOR_MSG, function(param)
    local type = param.type
    local data = param.data
    local success, result = pcall(cjson.decode, data or "{}")
    if success then
      self:onMsgReceive(type, {}, result)
    end
  end)
end

function CConnectorCenter:sendMsg(type, data)
  if v_type(data) == "table" then
    data = cjson.encode(data)
  end
  Me:sendPacket({
    pid = "ConnectorMsg",
    data = {type = type, data = data}
  })
end

CConnectorCenter:start()
