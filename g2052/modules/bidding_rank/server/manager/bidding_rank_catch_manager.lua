local BiddingRankCatchManager = T(Lib, "BiddingRankCatchManager")
local BiddingRankHelper = T(Lib, "BiddingRankHelper")
local blockRankList = {}

local function getNewBlockData(maxNum)
  return {
    maxNum = maxNum,
    mapIdList = {},
    rankList = {},
    upMap = {}
  }
end

function BiddingRankCatchManager:init()
end

function BiddingRankCatchManager:loadRankData(playerId, blockId, startIndex, data)
  local catchRankList = blockRankList[blockId]
  if not catchRankList then
    blockRankList[blockId] = getNewBlockData(data.totalSize)
    catchRankList = blockRankList[blockId]
  else
    catchRankList.maxNum = data.totalSize
  end
  local upMap = catchRankList.upMap
  upMap[playerId] = upMap[playerId] or {}
  for i, info in ipairs(data.data) do
    upMap[playerId][info.mapId] = info.userLikeType
  end
  BiddingRankHelper.addRank(catchRankList.rankList, catchRankList.mapIdList, data.data, startIndex)
end

function BiddingRankCatchManager:requestRankData(playerId, blockId, pageNum, callback)
  AsyncProcess.requestRankList(playerId, blockId, pageNum, Define.BIDDING_RANK_PAGE_SHOW_NUM, function(data)
    local startIndex = (pageNum - 1) * Define.BIDDING_RANK_PAGE_SHOW_NUM + 1
    self:loadRankData(playerId, blockId, startIndex, data)
    local resultData = self:getClientRankList(playerId, blockId, startIndex)
    callback(resultData)
  end, function(failMessage)
  end)
end

function BiddingRankCatchManager:tryGetCatchData(playerId, blockId, pageNum)
  local catchRankList = blockRankList[blockId]
  if catchRankList then
    local lostTime = os.time() - 3600
    local startRank = (pageNum - 1) * Define.BIDDING_RANK_PAGE_SHOW_NUM + 1
    local endRank = startRank + Define.BIDDING_RANK_PAGE_SHOW_NUM - 1
    endRank = math.min(endRank, catchRankList.maxNum)
    local rankList = catchRankList.rankList
    local upMap = catchRankList.upMap[playerId] or {}
    local rankData = {}
    for i = startRank, endRank do
      local info = rankList[i]
      if not info or info.isLost or upMap[info.mapId] == nil or lostTime > info.updateTime then
        return
      end
      table.insert(rankData, {
        userId = info.userId,
        mapId = info.mapId,
        picUrl = info.picUrl,
        likeNumber = info.likeNumber,
        rank = info.rank,
        nickName = info.nickName,
        userLikeType = upMap[info.mapId]
      })
    end
    return rankData
  end
end

function BiddingRankCatchManager:getRankList(playerId, blockId, pageNum, callback)
  local catchRankList = blockRankList[blockId]
  if catchRankList then
    local rankData = self:tryGetCatchData(playerId, blockId, pageNum)
    if rankData then
      return callback(rankData)
    else
      self:requestRankData(playerId, blockId, pageNum, callback)
    end
  else
    self:requestRankData(playerId, blockId, pageNum, callback)
  end
end

function BiddingRankCatchManager:getRankNum(blockId, callback)
  local catchRankList = blockRankList[blockId]
  if catchRankList and catchRankList.maxNum then
    return callback(catchRankList.maxNum)
  end
  callback(0)
end

function BiddingRankCatchManager:findPlayer(playerId, blockId, findStr, callback)
  AsyncProcess.requestFindPlayer(playerId, blockId, findStr, function(data)
    if data then
      self:loadRankData(playerId, blockId, data.rank, {
        totalSize = self:getRankMaxNum(blockId),
        data = {data}
      })
      local resultData = self:getClientRankList(playerId, blockId, data.rank, 1)
      callback(true, resultData)
    else
      return callback(true, {})
    end
  end, function(failMessage)
    callback(true, failMessage)
  end)
end

