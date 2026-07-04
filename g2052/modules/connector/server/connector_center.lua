require("server.connector_event")
require("server.connector_dispatch")
require("common.i_connector_center")
require("server.service.connector_center_service")
local v_type = type
local ConnectorClient
local SConnectorCenter = T(Lib, "ConnectorCenter")
local ConnectorCenterService = T(Lib, "ConnectorCenterService")
local ConnectorInterceptor = T(Lib, "ConnectorInterceptor")
local SendMsgCache = {}
local cjson = require("cjson")

function onConnectorMsgHandler(name, ...)
  local func = SConnectorCenter[name]
  if not func then
    return
  end
  func(SConnectorCenter, ...)
end

function SConnectorCenter:initRegisterGameEvent()
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(player)
    local userId = player.platformUserId
    self:onUserIn(userId)
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGOUT, function(userId)
    self:onUserOut(userId)
  end)
end

function SConnectorCenter:start()
  self.isReconnecting = false
  self:createConnect()
  Lib.subscribeEvent(Event.EVENT_CONNECTOR_MSG, function(data)
    SConnectorCenter:sendMsg(data.type, data.userId, data.data)
  end)
end

function SConnectorCenter:createConnect()
  self.isReconnecting = true
  AsyncProcess.GetConnectorListApi(function(_, responseData)
    local data = responseData.data
    if not data or not data.addr then
      Lib.logError("--------------[SCRIPT_EXCEPTION]-----------------\n", Lib.v2s(data))
      return
    end
    Lib.logInfo("[SConnectorCenter:createConnect]")
    Lib.pv(data)
    local address = Lib.splitString(data.addr, ":")
    local host = address[1]
    if PlatformUtil.isPlatformWindows() then
      local testHost = ({
        ["192.168.1.69"] = "52.82.23.100",
        ["192.168.1.4"] = "52.82.22.197",
        ["192.168.1.229"] = "52.83.140.52"
      })[host]
      host = testHost or host
    end
    local port = tonumber(address[2])
    ConnectorManager.Instance():createConnect(host, port)
  end)
end

function SConnectorCenter:onConnected()
  self.isReconnecting = false
  ConnectorClient = ConnectorManager.Instance():getConnectorClient()
  ConnectorCenterService:sendConnected()
end

function SConnectorCenter:onDisconnected()
  ConnectorCenterService:sendDisconnected(false)
end

function SConnectorCenter:sendCacheMsg()
  for _, cache in pairs(SendMsgCache) do
    self:sendMsg(unpack(cache))
  end
  SendMsgCache = {}
end

function SConnectorCenter:onUserIn(userId)
  if not ConnectorClient then
    return
  end
  ConnectorCenterService:sendUserIn(userId)
end

function SConnectorCenter:onUserOut(userId)
  if not ConnectorClient then
    return
  end
  ConnectorCenterService:sendUserOut(userId)
end

function SConnectorCenter:sendMsg(type, userId, data)
  if SConnectorCenter.isDebug then
    Lib.logInfo("[SConnectorCenter:sendMsg] type=" .. type)
    Lib.logInfo("[SConnectorCenter:sendMsg] userId=" .. tostring(userId))
    Lib.logInfo("[SConnectorCenter:sendMsg] data=" .. data)
  end
  local result = ConnectorInterceptor:onMsgInterceptor(type, userId, data)
  if result == true then
    return
  end
  if not ConnectorClient then
    return
  end
  if userId ~= 0 and not Game.GetPlayerByUserId(userId) then
    return
  end
  if v_type(result) == "string" then
    data = result
    if SConnectorCenter.isDebug then
      Lib.logInfo("[SConnectorCenter:sendMsg] result=" .. result)
    end
  end
  if self.isReconnecting then
    table.insert(SendMsgCache, {
      type,
      userId,
      data
    })
    return
  end
  if v_type(data) == "table" then
    data = cjson.encode(data)
  end
  ConnectorClient:sendMsg(type, userId, data)
end

SConnectorCenter:initRegisterGameEvent()
