local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
local GameTimes = T(Lib, "GameTimes")
GMItem["g2052\229\183\165\229\133\183/\228\191\174\230\148\185\230\184\184\230\136\143\229\134\133\230\151\182\233\151\180"] = GM:inputStr(function(self, var)
  local time = Lib.splitString(var or "", ":", true)
  GameTimes:setTime(time[1] or 12, time[2] or 0)
end, function()
  return string.format("%d:%d", 12, 0)
end)
