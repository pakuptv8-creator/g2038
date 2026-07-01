local PlayableTrack = Lib.class("PlayableTrack", require("script_client.time_line.track.track"))

function PlayableTrack:getFrameClass(type)
  local frameMap = {
    ScriptFrame = require("script_client.time_line.frame.script_frame")
  }
  return frameMap[type]
end

return PlayableTrack
