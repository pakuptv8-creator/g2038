local Player = _ENV.Player
local handles = T(Player, "PackageHandlers")
local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")

function handles:requestEnterGloryHall(packet)
  self:doEnterGloryHall()
end

function handles:requestLeaveGloryHall()
  self:doLeaveGloryHall()
end

function Player:doEnterGloryHall()
  self.gloryLastMapInfo = {
    lastMap = self.map.name,
    lastPos = self:getPosition(),
    lastRotationYaw = self:getRotationYaw(),
    lastRotationPitch = self:getRotationPitch()
  }
  self.needKickedOutGloryHall = false
  self:setMapPos(World.cfg.gloryHallMap, World.cfg.gloryHallPos)
  self:pushClientUpdateGloryDoor()
end

function Player:doLeaveGloryHall()
  if self.gloryLastMapInfo then
    self:setMapPos(self.gloryLastMapInfo.lastMap, self.gloryLastMapInfo.lastPos, self.gloryLastMapInfo.lastRotationYaw, self.gloryLastMapInfo.lastRotationPitch)
  else
    self:setMapPos(World.cfg.defaultMap, World.cfg.initPos)
  end
  self.gloryLastMapInfo = nil
  self:pushClientUpdateGloryDoor()
end

function Player:pushClientUpdateGloryDoor()
  local curServerTime = os.time()
  local timeList = PokemonGloryHallConfig:getAllRemainOpenTime()
  local packet = {
    pid = "SyncGloryHallRemainRT",
    timeList = timeList,
    doorNameTxtList = GloryHallMgr.doorNameTxtList,
    doorEntityList = GloryHallMgr.doorEntityList,
    curServerTime = curServerTime
  }
  self:sendPacket(packet)
end
