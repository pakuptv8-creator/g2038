local self = AsyncProcess
local strfmt = string.format
local cjson = require("cjson")
local uuid = require("common.uuid")
local DramaClientHelper = T(Lib, "DramaClientHelper")
local engine_version = EngineVersionSetting:getEngineVersion()
local configVersion = World.cfg.dramaSetting.configVersion

function AsyncProcess.GetDramaListWithPage(callback, pageNo, pageSize, tabType, lastRecordCreateTimeLong, lastRecordCurrentNumber, lastRecordId)
  local url = strfmt("%s/gameaide/api/v1/%s/scripts/query", self.ClientHttpHost, World.GameName)
  local params = {
    {
      "userId",
      Me.platformUserId
    }
  }
  local body = {
    lastRecordCreateTimeLong = lastRecordCreateTimeLong,
    lastRecordCurrentNumber = lastRecordCurrentNumber,
    engineVersion = engine_version,
    configVersion = configVersion,
    lastRecordId = lastRecordId or "",
    page = pageNo,
    regionId = DramaClientHelper.regionId,
    size = pageSize,
    type = tabType
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetDramaListWithPage Error: ", response.code)
      return
    end
    if callback then
      callback(response.data or {})
    end
  end, body, true)
end

function AsyncProcess.GetDramaDetailData(callback, id, userId)
  local url = strfmt("%s/gameaide/api/v1/%s/scripts", self.ClientHttpHost, World.GameName)
  local params = {
    {"userId", userId},
    {"scriptId", id}
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetDramaDetailData Error: ", response.code)
      return
    end
    if callback then
      callback(response.data)
    end
  end, body, true)
end

function AsyncProcess.ThumbUpOthersPlayer(callback, userId, targetId)
  local url = strfmt("%s/gameaide/api/v1/%s/scripts/like/user", self.ClientHttpHost, World.GameName)
  local params = {}
  local body = {
    userId = userId,
    targetId = targetId,
    regionId = DramaClientHelper.regionId,
    engineVersion = engine_version,
    configVersion = configVersion
  }
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("ThumbUpOthersPlayer Error: ", response.code)
      callback(false)
      return
    end
    if callback then
      callback(true)
    end
  end, body, true)
end

function AsyncProcess.GetLikesNumByUserID(callback, userId)
  local url = strfmt("%s/gameaide/api/v1/%s/scripts/like/user", self.ClientHttpHost, World.GameName)
  local params = {
    {"userId", userId},
    {
      "regionId",
      DramaClientHelper.regionId
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetLikesNumByUserID Error: ", response.code)
      return
    end
    if callback then
      response.data.likes = response.data.score or 0
      callback(response.data)
    end
  end, {}, true)
end

function AsyncProcess.GetLikeRankingListWithPage(callback, pageNo, pageSize)
  local url = strfmt("%s/gameaide/api/v1/g2052/scripts/like/user/ranking", self.ClientHttpHost)
  local params = {
    {
      "page",
      tostring(pageNo)
    },
    {
      "size",
      tostring(pageSize)
    },
    {
      "regionId",
      tostring(DramaClientHelper.regionId)
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AsyncProcess.GetLikeRankingListWithPage Error: ", response.code)
      return
    end
    callback(response, isSuccess, url, params, body)
  end, body, true)
end

function AsyncProcess.GetHistoryDrama(callback)
  local url = strfmt("%s/gameaide/api/v1/g2052/scripts/history", self.ClientHttpHost)
  local params = {
    {
      "userId",
      Me.platformUserId
    }
  }
  local body = {}
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AsyncProcess.GetHistoryDrama Error: ", response.code)
      return
    end
    callback(response, isSuccess, url, params, body)
  end, body, true)
end
