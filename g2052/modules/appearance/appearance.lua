require("common.event_appearance")
require("common.define_appearance")
require("common.config.appearance_config")
require("common.entity_appearance")
if World.isClient then
  require("client.player.player_appearance")
  require("client.player.packet_appearance")
  require("client.entity.entity_appearance")
  require("client.entity.entity_value_func_appearance")
  require("client.gate_appearance")
  require("client.gm_appearance")
  Lib.subscribeEvent(Event.EVENT_PLAYER_LOGIN, function(info)
    if info.objID ~= Me.objID then
      return
    end
    Me:loadNewAppearanceScanRecord()
    Me:updateAppearanceRedDotStatus()
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity or not entity:isValid() then
      return
    end
    if not entity.isPlayer then
      return
    end
    if Me and entity ~= Me then
      World.Timer(20, function()
        Me:sendPacket({
          pid = "reqDyeingStatus",
          userId = entity.platformUserId
        })
      end)
    end
  end)
else
  require("server.dyeing_status_mgr")
  require("server.player.player_appearance")
  require("server.player.packet_appearance")
  require("server.entity.entity_appearance")
  require("server.gate_appearance")
  require("server.gm_appearance")
end
local handlers = {}

function handlers.ENTITY_ENTER(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    if not DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
      local initBoundBox = entity:getInitBoundBox()
      if not initBoundBox.x then
        entity:setShapeScale(1)
      else
        local shapeScale = math.floor(entity:getShapeScale() * 100 + 0.5) / 100
        if shapeScale < World.cfg.shapeScaleSetting.min or shapeScale > World.cfg.shapeScaleSetting.max then
          entity:setShapeScale(1)
        else
          entity:setShapeScale(shapeScale)
        end
      end
    end
    local oldSkin = entity:data("skin")
    entity:setOriginalSkin(Lib.copyTable1(oldSkin))
    local skinAttrInfo = entity:getPlayerAttrInfo()
    if oldSkin.exclusive_parts then
      entity:setExclusiveParts(oldSkin.exclusive_parts)
    end
    World.Timer(40, function()
      if entity and entity:isValid() then
        local shapeInfo = entity:getShapeInfo()
        if next(shapeInfo) ~= nil then
          local changeSkinData = entity:parseNewSkinData()
          if Plugins.CallTargetPluginFunc("tendering_land", "checkResetTenderAppearance", entity.platformUserId, changeSkinData) then
            entity:doResetRoleSkin()
          else
            entity:changeSkin(changeSkinData)
          end
        end
      end
    end)
  end
end

function handlers.ENTITY_LEAVE(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  if entity.isPlayer then
    HouseManager:onPlayerHouseReport(entity.platformUserId)
    local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")
    DyeingStatusMgr:clearStatus(entity)
    local player = Game.GetPlayerByUserId(entity.platformUserId)
    if player and player:isValid() then
      player:stopDressAdDownTimer()
    end
  end
end

return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
