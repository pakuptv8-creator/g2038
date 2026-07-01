local ControlMoveFrame = Lib.class("ControlMoveFrame", require("script_client.time_line.frame.frame"))

function ControlMoveFrame:enter(tick)
  print("ControlMoveFrame:enter")
end

function ControlMoveFrame:apply(tick)
end

function ControlMoveFrame:onLeave(tick)
end

return ControlMoveFrame
