local SkateConfig = T(Config, "SkateConfig")
local handles = T(Player, "PackageHandlers")

function handles:setSkateMode(packet)
end

function handles:broadcastSkateAnim(packet)
  local player = World.CurWorld:getObject(self.objID)
  if not player or not player:isValid() then
    return
  end
  if player.rideOnId <= 0 then
    return
  end
  local packet = {
    pid = "playSkateAnimNotice",
    playerAnim = packet.playerAnim,
    skateAnim = packet.skateAnim,
    playerObjId = self.objID,
    skateObjId = player.rideOnId
  }
  self:sendPacketToTracking(packet)
end