function BiddingRankCatchManager:getPlayerBuild(blockId, mapId)
  local catchRankList = blockRankList[blockId]
  if not catchRankList then
    return {}
  end
  return catchRankList.mapIdList[mapId] or {}
end

function BiddingRankCatchManager:isLikeBuild(userId, blockId, mapId)
  local catchRankList = blockRankList[blockId] or {}
  local upMap = catchRankList.upMap or {}
  if upMap[userId] and upMap[userId][mapId] then
    return upMap[userId][mapId]
  end
  return 0
end

function BiddingRankCatchManager:upPlayerBuild(player, blockId, mapId, reportFrom, callback)
  local catchRankList = blockRankList[blockId]
  local userId = player.platformUserId
  if catchRankList and catchRankList.upMap and catchRankList.upMap[userId] and catchRankList.upMap[userId][mapId] ~= nil then
    local curLikeType = catchRankList.upMap[userId][mapId]
    local likeType = curLikeType == 1 and -1 or 1
    local status = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", blockId)
    AsyncProcess.likeBiddingBuild(userId, blockId, mapId, likeType, function(data)
      catchRankList.upMap[userId][mapId] = data.likeType
      if curLikeType ~= data.likeType then
        local info = self:getPlayerBuild(blockId, mapId)
        if curLikeType == 1 then
          info.likeNumber = info.likeNumber - 1
          BiddingRankHelper.resortRank(catchRankList.rankList, mapId, false)
        else
          info.likeNumber = info.likeNumber + 1
          BiddingRankHelper.resortRank(catchRankList.rankList, mapId, true)
        end
      end
      local info = self:getClientRankInfo(userId, blockId, mapId)
      callback(info)
    end, function(failMessage)
    end)
  end
end

function BiddingRankCatchManager:requestInitRankData(playerId, blockId, callback)
  local pageNum = 1
  AsyncProcess.requestRankList(playerId, blockId, pageNum, Define.BIDDING_RANK_PAGE_SHOW_NUM * 4, function(data)
    local startIndex = (pageNum - 1) * Define.BIDDING_RANK_PAGE_SHOW_NUM + 1
    self:loadRankData(playerId, blockId, startIndex, data)
    local resultData = self:getClientRankList(playerId, blockId, startIndex)
    callback(resultData)
  end, function(failMessage)
  end)
end

function BiddingRankCatchManager:getClientRankInfo(playerId, blockId, mapId)
  local info = self:getPlayerBuild(blockId, mapId)
  local isLike = self:isLikeBuild(playerId, blockId, mapId)
  return {
    userId = info.userId,
    mapId = info.mapId,
    picUrl = info.picUrl,
    likeNumber = info.likeNumber,
    rank = info.rank,
    nickName = info.nickName,
    userLikeType = isLike
  }
end

function BiddingRankCatchManager:getClientRankList(playerId, blockId, startIndex, num)
  local catchRankList = blockRankList[blockId]
  if not catchRankList then
    return {}
  end
  num = num or Define.BIDDING_RANK_PAGE_SHOW_NUM
  local resultData = {}
  local rankList = catchRankList.rankList
  local upMap = catchRankList.upMap
  local endIndex = math.min(startIndex + num - 1, catchRankList.maxNum)
  for i = startIndex, endIndex do
    local info = rankList[i]
    if info.userId then
      table.insert(resultData, {
        userId = info.userId,
        mapId = info.mapId,
        picUrl = info.picUrl,
        likeNumber = info.likeNumber,
        rank = info.rank,
        nickName = info.nickName,
        userLikeType = upMap[playerId][info.mapId]
      })
    end
  end
  return resultData
end

function BiddingRankCatchManager:getRankMaxNum(blockId)
  local catchRankList = blockRankList[blockId]
  if not catchRankList then
    return 0
  end
  return catchRankList.maxNum
end

function BiddingRankCatchManager:clearRankCatch(blockId)
  local catchRankList = blockRankList[blockId]
  if not catchRankList then
    return
  end
  local rankList = catchRankList.rankList
  for i, rank in pairs(rankList) do
    rank.isLost = true
  end
end

BiddingRankCatchManager:init()
