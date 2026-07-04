local BaseStatus = require("client.player_status.base_status")
local JumpStatus = class("JumpStatus", BaseStatus)
local StatusController = T(Lib, "StatusController")
local SkateControl = T(Lib, "SkateControl")
local SkateRayTest = T(Lib, "SkateRayTest")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local skateSetting = World.cfg.skateSetting
local SkateControlType = Define.SkateControlType

function JumpStatus:ctor(statusName, skateCfg)
  BaseStatus.ctor(self, statusName, skateCfg)
  self.skateJumpSpeed = self.skateCfg.jumpSpeed
  self.control = Blockman.Instance():control()
  self.rotateSpeed = skateSetting.defaultRotateSpeed
  self.autoRotateSpeed = skateSetting.autoRotateSpeed
  self.fallJudgeAngle = skateSetting.fallJudgeAngle
end

function JumpStatus:onEnter(forcePg)
  Lib.logWarning("JumpStatus onEnter")
  local jumpForce = SkateControl:getJumpFactor()
  local jumpForceUp = jumpForce.up or 1
  local jumpForceForward = jumpForce.forward or 1
  if jumpForceUp == 1 and jumpForceForward == 1 then
    self.jumpBySpring = false
  else
    self.jumpBySpring = true
  end
  if self.jumpBySpring then
    SkateAnimMgr:playFly()
    self:playSound("g2060_boardjump_up")
  else
    SkateAnimMgr:playJump(forcePg)
    self:playSound("g2060_jump_up")
  end
  Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, SkateAnimMgr:getCurAnimName(), Define.SkateAnimNameStatus.Show)
  SkateControl:setGravity(skateSetting.jumpUpGravity)
  self.rotateAngleVal = 0
  self.rotateCount = 0
  self.headHit = false
  self.fallOnGround = false
  self.turnAngleSpeed = skateSetting.turnMaxAngleSpeed
  local jumpSpeed = (0.8 + self.skateJumpSpeed * forcePg) * jumpForceUp
  SkateControl.motion.y = jumpSpeed
  self.enterMoveSpeed = SkateControl:getCurMoveSpeed()
  local moveSpeed = self.enterMoveSpeed * jumpForceForward
  SkateControl:setCurMoveSpeed(moveSpeed)
end

function JumpStatus:onUpdate(poleForward, poleStrafe, vAxisValue, hAxisValue)
  local forward = vAxisValue + poleForward
  local left = hAxisValue + poleStrafe
  local controlType = self:getControlType(poleForward, poleStrafe, forward, left)
  if controlType == SkateControlType.TurnRight or controlType == SkateControlType.TurnLeft then
    if left ~= 0 then
      if not self.jumpBySpring then
        local angleOffset = -(left / math.abs(left)) * self.turnAngleSpeed
        local targetYaw = self.skateEntity:getRotationYaw() + angleOffset
        self.skateEntity:setRotationYaw(targetYaw, false)
      else
        local curRoll = self.skateEntity:getRotationRoll()
        if 0 < left then
          self.skateEntity:setRotationRoll(self:fixRotateAngle(curRoll - self.rotateSpeed))
        else
          self.skateEntity:setRotationRoll(self:fixRotateAngle(curRoll + self.rotateSpeed))
        end
      end
    end
  elseif controlType == SkateControlType.ForwardAcc then
    if self.jumpBySpring then
      local curPitch = self.skateEntity:getRotationPitch()
      self.skateEntity:setRotationPitch(self:fixRotateAngle(curPitch + self.rotateSpeed))
    end
  elseif controlType == SkateControlType.Stop then
    if self.jumpBySpring then
      local curPitch = self.skateEntity:getRotationPitch()
      self.skateEntity:setRotationPitch(self:fixRotateAngle(curPitch - self.rotateSpeed))
    end
  elseif controlType == SkateControlType.Idle and self.jumpBySpring then
    self:autoResetRotate()
  end
  if self.jumpBySpring then
    if controlType ~= self.curControlType then
      self.curControlType = controlType
      self.rotateAngleVal = 0
    end
    if self.curControlType ~= SkateControlType.Stop and self.curControlType ~= SkateControlType.Idle then
      self.rotateAngleVal = self.rotateAngleVal + self.rotateSpeed
      local rotateCount = math.floor(self.rotateAngleVal / 360)
      if rotateCount > self.rotateCount then
        self.rotateCount = rotateCount
        Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, self:getFlyJumpAnimName(), Define.SkateAnimNameStatus.Show)
      end
    end
  end
  if 0 >= SkateControl.motion.y then
    SkateControl:setGravity(skateSetting.jumpDownGravity)
  elseif SkateRayTest:checkHeadCollision() then
    SkateControl:setMotionY(0)
    self.headHit = true
  end
  if self.skateEntity.onGround then
    StatusController:setLockStatus(nil)
  end
