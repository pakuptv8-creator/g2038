local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusBidding = class("BiddingStatusBidding", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.BIDDING, BiddingStatusBidding)
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusBidding:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.BIDDING
  self.isCreateUI = false
end

function BiddingStatusBidding:click(player)
  Lib.logDebug("BiddingStatusBidding:click ")
end

function BiddingStatusBidding:execute()
  Lib.logDebug("show BiddingStatusBidding ")
  self:updateNotice()
end

function BiddingStatusBidding:unExecute()
end

function BiddingStatusBidding:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  return data
end

function BiddingStatusBidding:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.config = data.config
  self:execute()
end

return BiddingStatusBidding
