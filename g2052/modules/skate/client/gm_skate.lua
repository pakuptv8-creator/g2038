local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["skate/\230\181\139\232\175\149\229\138\168\228\189\156"] = function()
  Me:updateUpperAction("g2052_boy_break_1", -1)
end
GMItem["skate/\232\185\178\228\184\139"] = function()
  SkateAnimMgr:playJumpSquat()
end
GMItem["skate/\229\136\185\232\189\1661"] = function()
  SkateAnimMgr:playBreak1()
end
