require("common.entity_guide_helper")
require("common.config.guide_config")
require("common.event_guide_helper")
if World.isClient then
  require("client.gm_guide_helper")
  require("client.player.player_guide_helper")
  require("client.entity.entity_value_func_guide_helper")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(playerInfo)
    if playerInfo.userId == Me.platformUserId then
    end
  end)
  Lib.subscribeEvent(Event.EVENT_OPEN_WINDOW, function(name)
    local guideCfg = World.cfg.guideHelper.guideCfg
    if guideCfg and guideCfg[name] then
      local guideData = Me:getGuideData()
      if not guideData[name] then
        World.Timer(1, function()
          UI:openWnd("dramaGuide", name)
        end)
      end
    end
  end)
else
  require("server.gm_guide_helper")
end
local handlers = {}
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
