require("common.config.house_config")
require("common.event_house_center")
require("common.define_house_center")
require("common.config.monitor_config")
require("common.config.houseBgm_config")
require("common.entity.entity_house_center")
require("common.config.disaster_config")
if World.isClient then
  require("client.player.packet_house_center")
  require("client.gm_house_center")
  require("client.player.player_house_center")
  require("client.monitor_helper")
  require("client.entity.entity_value_func_house_center")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.objID ~= Me.objID then
      return
    end
    Me:loadNewHouseRecord()
    Me:updateHouseRedDotStatus()
  end)
else
  Lib.declare("HouseManager", {})
  require("server.player.player_house_center")
  require("server.house_manager")
  require("server.player.packet_house_center")
  require("server.entity.entity_value_func_house_center")
  require("server.gm_house_center")
  HouseManager:init()
end
local handlers = {}

function handlers.OnPlayerLogin(player)
  if not World.isClient then
    local flag = player:getAllHouseFlag()
    if flag == -1 then
      player:updateAllHouseFlag()
    end
  end
end

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    HouseManager:syncLocationInfo(entity.platformUserId)
  else
  end
end

function handlers.ENTITY_LEAVE(context)
  local player = context.obj1
  if not player.isPlayer then
    return
  end
  player:removeFromMonitorUsingRecord()
  HouseManager:updateHouseCd(player.platformUserId, nil)
  player:clearHouseGhostTimer()
  player:clearHouseEarthquakeTimer()
  HouseManager:removePlayerInGhostDetectorArea(player)
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
