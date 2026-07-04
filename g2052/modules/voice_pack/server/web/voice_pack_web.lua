local self = AsyncProcess
AsyncProcess = AsyncProcess
local SetCustomValueApi = "%s/bedwar/api/v1/inner/user/game/date/value/set"
local GetCustomValueListApi = "%s/bedwar/api/v1/inner/user/game/date/batch/value/get"

function AsyncProcess.GetPlayerVoicePackData(userId, func)
  local url = string.format(GetCustomValueListApi, self.ServerHttpHost)
  local params = {
    {
      "userIds",
      tostring(userId)
    },
    {
      "fields",
      "voice_pack_list"
    }
  }
  self.HttpRequest("GET", url, params, function(response, isSuccess)
    if not isSuccess then
      return
    end
    local data = response.data and response.data[tostring(userId)]
    if data and data[1] then
      func(data[1].value)
    else
      func("")
    end
  end)
end

function AsyncProcess.SetPlayerVoicePackData(userId, data)
  local url = string.format(SetCustomValueApi, self.ServerHttpHost)
  local body = {
    params = {
      {
        dataType = "string",
        key = "voice_pack_list",
        value = data
      }
    },
    requestType = "1",
    userId = tonumber(userId)
  }
  self.HttpRequest("POST", url, {}, function(_, _)
  end, body)
end
