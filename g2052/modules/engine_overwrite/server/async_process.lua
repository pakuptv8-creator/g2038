local debugPort = require("common.debugport")
local self = AsyncProcess

function AsyncProcess.costDiamonds(userId, uniqueId, price, callback, clientInfo)
  local url = string.format("%s/pay/api/v2/inner/pay/users/purchase/game/props", self.ServerHttpHost)
  local body = {
    gameId = World.GameName,
    engineVersion = debugPort.engineVersion,
    appVersion = clientInfo.version_code or 0,
    packageName = clientInfo.package_name or 0,
    userId = userId,
    propsId = uniqueId,
    currency = 1,
    quantity = price
  }
  self.HttpRequest("POST", url, nil, function(response, isSuccess)
    local data = response.data
    if not isSuccess then
      if callback then
        callback(userId, false)
      end
      return
    end
    if callback then
      local success, consume = xpcall(callback, debug.traceback, userId, true)
      if not success then
        print("-----------[SCRIPT_EXCEPTION]------------\n", consume)
        consume = false
      end
      if consume == nil then
        consume = true
      end
      AsyncProcess:ProcessOrder(userId, data.orderId, consume)
    else
      AsyncProcess:ProcessOrder(userId, data.orderId, true)
    end
  end, body)
end
