require("common.entity_face_photo")
require("common.event_face_photo")
require("common.config.face_photo_config")
require("common.define_face_photo")
if World.isClient then
  require("client.helper.face_photo_helper")
  require("client.player.player_face_photo")
  require("client.player.packet_face_photo")
  require("client.entity.entity_face_photo")
  require("client.entity.entity_value_func_face_photo")
  require("client.gm_face_photo")
else
  require("server.player.player_face_photo")
  require("server.player.packet_face_photo")
  require("server.entity.entity_face_photo")
  require("server.gm_face_photo")
end
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    local lastLoginTime = entity:getLastLoginTime()
    if lastLoginTime <= 0 then
      entity:setIsWeekFirstLogin(false)
    else
      local nowTime = os.time()
      if Lib.isSameWeek(lastLoginTime, nowTime) then
        entity:setIsWeekFirstLogin(false)
      else
        entity:setIsWeekFirstLogin(true)
      end
    end
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
