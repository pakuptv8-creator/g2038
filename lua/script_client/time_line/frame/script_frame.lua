local ScriptFrame = Lib.class("ScriptFrame", require("script_client.time_line.frame.frame"))
local PlayableScript = require("script_client.time_line.playable_script")

function ScriptFrame:enter(tick)
  local func = PlayableScript[self.cfg.func]
  if func then
    local success, error = xpcall(func, debug.traceback)
    if not success then
      Lib.logError("ScriptFrame", self.cfg.func, error)
    end
  end
end

function ScriptFrame:apply(tick)
end

function ScriptFrame:onLeave(tick)
end

return ScriptFrame
