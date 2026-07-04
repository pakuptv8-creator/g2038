local BiddingConfig = T(Config, "BiddingConfig")
local timeLine = Define.BIDDING_STATUS_TIME_LINE
local DAY = 86400

local function timeLineWhile(func)
  local currStatus = Define.BIDDING_STATUS.WAIT
  while true do
    if func(currStatus) then
      return
    end
    local nextStatus = timeLine[currStatus]
    if nextStatus == currStatus then
      break
    end
    currStatus = nextStatus
  end
end

local function refreshBlockStatusEndTime(self, blockConfigList)
  for blockId, blockConfig in pairs(blockConfigList) do
    local blockTime = blockConfig.time
    local endTime = self.startTime
    self.blockTimeConfig[blockId] = {}
    self.blockConfig[blockId] = {
      daily = blockConfig.daily,
      notice = blockConfig.notice
    }
    timeLineWhile(function(currStatus)
      local statusTime = blockTime[currStatus] * DAY
      endTime = endTime + statusTime
      if currStatus == Define.BIDDING_STATUS.PUBLICITY then
        self.blockTimeConfig[blockId][currStatus] = {
          endTime = self.endTime,
          day = blockTime[currStatus]
        }
      else
        self.blockTimeConfig[blockId][currStatus] = {
          endTime = endTime,
          day = blockTime[currStatus]
        }
      end
    end)
  end
end

function BiddingConfig:init()
  self.isInitConfig = false
end

function BiddingConfig:setTimeLineConfig(data)
  self.startTime = tonumber(data.startTime) / 1000
  self.endTime = self.startTime + data.endTime * DAY
  self.season = data.season
  self.blockTimeConfig = {}
  self.blockConfig = {}
  refreshBlockStatusEndTime(self, data.block)
  self.isInitConfig = true
  Lib.emitEvent(Event.EVENT_BIDDING_CONFIG_CHANGE)
end

function BiddingConfig:getTimeLine(blockId)
  if self.blockTimeConfig[blockId] then
    return self.blockTimeConfig[blockId]
  end
  return
end

function BiddingConfig:getAllTimeLine(callback)
  if World.isClient then
    Me:sendPacket({
      pid = "requestBlockTimeConfig"
    }, callback)
    return
  end
  return self.blockTimeConfig
end

function BiddingConfig:getCurrStatus(blockId)
  local blockTimeLine = self:getTimeLine(blockId)
  if not blockTimeLine then
    return Define.BIDDING_STATUS.NORMAL
  end
  local currTime = os.time()
  if currTime < self.startTime then
    return Define.BIDDING_STATUS.NORMAL
  end
  local resultStatus = Define.BIDDING_STATUS.PUBLICITY
  timeLineWhile(function(currStatus)
    local endTime = blockTimeLine[currStatus].endTime
    if endTime > currTime then
      resultStatus = currStatus
      return true
    end
  end)
  return resultStatus
end

function BiddingConfig:getCurrSeason()
  return self.season
end

function BiddingConfig:getStatusTime(blockId, status)
end

function BiddingConfig:getEndStatusTime(blockId, status)
  if self.blockTimeConfig[blockId] then
    return self.blockTimeConfig[blockId][status].endTime
  end
  return -1
end

function BiddingConfig:getStartTime()
  return self.startTime
end

function BiddingConfig:getEndTime()
  return self.endTime
end

function BiddingConfig:getBlockConfig(blockId)
  return self.blockConfig[blockId]
end

function BiddingConfig:isInit()
  return self.isInitConfig
end

BiddingConfig:init()
