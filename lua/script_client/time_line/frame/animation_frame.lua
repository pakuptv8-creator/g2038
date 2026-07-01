local AnimationFrame = Lib.class("AnimationFrame", require("script_client.time_line.frame.frame"))

function AnimationFrame:enter(tick)
  Me:updateUpperAction(self.cfg.animationName, -1)
end

function AnimationFrame:apply(tick)
end

function AnimationFrame:onLeave(tick)
  Me:updateUpperAction("", 0)
end

return AnimationFrame
