local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusWait = class("BiddingStatusWait", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.WAIT, BiddingStatusWait)
local BiddingConfig = T(Config, "BiddingConfig")

function BiddingStatusWait:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.WAIT
end

function BiddingStatusWait:execute()
  Lib.logDebug("show BiddingStatusWait ")
  self:closeNotice()
  if World.isGameServer then
    Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingResultAward")
  end
end

function BiddingStatusWait:unExecute()
  if World.isClient then
  end
end

function BiddingStatusWait:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  local config = BiddingConfig:getBlockConfig(self.block.id)
  data.noticeConfig = config.notice
  return data
end

function BiddingStatusWait:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.noticeConfig = data.noticeConfig
end

return BiddingStatusWait
