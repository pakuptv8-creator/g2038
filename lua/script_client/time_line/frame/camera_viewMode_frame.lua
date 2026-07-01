local CameraViewModeFrame = Lib.class("CameraViewModeFrame", require("script_client.time_line.frame.frame"))

function CameraViewModeFrame:enter(tick)
  Blockman.instance:setPersonView(tonumber(self.cfg.viewMode))
end

function CameraViewModeFrame:apply(tick)
end

function CameraViewModeFrame:onLeave(tick)
end

return CameraViewModeFrame
