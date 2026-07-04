local SkateControl = T(Lib, "SkateControl")
local StatusController = T(Lib, "StatusController")
local SkateRayTest = T(Lib, "SkateRayTest")
local SkateCamera = T(Lib, "SkateCamera")
local SkateAnimMgr = T(Lib, "SkateAnimMgr")
local SoundManager = T(Lib, "SoundManager")
local bm = Blockman.Instance()
local SkateStatus = Define.SkateStatus
local skateSetting = World.cfg.skateSetting
local PartType = Define.PartType

function SkateControl:init(skateCfg)
  self.skateCfg = skateCfg
  self.curMoveSpeed = 0
  self.glideLock = false
  self.isBanMove = false
  self.cancelGlideCd = 2
  self.control = bm:control()
  local SkateMgr = T(Lib, "SkateMgr")
  self.skateEntity = SkateMgr:getSkateEntity()
  Me:doSetProp("disableActionStateAutoUpdate", 1)
  self.skateEntity:doSetProp("disableActionStateAutoUpdate", 1)
  self.entityPlayAnimData = {}
  self.skateOnGround = self.skateEntity.onGround
  self.turnAngleSpeed = skateSetting.turnDefaultAngleSpeed
  self.eventList = {}
  self.jumpFactor = {up = 1, forward = 1}
  self.isCharge = false
  self.forcePg = 0
  self.pitchDt = 1
  self.curPitch = self.skateEntity:getRotationPitch()
  self.motion = Vector3.new(0, 0, 0)
  self.gravity = skateSetting.jumpDownGravity
  self.isPause = false
  self.eventList[#self.eventList + 1] = Lib.lightSubscribeEvent("", Event.SET_JUMP_CHARGE, function(isCharge)
    if StatusController:isStatus(SkateStatus.StepOn) or StatusController:isStatus(SkateStatus.FallGround) or StatusController:isStatus(SkateStatus.StepDown) then
      return
    end
    if self.isCharge == isCharge then
      return
    end
    self.isCharge = isCharge
    if self.isCharge then
      if self.skateEntity.onGround then
        self.cacheForceJumpOpt = false
        self:forceJumpPower()
        StatusController:setLockStatus(nil)
        StatusController:setStatus(SkateStatus.Charge)
      else
        self.cacheForceJumpOpt = true
      end
    else
      self.cacheForceJumpOpt = false
      self:setForceJump()
    end
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y, preX, preY)
    self.touchMoveChangeDir = true
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y, preX, preY)
    self.touchMoveChangeDir = false
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SKATE_STEP_DOWN, function()
    StatusController:setStatus(SkateStatus.StepDown, nil, true)
    self:cancelForceJump()
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SKATE_BAN_MOVE, function(isBan)
    self.isBanMove = isBan
    if isBan then
      self.curMoveSpeed = 0
    end
  end)
end

function SkateControl:setControl(poleForward, poleStrafe, vAxisValue, hAxisValue)
  if not self.skateEntity or not self.skateEntity:isValid() then
    return
  end
  if self.isPause then
    return
  end
  self.motion.x = 0
  self.motion.z = 0
  self.fallOnGround = false
  local forward = vAxisValue + poleForward
  local left = hAxisValue + poleStrafe
  if not StatusController:isLockStatus() then
    if self.skateEntity.onGround and (self.curMoveSpeed == 0 and forward ~= 0 or left ~= 0 or 0 < self.curMoveSpeed) then
      StatusController:setStatus(SkateStatus.Run)
    elseif self.skateEntity.onGround and self.curMoveSpeed == 0 and not StatusController:isStatus(SkateStatus.Charge) then
      StatusController:setStatus(SkateStatus.Idle)
    end
  end
  local footCollisionData = SkateRayTest:checkFootCollision()
  self:setTargetPitch(footCollisionData.pitch)
  self:dealFootCollision(footCollisionData)
  StatusController:tick(poleForward, poleStrafe, vAxisValue, hAxisValue)
  if 0 < self.motion.y then
    self.motion.y = self.motion.y - self.gravity
  elseif self.skateEntity.onGround then
    self.motion.y = 0
  else
    self.motion.y = self.motion.y - self.gravity
  end
  if not self.isBanMove then
    local dir = Lib.v3(left, 0, forward)
    local yaw = bm:viewerRenderYaw()
    dir = Lib.posAroundYaw(dir, yaw)
    local motionCal = dir:normalize() * self.curMoveSpeed
    self.motion.z = motionCal.z
    self.motion.x = motionCal.x
    if self.skateEntity.onGround and self.curMoveSpeed ~= 0 and motionCal.x == 0 and motionCal.z == 0 then
      self:setCurMoveSpeed(0)
    end
  end
  if self.skateOnGround ~= self.skateEntity.onGround then
    self.skateOnGround = self.skateEntity.onGround
    self:dealOnGroundStatusChange()
  end
  if not self.fallOnGround then
    self:checkJumpDownAnim()
  else
    self:dealFallOnGround()
  end
  self.skateEntity.motion = self.motion
  self:setSkatePitchSmooth()
