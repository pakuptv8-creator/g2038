local CarConfig = T(Config, "CarConfig")
local Cinemachine = T(Lib, "LuaCinemachine")
local CAMERA_CONFIG = {
  vehicleFollow = {
    body = {
      type = "FocusRound",
      offset = {
        0,
        3,
        0
      },
      distance = 13
    },
    aim = {
      type = "SameAsFollowTarget",
      damping = World.cfg.vehicleAimDamping,
      maxDampingDegree = World.cfg.maxDampingDegree
    },
    avoider = {type = "ZoomIn"}
  },
  vehicleDrag = {
    body = {
      type = "FocusRound",
      localspace = true,
      offset = {
        0,
        3,
        0
      },
      distance = 13,
      distanceRange = {13, 13}
    },
    aim = {
      type = "POV",
      verticalRange = {-3, 90}
    },
    avoider = {type = "ZoomIn"}
  },
  vehicleSideFollow = {
    body = {
      type = "HardLockToTarget",
      localspace = true,
      offset = {
        0,
        0,
        0
      },
      damping = World.cfg.vehicleAimDamping
    },
    aim = {
      type = "HardLookAt",
      offset = {
        0,
        3,
        0
      }
    },
    avoider = {type = "ZoomIn"}
  }
}
local VehicleVirtualCamera = T(Lib, "VehicleVirtualCamera")

function VehicleVirtualCamera:init(vehicleInst)
  if not World.cfg.openVehicleCamera then
    return
  end
  if self._hasInit then
    return
  end
  for name, cfg in pairs(CAMERA_CONFIG) do
    Cinemachine:createCamera(name, cfg)
    Cinemachine:setFollow(name, vehicleInst)
    Cinemachine:setLookAt(name, vehicleInst)
  end
  Cinemachine:enable(false)
  self._hasInit = true
  self._isActive = false
  self.resetCameraCountDown = 0
  self.blending = {}
end

function VehicleVirtualCamera:activateVehicleCamera(instanceID)
  if not World.cfg.openVehicleCamera then
    return
  end
  local vehicleInst = Instance.getByInstanceId(instanceID)
  if not vehicleInst or not vehicleInst:isValid() then
    return
  end
  self.blending = {}
  if not self._hasInit then
    self:init(vehicleInst)
  end
  self._followInstanceID = instanceID
  local name = vehicleInst:getProperty("name")
  local cfg = CarConfig:getCfgByName("myplugin/" .. name) or {}
  self:updateCameraConfig(cfg)
  Cinemachine:enable(true)
  for name, _ in pairs(CAMERA_CONFIG) do
    Cinemachine:setFollow(name, vehicleInst)
    Cinemachine:setLookAt(name, vehicleInst)
  end
  Cinemachine:blendTo("vehicleFollow", 0, function()
    client_event("changeCameraDistance", self._followDistance)
  end)
  self._touchBeginCall = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function(x, y)
    if not Me.disableControl then
      self._touchBegin = true
    end
  end)
  self._touchMoveCall = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_MOVE, function(x, y, preX, preY)
    if not self._touchBegin or Me.disableControl then
      return
    end
    self:deleteMoveCheckTick()
    if self._delayToFollow then
      self._delayToFollow()
      self._delayToFollow = nil
    end
    if self._touchEndDelay then
      self._touchEndDelay()
      self._touchEndDelay = nil
    end
    local curCameraName = Cinemachine:getLiveCameraName()
    self:changeCameraType("vehicleDrag", 0, curCameraName)
    self:beginStopMoveTick(x, y)
  end)
  self._touchEndCall = Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_END, function(x, y, preX, preY)
    if not self._touchBegin or Me.disableControl then
      return
    end
    if self.stopMoveCheckTimer then
      self.stopMoveCheckTimer()
      self.stopMoveCheckTimer = nil
    end
    local isMoving = false
    if self._followInstanceID then
      local vehicleInst = Instance.getByInstanceId(self._followInstanceID)
      if vehicleInst and vehicleInst:isValid() then
        local moveDir = vehicleInst:getMountEntityTryMoveDir()
        if moveDir.x ~= 0 or moveDir.z ~= 0 then
          isMoving = true
        end
      end
    end
    if isMoving then
      if self._touchEndDelay then
        self._touchEndDelay()
        self._touchEndDelay = nil
      end
      local followDelay = World.cfg.vehicleFollowBackDelay
      local transition = 1
      if self._isFirstPersonViewMode then
        followDelay = 0
      end
      self._touchEndDelay = World.Timer(followDelay, function()
        local curCameraName = Cinemachine:getLiveCameraName()
        self:changeCameraType("vehicleFollow", transition, curCameraName)
        self._touchEndDelay = nil
      end)
    else
      self:beginMoveCheckTick()
    end
    self._touchBegin = nil
  end)
  self._fpvChangedCall = Lib.subscribeEvent(Event.EVENT_FAKE_FPV_CHANGED, function(isFirstPersonViewMode)
    local curCameraName = Cinemachine:getLiveCameraName()
    local virtual_cam = Cinemachine:getCamera("vehicleFollow")
    if virtual_cam then
      local damping = isFirstPersonViewMode and 0 or World.cfg.vehicleAimDamping
      self._followAimInit.damping = damping
      virtual_cam:setAim(self._followAimInit)
    end
    self._isFirstPersonViewMode = isFirstPersonViewMode
    if isFirstPersonViewMode then
      self:changeCameraType("vehicleFollow", 0.5, curCameraName)
    end
  end)
  self._isActive = true
  if UI:isOpen("cameraSwitch") then
    self:pause()
  end
