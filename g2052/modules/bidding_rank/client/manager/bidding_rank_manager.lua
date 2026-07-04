local BiddingRankManager = T(Lib, "BiddingRankManager")
local dataCatch = {}
local playerNameCatch = {}

function BiddingRankManager:init()
end

function BiddingRankManager:getRankList(blockId, page)
  if not dataCatch[blockId] then
    return {}
  end
  return dataCatch[blockId][page] or {}
end

function BiddingRankManager:clearCatch()
  dataCatch = {}
end

function BiddingRankManager:initRankList(blockId)
  self:clearCatch()
  Me:sendPacket({
    pid = "initBiddingRankList",
    blockId = blockId
  })
end

function BiddingRankManager:loadRankList(blockId, page)
  Me:sendPacket({
    pid = "loadBiddingRankList",
    blockId = blockId,
    page = page
  })
end

function BiddingRankManager:loadBuildImg(blockId, key, callback)
end

function BiddingRankManager:loadBuildConfig(blockId, key, callback)
end

function BiddingRankManager:upPlayerBuild(blockId, mapId, pageNum, reportFrom)
  Me:sendPacket({
    pid = "likeBiddingBuild",
    blockId = blockId,
    pageNum = pageNum,
    mapId = mapId,
    reportFrom = reportFrom
  })
end

function BiddingRankManager:loadPlayerName(userId)
  if not playerNameCatch[userId] then
    AsyncProcess.GetUserDetail(userId, function(userInfo)
      if not userInfo then
        return
      end
      playerNameCatch[userId] = userInfo.nickName
      Lib.emitEvent(Event.BIDDING_LOADED_PLAYER_NAME, userId, userInfo.nickName)
    end)
  end
end

function BiddingRankManager:getPlayerName(userId)
  return playerNameCatch[userId] or userId
end

function BiddingRankManager:setRankList(blockId, page, maxNum, data)
  dataCatch[blockId] = dataCatch[blockId] or {}
  dataCatch[blockId].maxNum = maxNum
  dataCatch[blockId][page] = data
  for i, info in ipairs(data) do
    self:loadPlayerName(info.userId)
  end
  Lib.emitEvent(Event.BIDDING_LOADED_RANK_LIST, blockId, page, data)
end

function BiddingRankManager:getRankMaxNum(blockId)
  dataCatch[blockId] = dataCatch[blockId] or {}
  return dataCatch[blockId].maxNum or 0
end

function BiddingRankManager:getRankInfo(blockId, mapId)
  Me:sendPacket({
    pid = "getBiddingRankInfo",
    blockId = blockId,
    mapId = mapId
  }, function(data)
    self:setRankInfo(blockId, mapId, data)
  end)
end

function BiddingRankManager:setRankInfo(blockId, mapId, data)
  Lib.logDebug("======== ", data)
  Lib.emitEvent(Event.BIDDING_RANK_INFO_LOADED, blockId, mapId, data)
end

function BiddingRankManager:getRecommendLandList(blockId)
  Me:sendPacket({
    pid = "GetRecommendLandList",
    blockId = blockId
  })
end

BiddingRankManager:init()
