require("common.entity_skate")
require("common.event_skate")
require("common.config.skate_config")
require("common.define_skate")
if World.isClient then
  require("client.player_status.status_controller")
  require("client.skate_ray_test")
  require("client.skate_anim_mgr")
  require("client.skate_control")
  require("client.skate_mgr")
  require("client.skate_map_object")
  require("client.player.player_skate")
  require("client.player.packet_skate")
  require("client.entity.entity_skate")
  require("client.entity.entity_value_func_skate")
  require("client.gm_skate")
else
  require("server.player.player_skate")
  require("server.player.packet_skate")
  require("server.entity.entity_skate")
  require("server.gm_skate")
end
local SkateMgr = T(Lib, "SkateMgr")
local SkateCamera = T(Lib, "SkateCamera")
local handlers = {}

function handlers.ENTER_SKATE_MODE(skateObjID, isMoving)
  SkateMgr:enterSkateMode(skateObjID, isMoving)
end

function handlers.LEAVE_SKATE_MODE()
  SkateMgr:leaveSkateMode()
end

function handlers.IS_SKATE_MODE()
  return SkateMgr:isSkateMode()
end

function handlers.IS_SKATE_ON_GROUND()
  return SkateMgr:isSkateOnGround()
end

function handlers.IS_CAN_LEAVE_SKATE_MODE()
  return SkateMgr:isCanLeaveSkateMode()
end

function handlers.DRAG_CAMERA_ROTATE_BEGIN()
  return SkateCamera:dragCameraRotateBegin()
end

function handlers.DRAG_CAMERA_ROTATE_END()
  return SkateCamera:dragCameraRotateEnd()
end

function handlers.IS_SKATE_ENTITY(id)
  local SkateConfig = T(Config, "SkateConfig")
  return SkateConfig:getCfgById(id) ~= nil
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
