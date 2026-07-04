local TenderingLandBoardManager = T(Lib, "TenderingLandBoardManager")
local board_list = {}
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local bidding_pai_cfg = PartCfg:get("myplugin/bidding_pai")

function TenderingLandBoardManager:showTenderingSignBoard(mapId, blockName, uiParams)
  local map = World.CurWorld:getMapById(mapId)
  if board_list[mapId] and board_list[mapId][blockName] then
    return board_list[mapId][blockName]:getInstanceID()
  end
  local scene = World.CurWorld:getScene(map.obj)
  local info = TenderingLandMgr:getBlockInfo(blockName)
  local offset = info.cfg.signOffset
  local rotation = info.cfg.signRotate
  local finalPos = Lib.v3(info.pos.x + offset.x, info.pos.y + offset.y, info.pos.z + offset.z)
  Lib.logDebug("finalPos === ", finalPos)
  local inst = Lib.createPartHelper(bidding_pai_cfg, scene, map, rotation, finalPos)
  board_list[mapId] = board_list[mapId] or {}
  board_list[mapId][blockName] = inst
  return inst:getInstanceID()
end

function TenderingLandBoardManager:closeTenderingSignBoard(mapId, blockName)
  Lib.logDebug("closeTenderingSignBoard === ", blockName)
  if board_list[mapId] and board_list[mapId][blockName] then
    local inst = board_list[mapId][blockName]
    Plugins.CallTargetPluginFunc("part_manager", "destroyPart", inst)
    board_list[mapId][blockName] = nil
  end
end
