local FlightVehicleControl = T(Lib, "FlightVehicleControl")
local bm = Blockman.Instance()
local carResetRotationTime = World.cfg.vehicleSetting.carResetRotationTime or 20
local carSlowDownTime = World.cfg.vehicleSetting.carSlowDownTime or 30
local weightlessnessUsesGears = World.cfg.vehicleSetting.weightlessnessUsesGears or 5

function FlightVehicleControl:init(car, cfg)
  if not car and not car:isValid() then
    return
  end
  self.curCar = car
  self.motion = Vector3.new(0, 0, 0)
  self.cfg = cfg
  self.curMoveSpeed = 30
  if self.cfg and self.cfg.speedMax then
    self.curMoveSpeed = self.cfg.speedMax[weightlessnessUsesGears] or self.cfg.speedMax[#self.cfg.speedMax]
  end
  self.inSlowDown = nil
  Me.inFlightVehicleControl = true
end

function FlightVehicleControl:setControl(poleForward, poleStrafe, vAxisValue, hAxisValue)
  if not self.curCar or not self.curCar:isValid() then
    self:stop()
    return
  end
  local mainCamera = CameraManager.Instance():findCamera("mainCamera")
  local rotation = self.curCar:getRotation()
  local forward = vAxisValue + poleForward
  local left = hAxisValue + poleStrafe
  local yawOffset = 90 * left
  local dir = Lib.v3(left, 0, forward)
  local yaw = bm:viewerRenderYaw()
  dir = Lib.posAroundYaw(dir, yaw)
  local motionCal = dir:normalize() * self.curMoveSpeed
  self.motion.z = motionCal.z
  self.motion.x = motionCal.x
  self.motion.y = motionCal.y
  if mainCamera and self.motion:len() ~= 0 then
    local direction = mainCamera:getDirection()
    local symbol = 1
    if forward ~= 0 then
      direction = direction * forward
      if forward < 0 then
        symbol = -1
      end
    end
    self.motion.y = direction.y * self.curMoveSpeed
    local q = Quaternion.fromVectorRotation(Lib.v3(0, 0, 1), direction)
    local x, y = q:toEulerAngle()
    self.curCar:setRotation(Lib.v3(x, y + yawOffset * symbol, 0))
    self.resetVelocityCount = (self.resetVelocityCount or 0) + 1
    if self.resetVelocityCount == carResetRotationTime then
      self.curCar:setAngleVelocity(Lib.v3(0, 0, 0))
      self.curCar:setLineVelocity(Lib.v3(0, 0, 0))
    end
  else
    self.resetVelocityCount = 0
  end
  if self.motion:len() ~= 0 then
    self.curCar:setLineVelocity(Lib.v3(self.motion.x, self.motion.y, self.motion.z))
    self.inSlowDown = nil
  else
    local curLineVelocity = self.curCar:getCurLineVelocity()
    if self.inSlowDown then
      if self.inSlowDown >= carSlowDownTime then
        self.curCar:setLineVelocity(Lib.v3(0, 0, 0))
      else
        if self.slowDownLineVelocity then
          self.curCar:setLineVelocity(curLineVelocity - self.slowDownLineVelocity)
        end
        self.inSlowDown = self.inSlowDown + 1
      end
    elseif curLineVelocity:len() ~= 0 then
      self.slowDownLineVelocity = curLineVelocity / carSlowDownTime
      self.inSlowDown = 0
    end
  end
end

function FlightVehicleControl:stop()
  self.curCar = nil
  self.cfg = nil
  Me.inFlightVehicleControl = nil
end

return FlightVehicleControl
