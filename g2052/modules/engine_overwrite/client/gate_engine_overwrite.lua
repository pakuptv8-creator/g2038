local main = {}
local tickEngineHandler = L("tickEngineHandler", handle_tick)

function handle_tick(frameTime)
  tickEngineHandler(frameTime)
  Lib.emitEvent(Event.EVENT_CLIENT_HANDLE_TICK)
end

function main:init()
  self:initLog()
  self:setGlobalProperty()
  CGame.instance:toggleDebugMessageShown(false)
  self:initGlobalEvent()
  GlobalProperty.Instance():setFloatProperty("MaxYMotion", World.cfg.maxYMotion or -2.0)
end

function main:setGlobalProperty()
  GlobalProperty.Instance():setBoolProperty("DebugSound", false)
  GlobalProperty.Instance():setBoolProperty("DisableCheckBlockTouch", true)
end

function main:initLog()
  Lib.setDebugLog(CGame.Instance():isDebuging())
end

function main:initGlobalEvent()
  Lib.subscribeKeyDownEvent("key.pull", function()
    if Me and Me.isValid and Me:isValid() and Me.getPosition then
      local pos = Me:getPosition()
      local str = string.format("%.2f,%.2f,%.2f,%.2f", pos.x, pos.y, pos.z, Blockman.instance:viewerRenderYaw())
      PlatformUtil.copyToClipboard(str, string.len(str))
      print("PlatformUtil.copyToClipboard " .. str)
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_PAUSE", Event.EVENT_GAME_PAUSE, function()
    TdAudioEngine.Instance():allMute(true)
  end)
  Lib.lightSubscribeEvent("error!!!!! : win_main lib event : EVENT_GAME_RESUME", Event.EVENT_GAME_RESUME, function()
    TdAudioEngine.Instance():allMute(false)
  end)
end

main:init()
