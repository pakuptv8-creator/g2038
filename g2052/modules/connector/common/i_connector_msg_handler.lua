local IConnectorMsgHandler = class("IConnectorMsgHandler")

function IConnectorMsgHandler:ctor()
  self.connectorMsgFuncMapping = {}
  self:init()
  self:initMsgFunc()
end

function IConnectorMsgHandler:init()
end

function IConnectorMsgHandler:initMsgFunc()
end

function IConnectorMsgHandler:isRegisterMsg(type)
  return self.connectorMsgFuncMapping[type] ~= nil
end

function IConnectorMsgHandler:registerMsgFunc(type, func)
  self.connectorMsgFuncMapping[type] = func
end

function IConnectorMsgHandler:onMsgReceive(type, targets, data)
  return self.connectorMsgFuncMapping[type](self, type, targets, data)
end

return IConnectorMsgHandler
