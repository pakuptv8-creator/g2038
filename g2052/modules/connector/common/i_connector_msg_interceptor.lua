local IConnectorMsgInterceptor = class("IConnectorMsgInterceptor")

function IConnectorMsgInterceptor:ctor()
  self.connectorMsgFuncMapping = {}
  self:init()
  self:initMsgFunc()
end

function IConnectorMsgInterceptor:init()
end

function IConnectorMsgInterceptor:initMsgFunc()
end

function IConnectorMsgInterceptor:isRegisterMsg(type)
  return self.connectorMsgFuncMapping[type] ~= nil
end

function IConnectorMsgInterceptor:registerMsgFunc(type, func)
  self.connectorMsgFuncMapping[type] = func
end

function IConnectorMsgInterceptor:onMsgInterceptor(type, userId, data)
  return self.connectorMsgFuncMapping[type](self, type, userId, data)
end

return IConnectorMsgInterceptor