end

function SkateControl:forceJumpPower()
  if self.skateEntity.onGround and not StatusController:isStatus(SkateStatus.StepDown) then
    SkateAnimMgr:playJumpSquat()
    self.forcePg = 0
    self.addForceTimer = World.Timer(1, function()
      self.forcePg = math.min(self.forcePg + skateSetting.forceJumpOneFrameAddVal, 1)
      Lib.emitEvent(Event.SET_FORCE_JUMP_BAR_DISPLAY, true, self.forcePg)
      if self.forcePg == 1 then
        self.addForceTimer = nil
        return false
      end
      return true
    end)
  end
end

function SkateControl:setForceJump()
  if self.addForceTimer then
    self.addForceTimer()
    self.addForceTimer = nil
  end
  Lib.emitEvent(Event.SET_FORCE_JUMP_BAR_DISPLAY, false)
  if StatusController:isStatus(SkateStatus.Jump) then
    return
  end
  if not self.skateEntity.onGround then
    SkateAnimMgr:playIdle(true)
    return
  end
  local footCollisionData = SkateRayTest:checkFootCollision()
  local objectType = footCollisionData.objectType
  if objectType and objectType == PartType.Jump then
    self:setJumpFactor()
  end
  StatusController:setLockStatus(nil)
  StatusController:setStatus(SkateStatus.Jump, self.forcePg, true)
  self.forcePg = 0
  self:setJumpFactor(1, 1)
end

function SkateControl:cancelForceJump()
  self.isCharge = false
  if self.addForceTimer then
    self.addForceTimer()
    self.addForceTimer = nil
  end
  Lib.emitEvent(Event.SET_FORCE_JUMP_BAR_DISPLAY, false)
end

function SkateControl:checkJumpDownAnim()
  if self.isCharge and self.skateOnGround then
    SkateAnimMgr:playJumpSquat()
  end
end

function SkateControl:dealFallOnGround()
  self:cancelForceJump()
  StatusController:setStatus(SkateStatus.FallGround, nil, true)
end

function SkateControl:dealOnGroundStatusChange()
  if self.skateOnGround then
    if not self.fallOnGround then
      local animName = SkateAnimMgr:getCurAnimName(Me.objID)
      if animName ~= "g2060_boy_jump_squat" then
        SkateAnimMgr:playJumpDown()
      end
      if self.cacheForceJumpOpt then
        self.cacheForceJumpOpt = false
        self:forceJumpPower()
      end
      self.skateEntity:setRotationRoll(0)
    else
      self.cacheForceJumpOpt = false
    end
  end
  Lib.emitEvent(Event.EVENT_SKATE_ON_GROUND_STATUS_CHANGE, self.skateOnGround)
end

function SkateControl:setTargetPitch(pitch)
  if not pitch then
    return
  end
  pitch = math.floor(pitch)
  if self.targetPitch ~= pitch then
    self.targetPitch = pitch
    self.curPitch = self.skateEntity:getRotationPitch()
    self.pitchDt = 0
  end
end

function SkateControl:setSkatePitchSmooth()
  if self.pitchDt < 1 then
    self.pitchDt = self.pitchDt + 0.2
    self.curPitch = self:line_lerp(self.curPitch, self.targetPitch, self.pitchDt)
    self.skateEntity:setRotationPitch(self.curPitch)
  end
end

