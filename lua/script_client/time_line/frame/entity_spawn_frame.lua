local EntitySpawnFrame = Lib.class("EntitySpawnFrame", require("script_client.time_line.frame.frame"))
local nextObjectID = 1342177280

local function entitySpawnPlayer(cfgName, pos, yaw, pitch, callBack)
  Game.EntitySpawn(Me, {
    objID = nextObjectID,
    cfgName = cfgName,
    actorName = "ninja_boy.actor",
    pos = pos,
    rotationYaw = yaw,
    rotationPitch = pitch,
    name = Me.name,
    curHp = 1,
    rideOnId = 0
  }, callBack)
  nextObjectID = nextObjectID + 1
  return nextObjectID - 1
end

function EntitySpawnFrame:enter(tick)
  print("EntitySpawnFrame:enter")
  if self.cfg.type == "player" then
    local pos = Lib.splitString(self.cfg.pos, ",")
    self.objID = entitySpawnPlayer(self.cfg.cfgName, Lib.v3(pos[1], pos[2], pos[3]), tonumber(self.cfg.yaw) or 0, tonumber(self.cfg.pitch) or 0, function(entity)
      if entity then
        entity.isMovieEntity = true
      end
    end)
  else
  end
end

function EntitySpawnFrame:apply(tick)
end

function EntitySpawnFrame:onLeave(tick)
  local entity = World.CurWorld:getObject(self.objID)
  if entity then
    entity:destroy()
  end
end

return EntitySpawnFrame
