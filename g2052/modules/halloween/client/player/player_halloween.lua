local HalloweenHelperClient = T(Lib, "HalloweenHelperClient")
local Player = _ENV.Player

function Player:onCatchGhost(type, target, params)
  HalloweenHelperClient:catchGhost(target)
end
