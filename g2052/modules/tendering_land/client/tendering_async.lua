local self = AsyncProcess
local strfmt = string.format
local cjson = require("cjson")

function AsyncProcess.SendMayorEmail(userId, content, callback)
  local url = strfmt("%s/game/api/v1/game/bidding/saveMayorMail", self.ClientHttpHost)
  local body = {content = content, userId = userId}
  local params = {}
  self.HttpRequest("POST", url, params, function(response, isSuccess)
    if not isSuccess then
      print("SendMayorEmail Error: ", response.code)
      if callback then
        callback(false)
      end
      return
    end
    if callback then
      callback(true)
    end
  end, body)
end
