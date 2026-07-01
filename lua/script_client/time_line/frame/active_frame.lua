local ActiveFrame = Lib.class("ActiveFrame", require("script_client.time_line.frame.frame"))

function ActiveFrame:enter(tick)
  local active = Lib.toBool(self.cfg.active)
  Me:setEntityHide(not active)
  if self.cfg.pos then
    local pos = Lib.splitString(self.cfg.pos, ",")
    Me:setPosition(Lib.v3(pos[1], pos[2], pos[3]))
    Lib.logDebug("ActiveFrame:enter", pos[1], pos[2], pos[3])
  end
  local yaw = self.cfg.yaw or 0
  Me:setBodyYaw(yaw)
  Me:setRotationYaw(yaw)
  Me:setRotationPitch(self.cfg.pitch or 0)
end

function ActiveFrame:apply(tick)
end

function ActiveFrame:onLeave(tick)
end

return ActiveFrame
