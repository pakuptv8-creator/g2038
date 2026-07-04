local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusFinals = class("BiddingStatusFinals", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.FINALS, BiddingStatusFinals)
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusFinals:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.FINALS
end

function BiddingStatusFinals:click(player)
  Lib.logDebug("BiddingStatusBidding:click ")
  if World.isClient then
    UI:openWnd("biddingRankList", self.block.id)
  else
    self:syncClientClick(player)
  end
end

function BiddingStatusFinals:execute()
  Lib.logDebug("show BiddingStatusFinals ")
  self:updateNotice()
end

function BiddingStatusFinals:unExecute()
end

function BiddingStatusFinals:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  local config = BiddingConfig:getBlockConfig(self.block.id)
  data.noticeConfig = config.notice
  return data
end

function BiddingStatusFinals:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.noticeConfig = data.noticeConfig
end

return BiddingStatusFinals
