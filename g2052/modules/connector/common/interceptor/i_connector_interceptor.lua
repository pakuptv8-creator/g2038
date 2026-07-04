local IConnectorInterceptor = class("IConnectorInterceptor", require("engine_base.connector.IConnectorMsgInterceptor"))
local ConnectorInterceptor = T(Lib, "ConnectorInterceptor")

function IConnectorInterceptor:init()
end

function IConnectorInterceptor:initMsgFunc()
end

ConnectorInterceptor:registerInterceptor(T(Lib, "IConnectorInterceptor", IConnectorInterceptor.new()))
