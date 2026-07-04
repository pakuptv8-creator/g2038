local MessageNoticeManager = T(Lib, "MessageNoticeManager")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2052\229\183\165\229\133\183/\230\142\168\233\128\129\230\182\136\230\129\175"] = function(self)
end
