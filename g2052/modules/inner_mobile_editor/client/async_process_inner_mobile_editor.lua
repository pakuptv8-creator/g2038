local self = AsyncProcess
local strfmt = string.format
local cjson = require("cjson")

function AsyncProcess.UploadMapScreenShot(fileName, filePath, fileType, needPreview, callback)
  local url = strfmt("%s/slow/api/v1/file/map/image", self.ClientHttpHost)
  local params = {
    {"fileName", fileName},
    {"fileType", fileType},
    {
      "needPreview",
      needPreview
    }
  }
  self.HttpRequest("MULTIPART_POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AsyncProcess UploadMapScreenShot Error: ", response.code)
    end
    if callback then
      callback(response.data, isSuccess)
    end
  end, filePath, true)
end

function AsyncProcess.UploadMap(filePath, fileType, callback)
  local url = strfmt("%s/slow/api/v1/file/map", self.ClientHttpHost)
  local params = {
    {"fileType", fileType}
  }
  self.HttpRequest("MULTIPART_POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("AsyncProcess UploadMap Error: ", response.code)
    end
    if callback then
      callback(response.data, isSuccess)
    end
  end, filePath, true)
end

function AsyncProcess.PushMapData(blockId, picUrl, mapResourceUrl, type, callback)
  local url = strfmt("%s/game/api/v1/game/bidding/updateUserGameBlock", self.ClientHttpHost)
  local body = {
    blockId = blockId,
    gameId = World.GameName,
    mapResourceUrl = mapResourceUrl,
    picUrl = picUrl,
    type = type,
    userId = Me.platformUserId
  }
  self.HttpRequest("POST", url, {}, function(response, isSuccess)
    if callback then
      callback(isSuccess)
    end
  end, body, true)
end

function AsyncProcess.GetMapBlockData(blockId, callback)
  local url = strfmt("%s/game/api/v1/game/bidding/getUserGameBlock", self.ClientHttpHost)
  local params = {
    {"blockId", blockId},
    {
      "gameId",
      World.GameName
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if callback then
      callback(response.data, isSuccess)
    end
  end, {}, true)
end
