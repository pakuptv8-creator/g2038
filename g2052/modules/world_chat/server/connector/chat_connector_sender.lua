local ChatConnectorSender = T(Lib, "ChatConnectorSender")
local ChatLangConfig = T(Config, "ChatLangConfig")
local cjson = require("cjson")
local game_id = Server.CurServer:getGameId()
local game_name = World.GameName
local game_mode = Game.GetGameMode()
local engine_version = EngineVersionSetting:getEngineVersion()
local roomGameConfig = Server.CurServer:getConfig()
local Game2ConnectorMsgType = {
  SendMsgReq = 30006,
  JoinChannelReq = 30103,
  LeaveChannelReq = 30104
}

function ChatConnectorSender:init()
  self.channelMsgList = {}
end

function ChatConnectorSender:requestSendChannelMsg(player, msg, emoji, language)
  msg = World.CurWorld:filterWord(msg or "")
  local req = {
    gameType = game_name,
    gameMode = game_mode,
    engineVersion = engine_version,
    mid = roomGameConfig.mapID,
    language = language or player.language or "en",
    userId = player.platformUserId,
    nickName = player.name,
    sex = player:data("main").sex,
    msg = msg or "",
    emoji = emoji or ""
  }
  local params = {
    type = Game2ConnectorMsgType.SendMsgReq,
    userId = player.platformUserId,
    data = req
  }
  Lib.emitEvent(Event.EVENT_CONNECTOR_MSG, params)
end

function ChatConnectorSender:requestJoinChannel(player, language)
  local strs = Lib.splitString(language or "", "_")
  local langPrefix = "en_g2052"
  if strs[1] and strs[1] ~= "" and ChatLangConfig:getCfgByLang(strs[1]) then
    langPrefix = strs[1] .. "_g2052"
  end
  local req = {
    gameType = game_name,
    gameMode = game_mode,
    engineVersion = engine_version,
    mid = roomGameConfig.mapID,
    lang = langPrefix,
    maxUser = World.cfg.world_chatSetting.channelMaxNum or 100
  }
  local params = {
    type = Game2ConnectorMsgType.JoinChannelReq,
    userId = player.platformUserId,
    data = req
  }
  Lib.emitEvent(Event.EVENT_CONNECTOR_MSG, params)
end

function ChatConnectorSender:requestLeaveChannel(player)
  local req = {
    gameType = game_name,
    gameMode = game_mode,
    engineVersion = engine_version,
    mid = roomGameConfig.mapID
  }
  local params = {
    type = Game2ConnectorMsgType.LeaveChannelReq,
    userId = player.platformUserId,
    data = req
  }
  Lib.emitEvent(Event.EVENT_CONNECTOR_MSG, params)
end

function ChatConnectorSender:addOneWorldChatMsg(info)
  if not info or not info.language then
    return
  end
  if not self.channelMsgList then
    self.channelMsgList = {}
  end
  if not self.channelMsgList[info.language] then
    self.channelMsgList[info.language] = {}
  end
  table.insert(self.channelMsgList[info.language], info)
  if #self.channelMsgList[info.language] > World.cfg.world_chatSetting.loginWorldMsgNum then
    table.remove(self.channelMsgList[info.language], 1)
  end
end

function ChatConnectorSender:pushClientCacheWorldChatMsg(player)
  local strs = Lib.splitString(player.language or "", "_")
  local languageChannel = "en"
  if strs[1] and strs[1] ~= "" and ChatLangConfig:getCfgByLang(strs[1]) then
    languageChannel = strs[1]
  end
  if self.channelMsgList[languageChannel] and #self.channelMsgList[languageChannel] > 0 then
    local packet = {
      pid = "PushClientWorldChatCacheMsg",
      msgList = self.channelMsgList[languageChannel]
    }
    player:sendChatMsg(packet)
  end
end

ChatConnectorSender:init()
