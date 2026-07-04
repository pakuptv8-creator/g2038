local HighlightDataHandler = T(Lib, "HighlightDataHandler")
local cjson = require("cjson")

function HighlightDataHandler:getReportUrl()
  if self.reportUrl == nil then
    local baseUrl = Server.CurServer:getServerHttpHost()
    self.reportUrl = baseUrl .. "/game/api/v1/inner/highlight-data/report"
  end
  return self.reportUrl
end

function HighlightDataHandler:reportHighlightData(userId, gameType, gameDataKey, gameDataValue)
  if not userId or userId == 0 then
    print("HighlightDataHandler:reportHighlightData userId is nil")
    return
  end
  local reportUrl = self:getReportUrl()
  if reportUrl == nil or #reportUrl == 0 then
    print("HighlightDataHandler:reportHighlightData reportUrl is nil")
    return
  end
  local gameData = {}
  gameData[gameDataKey] = gameDataValue
  local body = {
    gameType = gameType,
    userId = userId,
    gameData = gameData
  }
  print("HighlightDataHandler:reportHighlightData url:" .. reportUrl .. " params:" .. Lib.v2s(body))
  AsyncProcess.HttpRequest("POST", reportUrl, {}, function(response)
    local content = cjson.encode(response)
    local code = response.code
    local message = response.message
    print("HighlightDataHandler:reportHighlightData response content:" .. tostring(content) .. " code:" .. tostring(code) .. " message:" .. tostring(message))
  end, body)
end

return HighlightDataHandler
