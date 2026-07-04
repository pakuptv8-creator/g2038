require("common.connector_interceptor")
local ConnectorCenter = T(Lib, "ConnectorCenter")
ConnectorCenter.isDebug = false
local IConnectorDispatch = T(Lib, "ConnectorDispatch")

function ConnectorCenter:onMsgReceive(type, targets, data)
  IConnectorDispatch:onMsgReceive(type, targets, data)
end
