local AnimationTrack = Lib.class("AnimationTrack", require("script_client.time_line.track.track"))

function AnimationTrack:getFrameClass(type)
  local frameMap = {
    AnimationFrame = require("script_client.time_line.frame.animation_frame"),
    MoveFrame = require("script_client.time_line.frame.move_frame")
  }
  return frameMap[type]
end

function AnimationTrack:onStart(tick)
end

function AnimationTrack:onUpdate(tick)
end

function AnimationTrack:onStop()
end

return AnimationTrack
