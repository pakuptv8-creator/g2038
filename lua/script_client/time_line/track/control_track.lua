local ControlTrack = Lib.class("ControlTrack", require("script_client.time_line.track.track"))

function ControlTrack:getFrameClass(type)
  local frameMap = {
    ControlMoveFrame = require("script_client.time_line.frame.control_move_frame"),
    ControlJumpFrame = require("script_client.time_line.frame.control_jump_frame")
  }
  return frameMap[type]
end

return ControlTrack