end

function VehicleVirtualCamera:updateCameraConfig(carCfg)
  local curDistance = Blockman.instance:viewerRenderDistance()
  local followDistance = curDistance <= carCfg.cameraFollowDis and carCfg.cameraFollowDis or curDistance
  self._followDistance = followDistance
  local cameraDisMin = carCfg.cameraFollowDis - 2
  if World.cfg.fakeFirstPersonViewMode and World.cfg.fakeFirstPersonViewMode.distance then
    cameraDisMin = World.cfg.fakeFirstPersonViewMode.distance - 0.05
  end
  self._minFollowDistance = cameraDisMin
  local virtual_cam = Cinemachine:getCamera("vehicleFollow")
  if virtual_cam then
    self._followBodyInit = {
      type = "FocusRound",
      offset = {
        carCfg.cameraFollowOffset[1] or 0,
        carCfg.cameraFollowOffset[2] or 0,
        carCfg.cameraFollowOffset[3] or 0
      },
      distance = followDistance,
      distanceRange = {
        cameraDisMin,
        World.cfg.cameraDistanceMax
      }
    }
    virtual_cam:setBody(self._followBodyInit)
    self._followAimInit = {
      type = "SameAsFollowTarget",
      damping = World.cfg.vehicleAimDamping,
      maxDampingDegree = World.cfg.maxDampingDegree,
      offsetAngles = {
        carCfg.cameraFollowPitch[1] or 0,
        carCfg.cameraFollowPitch[2] or 0,
        carCfg.cameraFollowPitch[3] or 0
      }
    }
    virtual_cam:setAim(self._followAimInit)
  end
  local virtual_cam_drag = Cinemachine:getCamera("vehicleDrag")
  if virtual_cam_drag then
    self._dragBodyInit = {
      type = "FocusRound",
      localspace = true,
      offset = {
        carCfg.cameraFollowOffset[1] or 0,
        carCfg.cameraFollowOffset[2] or 0,
        carCfg.cameraFollowOffset[3] or 0
      },
      distance = followDistance,
      distanceRange = {
        cameraDisMin,
        World.cfg.cameraDistanceMax
      }
    }
    virtual_cam_drag:setBody(self._dragBodyInit)
  end
  local virtual_cam_drag = Cinemachine:getCamera("vehicleSideFollow")
  if virtual_cam_drag then
    virtual_cam_drag:setAim({
      type = "HardLookAt",
      offset = {
        carCfg.cameraFollowOffset[1] or 0,
        carCfg.cameraFollowOffset[2] or 0,
        carCfg.cameraFollowOffset[3] or 0
      }
    })
  end
end

function VehicleVirtualCamera:changeCameraType(targetName, time, fromCamera)
  local curCameraName = Cinemachine:getLiveCameraName()
  if curCameraName == targetName then
    return
  end
  if self._targetNameDelay and self._targetNameDelay == targetName then
    return
  end
  if self.blending[fromCamera] == targetName then
    return
  end
  self.blending[fromCamera] = targetName
  local isResetBody = false
  local curDistance = Blockman.instance:viewerRenderDistance()
  if targetName == "vehicleDrag" or targetName == "vehicleFollow" then
    local tab = Lib.copyTable1(targetName == "vehicleFollow" and self._followBodyInit or self._dragBodyInit)
    if curDistance < self._minFollowDistance then
      curDistance = self._minFollowDistance
    end
    tab.distance = curDistance
    local virtual_cam = Cinemachine:getCamera(targetName)
    if virtual_cam then
      virtual_cam:setBody(tab)
      self._followDistance = curDistance
    end
    isResetBody = true
  end
  
  local function doChange()
    if fromCamera then
      Cinemachine:stateCopy(fromCamera, targetName)
    end
    Cinemachine:blendTo(targetName, time, function()
      self.blending[fromCamera] = nil
    end)
    self._targetNameDelay = nil
    Lib.logDebug("changeCameraType: ", curCameraName, fromCamera, targetName, time)
  end
  
  if isResetBody then
    self._targetNameDelay = targetName
    World.Timer(2, function()
      doChange()
    end)
  else
    doChange()
  end
  return true
