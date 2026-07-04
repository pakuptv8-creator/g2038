require("common.entity_halloween")
require("common.event_halloween")
require("common.define_halloween")
require("common.halloween_helper_common")
require("common.config.halloween_exchange_config")
require("common.config.halloween_ghost_config")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
if World.isClient then
  require("client.halloween_helper_client")
  require("client.player.player_halloween")
  require("client.player.packet_halloween")
  require("client.entity.entity_halloween")
  require("client.entity.entity_value_func_halloween")
  require("client.halloween_ui_helper")
  require("client.halloween_ui_manager")
  require("client.gm_halloween")
else
  require("server.halloween_part_helper")
  require("server.player.player_halloween")
  require("server.player.packet_halloween")
  require("server.entity.entity_halloween")
  require("server.gm_halloween")
end
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    local packet = {
      pid = "setHalloweenDayS2C",
      isOpen = HalloweenHelperCommon:isHalloweenDay()
    }
    entity:sendPacket(packet)
  end
end

function handlers.OnPlayerLogin(player)
  player:checkClearCandyDayCount()
  player:checkClearHalloweenCandyDayPlayer()
end

function handlers.isDuringHalloweenPeriod()
  return HalloweenHelperCommon:isHalloweenDay()
end

if World.isClient then
  function handlers.doShareCandyToOthers(targetID)
    local isShowCandy = HalloweenHelperCommon:isHalloweenDay()
    
    if not isShowCandy then
      return
    end
    local packet = {
      pid = "CSShareCandyToOthers",
      targetID = targetID
    }
    Me:sendPacket(packet)
  end
  
  function handlers.doAcceptCandyToOthers(targetID)
    local isShowCandy = HalloweenHelperCommon:isHalloweenDay()
    if not isShowCandy then
      return
    end
    local packet = {
      pid = "CSAskForCandyFromOthers",
      targetID = targetID
    }
    Me:sendPacket(packet)
  end
else
  local HalloweenPartHelper = T(Lib, "HalloweenPartHelper")
  
  function handlers.ENTER_MAP(info)
    if info.obj1.isPlayer then
      World.Timer(40, function()
        if not info.obj1 or not info.obj1:isValid() then
          return
        end
        HalloweenPartHelper:pushClientHalloweenUIInfo(info.map.name, info.obj1)
      end)
    end
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
