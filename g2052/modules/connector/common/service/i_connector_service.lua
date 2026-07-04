local IConnectorService = class("IConnectorService", require("common.connector.i_connector_msg_handler"))
local ConnectorCenter = T(Lib, "ConnectorCenter")
local ConnectorDispatch = T(Lib, "ConnectorDispatch")

function IConnectorService:init()
end

function IConnectorService:initMsgFunc()
end

ConnectorDispatch:registerHandler(T(Lib, "IConnectorService", IConnectorService.new()))
