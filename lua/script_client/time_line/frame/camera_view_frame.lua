local CameraViewFrame = Lib.class("CameraViewFrame", require("script_client.time_line.frame.frame"))
local FrameType = {
  None = 0,
  CasterXOffset = 1,
  TargetXOffset = 2
}

function CameraViewFrame:getCameraXOffset()
  if not self.cfg.cameraMoveType then
    return 0
  end
  local cameraMoveType = tonumber(self.cfg.cameraMoveType)
  if cameraMoveType == FrameType.CasterXOffset then
    if Me.movieCasterBp == 2 or Me.movieCasterBp == 5 or Me.movieCasterBp == 9 or Me.movieCasterBp == 12 then
      return -2
    elseif Me.movieCasterBp == 3 or Me.movieCasterBp == 6 or Me.movieCasterBp == 8 or Me.movieCasterBp == 11 then
      return 2
    end
  elseif cameraMoveType == FrameType.TargetXOffset then
    if Me.movieTargetBp == 2 or Me.movieTargetBp == 5 or Me.movieTargetBp == 9 or Me.movieTargetBp == 12 then
      return -2
    elseif Me.movieTargetBp == 3 or Me.movieTargetBp == 6 or Me.movieTargetBp == 8 or Me.movieTargetBp == 11 then
      return 2
    end
  end
  return 0
end

function CameraViewFrame:enter(tick)
  local pos
  local param = self.track.timeLine.param or {}
  if self.cfg.pos then
    local result = Lib.splitString(self.cfg.pos, ",")
    pos = Lib.v3(tonumber(result[1]), tonumber(result[2]), tonumber(result[3]))
  end
  local isReverse = Me:isReverseCamera()
  if isReverse then
    pos = Lib.v3(-pos.x, pos.y, -pos.z)
  end
  local cameraXOffset = param.cameraXOffset or self:getCameraXOffset()
  local cameraZOffset = param.cameraZOffset or 0
  pos = Lib.v3(pos.x + cameraXOffset, pos.y, pos.z + cameraZOffset)
  local cameraYawOffset = param.cameraYawOffset or 0
  local yaw = self.cfg.yaw + cameraYawOffset
  yaw = tonumber(isReverse and yaw + 180 or yaw)
  Me:changeCameraView(pos, yaw, tonumber(self.cfg.pitch), tonumber(self.cfg.distance), tonumber(self.cfg.smooth))
  if Lib.toBool(self.cfg.debug) then
    Lib.logInfo("CameraViewFrame enter", cameraXOffset, Lib.v2s(pos), self.cfg.yaw, self.cfg.pitch, self.cfg.distance, self.cfg.smooth)
  end
end

function CameraViewFrame:apply(tick)
end

function CameraViewFrame:onLeave(tick)
end

return CameraViewFrame
