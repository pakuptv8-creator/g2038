local cm = CameraManager:Instance()
local MONITOR_CAMERA_NAME = "monitorCamera"
local MonitorHelper = T(Lib, "MonitorHelper")

function MonitorHelper:init(cam)
  local mainCamera = cm:getMainCamera()
  if not mainCamera then
    return
  end
  cam:setPosition(mainCamera:getPosition())
  cam:setDirection(mainCamera:getDirection())
  cam:setUp(mainCamera:getUp())
  cam:setFov(mainCamera:getFov())
  cam:setWidth(mainCamera:getWidth())
  cam:setHeight(mainCamera:getHeight())
  cam:setNearClip(mainCamera:getNearClip())
  cam:setFarClip(mainCamera:getFarClip())
end

function MonitorHelper:activate(cameraPos, targetPos, direction)
  if not cameraPos then
    return
  end
  local monitorCamera = Me:getSecondCamera()
  if not self.hasInit then
    self:init(monitorCamera)
    self.hasInit = true
  end
  monitorCamera:setActive()
  monitorCamera:setPosition(Lib.tov3(cameraPos))
  if targetPos then
    monitorCamera:setTarget(Lib.tov3(targetPos))
    Lib.logDebug("direction monitor ", Lib.v2s(monitorCamera:getDirection()))
    Lib.logDebug("up monitor ", Lib.v2s(monitorCamera:getUp()))
  elseif direction then
    monitorCamera:setDirection(Lib.tov3(direction))
  end
  monitorCamera:setUp(Lib.v3(0, 1, 0))
  Me.disableControl = true
  monitorCamera:setFov(1.22)
end

function MonitorHelper:deactivate()
  local camera = cm:getMainCamera()
  if camera then
    camera:setActive()
    Me.disableControl = false
  end
end

return MonitorHelper
