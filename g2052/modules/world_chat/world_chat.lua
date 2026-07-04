require("common.entity_world_chat")
require("common.event_world_chat")
require("common.config.chatLang_config")
require("common.define_world_chat")
if World.isClient then
  require("client.world_chat_helper")
  require("client.player.player_world_chat")
  require("client.player.packet_world_chat")
  require("client.entity.entity_world_chat")
  require("client.entity.entity_value_func_world_chat")
  require("client.gm_world_chat")
else
  require("server.entity.entity_world_chat")
  require("server.connector.chat_connector_sender")
  require("server.connector.chat_connector_handler")
  require("server.player.player_world_chat")
  require("server.player.packet_world_chat")
  require("server.gm_world_chat")
end
local handlers = {}
if World.isClient then
  local WorldChatHelper = T(Lib, "WorldChatHelper")
  
  function handlers.updateBlockPlayerMsgState(userId, value)
    WorldChatHelper:updateBlockPlayerList(userId, value)
  end
  
  function handlers.getBlockPlayerMsgState(userId)
    return WorldChatHelper.blockPlayerMsgList[userId]
  end
else
  Plugins.CallTargetPluginFunc("connector", "start")
  local ChatConnectorSender = T(Lib, "ChatConnectorSender")
  
  function handlers.OnPlayerLogin(player)
    ChatConnectorSender:requestJoinChannel(player, player.language)
    ChatConnectorSender:pushClientCacheWorldChatMsg(player)
  end
  
  function handlers.ENTITY_LEAVE(context)
    local player = context.obj1
    if not player.isPlayer then
      return
    end
    ChatConnectorSender:requestLeaveChannel(player)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
