local EmergencyEffectMgr = T(Lib, "EmergencyEffectMgr")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["emergency/\231\129\173\231\129\171\230\137\128\230\156\137"] = function()
  EmergencyEffectMgr:delAllEffect()
end
