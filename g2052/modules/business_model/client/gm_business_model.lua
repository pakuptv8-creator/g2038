local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["ME/\230\137\147\229\188\128vip\232\180\173\228\185\176\233\161\181"] = function()
  UI:openWnd("g2052Shop")
end
GMItem["ME/\230\137\147\229\188\128vip\230\142\168\233\148\128"] = function()
  UI:openWnd("g2052Marketing", Define.PRODUCT_TYPE.PRIVILEGE, Define.PRIVILEGE_TYPE.VIP)
end
