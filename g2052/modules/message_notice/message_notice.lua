require("common.entity_message_notice")
require("common.event_message_notice")
require("common.config.message_config")
require("common.define_message_notice")
if World.isClient then
  require("client.player.player_message_notice")
  require("client.player.packet_message_notice")
  require("client.entity.entity_message_notice")
  require("client.entity.entity_value_func_message_notice")
  require("client.gm_message_notice")
else
  require("server.player.player_message_notice")
  require("server.player.packet_message_notice")
  require("server.entity.entity_message_notice")
  require("server.gm_message_notice")
  require("server.message_notice_manager")
end
local handlers = {}

function handlers.onPlayerLogout(player)
  if player and player:isValid() then
    local MessageNoticeManager = T(Lib, "MessageNoticeManager")
    MessageNoticeManager:clearMessageNotice(player.platformUserId)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
