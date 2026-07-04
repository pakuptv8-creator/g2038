local Player = _ENV.Player
local GraffitiConfig = T(Config, "GraffitiConfig")

function Player:checkEyeFrontObstacle(dis)
  local world = self.map:getPhysicsWorld()
  local origin = self:getEyePos()
  local desPos = self:getFrontPos(dis)
  local dir = desPos - origin
  local len = dir:len()
  if len <= 0.01 then
    return false
  end
  local result = world:raycast(origin, dir, len)
  if result and result.target and result.target.isCameraCollideEnable and result.target:isCameraCollideEnable() then
    return result
  end
  return false
end

function Player:doPlayDoodleEffect(info)
  local packet = {
    pid = "SCPlayDoodleEffect",
    doodleId = GraffitiConfig:getOneRandomCfg().id,
    objID = self.objID,
    mapName = self.map.name
  }
  local result = self:checkEyeFrontObstacle(World.cfg.graffitiSetting.frontDistance)
  if result then
    packet.isGround = false
    packet.pos = result.collidePos + result.normalOnHitObject * World.cfg.graffitiSetting.offsetFront
    local fPos = result.collidePos + result.normalOnHitObject * 2
    local x = fPos.x - result.collidePos.x
    local z = fPos.z - result.collidePos.z
    local tan = math.atan(z, x)
    local cYaw = math.deg(tan)
    packet.yaw = 540 - (cYaw - 90) - 180
  else
    packet.pos = info.clientFootPos
    packet.pos.y = self:getFrontPos(World.cfg.graffitiSetting.frontDistance, true).y + World.cfg.graffitiSetting.offsetY
    packet.yaw = 540 - info.yaw
    packet.isGround = true
  end
  self:sendPacketToTracking(packet, true)
end
