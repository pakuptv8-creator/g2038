local handles = T(Player, "PackageHandlers")
local BiddingManagerClient = T(Lib, "BiddingManagerClient")

function handles:syncBiddingBlockData(packet)
  BiddingManagerClient:setBlockSyncData(packet.data.id, packet.data)
end

function handles:syncAllBiddingBlockData(packet)
  BiddingManagerClient:setAllBlockSyncData(packet.data)
end

function handles:biddingNoticeClick(packet)
  local block = BiddingManagerClient:getBlock(packet.blockId)
  if block.status.status == packet.status then
    block.status:click(self)
  else
    assert(false, "block status is different ", block.status.status, packet.status)
  end
end

function handles:syncBiddingOpenEditor(packet)
  self:showBiddingOpenEditor(packet.blockId, packet.screenShot)
end
