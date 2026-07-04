local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local LuaTimer = T(Lib, "LuaTimer")
GMItem["g2052\229\183\165\229\133\183/\230\137\147\229\188\128\229\174\161\230\160\184\230\142\146\232\161\140\230\166\156"] = GM:inputStr(function(self, value)
  value = value == "" and "test_land" or value
  local wnd = UI:openWnd("biddingAuditRankList", value)
  wnd:show()
  wnd:setBlockId(value)
end)
