local UITrack = Lib.class("UITrack", require("script_client.time_line.track.track"))

function UITrack:getFrameClass(type)
  local frameMap = {
    UIEffectFrame = require("script_client.time_line.frame.uieffect_frame"),
    SubtitleFrame = require("script_client.time_line.frame.subtitle_frame")
  }
  return frameMap[type]
end

function UITrack:onStart(tick)
  UI:openWnd("cutscene")
  self.showFunc = UI:hideOpenedWnd("cutscene")
end

function UITrack:onUpdate(tick)
end

function UITrack:onStop()
  UI:closeWnd("cutscene")
  if self.showFunc then
    self.showFunc()
  end
end

return UITrack
