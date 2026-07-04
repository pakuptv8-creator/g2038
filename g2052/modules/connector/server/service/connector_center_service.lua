local ConnectorCenterService = class("ConnectorCenterService", require("common.i_connector_msg_handler"))
local ConnectorCenter = T(Lib, "ConnectorCenter")
local ConnectorDispatch = T(Lib, "ConnectorDispatch")
local uuid = require("common.uuid")
local cjson = require("cjson")
local Game2ConnectorMsgType = {
  Connected = 10001,
  Disconnected = 10002,
  UserIn = 10003,
  UserOut = 10004
}
local Connector2GameMsgType = {
  TestMsg = 10005,
  ServiceUpdate = 10010,
  Connected = 10011
}

function ConnectorCenterService:init()
  self.requestIdList = {}
end

function ConnectorCenterService:initMsgFunc()
  self:registerMsgFunc(Connector2GameMsgType.ServiceUpdate, self.onUpdateService)
  self:registerMsgFunc(Connector2GameMsgType.TestMsg, self.onTestMsg)
  self:registerMsgFunc(Connector2GameMsgType.Connected, self.onConnected)
end

function ConnectorCenterService:onUpdateService()
  Lib.logInfo("[ConnectorCenterService:onUpdateService]")
  self:sendDisconnected(true)
  ConnectorCenter:createConnect()
end

function ConnectorCenterService:onTestMsg(type, targets, data)
  Lib.logInfo("[ConnectorCenterService:onTestMsg] type=" .. type)
  Lib.logInfo("[ConnectorCenterService:onTestMsg] targets=" .. cjson.encode(targets))
  Lib.logInfo("[ConnectorCenterService:onTestMsg] data=" .. data)
  return true
end

function ConnectorCenterService:onConnected()
  Lib.logInfo("[ConnectorCenterService:onConnected]")
  local players = Game.GetAllPlayers() or {}
  for _, player in pairs(players) do
    if player and player:isAlivePlayer() then
      self:sendUserIn(player.platformUserId)
    end
  end
  ConnectorCenter:sendCacheMsg()
end

function ConnectorCenterService:sendConnected()
  local config = Server.CurServer:getConfig()
  local data = {}
  data.gameId = config.gameId
  data.gameType = config.gameType
  data.engineVersion = EngineVersionSetting.getEngineVersion()
  data.regionId = config.regionId
  data = cjson.encode(data)
  Lib.logInfo("[ConnectorCenterService:sendConnected]", data)
  ConnectorCenter:sendMsg(Game2ConnectorMsgType.Connected, 0, data)
end

function ConnectorCenterService:sendDisconnected(jump)
  local config = Server.CurServer:getConfig()
  local data = {}
  data.gameId = config.gameId
  data.jump = jump
  data = cjson.encode(data)
  Lib.logInfo("[ConnectorCenterService:sendDisconnected]", data)
  ConnectorCenter:sendMsg(Game2ConnectorMsgType.Disconnected, 0, data)
end

function ConnectorCenterService:sendUserIn(userId)
  if not userId then
    Lib.logError("sendUserIn userId is nil", debug.traceback())
    return
  end
  uuid.seed()
  local gameId = Server.CurServer:getGameId()
  self.requestIdList[userId] = uuid() .. "-" .. gameId .. "-" .. os.time()
  local data = {}
  data.gameId = gameId
  data.userId = userId
  data.requestId = self.requestIdList[userId]
  data = cjson.encode(data)
  Lib.logInfo("[ConnectorCenterService:sendUserIn]", data)
  ConnectorCenter:sendMsg(Game2ConnectorMsgType.UserIn, 0, data)
end

function ConnectorCenterService:sendUserOut(userId)
  local data = {}
  data.gameId = Server.CurServer:getGameId()
  data.userId = userId
  data.requestId = self.requestIdList[userId]
  data = cjson.encode(data)
  Lib.logInfo("[ConnectorCenterService:sendUserOut]", data)
  ConnectorCenter:sendMsg(Game2ConnectorMsgType.UserOut, 0, data)
  self.requestIdList[userId] = nil
end

ConnectorDispatch:registerHandler(T(Lib, "ConnectorCenterService", ConnectorCenterService.new()))
