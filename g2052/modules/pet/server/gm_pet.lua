local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_server.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_server")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["pet/newPet"] = function(self)
  self:addNewPet(2)
end
GMItem["pet/\228\184\190\232\181\183\229\174\160\231\137\169"] = function(self)
  self:liftUpPet(6)
end
GMItem["pet/\229\150\130\233\163\159\229\174\160\231\137\169"] = function(self)
  self:feedPet()
end
GMItem["pet/\232\167\163\233\148\129\233\169\172\229\140\185"] = function(self)
  for i = 11, 13 do
    self:setPetReceived(i)
  end
end
GMItem["pet/\230\184\133\233\153\164\232\167\163\233\148\129\233\169\172\229\140\185"] = function(self)
  self:clearPetReceived()
end
GMItem["pet/\230\184\133\233\153\164\233\162\134\229\143\150\233\169\172\229\140\185\231\138\182\230\128\129"] = function(self)
  self:clearPeakDayPetReceived()
end
