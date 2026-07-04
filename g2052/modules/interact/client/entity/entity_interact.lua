local VehicleVirtualCamera = T(Lib, "VehicleVirtualCamera")
local Entity = _ENV.Entity

function Entity:openTelescopeLikeCameraMode(fovAngle, forbidFovAngleOp, view, firstViewActor)
  if self.telescopeCacheInfo then
    return
  end
  forbidFovAngleOp = forbidFovAngleOp or true
  self.telescopeCacheInfo = {forbidFovAngleOp = forbidFovAngleOp}
  local cacheFovAngel = Blockman.instance:getViewFovAngle()
  VehicleVirtualCamera:pause()
  Blockman.instance.gameSettings:setHideSelf(true)
  if fovAngle ~= nil then
    self.telescopeCacheInfo.fovAngle = cacheFovAngel
    Blockman.instance:setViewFovAngle(fovAngle)
  end
  if forbidFovAngleOp then
  end
end

function Entity:closeTelescopeLikeCameraMode()
  if not self.telescopeCacheInfo then
    return
  end
  Blockman.instance.gameSettings:setHideSelf(false)
  VehicleVirtualCamera:recover()
  if self.telescopeCacheInfo.fovAngle then
    print(" -- telescopeCacheInfo.fovAngle =" .. tostring(self.telescopeCacheInfo.fovAngle))
    Blockman.instance:setViewFovAngle(self.telescopeCacheInfo.fovAngle)
  end
  if self.telescopeCacheInfo.forbidFovAngleOp == true then
  end
  self.telescopeCacheInfo = nil
end
