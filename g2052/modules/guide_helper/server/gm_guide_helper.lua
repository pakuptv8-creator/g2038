local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["g2052/\230\184\133\231\169\186\229\188\149\229\175\188\228\191\161\230\129\175"] = function(self)
  self:setValue("guideInfo", {})
  self:setValue("playerActive", {})
end
