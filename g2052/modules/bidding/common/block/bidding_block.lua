local BiddingBlock = class("BiddingBlock")
local BiddingStatusCls = require("common.status.bidding_status")
local BiddingStatusTimeLine = T(Lib, "BiddingStatusTimeLine")

function BiddingBlock:ctor(id)
  self.id = id
  self.mapName = nil
  self.status = nil
  self.season = 1
  self.house_url = ""
  self.config = {}
end

function BiddingBlock:setMapName(mapName)
  self.mapName = mapName
end

function BiddingBlock:updateConfig(config)
  self.config = config
  Lib.logDebug("updateConfig == ", config)
end

function BiddingBlock:updateStatus(status)
  Lib.logDebug("updateStatus ", self.id, status)
  if self.status then
    if self.status:getStatus() == status then
      self.status:updateStatus()
      return
    end
    self.status:unExecute()
    self.status:remove()
    self.status = nil
  end
  self.status = BiddingStatusCls.getNewObj(status)
  self.status:add(self)
  self.status:execute()
end

function BiddingBlock:refreshStatus()
  local status = BiddingStatusTimeLine:getCurrTimeStatus(self.id)
  self:updateStatus(status)
end

function BiddingBlock:getSyncData()
  return {
    id = self.id,
    mapName = self.mapName,
    house_url = self.house_url,
    status = self.status and self.status:getSyncData() or nil,
    config = self.config
  }
end

function BiddingBlock:setSyncData(data)
  self.id = data.id
  self.mapName = data.mapName
  self.house_url = data.house_url
  self.config = data.config
  Lib.logDebug("config update ", self.config)
  if data.status then
    local status = data.status.status
    if self.status then
      if self.status:getStatus() == status then
        self.status:setSyncData(data.status)
        self.status:updateStatus()
        return
      else
        self.status:unExecute()
        self.status:remove()
        self.status = nil
      end
    end
    self.status = BiddingStatusCls.getNewObj(status)
    self.status:add(self)
    self.status:setSyncData(data.status)
    self.status:execute()
  end
  Plugins.CallPluginFunc("biddingBlockStatusChange", self)
end

function BiddingBlock:syncData()
  local data = self:getSyncData()
  WorldServer.BroadcastPacket({
    pid = "syncBiddingBlockData",
    data = data
  })
end

return BiddingBlock
