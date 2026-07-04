local SkateCamera = T(Lib, "SkateCamera")
local SkateControl = T(Lib, "SkateControl")
local Cinemachine = T(Lib, "LuaCinemachine")
local skateSetting = World.cfg.skateSetting
local bm = Blockman.Instance()

function SkateCamera:init(skateCfg)
  local SkateMgr = T(Lib, "SkateMgr")
  self.skateEntity = SkateMgr:getSkateEntity()
  self.eventList = {}
  self.cameraDict = {}
  self.isFlyJump = false
  self.isFallDown = false
  self:createCamera()
  self.rotateYawDt = 1
  self.dragAngleSmooth = 0.1
  self.dragCamera = false
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y, preX, preY)
    self:dragCameraRotateBegin()
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_MOVE, function(x, y, preX, preY)
    self:changeRotateYaw()
  end)
  self.eventList[#self.eventList + 1] = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y, preX, preY)
    self:dragCameraRotateEnd()
  end)
  
  function Me:handleCameraTick(frameTime)
    SkateCamera:smoothRotate()
    SkateCamera:setJumpDownCamera()
  end
end

function SkateCamera:dragCameraRotateBegin()
  self.dragCamera = true
  if self.resetCameraTimer then
    self.resetCameraTimer()
    self.resetCameraTimer = nil
  end
  if self.initCamera and not SkateControl:isGlideStatus() then
    self.rotateYawDt = 1
    if not self.isFlyJump then
      local curCameraName = Cinemachine:getLiveCameraName()
      local targetCameraName
      if curCameraName == "skateCameraDrag" then
        targetCameraName = "skateCameraDrag2"
      else
        targetCameraName = "skateCameraDrag"
      end
      self:changeCameraType(targetCameraName, skateSetting.cameraTime.touchDragEnter)
    end
  end
end

function SkateCamera:dragCameraRotateEnd()
  self.dragCamera = false
  self:changeRotateYaw()
end

function SkateCamera:fixRotateAngle(val)
  val = val % 360
  if 180 < val then
    val = val - 360
  elseif val < -180 then
    val = val + 360
  end
  return val
end

function SkateCamera:changeRotateYaw()
  if self.initCamera and not SkateControl:isGlideStatus() and not self.isFallDown then
    local yaw = self:fixRotateAngle(bm:getViewerYaw())
    self.curStartRotateYaw = self:fixRotateAngle(self.skateEntity:getRotationYaw())
    local flag = false
    if self.curStartRotateYaw > 0 and yaw < 0 or self.curStartRotateYaw < 0 and 0 < yaw then
      flag = true
    end
    if flag then
      local tempYaw = yaw
      if 0 < yaw then
        tempYaw = yaw - 360
      else
        tempYaw = yaw + 360
      end
      local r1 = math.abs(self.curStartRotateYaw - yaw)
      local r2 = math.abs(self.curStartRotateYaw - tempYaw)
      if r1 > r2 then
        yaw = tempYaw
      end
    end
    self.targetRotateYaw = yaw
    self.rotateOffset = (self.targetRotateYaw - self.curStartRotateYaw) * self.dragAngleSmooth
    self.rotateYawDt = 0
  end
end

function SkateCamera:smoothRotate()
  if self.rotateYawDt < 1 then
    if SkateControl:isGlideStatus() then
      self.rotateYawDt = 1
      return
    end
    self.rotateYawDt = self.rotateYawDt + self.dragAngleSmooth
    if self.curStartRotateYaw > self.targetRotateYaw then
      self.curStartRotateYaw = math.max(self.curStartRotateYaw + self.rotateOffset, self.targetRotateYaw)
    else
      self.curStartRotateYaw = math.min(self.curStartRotateYaw + self.rotateOffset, self.targetRotateYaw)
    end
    self.skateEntity:setRotationYaw(self.curStartRotateYaw)
    self.skateEntity:setBodyYaw(self.curStartRotateYaw)
    self.rotateYawDt = math.min(self.rotateYawDt, 1)
    if not self.dragCamera and self.rotateYawDt == 1 then
      local curCameraName = Cinemachine:getLiveCameraName()
      if not self.isFlyJump and curCameraName ~= "mainCamera" then
        self.resetCameraTimer = World.Timer(skateSetting.delayResetCameraTime, function()
          self:changeCameraType("skateFollow", skateSetting.cameraTime.touchDragExit)
          self.resetCameraTimer = nil
        end)
      end
    end
  end
