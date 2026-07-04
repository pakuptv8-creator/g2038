local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusNormal = class("BiddingStatusNormal", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.NORMAL, BiddingStatusNormal)

function BiddingStatusNormal:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.NORMAL
end

function BiddingStatusNormal:execute()
  Lib.logDebug("show BiddingStatusNormal ")
  self:closeNotice()
  if World.isGameServer then
    Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingResultAward")
  end
end

function BiddingStatusNormal:unExecute()
end

function BiddingStatusNormal:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  return data
end

function BiddingStatusNormal:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
end

return BiddingStatusNormal
