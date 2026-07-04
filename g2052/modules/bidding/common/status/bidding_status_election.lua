local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusElection = class("BiddingStatusElection", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.ELECTION, BiddingStatusElection)

function BiddingStatusElection:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.ELECTION
end

function BiddingStatusElection:click()
end

function BiddingStatusElection:getRankList(page)
end

function BiddingStatusElection:getRankListByFind(findStr)
end

function BiddingStatusElection:click(player)
  Lib.logDebug("BiddingStatusBidding:click ")
  if World.isClient then
    UI:openWnd("biddingRankList", self.block.id)
  else
    self:syncClientClick(player)
  end
end

function BiddingStatusElection:execute()
  Lib.logDebug("show BiddingStatusElection ")
  self:updateNotice()
end

function BiddingStatusElection:unExecute()
end

function BiddingStatusElection:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  return data
end

function BiddingStatusElection:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
end

return BiddingStatusElection