end

function JumpStatus:checkFallToGround()
  local pitch = self.skateEntity:getRotationPitch()
  if pitch < -self.fallJudgeAngle.pitch or pitch > self.fallJudgeAngle.pitch then
    return true
  end
  local roll = self.skateEntity:getRotationRoll()
  if roll < -self.fallJudgeAngle.roll or roll > self.fallJudgeAngle.roll then
    return true
  end
  return false
end

function JumpStatus:autoResetRotate()
  local curPitch = self.skateEntity:getRotationPitch()
  local curRoll = self.skateEntity:getRotationRoll()
  local newRoll, newPitch
  if curPitch ~= 0 then
    if 0 < curPitch then
      newPitch = math.max(curPitch - self.autoRotateSpeed, 0)
    elseif curPitch < 0 then
      newPitch = math.min(curPitch + self.autoRotateSpeed, 0)
    end
    if newPitch ~= curPitch then
      self.skateEntity:setRotationPitch(newPitch)
    end
  end
  if curRoll ~= 0 then
    if 0 < curRoll then
      newRoll = math.max(curRoll - self.autoRotateSpeed, 0)
    elseif curRoll < 0 then
      newRoll = math.min(curRoll + self.autoRotateSpeed, 0)
    end
    if newRoll ~= curRoll then
      self.skateEntity:setRotationRoll(newRoll)
    end
  end
end

function JumpStatus:fixRotateAngle(val)
  val = val % 360
  if 180 < val then
    val = val - 360
  elseif val < -180 then
    val = val + 360
  end
  return val
end

function JumpStatus:getFlyJumpAnimName()
  local curFlyAnim = SkateAnimMgr:getCurAnimName()
  if self.rotateCount > 0 then
    return curFlyAnim .. self.rotateCount * 360
  else
    return curFlyAnim
  end
end

function JumpStatus:onExit()
  Lib.logWarning("JumpStatus onExit")
  SkateControl:setGravity(skateSetting.jumpDownGravity)
  if self.jumpBySpring then
    self.fallOnGround = self:checkFallToGround()
    SkateControl:setFallOnGround(self.fallOnGround)
    SkateControl:setCurMoveSpeed(self.enterMoveSpeed)
    SkateControl:setTargetPitch(self.skateEntity:getRotationPitch())
    if self.fallOnGround then
      Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, self:getFlyJumpAnimName(), Define.SkateAnimNameStatus.Fail)
    else
      Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, self:getFlyJumpAnimName(), Define.SkateAnimNameStatus.Success)
      self:playSound("g2060_boardjump_down")
    end
  elseif self.headHit then
    Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, SkateAnimMgr:getCurAnimName(), Define.SkateAnimNameStatus.Fail)
  else
    Lib.emitEvent(Event.EVENT_SHOW_SKATE_NAME, SkateAnimMgr:getCurAnimName(), Define.SkateAnimNameStatus.Success)
  end
  SkateAnimMgr:resetPlayAnimData()
end

return JumpStatus
