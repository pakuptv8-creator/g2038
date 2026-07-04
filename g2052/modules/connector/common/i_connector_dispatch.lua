local IConnectorDispatch = class("ConnectorDispatch")
local cjson = require("cjson")
local v_type = type

function IConnectorDispatch:ctor()
  self.isDebug = false
  self.connectorMsgHandlerList = {}
end

function IConnectorDispatch:onMsgReceive(type, targets, data)
  if self.isDebug then
    Lib.logInfo("[IConnectorDispatch:onMsgReceive] type=" .. type)
    Lib.logInfo("[IConnectorDispatch:onMsgReceive] targets=" .. Lib.v2s(targets))
    if v_type(data) == "string" then
      Lib.logInfo("[IConnectorDispatch:onMsgReceive] data=" .. data)
    else
      Lib.logInfo("[IConnectorDispatch:onMsgReceive] data=" .. cjson.encode(data))
    end
  end
  local intercept, hasHandler = false, false
  for _, handler in pairs(self.connectorMsgHandlerList) do
    if handler:isRegisterMsg(type) then
      if self.isDebug then
        Lib.logInfo("[IConnectorDispatch:onMsgReceive] handler=" .. handler.__cname)
      end
      hasHandler = true
      intercept = handler:onMsgReceive(type, targets, data) or intercept
    end
  end
  return intercept
end

function IConnectorDispatch:registerHandler(handler)
  table.insert(self.connectorMsgHandlerList, handler)
end

return IConnectorDispatch
