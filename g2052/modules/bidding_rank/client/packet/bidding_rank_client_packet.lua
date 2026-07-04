local BiddingRankManager = T(Lib, "BiddingRankManager")
local handles = T(Player, "PackageHandlers")
local subscribeEvent

function handles:syncBiddingRankList(packet)
  BiddingRankManager:setRankList(packet.blockId, packet.page, packet.maxNum, packet.data)
end

function handles:syncBiddingRankInfo(packet)
  BiddingRankManager:setRankInfo(packet.blockId, packet.mapId, packet.data)
end

function handles:syncPreviewMapData(packet)
  subscribeEvent = Lib.subscribeEvent(Event.EVENT_LOAD_WORLD_END, function()
    if World.CurMap.name == packet.mapName then
      Plugins.CallTargetPluginFunc("engine_overwrite", "removeMapCfg", packet.mapName)
      subscribeEvent()
      subscribeEvent = nil
    end
  end)
  Plugins.CallTargetPluginFunc("engine_overwrite", "addMapCfg", packet.mapName, packet.mapCfg)
end

function handles:syncBiddingFindRankList(packet)
  BiddingRankManager:clearCatch()
  BiddingRankManager:setRankList(packet.blockId, 1, 1, packet.data)
  if #packet.data == 0 then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_rank.not_found_tip"))
  end
end

function handles:syncMyBiddingRankList(packet)
  Lib.emitEvent(Event.UPDATE_BIDDING_MY_INFO, packet.blockId, packet.data)
end

function handles:syncMyRecommendRankList(packet)
  Lib.emitEvent(Event.UPDATE_BIDDING_RECOMMEND_UP, packet.blockId, packet.mapId, packet.data)
end

function handles:syncAuditRankData(packet)
  local data = packet.data
  local blockId = packet.blockId
  local pageNum = packet.pageNum
  Lib.emitEvent(Event.BIDDING_LOADED_AUDIT_RANK_LIST, blockId, pageNum, data)
end

function handles:syncAuditBiddingMap(packet)
  if packet.isSuccess then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_audit.pass_tip"))
    Lib.emitEvent(Event.BIDDING_AUDIT_SUCCESS)
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.bidding_audit.not_pass_tip"))
  end
end

function handles:syncAuditMapData(packet)
  Lib.emitEvent(Event.BIDDING_LOADED_AUDIT_MAP_INFO, packet.data)
end

function handles:syncRecommendLandData(packet)
  Lib.emitEvent(Event.UPDATE_BIDDING_RECOMMEND_INFO, packet.blockId, packet.data)
end
