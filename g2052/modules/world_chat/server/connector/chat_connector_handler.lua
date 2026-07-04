local ChatConnectorHandler = Plugins.CallTargetPluginFunc("connector", "registerConnectorMsgHandlerSubCls", "MatchConnectorHandler")
local ConnectorDispatch = T(Lib, "ConnectorDispatch")
local ChatConnectorSender = T(Lib, "ChatConnectorSender")
local cjson = require("cjson")
local Game2ConnectorMsgType = {
  TestMsg = 10005,
  ReceiveMsgRes = 30016,
  JoinChannelRes = 30113,
  LeaveChannelRes = 30114
}

function ChatConnectorHandler:init()
end

function ChatConnectorHandler:initMsgFunc()
  self:registerMsgFunc(Game2ConnectorMsgType.TestMsg, self.onTestMsg, self)
  self:registerMsgFunc(Game2ConnectorMsgType.ReceiveMsgRes, self.onReceiveWorldChatMsg, self)
  self:registerMsgFunc(Game2ConnectorMsgType.JoinChannelRes, self.onJoinChannelSuccess, self)
  self:registerMsgFunc(Game2ConnectorMsgType.LeaveChannelRes, self.onLeaveChannelSuccess, self)
end

function ChatConnectorHandler:onTestMsg(_, _, data)
end

function ChatConnectorHandler:onReceiveWorldChatMsg(type, targets, data)
  if not data then
    return
  end
  local ok, data = pcall(cjson.decode, data)
  if not ok then
    return
  end
  if not data or not data.language then
    return
  end
  local packet = {
    pid = "PushClientWorldChatMsg",
    data = data
  }
  for _, userId in pairs(targets or {}) do
    local player = Game.GetPlayerByUserId(userId)
    if player and player:isValid() then
      player:sendPacket(packet)
    end
  end
  ChatConnectorSender:addOneWorldChatMsg(data)
end

function ChatConnectorHandler:onJoinChannelSuccess(type, targets, data)
  data = cjson.decode(data)
end

function ChatConnectorHandler:onLeaveChannelSuccess(type, targets, data)
  data = cjson.decode(data)
end

ConnectorDispatch:registerHandler(T(Lib, "ArenaInterceptor", ChatConnectorHandler.new()))
