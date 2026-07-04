local GameTimes = T(Lib, "GameTimes")
local handles = T(Player, "PackageHandlers")

function handles:adjustGameTime(packet)
  GameTimes:adjustGameTime(packet)
end
