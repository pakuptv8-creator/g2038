local handles = T(Player, "PackageHandlers")
local ChatConnectorSender = T(Lib, "ChatConnectorSender")

function handles:ClientSendWorldChatMsg(packet)
  ChatConnectorSender:requestSendChannelMsg(self, packet.msg, packet.emoji, packet.language)
  local reportData = {
    world_chat_lang = packet.language
  }
  if packet.emoji then
    reportData.world_chat_type = 2
  else
    reportData.world_chat_type = 1
  end
  Plugins.CallTargetPluginFunc("report", "report", "world_chat", reportData, self)
end

function handles:ClientJoinWorldChatChannel(packet)
  ChatConnectorSender:requestJoinChannel(self, packet.language)
end

function handles:ClientLeaveWorldChatChannel(packet)
  ChatConnectorSender:requestLeaveChannel(self)
end
