local BiddingManagerClient = T(Lib, "BiddingManagerClient")
local BiddingBlockCls = require("common.block.bidding_block")

function BiddingManagerClient:init()
  self.blockList = {}
  self:registerEvent()
end

function BiddingManagerClient:registerEvent()
end

function BiddingManagerClient:createBlock(id)
  return BiddingBlockCls.new(id)
end

function BiddingManagerClient:setBlockSyncData(blockId, data)
  local block = self.blockList[blockId]
  if not block then
    block = self:createBlock(blockId)
    self.blockList[blockId] = block
  end
  block:setSyncData(data)
end

function BiddingManagerClient:setAllBlockSyncData(data)
  for blockId, blockData in pairs(data) do
    self:setBlockSyncData(blockId, blockData)
  end
end

function BiddingManagerClient:getBlock(id)
  return self.blockList[id]
end

BiddingManagerClient:init()
