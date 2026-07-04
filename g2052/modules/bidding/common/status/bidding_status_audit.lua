local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusAudit = class("BiddingStatusAudit", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.AUDIT, BiddingStatusAudit)
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusAudit:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.AUDIT
  self.isCreateUI = false
end

function BiddingStatusAudit:click(player)
  Lib.logDebug("BiddingStatusAudit:click ")
end

function BiddingStatusAudit:execute()
  Lib.logDebug("show BiddingStatusAudit ")
  self:updateNotice()
end

function BiddingStatusAudit:unExecute()
end

function BiddingStatusAudit:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  return data
end

function BiddingStatusAudit:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.config = data.config
  self:execute()
end

return BiddingStatusAudit
