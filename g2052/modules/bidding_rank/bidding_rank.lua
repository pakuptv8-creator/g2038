require("common.define_bidding_rank")
require("common.event_bidding_rank")
require("common.helper.bidding_rank_helper")
if World.isClient then
  require("client.manager.bidding_rank_manager")
  require("client.packet.bidding_rank_client_packet")
  require("client.gm_bidding_rank")
  require("client.player.player_bidding_rank")
else
  require("server.async.bidding_rank_async")
  require("server.manager.bidding_rank_catch_manager")
  require("server.manager.bidding_preview_manager")
  require("server.packet.bidding_rank_packet")
  require("server.gm_bidding_rank")
end
local handlers = {}
if World.isClient then
else
  local BiddingRankCatchManager = T(Lib, "BiddingRankCatchManager")
  local BiddingPreviewManager = T(Lib, "BiddingPreviewManager")
  
  function handlers.getBiddingRankFirst(blockId, callback)
    for _, player in pairs(Game.GetAllPlayers()) do
      if player and player:isValid() then
        BiddingRankCatchManager:getRankList(player.platformUserId, blockId, 1, function(rankList)
          local info = rankList[1]
          if not info then
            return
          end
          callback(info)
        end)
        return
      end
    end
  end
  
  function handlers.biddingBlockStatusChange(block)
    BiddingRankCatchManager:clearRankCatch(block.id)
  end
  
  function handlers.previewFirstBuild(player, blockId)
    BiddingPreviewManager:previewFirstBuild(player, blockId)
  end
end
return function(name, ...)
  if type(handlers[name]) ~= "function" then
    return
  end
  return handlers[name](...)
end
