local BiddingStatus = class("BiddingStatus")
local subClsList = {}

function BiddingStatus.registerSubCls(status, cls)
  subClsList[status] = cls
end

function BiddingStatus.getCls(status)
  return subClsList[status]
end

function BiddingStatus.getNewObj(status)
  local cls = subClsList[status]
  return cls.new()
end

local BiddingStatusTimeLine = T(Lib, "BiddingStatusTimeLine")
local BiddingTimer = T(Lib, "BiddingTimer")

function BiddingStatus:ctor()
  self.status = Define.BIDDING_STATUS.NORMAL
  self.endTime = math.maxinteger
end

function BiddingStatus:getStatus()
  return self.status
end

function BiddingStatus:add(block)
  self.block = block
  self:updateEndTimer()
end

function BiddingStatus:remove()
  if self.endTimer then
    self.endTimer()
    self.endTimer = nil
  end
end

function BiddingStatus:updateEndTimer()
  if World.isClient then
    return
  end
  if self.endTimer then
    self.endTimer()
    self.endTimer = nil
  end
  local endTime = BiddingStatusTimeLine:getEndStatusTime(self.block.id, self.status)
  if endTime == -1 then
    return
  end
  self.endTimer = BiddingTimer:registerTimer(endTime, function()
    self.endTimer = nil
    self.block:updateStatus(BiddingStatusTimeLine:getNextStatus(self.status))
    self.block:syncData()
  end)
end

function BiddingStatus:execute()
end

function BiddingStatus:unExecute()
end

function BiddingStatus:click(player)
end

function BiddingStatus:updateStatus()
  self:updateEndTimer()
end

function BiddingStatus:getSyncData()
  return {
    status = self.status
  }
end

function BiddingStatus:setSyncData(data)
  self.status = data.status
end

function BiddingStatus:updateNotice(showData)
  if World.isClient then
    showData = showData or {}
    local signKey = self.block.id
    local notice = self.block.config.notice or {}
    Lib.logDebug("notice === ", notice)
    local blockCfg = Plugins.CallTargetPluginFunc("tendering_land", "getBlockConfig", signKey)
    if not blockCfg then
      Lib.logError("-not-blockCfg-blockId is null-", signKey)
      blockCfg = {}
    end
    local titleLang
    if blockCfg.initialBuildings ~= "" then
      titleLang = Lang:formatMessageByIndex("g2052.gui.bidding.title_season", Lang:toText(blockCfg.buildName), notice.season or 1)
    else
      titleLang = Lang:formatMessageByIndex("g2052.gui.bidding.title", Lang:toText(blockCfg.buildName))
    end
    local data = {
      signTitle = showData.signTitle or titleLang,
      signState = showData.signState or Define.BIDDING_STATUS_NOTICE_DESC[self.status],
      signPlayer = showData.signPlayer,
      signUnit = showData.signUnit or Lang:toText(notice.signUnit)
    }
    Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, self.status, data)
  else
    local signKey = self.block.id
    local blockInfo = Plugins.CallTargetPluginFunc("tendering_land", "getBlockInfo", signKey)
    if not blockInfo then
      return
    end
    self.instanceId = Plugins.CallTargetPluginFunc("tendering_land", "showTenderingSignBoard", blockInfo.mapId, signKey)
    local part = Instance.getByInstanceId(self.instanceId)
    if part then
      part.biddingBlock = self.block
      Plugins.CallTargetPluginFunc("part_manager", "UpdateBiddingPartLand", self.instanceId, blockInfo.mapName, signKey)
    end
  end
end

function BiddingStatus:closeNotice()
  if World.isClient then
    local signKey = self.block.id
    Plugins.CallTargetPluginFunc("tendering_land", "updateTenderingSignUIData", signKey, Define.BIDDING_STATUS.NORMAL, {})
  else
    local signKey = self.block.id
    local blockInfo = Plugins.CallTargetPluginFunc("tendering_land", "getBlockInfo", signKey)
    if not blockInfo then
      return
    end
    Plugins.CallTargetPluginFunc("tendering_land", "closeTenderingSignBoard", blockInfo.mapId, signKey)
  end
end

function BiddingStatus:syncClientClick(player)
  player:sendPacket({
    pid = "biddingNoticeClick",
    blockId = self.block.id,
    status = self.status
  })
end

return BiddingStatus
