local BiddingStatusCls = require("common.status.bidding_status_wait")
local BiddingStatusPublicity = class("BiddingStatusPublicity", BiddingStatusCls)
BiddingStatusCls.registerSubCls(Define.BIDDING_STATUS.PUBLICITY, BiddingStatusPublicity)

function BiddingStatusPublicity:ctor()
  BiddingStatusCls.ctor(self)
  self.status = Define.BIDDING_STATUS.PUBLICITY
  self.firstInfo = {}
end

function BiddingStatusPublicity:click(player)
  if World.isGameServer then
    local blockId = self.block.id
    Plugins.CallTargetPluginFunc("bidding_rank", "previewFirstBuild", player, blockId)
  end
end

function BiddingStatusPublicity:execute()
  Lib.logDebug("show BiddingStatusPublicity ")
  self:updateNotice({
    signPlayer = self.firstInfo.userId
  })
  if World.isGameServer then
    Plugins.CallTargetPluginFunc("bidding_rank", "getBiddingRankFirst", self.block.id, function(info)
      self.firstInfo = info
      self.block:syncData()
    end)
  end
end

function BiddingStatusPublicity:unExecute()
end

function BiddingStatusPublicity:getSyncData()
  local data = BiddingStatusCls.getSyncData(self)
  data.firstInfo = self.firstInfo
  return data
end

function BiddingStatusPublicity:setSyncData(data)
  BiddingStatusCls.setSyncData(self, data)
  self.firstInfo = data.firstInfo
  self:updateNotice({
    signPlayer = self.firstInfo.userId
  })
end

return BiddingStatusPublicity
