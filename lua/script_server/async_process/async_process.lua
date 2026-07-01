local RedisHandler = require("script_server.redishandler")
local cjson = require("cjson")
local type = _ENV.type
local strfmt = string.format
local traceback = _ENV.traceback
local self = AsyncProcess
local gameName = World.GameName
local debugPort = require("common.debugport")

function AsyncProcess.RequestSpecificRankRange(name, count, callback)
  RedisHandler:ZRange(name, 0, count - 1, function(success, data)
    if not success then
      print("AsyncProcess.RequestSpecificRankRange request error", name, data)
    else
      Rank.ReceiveRankData(name, data)
      if callback then
        callback(true)
      end
    end
  end)
end

function AsyncProcess.RequestHGetAll(name, callback)
  RedisHandler:HGetAll(name, function(success, data)
    if not success then
      print("AsyncProcess.RequestHGetAll request error", name, data)
    else
      Lib.logDebug("RequestHGetAll name and data = ", name, data)
      Rank.ReceiveRankData(name, data)
      if callback then
        callback(true)
      end
    end
  end)
end

function AsyncProcess.RequestHSet(name, data, callback)
  RedisHandler:HSet(data, function(success, data)
    if not success then
      print("AsyncProcess.RequestHSet request error", data)
      if callback then
        callback(false)
      end
    else
      Rank.ReceiveRankData(name, data)
      if callback then
        callback(true)
      end
    end
  end)
end

function AsyncProcess.RequestLastWeekGymPlayerRankInfo(userId, name)
  RedisHandler:HGetAll(name, function(success, data)
    if not success then
      print("AsyncProcess.RequestLastWeekGymPlayerRankInfo request error", name, data)
    else
      Lib.logDebug("ReceiveLastWeekRankData name and data = ", name, data)
      Rank.ReceiveLastWeekRankData(userId, name, data)
    end
  end)
end

function AsyncProcess:ProcessOrder(userId, orderId, consume)
  if consume then
    local path = strfmt("%s/pay/api/v1/pay/users/game/props/billings", self.ServerHttpHost)
    local params = {
      {
        "orderId",
        tostring(orderId)
      }
    }
    self.HttpRequest("PUT", path, params, function(_, _)
      Lib.logInfo(string.format("[%s][ConsumeOrder]", gameName), "orderId=" .. orderId)
    end, {})
  else
    local path = strfmt("%s/pay/api/v1/pay/inner/users/game/props/billings/refund", self.ServerHttpHost)
    local params = {
      {
        "orderId",
        tostring(orderId)
      }
    }
    self.HttpRequest("PUT", path, params, function(_, _)
      Lib.logInfo(string.format("[%s][RefundOrder]", gameName), "orderId=" .. orderId)
      local player = Game.GetPlayerByUserId(userId)
      if player then
        AsyncProcess.LoadUserMoney(userId)
      end
    end, {})
  end
end

function AsyncProcess.BuyGoods(userId, uniqueId, currency, price, session, callback)
  local url = strfmt("%s/pay/api/v2/inner/pay/users/purchase/game/props", self.ServerHttpHost)
  local player = Game.GetPlayerByUserId(userId)
  if not player or not player:isValid() then
    return
  end
  local body = {
    gameId = gameName,
    engineVersion = tonumber(debugPort.engineVersion),
    appVersion = player.clientInfo and tonumber(player.clientInfo.version_code) or 0,
    packageName = player.clientInfo and player.clientInfo.package_name or 0,
    gameCashCoupon = player:getCurrency("gameCashCoupon", true).count,
    userId = userId,
    propsId = uniqueId,
    currency = currency,
    quantity = price
  }
  Lib.logInfo(string.format("[%s][PayDiamond]", gameName), "uniqueId=" .. tostring(uniqueId))
  self.HttpRequest("POST", url, nil, function(response, isSuccess)
    if not isSuccess then
      if callback then
        callback(userId, false, session)
      end
      return
    end
    local data = response.data
    if not player or not player:isValid() then
      AsyncProcess:ProcessOrder(userId, data.orderId, false)
      return
    end
    if callback then
      local success, consume = xpcall(callback, debug.traceback, userId, true, session)
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
    if data.gameCashCoupon then
      player:UpdateDiamondsAndGolds(data.gDiamonds, data.golds, data.gameCashCoupon.balance)
      if data.gameCashCoupon.usage and data.gameCashCoupon.usage > 0 then
        player:sendTip(1, "ui.cash.coupon.expend", 40, nil, nil, data.gameCashCoupon.usage, price - data.gameCashCoupon.usage)
      end
    else
      player:UpdateDiamondsAndGolds(data.gDiamonds, data.golds)
    end
  end, body)
end
