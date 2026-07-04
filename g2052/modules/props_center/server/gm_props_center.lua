local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["HandItem/\232\142\183\229\190\151\230\140\135\229\174\154\233\161\185\231\155\174"] = GM:inputStr(function(self, itemId)
  self:addHandItem(itemId)
end, function(self)
end)
GMItem["HandItem/S_DEBUG"] = function(self)
  local cfg = self.cfg
  Lib.logDebug(" ---cfg = " .. cfg)
end
GMItem["HandItem/\232\167\163\233\148\129\233\129\147\229\133\183"] = GM:inputStr(function(self, itemId)
  itemId = tonumber(itemId)
  self:unlockProp(itemId)
end)
GMItem["HandItem/\228\189\191\231\148\168\233\129\147\229\133\183"] = GM:inputStr(function(self, itemId)
  itemId = tonumber(itemId)
  self:onOperationBag({id = itemId})
end)
GMItem["HandItem/\233\128\129\229\135\186\233\129\147\229\133\183"] = GM:inputStr(function(self, itemId)
  itemId = tonumber(itemId)
  self:cancelHandItem({itemId = itemId})
end)
