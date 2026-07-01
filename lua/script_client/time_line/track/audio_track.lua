local AudioTrack = Lib.class("AudioTrack", require("script_client.time_line.track.track"))

function AudioTrack:getFrameClass(type)
  local frameMap = {
    AudioFrame = require("script_client.time_line.frame.audio_frame")
  }
  return frameMap[type]
end

function AudioTrack:onStart(tick)
  Me.disableGameBgm = true
  Player.CurPlayer:stopGameBgm()
end

function AudioTrack:onUpdate(tick)
end

function AudioTrack:onStop()
  Me.disableGameBgm = false
  Player.CurPlayer:playGameBgm()
end

return AudioTrack
