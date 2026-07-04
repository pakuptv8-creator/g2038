require("common.entity_part_manager")
require("common.event_part_manager")
require("common.config.regionEffects_config")
require("common.config.part_scene_name_config")
require("common.define_part_manager")
if World.isClient then
  require("client.part_ui_client_manager")
  require("client.part_tips_client_manager")
  require("client.player_photograph_client_manager")
  require("client.player.player_part_manager")
  require("client.player.packet_part_manager")
  require("client.entity.entity_part_manager")
  require("client.entity.entity_value_func_part_manager")
  require("client.gate_part_manager")
  require("client.gm_part_manager")
  require("client.part_manager_helper")
else
  require("server.player.player_part_manager")
  require("server.player.packet_part_manager")
  require("server.entity.entity_part_manager")
  require("server.gate_part_manager")
  require("server.gm_part_manager")
  require("server.part_manager_helper")
  require("server.part_manager_show")
  Lib.declare("SceneUIPartManager", {})
  require("server.part_scene_ui_manager")
end
local handlers = {}
if World.isClient then
else
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  local PartEffectHelper = T(Lib, "PartEffectHelper")
  local EmergencyHelper = T(Lib, "EmergencyHelper")
  local PropsConfig = T(Config, "PropsConfig")
  
  function handlers.ENTITY_LEAVE(context)
    local entity = context and context.obj1
    if entity and entity.isPlayer then
      if not World.isClient then
        entity:stopSwing()
      end
      local oldEnterId = entity:getInteractCarEnterID()
      local partId = entity:getInteractionPartID()
      if partId ~= "" or oldEnterId ~= "" or entity.rideFixedPointVehicleId and entity.rideFixedPointVehicleId ~= "" then
        entity:clientDoJumpEvent()
      end
      local oldSinglePartId = entity:getSingleInteractPartID()
      if oldSinglePartId ~= "" then
        PartManagerHelper:cleanSingleInteractData(entity)
      end
      PartManagerHelper:removeBindPlayerInfo(entity.objID)
      PartManagerHelper:removeOccupationInfo(entity.platformUserId)
    end
  end
  
  function handlers.OnPlayerLogin(player)
    PartManagerHelper:loginSyncPartInteractState(player)
  end
  
  function handlers.UpdateBiddingPartLand(partId, mapName, signKey)
    PartManagerHelper:updateBiddingPartLand(partId, mapName, signKey)
  end
  
  function handlers.SKILL_CAST_FINISH(context)
    local entity = context and context.obj1
    if entity and entity.isPlayer then
      local target = context.obj2
      local inUseItem = entity:getInUseProp()
      if not inUseItem or not inUseItem.itemId then
        return
      end
      local cfg = PropsConfig:getCfgById(inUseItem.itemId)
      if not cfg or cfg.throwTrigger ~= Define.ThrowObjTrigger.skillCast then
        return
      end
      if context.fullName ~= cfg.skill[inUseItem.index] then
        return
      end
      if cfg.isThrowObj == Define.ThrowObjType.Bomb then
        entity:onExplodeBarrier(Define.PART_INTERACT_TYPE.CLICKED, target, context, cfg)
      elseif cfg.isThrowObj == Define.ThrowObjType.Hamburger or cfg.isThrowObj == Define.ThrowObjType.Ladder then
        if not target or not target:isValid() then
          return
        end
        local hasPlayer = false
        if target.isPlayer then
          hasPlayer = true
        end
        if not hasPlayer and target.data then
          for idx, objID in pairs(target:data("passengers")) do
            local entity = World.CurWorld:getEntity(objID)
            if entity and entity:isValid() and entity.isPlayer then
              hasPlayer = true
            end
          end
        end
        if not hasPlayer then
          entity:onPlaceToWorld(Define.PART_INTERACT_TYPE.CLICKED, target, context)
        end
      end
    end
  end
  
  function handlers.destroyPart(part)
    PartManagerHelper:doDestroyPart(part)
  end
  
  function handlers.ENTER_MAP(info)
    if info.obj1.isPlayer then
      PartManagerHelper:updateAllClientEffect(info.map.name, info.obj1)
      World.Timer(10, function()
        if not info.obj1 or not info.obj1:isValid() then
          return
        end
        PartEffectHelper:loginInitPartRegionEffect(info.map.name, info.obj1)
        SceneUIPartManager:pushClientPartUIMapInfo(info.map.name, info.obj1)
        SceneUIPartManager:pushClientPartContentMapInfo(info.map.name, info.obj1)
      end)
      EmergencyHelper:syncDataS2C(info.map.name, info.obj1)
    end
  end
  
  function handlers.updatePartInteractPlayer(part, objID, isInteracting)
    PartManagerHelper:updatePartInteractPlayer(part, objID, isInteracting)
  end
  
  function handlers.updateBindPlayerPartList(partList, objID, isInteracting)
    PartManagerHelper:updateBindPlayerList(partList, objID, isInteracting)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
