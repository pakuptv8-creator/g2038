local CameraTrack = Lib.class("CameraTrack", require("script_client.time_line.track.track"))

function CameraTrack:getFrameClass(type)
  local frameMap = {
    CameraViewModeFrame = require("script_client.time_line.frame.camera_viewMode_frame"),
    CameraViewFrame = require("script_client.time_line.frame.camera_view_frame")
  }
  return frameMap[type]
end

function CameraTrack:onStop()
  if not self.cfg then
    return
  end
  local pos
  if self.cfg.pos then
    local result = Lib.splitString(self.cfg.pos, ",")
    pos = Lib.v3(tonumber(result[1]), tonumber(result[2]), tonumber(result[3]))
  end
  local isReverse = Me:isReverseCamera()
  if isReverse then
    pos = Lib.v3(-pos.x, pos.y, -pos.z)
  end
  Me:changeCameraView(pos, isReverse and self.cfg.yaw + 180 or self.cfg.yaw or 0, self.cfg.pitch or 0, 0, 0)
end

return CameraTrack
