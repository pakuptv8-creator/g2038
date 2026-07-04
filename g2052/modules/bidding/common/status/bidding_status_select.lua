local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusSelect = class("BiddingStatusSelect", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.SELECT, BiddingStatusSelect)
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusSelect:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.SELECT
end

function BiddingStatusSelect:click(player)
  Lib.logDebug("BiddingStatusBidding:click ")
  if World.isClient then
    UI:openWnd("biddingRankList", self.block.id)
  else
    self:syncClientClick(player)
  end
end

function BiddingStatusSelect:execute()
  Lib.logDebug("show BiddingStatusSelect ")
  self:updateNotice()
end

function BiddingStatusSelect:unExecute()
end

function BiddingStatusSelect:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  local config = BiddingConfig:getBlockConfig(self.block.id)
  data.noticeConfig = config.notice
  return data
end

function BiddingStatusSelect:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.noticeConfig = data.noticeConfig
end

return BiddingStatusSelect
