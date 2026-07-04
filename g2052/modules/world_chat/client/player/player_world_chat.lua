local Player = _ENV.Player
local WorldChatHelper = T(Lib, "WorldChatHelper")

function Player:clientSendWorldChatMsg(msg, emoji, language)
  local packet = {
    pid = "ClientSendWorldChatMsg",
    msg = msg,
    emoji = emoji,
    language = language or WorldChatHelper.curSelectChannel
  }
  self:sendPacket(packet)
end

function Player:clientJoinWorldChatChannel(language)
  local packet = {
    pid = "ClientJoinWorldChatChannel",
    language = language
  }
  self:sendPacket(packet)
end

function Player:clientLeaveWorldChatChannel()
  local packet = {
    pid = "ClientLeaveWorldChatChannel"
  }
  self:sendPacket(packet)
end
