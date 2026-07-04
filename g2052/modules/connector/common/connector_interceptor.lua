local ConnectorInterceptor = T(Lib, "ConnectorInterceptor")

function ConnectorInterceptor:init()
  self.connectorInterceptorList = {}
end

function ConnectorInterceptor:onMsgInterceptor(type, userId, data)
  for _, interceptor in pairs(self.connectorInterceptorList) do
    if interceptor:isRegisterMsg(type) then
      return interceptor:onMsgInterceptor(type, userId, data)
    end
  end
  return false
end

function ConnectorInterceptor:registerInterceptor(interceptor)
  table.insert(self.connectorInterceptorList, interceptor)
end

ConnectorInterceptor:init()
