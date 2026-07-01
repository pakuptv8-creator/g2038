local ControlJumpFrame = Lib.class("ControlJumpFrame", require("script_client.time_line.frame.frame"))

function ControlJumpFrame:enter(tick)
  print("ControlJumpFrame:enter")
  Me:changeJumpState("JumpRaiseState")
  self.targetPosX = self.cfg.targetPosX
  self.targetPosZ = self.cfg.targetPosZ
  self.targetPosY = self.cfg.targetPosY
  local startPos = Me:getPosition()
  self.totalTick = self.endTick - self.startTick
  self.deltaX = (self.targetPosX - startPos.x) / self.totalTick
  self.deltaZ = (self.targetPosZ - startPos.z) / self.totalTick
  local curPos = Me:getPosition()
  self.targetYaw = math.deg(math.atan(self.targetPosZ - curPos.z, self.targetPosX - curPos.x)) - 90
  local totalYaw = Lib.clampDegree(self.targetYaw) - Lib.clampDegree(Me:getRotationYaw())
  self.deltaYaw = totalYaw / self.totalTick
  Me:setEntityProp("moveSpeed", 10)
  Me:setEntityProp("moveAcc", 0.0)
  Me.motion = Lib.v3(self.deltaX, Me.motion.y, self.deltaZ)
end

function ControlJumpFrame:apply(tick)
  local yaw = Me:getRotationYaw() + self.deltaYaw
  Me:setBodyYaw(yaw)
  Me:setRotationYaw(yaw)
end

function ControlJumpFrame:onLeave(tick)
  Me:recoverEntityProp("moveSpeed")
  Me:recoverEntityProp("moveAcc")
  Me.motion = Lib.v3(0, Me.motion.y, 0)
  Me:setPosition(Lib.v3(self.targetPosX, self.targetPosY or Me:getPosition().y, self.targetPosZ))
  Me:setBodyYaw(self.targetYaw)
  Me:setRotationYaw(self.targetYaw)
end

return ControlJumpFrame
