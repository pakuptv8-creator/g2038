require("common.entity_bidding")
require("common.event_bidding")
require("common.define_bidding")
require("common.config.bidding_config")
require("common.bidding_status_time_line")
require("common.timer.bidding_timer")
require("common.block.bidding_block")
require("common.status.bidding_status")
require("common.status.bidding_status_bidding")
require("common.status.bidding_status_audit")
require("common.status.bidding_status_election")
require("common.status.bidding_status_finals")
require("common.status.bidding_status_normal")
require("common.status.bidding_status_publicity")
require("common.status.bidding_status_select")
require("common.status.bidding_status_wait")
require("common.status.bidding_status_wait")
if World.isClient then
  require("client.entity.entity_value_func_bidding")
  require("client.manager.bidding_manager_client")
  require("client.player.packet_bidding")
  require("client.player.player_bidding")
  require("client.gm_bidding")
else
  require("server.player.packet_bidding")
  require("server.player.interact_bidding_player")
  require("server.gm_bidding")
  require("server.async.bidding_async")
  require("server.manager.bidding_manager")
end
local handlers = {}
if World.isClient then
  local BiddingManagerClient = T(Lib, "BiddingManagerClient")
  
  function handlers.getBlockStatus(blockId)
    local block = BiddingManagerClient:getBlock(blockId)
    if not block or not block.status then
      return Define.BIDDING_STATUS.NORMAL
    end
    return block.status.status
  end
else
  local BiddingManager = T(Lib, "BiddingManager")
  
  function handlers.blockDataLoaded()
    local allInfo = TenderingLandMgr:getCurRegionAllLandInfo()
    BiddingManager:createAllBlocks(allInfo)
  end
  
  function handlers.ENTITY_ENTER(context)
    local entity = context.obj1
    if not entity or not entity:isValid() then
      return
    end
    if entity.isPlayer then
      TenderingLandMgr:syncAllInfo(entity)
      BiddingManager:syncDataToPlayer(entity)
    end
  end
  
  function handlers.getBlockStatus(blockId)
    local block = BiddingManager:getBlock(blockId)
    if not block or not block.status then
      return Define.BIDDING_STATUS.NORMAL
    end
    return block.status.status
  end
  
  function handlers.BiddingBuildAwardLoaded(data)
    for i, info in pairs(data) do
      BiddingManager:setBlockSeason(info.blockId, info.season)
    end
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
