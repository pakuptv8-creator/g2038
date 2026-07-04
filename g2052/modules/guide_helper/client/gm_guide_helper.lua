local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["ME/\230\184\133\231\169\186\229\188\149\229\175\188\228\191\161\230\129\175"] = function(self)
  Me:setValue("guideInfo", {})
end
