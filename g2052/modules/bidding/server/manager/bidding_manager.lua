local BiddingManager = T(Lib, "BiddingManager")
local BiddingBlockCls = require("common.block.bidding_block")
local BiddingConfig = T(Config, "BiddingConfig")
local BiddingTimer = T(Lib, "BiddingTimer")
local blockSeason = {}

function BiddingManager:init()
  self.startTime = math.maxinteger
  self.blockList = {}
  self.isInitBlock = false
  self:registerEvent()
  self:loadConfig()
end

function BiddingManager:registerEvent()
  Lib.subscribeEvent(Event.EVENT_BIDDING_CONFIG_CHANGE, function()
    self:checkStartTime()
    self:tryUpdateBlocksStatus()
  end)
end

function BiddingManager:loadConfig()
  AsyncProcess.loadBiddingConfig()
  self.updateConfigTimer = World.Timer(72000, function()
    self.updateConfigTimer = nil
    self:loadConfig()
  end)
end

function BiddingManager:checkStartTime()
  if not BiddingConfig:isInit() then
    return
  end
  local startTime = BiddingConfig:getStartTime()
  local currTime = os.time()
  if self.startTimer then
    self.startTimer()
    self.startTimer = nil
  end
  if startTime > currTime then
    self.startTimer = BiddingTimer:registerTimer(startTime, function()
      self.startTimer = nil
      self:tryUpdateBlocksStatus()
    end)
  end
end

function BiddingManager:createBlock(id)
  return BiddingBlockCls.new(id)
end

function BiddingManager:createAllBlocks(allInfo)
  local blocks = allInfo or {}
  for mapName, blockList in pairs(allInfo) do
    for partName, blockInfo in pairs(blockList) do
      self.blockList[partName] = self:createBlock(partName)
      self.blockList[partName]:setMapName(mapName)
      self.blockList[partName].season = blockSeason[partName]
    end
  end
  self.isInitBlock = true
  self:tryUpdateBlocksStatus()
end

function BiddingManager:tryUpdateBlocksStatus()
  if self.isInitBlock and BiddingConfig:isInit() then
    self:updateBlocksStatus()
  end
end

function BiddingManager:updateBlocksStatus()
  Lib.logDebug("11111111111111111")
  for i, block in pairs(self.blockList) do
    Lib.logDebug("22222222222222")
    block:updateConfig(BiddingConfig:getBlockConfig(block.id))
    block:refreshStatus()
  end
  self:syncData()
end

function BiddingManager:getSyncData()
  local data = {}
  for blockId, block in pairs(self.blockList) do
    data[blockId] = block:getSyncData()
  end
  return data
end

function BiddingManager:getBlock(blockId)
  return self.blockList[blockId]
end

function BiddingManager:syncData()
  local data = self:getSyncData()
  WorldServer.BroadcastPacket({
    pid = "syncAllBiddingBlockData",
    data = data
  })
end

function BiddingManager:syncDataToPlayer(player)
  local data = self:getSyncData()
  player:sendPacket({
    pid = "syncAllBiddingBlockData",
    data = data
  })
end

function BiddingManager:setBlockSeason(blockId, season)
  blockSeason[blockId] = season
  local block = self:getBlock(blockId)
  if block then
    block.season = season
    if self.isInitBlock and BiddingConfig:isInit() then
      block:syncData()
    end
  end
end

BiddingManager:init()
