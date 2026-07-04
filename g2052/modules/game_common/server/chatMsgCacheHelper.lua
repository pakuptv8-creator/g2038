local ChatMsgCacheHelper = T(Lib, "ChatMsgCacheHelper")

function ChatMsgCacheHelper:init()
  self.msgList = {}
end

function ChatMsgCacheHelper:addOneCommonChatMsg(packet)
  table.insert(self.msgList, packet)
  if #self.msgList > World.cfg.loginChatMsgNum then
    table.remove(self.msgList, 1)
  end
end

function ChatMsgCacheHelper:pushClientCacheChatMsg(player)
  local packet = {
    pid = "PushClientCacheChatMsg",
    msgList = self.msgList
  }
  player:sendChatMsg(packet)
end

ChatMsgCacheHelper:init()
