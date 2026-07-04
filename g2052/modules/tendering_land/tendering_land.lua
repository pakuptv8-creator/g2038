require("common.entity.entity_tendering_land")
require("common.config.tendering_config")
require("common.define_tendering_land")
if World.isClient then
  require("client.tenderingSignManager")
  require("client.tenderingPublicManager")
  require("client.tendering_client_award_manager")
  require("client.gm_tendering_land")
  require("client.player.player_tendering_land")
  require("client.player.packet_tendering_land")
  require("client.player.entity_value_func_tendering_land")
  require("client.tendering_async")
else
  Lib.declare("TenderingLandMgr", {})
  require("server.gm_tendering_land")
  require("server.tendering_land_mgr")
  require("server.tendering_async")
  require("server.tendering_land_board_manager")
  require("server.tendering_land_award_manager")
end
local handlers = {}

function handlers.getTenderingDressCanUseById(userId, dressId)
  if World.isClient then
    local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
    return TenderClientAwardManager:checkDressIsCanUse(userId, dressId)
  else
    local TenderingAwardManager = T(Lib, "TenderingAwardManager")
    return TenderingAwardManager:checkDressIsCanUse(userId, dressId)
  end
end

function handlers.getTenderingDressTips(dressId)
  if World.isClient then
    local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
    return TenderClientAwardManager:getTenderingDressTips(dressId)
  else
    local TenderingAwardManager = T(Lib, "TenderingAwardManager")
    return TenderingAwardManager:getTenderingDressTips(dressId)
  end
end

function handlers.getTenderingPetCanUseById(userId, petId)
  if World.isClient then
    local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
    return TenderClientAwardManager:checkTakePetIsCanUse(userId, petId)
  else
    local TenderingAwardManager = T(Lib, "TenderingAwardManager")
    return TenderingAwardManager:checkTakePetIsCanUse(userId, petId)
  end
end

function handlers.getTenderingPetTips(petId)
  if World.isClient then
    local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
    return TenderClientAwardManager:getTenderingPetTips(petId)
  else
    local TenderingAwardManager = T(Lib, "TenderingAwardManager")
    return TenderingAwardManager:getTenderingPetTips(petId)
  end
end

if World.isClient then
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if not entity or not entity:isValid() then
      return
    end
    local cfg = entity:cfg()
    if cfg.isMayorStatue then
      entity:updateUpperAction("g2052_diaoxiang", -1)
      Me:onUpdateMayorStatueUI(true, objID)
    end
  end)
  local TenderingSignManager = T(Lib, "TenderingSignManager")
  local TenderClientAwardManager = T(Lib, "TenderClientAwardManager")
  
  function handlers.createTenderingSignUI(signKey, uiParams)
    TenderingSignManager:createSignUI(signKey, uiParams)
  end
  
  function handlers.updateTenderingSignUIData(signKey, tenderState, data)
    TenderingSignManager:updateSignUIData(data, signKey, tenderState)
  end
  
  function handlers.updateTenderingSignUIParams(signKey, uiParams)
    TenderingSignManager:updateSignUIParams(signKey, uiParams)
  end
  
  function handlers.getBlockConfig(signKey)
    return TenderingSignManager:getTenderingLandCfg(signKey)
  end
  
  function handlers.getTenderDesignationAward(userId, needColor)
    return TenderClientAwardManager:getTenderDesignationAward(userId, needColor)
  end
  
  function handlers.openMayorEmailWnd()
    UI:getWnd("tenderingAwardEmail"):onShow(true)
  end
  
  function handlers.openTenderSignWnd()
    UI:getWnd("tenderSignWnd"):onShow(true)
  end
  
  function handlers.checkIsCanSendMayorEmail(userId)
    return TenderClientAwardManager:isNormalMayor(userId)
  end
  
  function handlers.updateClientRegionId(regionId)
    TenderClientAwardManager:updateClientRegionId(regionId)
  end
end
if World.isGameServer then
  local TenderingLandBoardManager = T(Lib, "TenderingLandBoardManager")
  local TenderingAwardManager = T(Lib, "TenderingAwardManager")
  
  function handlers.END_MAP_LOADING()
    TenderingLandMgr:loadingMapBuildings()
  end
  
  function handlers.showTenderingSignBoard(mapId, signKey)
    return TenderingLandBoardManager:showTenderingSignBoard(mapId, signKey)
  end
  
  function handlers.closeTenderingSignBoard(mapId, signKey)
    TenderingLandBoardManager:closeTenderingSignBoard(mapId, signKey)
  end
  
  function handlers.getBlockInfo(partName)
    return TenderingLandMgr:getBlockInfo(partName)
  end
  
  function handlers.updateTenderingResultAward()
    TenderingAwardManager:updateTenderingAwardData()
  end
  
  function handlers.checkResetTenderAppearance(userId, curSkin)
    return TenderingAwardManager:checkResetTenderAppearance(userId, curSkin)
  end
  
  function handlers.OnPlayerLogin(player)
    TenderingAwardManager:pushClientSocialAward(player)
    TenderingAwardManager:pushClientBuildAward(player)
    TenderingAwardManager:requestWebPassBlockIdList(player.platformUserId)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
