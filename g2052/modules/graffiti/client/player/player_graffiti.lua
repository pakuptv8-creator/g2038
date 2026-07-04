local Player = _ENV.Player
local graffitiSetting = World.cfg.graffitiSetting

function Player:useDoodle()
  if self:isCanUseDoodle() then
    self.doodleCd = os.time() + graffitiSetting.UseSprayCdTime
    Me.disableControl = true
    local packet = {
      pid = "RequestPlayDoodleEffect",
      yaw = self:getBodyYaw(),
      clientFootPos = self:getFrontPos(World.cfg.graffitiSetting.frontDistance, true)
    }
    Me:sendPacket(packet)
    return true
  else
    return false
  end
end

function Player:isCanUseDoodle()
  local cdTime = self.doodleCd or 0
  return cdTime < os.time()
end
