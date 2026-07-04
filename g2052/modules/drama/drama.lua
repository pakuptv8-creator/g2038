require("common.entity_drama")
require("common.event_drama")
require("common.config.drama_cover_config")
require("common.define_drama")
require("common.config.drama_template_config")
require("common.drama_common_helper")
if World.isClient then
  require("client.drama_client_helper")
  require("client.player.player_drama")
  require("client.player.packet_drama")
  require("client.entity.entity_drama")
  require("client.entity.entity_value_func_drama")
  require("client.async_process.async_process_drama")
  require("client.gm_drama")
else
  require("server.drama_server_helper")
  require("server.player.player_drama")
  require("server.player.packet_drama")
  require("server.entity.entity_drama")
  require("server.async_process.async_process_drama")
  require("server.giant_hamburger_helper")
  require("server.gm_drama")
  require("server.drama_manager")
end
local handlers = {}
if World.isClient then
  local DramaClientHelper = T(Lib, "DramaClientHelper")
  
  function handlers.updateClientRegionId(regionId)
    DramaClientHelper:updateClientRegionId(regionId)
  end
  
  function handlers.getDramaPlayerLikesInfo(userId)
    Me:requestLikesNumByUserID(userId)
  end
  
  function handlers.doDramaThumbUpPlayer(targetUserId)
    DramaClientHelper:doDramaThumbUpPlayer(targetUserId)
  end
  
  function handlers.getDramaThumbUpState(userId)
    return DramaClientHelper.thumbUpList[userId]
  end
else
  local DramaServerHelper = T(Lib, "DramaServerHelper")
  local GiantHamburgerHelper = T(Lib, "GiantHamburgerHelper")
  
  function handlers.ENTITY_ENTER(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      DramaManager:securityEntrances("sendCurDramaInfo")
      DramaManager:securityEntrances("sendCurDramaLikeInfo", entity)
      DramaManager:securityEntrances("entryDrama", entity)
      DramaServerHelper:resetThumbUpInfo(entity.platformUserId, {})
      entity:setJoinDramaTime({})
      if DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
        local giantSetting = World.cfg.dramaSetting.giantSetting
        entity:setGiantScale(giantSetting.initShapeScale)
      end
      if DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Flight) then
        entity:addBuff("myplugin/player_fly_buff")
      end
      GiantHamburgerHelper:updatePlayerLoginMap(entity)
    elseif DramaManager:checkInTemplateMod(Define.DramaTemplateKey.Flight) then
      entity:addBuff("myplugin/fly_buff")
    end
  end
  
  function handlers.ENTITY_LEAVE(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      DramaManager:securityEntrances("exitDrama", entity.platformUserId, entity)
      DramaServerHelper:resetThumbUpInfo(entity.platformUserId)
    end
  end
  
  function handlers.GAME_EXIT()
    DramaManager:securityEntrances("amendDramaStatus", Define.DramaStatus.End)
  end
  
  function handlers.GAME_OVER()
    DramaManager:securityEntrances("amendDramaStatus", Define.DramaStatus.End)
  end
  
  function handlers.PLAYER_BE_SEND_MESSAGE(context)
    local player = context.obj1
    local content = context.content
    if content and content.key == "createAParty" then
      local configVersion = World.cfg.dramaSetting.configVersion
      if content.configVersion ~= configVersion then
        return
      end
      if Lib.isGameDrama() then
        return
      end
      if player and player:isValid() then
        player:sendPacket({
          pid = "syncNotifyParty",
          content = content
        })
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
