local GuideConfig = T(Config, "GuideConfig")
local Player = _ENV.Player

local function fun(uiName, ...)
  UI:openWnd(uiName, ...)
end

function Player:openGuideUI(uiName, ...)
  local cfg = GuideConfig:getAllCfgs()
  local guideInfo = Me:getGuideInfo()
  Lib.emitEvent(Event.EVENT_TRIGGER_GUIDE_OPERATION, false)
  if cfg[uiName] then
    UI:closeWnd("g2052Guide")
    local active = self:getPlayerActive()
    if active.activeType and active.activeType > 1 and not cfg[uiName].newModule then
      fun(uiName, ...)
      self:addGuideInfo(uiName)
      return
    end
    if not guideInfo[uiName] then
      UI:openWnd("g2052Guide", uiName, fun, ...)
      self:addGuideInfo(uiName)
    else
      fun(uiName, ...)
    end
  else
    fun(uiName, ...)
  end
end
