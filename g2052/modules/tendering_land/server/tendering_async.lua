local self = AsyncProcess
local strfmt = string.format
local roomGameConfig = Server.CurServer:getConfig()
local regionId = roomGameConfig:getRegionId()

function AsyncProcess.GetCurSeasonTenderingResult(callback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/getBiddingResult", self.ServerHttpHost)
  local params = {
    {"regionId", regionId}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetCurSeasonTenderingResult Error: ", response.code)
      return
    end
    callback(response.data or {})
  end, {}, true)
end

function AsyncProcess.GetTenderingSocialAward(callback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/getUserBiddingResult", self.ServerHttpHost)
  local params = {
    {"regionId", regionId}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetTenderingSocialAward Error: ", response.code)
      return
    end
    callback(response.data or {})
  end, {}, true)
end

function AsyncProcess.GetPlayerTenderingBlockIdList(userId, callback)
  local url = strfmt("%s/game/api/v1/inner/game/bidding/userAuditPassBiddingBlock", self.ServerHttpHost)
  local params = {
    {"regionId", regionId},
    {"userId", userId}
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      print("GetPlayerTenderingBlockIdList Error: ", response.code)
      return
    end
    callback(response.data or {}, userId, regionId)
  end, {}, true)
end
