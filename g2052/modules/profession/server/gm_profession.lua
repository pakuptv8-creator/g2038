local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\232\129\140\228\184\154/S\230\155\180\230\150\176\232\129\140\228\184\154"] = function(self)
  Plugins.CallTargetPluginFunc("profession", "updatePlayerProfession", self, 1)
end
