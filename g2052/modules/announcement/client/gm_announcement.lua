local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\229\133\172\229\145\138/\229\133\172\229\145\138"] = function()
  Me:openAnnouncementWnd()
end
