local UIEffectFrame = Lib.class("UIEffectFrame", require("script_client.time_line.frame.frame"))

function UIEffectFrame:enter(tick)
  local wnd = UI:getWnd("cutscene")
  wnd:playEffect(self.cfg.effectName)
end

function UIEffectFrame:apply(tick)
end

function UIEffectFrame:onLeave(tick)
  local wnd = UI:getWnd("cutscene")
  wnd:stopEffect()
end

return UIEffectFrame