function SkateControl:isGlideStatus()
  return self.isGlide
end

function SkateControl:isTouchMoveChangeDir()
  return self.touchMoveChangeDir
end

function SkateControl:setTouchMoveChangeDir(val)
  self.touchMoveChangeDir = val
end

function SkateControl:setFallOnGround(fallOnGround)
  self.fallOnGround = fallOnGround
end

function SkateControl:dealFootCollision(footCollisionData)
  local objectType = footCollisionData.objectType
  local result = footCollisionData.result
  if objectType then
    if objectType == PartType.Box then
      if not self:isGlideStatus() and result.target then
        self:setEnterBoxGlide(result)
      end
    elseif self:isGlideStatus() then
      self:setLeaveBoxGlide(self.cancelGlideCd)
    end
  elseif self:isGlideStatus() then
    self:setLeaveBoxGlide(self.cancelGlideCd)
  end
end

function SkateControl:setGlideCd(time)
  if self.cancelGlideTimer then
    self.cancelGlideTimer()
  end
  self.glideLock = true
  self.cancelGlideTimer = World.Timer(time, function()
    self.glideLock = false
    self.cancelGlideTimer = nil
  end)
end

function SkateControl:setEnterBoxGlide(collisionResult)
  if self.glideLock or self.curMoveSpeed == 0 then
    return
  end
  if not self.isGlide then
    self.isGlide = true
    Lib.logInfo("setGlide ", self.isGlide)
    StatusController:setStatus(SkateStatus.Glide, collisionResult, true)
  end
end

function SkateControl:setLeaveBoxGlide(cdTime)
  if self.isGlide then
    self.isGlide = false
    Lib.logInfo("setGlide ", self.isGlide)
    self:setGlideCd(cdTime)
    if self.touchMoveChangeDir then
      SkateCamera:changeCameraType("skateCameraDrag", skateSetting.cameraTime.touchDragEnter)
    else
      SkateCamera:changeCameraType("skateFollow", skateSetting.cameraTime.enterBoxSlip)
    end
    StatusController:setLockStatus(nil)
    if not StatusController:isStatus(SkateStatus.Jump) then
      StatusController:setStatus(SkateStatus.Run)
    end
  end
end

function SkateControl:setFailBoxGlide(angle)
  local curYaw = self.skateEntity:getRotationYaw()
  local targetYaw = curYaw + (angle or 15)
  self.skateEntity:setRotationYaw(targetYaw)
end

function SkateControl:setMotionY(val)
  self.motion.y = val
end

function SkateControl:setMotionX(val)
  self.motion.x = val
end

function SkateControl:getMotion()
  return self.motion
end

function SkateControl:setCurMoveSpeed(speed)
  self.curMoveSpeed = speed
end

function SkateControl:getCurMoveSpeed()
  return self.curMoveSpeed
end

function SkateControl:getCurTurnAngleSpeed()
  return self.turnAngleSpeed
end

function SkateControl:setCurTurnAngleSpeed(speed)
  self.turnAngleSpeed = speed
end

function SkateControl:setGravity(gravity)
  self.gravity = gravity
end

function SkateControl:setJumpFactor(up, forward)
  self.jumpFactor.up = up or skateSetting.defaultJumpFactor.up
  self.jumpFactor.forward = forward or skateSetting.defaultJumpFactor.forward
end

function SkateControl:getJumpFactor()
  return self.jumpFactor
end

function SkateControl:line_lerp(val, targetVal, t)
  if t <= 0 then
    return val
  elseif 1 <= t then
    return targetVal
  end
  return t * targetVal + (1 - t) * val
end

function SkateControl:unInit()
  self.curMoveSpeed = 0
  self.glideLock = false
  self.isBanMove = false
  for _, event in pairs(self.eventList) do
    event()
  end
  self.eventList = {}
  if self.cancelGlideTimer then
    self.cancelGlideTimer()
    self.cancelGlideTimer = nil
  end
  if self.addForceTimer then
    self.addForceTimer()
    self.addForceTimer = nil
  end
  Me:doSetProp("disableActionStateAutoUpdate", 0)
  Me:updateUpperAction("idle")
end

function SkateControl:pause()
  self.isPause = true
end

function SkateControl:resume()
  self.isPause = false
end
