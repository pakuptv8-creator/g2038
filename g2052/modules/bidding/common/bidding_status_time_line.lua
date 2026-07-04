local BiddingStatusTimeLine = T(Lib, "BiddingStatusTimeLine")
local timeLine = Define.BIDDING_STATUS_TIME_LINE
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusTimeLine:getNextStatus(status)
  return timeLine[status]
end

function BiddingStatusTimeLine:getEndStatusTime(blockId, status)
  local nextStatus = self:getNextStatus(status)
  if nextStatus == status then
    return -1
  end
  local endTime = BiddingConfig:getEndStatusTime(blockId, status)
  return endTime
end

function BiddingStatusTimeLine:getCurrTimeStatus(blockId)
  return BiddingConfig:getCurrStatus(blockId)
end
