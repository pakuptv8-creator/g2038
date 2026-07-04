local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["ME/\232\142\183\229\143\150vip\230\191\128\230\180\187\231\138\182\230\128\129"] = GM:inputStr(function(self, value)
  local BusinessHelper = T(Lib, "BusinessHelper")
  local privilegeInfo = BusinessHelper:getPlayerPrivilegeInfo(tonumber(value) or self.platformUserId)
  print("---privilegeInfo---", Lib.v2s(privilegeInfo))
end)
GMItem["ME/\230\191\128\230\180\187\231\137\185\230\157\131"] = function(self)
  local data = {}
  for _, v in pairs(Define.PRIVILEGE_TYPE) do
    data[v] = os.time()
  end
  self:setPrivilegeInfo(data)
end
GMItem["ME/\230\184\133\233\153\164\231\137\185\230\157\131"] = function(self)
  self:setPrivilegeInfo({})
end
GMItem["ME/\230\184\133\233\153\164\230\142\168\232\141\144\232\180\173\228\185\176"] = function(self)
  self:setMarketData({})
end
GMItem["ME/\230\184\133\233\153\164\229\149\134\229\186\151\228\191\161\230\129\175"] = function(self)
  self:setBusinessData({})
end
