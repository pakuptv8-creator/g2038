local handles = T(Player, "PackageHandlers")

function handles:RequestPlayDoodleEffect(packet)
  self:doPlayDoodleEffect(packet)
end
