local handles = T(Player, "PackageHandlers")
local WorldChatHelper = T(Lib, "WorldChatHelper")

function handles:PushClientWorldChatMsg(packet)
  WorldChatHelper:receiveNewWorldMsg(packet.data)
end

function handles:PushClientWorldChatCacheMsg(packet)
  for _, data in pairs(packet.msgList) do
    WorldChatHelper:receiveNewWorldMsg(data)
  end
end
