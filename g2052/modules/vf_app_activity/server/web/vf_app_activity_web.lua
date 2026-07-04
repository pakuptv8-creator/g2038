local self = AsyncProcess
AsyncProcess = AsyncProcess
local AddGameBadgeApi = "%s/activity/api/v1/inner/game/badge"

function AsyncProcess.AddGameBadge(userId, language, func)
  local path = string.format(AddGameBadgeApi, AsyncProcess.ServerHttpHost)
  local params = {
    {
      "gameId",
      World.GameName
    },
    {"userId", userId},
    {"language", language}
  }
  self.HttpRequest("POST", path, params, function(response, isSuccess)
    if not isSuccess then
      return
    end
    if response.code ~= 1 then
      return
    end
    func(response.data)
  end)
end

function AsyncProcess.RemoveGameBadge(userId)
  local path = string.format(AddGameBadgeApi, AsyncProcess.ServerHttpHost)
  local params = {
    {
      "gameId",
      World.GameName
    },
    {"userId", userId}
  }
  self.HttpRequest("DELETE", path, params, function()
  end)
end
