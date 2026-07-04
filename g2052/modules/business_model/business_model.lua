require("common.entity_business_model")
require("common.event_business_model")
require("common.config.privilege_config")
require("common.define_business_model")
require("common.helper.business_helper")
require("common.config.business_goods_config")
if World.isClient then
  require("client.player.player_business_model")
  require("client.player.packet_business_model")
  require("client.entity.entity_business_model")
  require("client.entity.entity_value_func_business_model")
  require("client.gm_business_model")
else
  require("server.player.player_business_model")
  require("server.player.packet_business_model")
  require("server.entity.entity_business_model")
  require("server.entity.entity_value_func_business_model")
  require("server.gm_business_model")
end
local handlers = {}
local BusinessHelper = T(Lib, "BusinessHelper")

function handlers.getPlayerPrivilegeInfo(platformUserId, type)
  return BusinessHelper:getPlayerPrivilegeInfo(platformUserId, type)
end

function handlers.openBuyPrivilegeDialog(player, type)
  if not World.isClient then
    player:sendPacket({
      pid = "openBuyPrivilegeDialog",
      needPrivilege = type
    })
  end
end

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    BusinessHelper:syncAllPlayerPrivilegeInfo(entity)
    local lastLoginTime = entity:getLastLoginTime()
    if lastLoginTime <= 0 then
      entity:setIsDayFirstLogin(true)
    else
      local nowTime = os.time()
      if Lib.isSameDay(lastLoginTime, nowTime) then
        entity:setIsDayFirstLogin(false)
      else
        entity:setIsDayFirstLogin(true)
      end
    end
  else
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
