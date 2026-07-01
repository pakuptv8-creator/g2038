local ActivationTrack = Lib.class("ActivationTrack", require("script_client.time_line.track.track"))

function ActivationTrack:getFrameClass(type)
  local frameMap = {
    ActiveFrame = require("script_client.time_line.frame.active_frame"),
    EntitySpawnFrame = require("script_client.time_line.frame.entity_spawn_frame")
  }
  return frameMap[type]
end

function ActivationTrack:onStart(tick)
end

function ActivationTrack:onUpdate(tick)
end

function ActivationTrack:onStop()
  if self.cfg.pos then
    local pos = Lib.splitString(self.cfg.pos, ",")
    Me:setPosition(Lib.v3(pos[1], pos[2], pos[3]))
    Lib.logDebug("ActivationTrack:onStop", pos[1], pos[2], pos[3])
  end
  local yaw = self.cfg.yaw or 0
  Me:setBodyYaw(yaw)
  Me:setRotationYaw(yaw)
  Me:setRotationPitch(self.cfg.pitch or 0)
end

return ActivationTrack
