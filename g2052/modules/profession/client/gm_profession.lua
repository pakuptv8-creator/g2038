local path = Root.Instance():getGamePath():gsub("\\", "/") .. "lua/gm_client.lua"
local file, err = io.open(path, "r")
local GMItem
if file then
  GMItem = require("gm_client")
  file:close()
end
GMItem = GMItem or GM:createGMItem()
GMItem["\232\129\140\228\184\154/\232\190\147\229\133\165\229\144\141\229\173\151"] = GM:inputStr(function(self, value)
  Me:setNameContent(value)
end, function(self)
end)
GMItem["\232\129\140\228\184\154/\232\190\147\229\133\165\232\129\140\228\184\154"] = GM:inputStr(function(self, value)
  Me:clientSetProfession(tonumber(value))
end, function(self)
end)
GMItem["\232\129\140\228\184\154/\232\190\147\229\133\165\233\162\156\232\137\178"] = GM:inputStr(function(self, value)
  Me:setNameColor("FF" .. value)
end, function(self)
end)
GMItem["\232\129\140\228\184\154/\229\189\147\229\137\141\229\144\141\229\173\151"] = function(self)
  print(Me:getNameContent())
end
GMItem["\232\129\140\228\184\154/\230\152\190\231\164\186\231\137\185\230\149\136"] = function(self)
  local effect = {
    effect = "g2052_phone_left.effect",
    pos = {
      x = 0,
      y = 3,
      z = 0
    },
    yaw = 0,
    once = true,
    time = 5000
  }
  Me.testEffectName = Me:showEffect(effect)
end
GMItem["\232\129\140\228\184\154/\231\167\187\233\153\164\231\137\185\230\149\136"] = function(self)
  if Me.testEffectName then
    Me:delEffect(Me.testEffectName)
    Me.testEffectName = nil
  end
end
GMItem["\232\129\140\228\184\154/\230\157\165\231\148\181\233\159\179\230\149\136"] = function(self)
  Me:playSoundByKey(World.cfg.phoneProfession.rSoundKey, World.cfg.phoneProfession.rSoundTime * 20)
end
GMItem["\232\129\140\228\184\154/\229\142\187\231\148\181\233\159\179\230\149\136"] = function(self)
  Me:playSoundByKey(World.cfg.phoneProfession.sSoundKey, World.cfg.phoneProfession.sSoundTime * 20)
end
GMItem["\232\129\140\228\184\154/\230\181\139\232\175\149\233\159\179\230\149\136"] = function(self)
  local ProfessionalHelper = T(Lib, "ProfessionalHelper")
  ProfessionalHelper:playCallSoundByKey(World.cfg.phoneProfession.sSoundKey, World.cfg.phoneProfession.sSoundTime * 20, 1)
end
