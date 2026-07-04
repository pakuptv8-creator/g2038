require("common.entity.entity_props_center")
require("common.event_props_center")
require("common.props_center_define")
require("common.config.gen_buff_file_helper")
require("common.config.props_config")
require("common.config.props_attr_config")
if World.isClient then
  require("client.gm_props_center")
  require("client.entity.entity_props_center")
  require("client.entity.entity_value_func_props_center")
  require("client.player.player_hand_item")
  require("client.player.packet_props_center")
  require("client.player.player_props_center")
  require("client.billboard_helper")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.objID ~= Me.objID then
      return
    end
    Me:loadNewPropsScanRecord()
    Me:updatePropsRedDotStatus()
  end)
else
  require("server.entity.entity_skill_props_center")
  require("server.trigger_handlers_props_center")
  require("server.player.player_hand_item")
  require("server.player.packet_props_center")
  require("server.gm_props_center")
  require("server.player.player_props_center")
end
local handlers = {}

function handlers.ENTITY_LEAVE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    if entity:getInUseProp() then
      Plugins.CallTargetPluginFunc("report", "report", "item_use", nil, entity)
    end
    entity:cancelThrowProp()
  end
end

function handlers.SKILL_CAST_FINISH(context)
  local entity = context and context.obj1
  if not entity or entity.isPlayer then
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
