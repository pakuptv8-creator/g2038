local SubtitleFrame = Lib.class("SubtitleFrame", require("script_client.time_line.frame.frame"))
local PlayableScript = require("script_client.time_line.playable_script")

function SubtitleFrame:enter(tick)
  Lib.logDebug("SubtitleFrame:enter", self.cfg.content, self.cfg.scriptParam, Lang:getMessage(PlayableScript.param[self.cfg.scriptParam]))
  local wnd = UI:getWnd("cutscene")
  local message = Lang:getMessage(self.cfg.content)
  if self.cfg.scriptParam then
    message = string.format(Lang:getMessage(self.cfg.content), Lang:getMessage(PlayableScript.param[self.cfg.scriptParam]))
  end
  wnd:showSubtitle(message)
end

function SubtitleFrame:apply(tick)
end

function SubtitleFrame:onLeave(tick)
  local wnd = UI:getWnd("cutscene")
  wnd:hideSubtitle()
end

return SubtitleFrame
