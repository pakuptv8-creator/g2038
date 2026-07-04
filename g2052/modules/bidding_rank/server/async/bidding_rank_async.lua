local self = AsyncProcess
local strfmt = string.format
local roomGameConfig = Server.CurServer:getConfig()
local regionId = roomGameConfig:getRegionId()
local gameId = World.GameName or "g2052"

function AsyncProcess.requestRankList(playerId, blockId, pageNum, pageSize, callback, failCallback)
  local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", blockId)
  Lib.logDebug({
    {"userId", playerId},
    {"blockId", blockId},
    {"gameId", gameId},
    {
      "pageNo",
      pageNum - 1
    },
    {"pageSize", pageSize},
    {"stage", blockStatus},
    {"regionId", regionId}
  })
  local url = strfmt("%s/game/api/v1/inner/game/bidding/findGameBlockUserLikeRankPage", self.ServerHttpHost)
  self.HttpRequest("GET", url, {
    {"userId", playerId},
    {"blockId", blockId},
    {"gameId", gameId},
    {
      "pageNo",
      pageNum - 1
    },
    {"pageSize", pageSize},
    {"stage", blockStatus},
    {"regionId", regionId}
  }, function(response, isSuccess)
    if not isSuccess then
      Lib.logDebug("requestRankList fail === ", response)
      local code = response.code
      if code == 27110 then
        failCallback()
      elseif code == 27112 then
      elseif code == 27113 then
      elseif code == 27114 then
      end
      return
    end
    Lib.logDebug("requestRankList === ", response.data)
    callback(response.data)
  end, {}, false)
end

function AsyncProcess.requestFindPlayer(userId, blockId, targetId, callback, failCallback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/findGameBlockUserLikeRankByUserId", self.ServerHttpHost)
  local stage = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", blockId)
  Lib.logDebug("========= ", blockId, stage)
  self.HttpRequest("GET", url, {
    {"userId", userId},
    {"blockId", blockId},
    {"gameId", gameId},
    {"targetId", targetId},
    {"regionId", regionId},
    {"stage", stage}
  }, function(response, isSuccess)
    Lib.logDebug("---------------------", response)
    if not isSuccess then
      local code = response.code
      if code == 27110 then
        failCallback()
      elseif code == 27112 then
      elseif code == 27113 then
      elseif code == 27114 then
      end
      return
    end
    callback(response.data)
  end, {}, false)
end

function AsyncProcess.GetFileData(url, callback)
  AsyncProcess.HttpRequest("GET", url, {}, callback)
end

function AsyncProcess.likeBiddingBuild(userId, blockId, mapId, likeType, callback, failCallback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/gameBlockMapLike", self.ServerHttpHost)
  local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", blockId)
  local body = {
    userId = userId,
    blockId = blockId,
    mapId = mapId,
    gameId = gameId,
    stage = blockStatus,
    likeType = likeType,
    regionId = regionId
  }
  Lib.logDebug(" params === ", body)
  self.HttpRequest("POST", url, {}, function(response, isSuccess)
    if not isSuccess then
      Lib.logDebug("AsyncProcess likeBiddingBuild Error: ", response.code, response)
      local code = response.code
      if code == 27110 then
        failCallback()
      elseif code == 27112 then
      elseif code == 27113 then
      elseif code == 27114 then
      end
      return
    end
    Lib.logDebug(response)
    callback(response.data)
  end, body, false)
end

function AsyncProcess.requestAuditRankList(blockId, pageNum, pageSize, findParams, callback, failCallback)
  local auditStatus = findParams.auditStatus
  if auditStatus == Define.AUDIT_STATUS.ALL then
    auditStatus = nil
  end
  local body = {
    blockId = blockId,
    gameId = gameId,
    regionId = regionId,
    auditStatus = auditStatus,
    userId = findParams.findId,
    mapId = findParams.mapId
  }
  Lib.logDebug("body === ", body)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/findGameBlockBiddingPageInner", self.ServerHttpHost)
  self.HttpRequest("POST", url, {
    {
      "pageNo",
      pageNum - 1
    },
    {"pageSize", pageSize}
  }, function(response, isSuccess)
    if not isSuccess then
      Lib.logDebug("response not isSuccess ===", response)
      local code = response.code
      if code == 27110 then
        failCallback(response)
      elseif code == 27112 then
      elseif code == 27113 then
      elseif code == 27114 then
      end
      return
    end
    Lib.logDebug("response ===", response.data)
    callback(response.data)
  end, body, false)
end

function AsyncProcess.auditMap(playerId, auditType, mapId, callback, failCallback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/auditMap", self.ServerHttpHost)
  self.HttpRequest("POST", url, {}, function(response, isSuccess)
    Lib.logDebug("response ===", response)
    if not isSuccess then
      failCallback()
    end
    callback(response.code, response.data)
  end, {
    auditOperator = tostring(playerId),
    auditType = auditType,
    mapId = mapId
  }, false)
end

function AsyncProcess.getRecommendLandList(userId, blockId, callback)
  local params = {
    {"gameId", gameId},
    {"regionId", regionId},
    {"userId", userId},
    {"blockId", blockId},
    {"pageSize", 4}
  }
  local url = strfmt("%s/game/api/v1/inner/game/bidding/findRecommendList", self.ServerHttpHost)
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("getRecommendLandList not isSuccess ===", Lib.v2s(response))
      return
    end
    callback(response.data)
  end, {}, true)
end
