require("common.entity_interaction_ui")
require("common.event_interaction_ui")
require("common.define_interaction_ui")
require("common.config.playerInteractive_config")
require("common.config.dance_config")
if World.isClient then
  require("client.player.player_interaction_ui")
  require("client.player.packet_interaction_ui")
  require("client.player.player_interaction_event")
  require("client.entity.entity_interaction_ui")
  require("client.entity.entity_value_func_interaction_ui")
  require("client.entity.entity_interaction_event")
  require("client.interact_event")
  require("client.gate_interaction_ui")
  require("client.gm_interaction_ui")
  require("client.interaction_helper")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.userId == Me.platformUserId then
      UI:getWnd("loseControlGlass"):onShow(false)
      UI:getWnd("telescope"):onShow(false)
    end
  end)
else
  require("server.player.player_interaction_ui")
  require("server.player.packet_interaction_ui")
  require("server.entity.entity_interaction_ui")
  require("server.entity.entity_interaction_event")
  require("server.gate_interaction_ui")
  require("server.gm_interaction_ui")
  require("server.interaction_helper")
end
local handlers = {}
if World.isClient then
  function handlers.cancelInteractiveAction()
    Me:sendPacket({
      pid = "CancelInteractiveAction"
    })
  end
  
  Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(objID, rideOnId)
    if Me.objID == objID then
      local target = World.CurWorld:getEntity(rideOnId)
      if target and target:isValid() and target:cfg().entityType == Define.EntityType.Palette then
        UI:openWnd("palette", target:getPaletteData(), rideOnId)
      end
    end
  end)
else
  local InteractionHelper = T(Lib, "InteractionHelper")
  
  function handlers.OnPlayerLogin(player)
    player:addBuff("myplugin/attach_point_index_1_buff")
    player:addBuff("myplugin/walk_move_buff")
  end
  
  function handlers.updatePlayerInteractiveUI(entity)
    if entity.isPlayer and entity:getInteractPlayerHorseID() > 0 then
      entity:removeInteractiveState()
    end
  end
  
  function handlers.cleanPlayerAllInteraction(player)
    if not World.isClient then
      InteractionHelper:cleanPlayerAllInteraction(player)
      player:removeUsingVehicle()
    end
  end
  
  function handlers.updatePlayerInteractPart(player, partId, isInteracting)
    InteractionHelper:updatePlayerInteractPart(player, partId, isInteracting)
  end
  
  function handlers.ENTITY_LEAVE(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      entity:forceClearRobber()
    end
  end
  
  function handlers.SEND_CHAT_MESSAGE(context)
    if context.msgType == "msg" then
      local DanceConfig = T(Config, "DanceConfig")
      local actionId = DanceConfig:getChatMsgActionId(context.msg)
      if actionId and 0 < actionId then
        InteractionHelper:doDanceAction(context.obj1, actionId, true)
      end
    end
  end
  
  local ConditionCheckUtils = T(Lib, "ConditionCheckUtils")
  
  function handlers.SKILL_CAST(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if context.fullName == "/jump_trigger" then
    end
  end
end

function handlers.stopDanceAction(isOnlyStop, player)
  if World.isClient then
    Me:requestStopDanceAction(isOnlyStop)
  else
    local InteractionHelper = T(Lib, "InteractionHelper")
    local oldDanceId = player:getPlayDanceID()
    if 0 < oldDanceId then
      InteractionHelper:doDanceAction(player, nil, false, isOnlyStop)
    end
  end
end

function handlers.ShowOneInteractTips(content, player)
  local InteractionHelper = T(Lib, "InteractionHelper")
  if World.isClient then
    InteractionHelper:showOneInteractTips(content)
  else
    local packet = {
      pid = "ClientUpdateInteractTips",
      content = content,
      isShow = true
    }
    player:sendPacket(packet)
  end
end

function handlers.HideOneInteractTips(player)
  local InteractionHelper = T(Lib, "InteractionHelper")
  if World.isClient then
    InteractionHelper:hideOneInteractTips()
  else
    local packet = {
      pid = "ClientUpdateInteractTips",
      isShow = false
    }
    player:sendPacket(packet)
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