end

function SkateCamera:createCamera()
  if not self.initCamera then
    for key, cfg in pairs(skateSetting.cinemachineCfg) do
      local cameraData = {
        follow = Me,
        lookAt = Me
      }
      cameraData.body = cfg.body
      cameraData.aim = cfg.aim
      cameraData.avoider = cfg.avoider
      local camera = Cinemachine:createCamera(key, cameraData)
      self.cameraDict[key] = camera
      if key == "skateCameraDrag" then
        local dragCamera2 = Cinemachine:createCamera("skateCameraDrag2", cameraData)
        self.cameraDict.skateCameraDrag2 = dragCamera2
      end
    end
    self.initCamera = true
  else
    for key, cfg in pairs(self.cameraDict) do
      Cinemachine:setFollow(key, Me)
      Cinemachine:setLookAt(key, Me)
    end
  end
  Cinemachine:enable(true)
end

function SkateCamera:setFallDownFlag(val)
  self.isFallDown = val
end

function SkateCamera:setJumpUpCamera(isFlyJump)
  self.isFlyJump = isFlyJump
  if isFlyJump then
    self.fall = false
    if self.resetCameraTimer then
      self.resetCameraTimer()
      self.resetCameraTimer = nil
    end
    self:changeCameraType("skateFly", skateSetting.cameraTime.flyUp)
  end
end

function SkateCamera:setJumpToGroundCamera(isFlyJump)
  if isFlyJump then
    self:changeCameraType("flyDownOnGround", skateSetting.cameraTime.flyOnGround, function()
      if self.dragCamera then
        self:changeCameraType("skateCameraDrag", skateSetting.cameraTime.flyFallOnGroundToDrag)
      else
        self:changeCameraType("skateFollow", skateSetting.cameraTime.flyOnGround)
      end
    end)
  elseif self.dragCamera then
    self:changeCameraType("skateCameraDrag", skateSetting.cameraTime.flyOnGround)
  else
    self:changeCameraType("skateFollow", skateSetting.cameraTime.flyOnGround)
  end
  self.isFlyJump = false
end

function SkateCamera:setJumpDownCamera()
  if self.isFlyJump and SkateControl.motion.y < 0 and not self.fall then
    self.fall = true
    self:changeCameraType("skateFlyDown", skateSetting.cameraTime.flyFallDown)
  end
end

function SkateCamera:setStepOnCamera(rideOnMoveStatue)
  self:changeRotateYaw()
  if rideOnMoveStatue then
    self:changeCameraType("skateStepOn", skateSetting.cameraTime.stepOnSkate, function()
      self:changeCameraType("skateFollow", skateSetting.cameraTime.stepOnSkate)
    end)
  else
    self:changeCameraType("skateFollow", skateSetting.cameraTime.stepOnSkate)
  end
end

function SkateCamera:changeCameraType(targetName, time, cb)
  local curCameraName = Cinemachine:getLiveCameraName()
  if curCameraName == targetName then
    return
  end
  if curCameraName then
    Cinemachine:stateCopy(curCameraName, targetName)
  end
  Cinemachine:blendTo(targetName, time, function(a, b)
    if cb then
      cb()
    end
  end)
end

function SkateCamera:unInit()
  if self.cameraFollowTimer then
    self.cameraFollowTimer()
    self.cameraFollowTimer = nil
  end
  if self.resetCameraTimer then
    self.resetCameraTimer()
    self.resetCameraTimer = nil
  end
  Me.handleCameraTick = nil
  for _, event in pairs(self.eventList) do
    event()
  end
  self.isFollowPlayer = true
  self.eventList = {}
  self.skateEntity = nil
  Cinemachine:enable(false)
end
