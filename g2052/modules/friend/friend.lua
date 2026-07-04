require("common.entity_friend")
require("common.event_friend")
require("common.define_friend")
if World.isClient then
  require("client.player.player_friend")
  require("client.player.packet_friend")
  require("client.entity.entity_friend")
  require("client.entity.entity_value_func_friend")
  require("client.gate_friend")
  require("client.gm_friend")
  Lib.subscribeEvent(Event.EVENT_PLAYER_BEGIN, function()
    FriendManager.LoadFriendData(true)
  end)
  Lib.subscribeEvent(Event.EVENT_PLAYER_STATUS, function(status, uId, uName)
    if uId == Me.platformUserId and not Me.loadDef then
      Me.loadDef = true
      Me:tryInitFriends()
    end
  end)
  Lib.subscribeEvent(Event.EVENT_FINISH_LOAD_FRIEND_DATA, function()
    if not Me.loadFriends then
      Me.loadFriends = true
      Me:tryInitFriends()
    end
  end)
else
  require("server.player.player_friend")
  require("server.player.packet_friend")
  require("server.entity.entity_friend")
  require("server.gate_friend")
  require("server.gm_friend")
end
local handlers = {}

function handlers.openCloseFriendWnd(isShow)
  UI:getWnd("friend"):onShow(isShow)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
