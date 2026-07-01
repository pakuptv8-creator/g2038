local MoveFrame = Lib.class("MoveFrame", require("script_client.time_line.frame.frame"))

function MoveFrame:enter(tick)
  print("MoveFrame:enter")
  Me:updateUpperAction("run", -1)
  self.targetPosX = self.cfg.targetPosX
  self.targetPosZ = self.cfg.targetPosZ
  local startPos = Me:getPosition()
  self.totalTick = self.endTick - self.startTick
  self.deltaX = (self.targetPosX - startPos.x) / self.totalTick
  self.deltaZ = (self.targetPosZ - startPos.z) / self.totalTick
  Me:setEntityProp("moveAcc", 0.0)
  Me.motion = Lib.v3(self.deltaX, 0, self.deltaZ)
end

function MoveFrame:apply(tick)
  Me.motion = Lib.v3(self.deltaX, 0, self.deltaZ)
  local curPos = Me:getPosition()
  local yaw = Lib.clampDegree(math.deg(math.atan(self.targetPosZ - curPos.z, self.targetPosX - curPos.x)) - 90)
  Me:setBodyYaw(yaw)
  Me:setRotationYaw(yaw)
end

function MoveFrame:onLeave(tick)
  Me:recoverEntityProp("moveAcc")
  Me.motion = Lib.v3(0, Me.motion.y, 0)
  Me:setPosition(Lib.v3(self.targetPosX, Me:getPosition().y, self.targetPosZ))
  Lib.logDebug("MoveFrame:onLeave", self.targetPosX, Me:getPosition().y, self.targetPosZ)
  if self.cfg.endAction then
    Me:updateUpperAction(self.cfg.endAction, -1)
    print("updateUpperAction " .. self.cfg.endAction)
  end
end

return MoveFrame
