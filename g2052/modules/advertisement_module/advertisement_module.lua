require("common.entity_advertisement_module")
require("common.event_advertisement_module")
require("common.define_advertisement_module")
require("common.config.advertisement_pool_config")
require("common.config.advertisement_scene_part_config")
require("common.config.advertisement_scene_point_config")
if World.isClient then
  require("client.player.player_advertisement_module")
  require("client.player.packet_advertisement_module")
  require("client.entity.entity_advertisement_module")
  require("client.entity.entity_value_func_advertisement_module")
  require("client.gm_advertisement_module")
else
  require("server.player.player_advertisement_module")
  require("server.player.packet_advertisement_module")
  require("server.entity.entity_advertisement_module")
  require("server.gm_advertisement_module")
end
require("common.helper.advertisement_module_helper")
local AdvertisementModuleHelper = T(Lib, "AdvertisementModuleHelper")
local handlers = {}

function handlers.openAdvertisementMain(check)
  AdvertisementModuleHelper:openAdvertisementMain(check)
end

function handlers.getFreeItemCount(player, itemType, itemId)
  return AdvertisementModuleHelper:getFreeItemCount(player, itemType, itemId)
end

function handlers.costFreeItem(player, itemType, itemId)
  AdvertisementModuleHelper:costFreeItem(player, itemType, itemId)
end

function handlers.onWatchAdResult(context, type, success, params)
  if World.isClient then
    return
  end
  local entity = context.obj1
  if not (entity and entity.isValid) or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    if type == Define.AdvertisingType.AdvertisementDraw then
      if success then
        AdvertisementModuleHelper:doDrawReward(entity)
      else
        entity:sendPacket({
          pid = Define.ADVERTISEMENT_PID.Draw,
          objID = entity.objID,
          state_code = -1
        })
      end
    elseif type == Define.AdvertisingType.AdvertisementLockSlot then
      if success then
        local paramList = Lib.splitString(params, "|", true)
        local lockSlot = paramList[1]
        local lockId = paramList[2]
        AdvertisementModuleHelper:doLockSlot(lockSlot, lockId, entity)
      else
        entity:sendPacket({
          pid = Define.ADVERTISEMENT_PID.LockSlot,
          objID = entity.objID,
          state_code = -1
        })
      end
    elseif type == Define.AdvertisingType.AdvertisementScene then
      local partId = tonumber(params)
      if success then
        AdvertisementModuleHelper:doOnSceneAdvertisemenetClick(partId, entity)
      else
        entity:sendPacket({
          pid = Define.ADVERTISEMENT_PID.SceneClick,
          objID = entity.objID,
          state_code = -1,
          part_id = partId
        })
      end
    end
  end
end

if World.isClient then
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    AdvertisementModuleHelper:onPlayerLogin(info)
  end)
else
  function handlers.OnPlayerLogin(player)
    AdvertisementModuleHelper:onPlayerLogin(player)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
