local AudioFrame = Lib.class("AudioFrame", require("script_client.time_line.frame.frame"))

function AudioFrame:enter(tick)
  self.soundId = TdAudioEngine.Instance():play2dSound(self.cfg.path, Lib.toBool(self.cfg.loop))
  TdAudioEngine.Instance():setSoundsVolume(self.soundId, self.cfg.volume or 1)
end

function AudioFrame:apply(tick)
end

function AudioFrame:onLeave(tick)
  TdAudioEngine.Instance():stopSound(self.soundId)
end

return AudioFrame
