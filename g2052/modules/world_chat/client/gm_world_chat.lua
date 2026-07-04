local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["world_chat/\229\143\145\230\182\136\230\129\175"] = GM:inputStr(function(self, value)
  Me:clientSendWorldChatMsg(value)
end, function(self)
end)
GMItem["world_chat/\229\138\160\229\133\165\233\162\145\233\129\147"] = GM:inputStr(function(self, value)
  Me:clientJoinWorldChatChannel(value)
end, function(self)
end)
GMItem["world_chat/\231\166\187\229\188\128\233\162\145\233\129\147"] = function()
  Me:clientLeaveWorldChatChannel()
end
GMItem["world_chat/c\232\175\173\232\168\128"] = function()
  print("wwwwww World.Lang", World.Lang, World.LangPrefix)
end