end

function VehicleVirtualCamera:deactivateVehicleCamera(isPause)
  if not World.cfg.openVehicleCamera then
    return
  end
  Cinemachine:enable(false)
  if not isPause then
    self._followInstanceID = nil
  end
  if self._touchBeginCall then
    self._touchBeginCall()
    self._touchBeginCall = nil
  end
  if self._touchMoveCall then
    self._touchMoveCall()
    self._touchMoveCall = nil
  end
  if self._touchEndCall then
    self._touchEndCall()
    self._touchEndCall = nil
  end
  if self._fpvChangedCall then
    self._fpvChangedCall()
    self._fpvChangedCall = nil
  end
  self:deleteMoveCheckTick()
  self._isActive = false
  self._isFirstPersonViewMode = nil
end

function VehicleVirtualCamera:beginMoveCheckTick()
  self:deleteMoveCheckTick()
  self.moveCheckTimer = World.Timer(1, function()
    if self._followInstanceID then
      local vehicleInst = Instance.getByInstanceId(self._followInstanceID)
      if vehicleInst and vehicleInst:isValid() then
        local moveDir = vehicleInst:getMountEntityTryMoveDir()
        if moveDir.x == 0 and moveDir.z == 0 then
          self.resetCameraCountDown = 0
        else
          local followDelay = World.cfg.vehicleFollowBackDelay
          self.resetCameraCountDown = self.resetCameraCountDown + 1
          local transition = 1
          if self._isFirstPersonViewMode == true then
            followDelay = 0
          end
          if followDelay <= self.resetCameraCountDown then
            local curCameraName = Cinemachine:getLiveCameraName()
            self:changeCameraType("vehicleFollow", transition, curCameraName)
            return
          end
        end
        return true
      end
    end
  end)
end

function VehicleVirtualCamera:deleteMoveCheckTick()
  if self.moveCheckTimer then
    self.moveCheckTimer()
    self.moveCheckTimer = nil
  end
end

function VehicleVirtualCamera:beginStopMoveTick(x, y)
  if self.stopMoveCheckTimer then
    self.stopMoveCheckTimer()
    self.stopMoveCheckTimer = nil
  end
  self.stopMoveCheckTimer = World.Timer(10, function()
    local isMoving = false
    local vehicleInst
    if self._followInstanceID then
      vehicleInst = Instance.getByInstanceId(self._followInstanceID)
      if vehicleInst and vehicleInst:isValid() then
        local moveDir = vehicleInst:getMountEntityTryMoveDir()
        if moveDir.x ~= 0 or moveDir.z ~= 0 then
          isMoving = true
        end
      end
    end
    if isMoving then
      local camera = CameraManager.Instance():getMainCamera()
      local pos_camera = camera:getPosition()
      local pos_vehicle = vehicleInst:getPosition()
      local rot_vehicle = vehicleInst:getWorldQuaternion()
      local virtual_cam = Cinemachine:getCamera("vehicleSideFollow")
      if virtual_cam then
        virtual_cam:setBody({
          type = "HardLockToTarget",
          localspace = true,
          offset = rot_vehicle:conjugated() * (pos_camera - pos_vehicle),
          damping = 0
        })
      end
      local curCameraName = Cinemachine:getLiveCameraName()
      self:changeCameraType("vehicleSideFollow", 0, curCameraName)
      print("change to vehicleSideFollow--------------------------")
    end
  end)
end

function VehicleVirtualCamera:isActive()
  if not World.cfg.openVehicleCamera then
    return
  end
  return self._isActive
end

function VehicleVirtualCamera:pause()
  if not World.cfg.openVehicleCamera then
    return
  end
  if not self._isActive then
    return
  end
  self:deactivateVehicleCamera(true)
end

function VehicleVirtualCamera:recover()
  if not World.cfg.openVehicleCamera then
    return
  end
  if self._isActive == nil or self._isActive == true then
    return
  end
  if not self._followInstanceID then
    return
  end
  self:activateVehicleCamera(self._followInstanceID)
end

return VehicleVirtualCamera
