function Lib.equals(t1, t2)
  if t1 == t2 then
    return true
  end
  local t1Type = type(t1)
  local t2Type = type(t2)
  if t1Type ~= t2Type then
    return false
  end
  if t1Type ~= "table" then
    return false
  end
  local t1Empty = not next(t1)
  local t2Empty = not next(t2)
  if t1Empty and t2Empty then
    return true
  end
  if t1Empty ~= t2Empty then
    return false
  end
  for k, v in pairs(t1) do
    local t2v = t2[k]
    if t2v == nil then
      return false
    end
    if not Lib.equals(v, t2v) then
      return false
    end
  end
  for k, v in pairs(t2) do
    local t1v = t1[k]
    if t1v == nil then
      return false
    end
  end
  return true
end

local PayLocks = {}

function Lib.payMoney(player, uniqueId, coinId, price, callback, goodsNum, reason)
  if World.isClient then
    return
  end
  local key = tostring(player.platformUserId) .. "-" .. uniqueId
  if PayLocks[key] then
    return
  end
  if price <= 0 or coinId == 0 and (os.getenv("startFromWorldEditor") or string.sub(World.GameName or "", -1) == "b") then
    callback(true)
    GameAnalytics.OnPlayerCostMoneyExchangeItems(player, uniqueId, coinId, price, goodsNum, reason)
    Lib.reportPayMoney(player, uniqueId, coinId, price, goodsNum, reason)
    return
  end
  if not Lib.checkMoney(player, coinId, price) then
    callback(false)
    return
  end
  if coinId <= 2 then
    PayLocks[key] = true
    AsyncProcess.BuyGoods(player.platformUserId, tonumber(uniqueId) or 1, coinId, price, nil, function(_, ret, _)
      PayLocks[key] = nil
      local callbackResult = callback(ret)
      if ret then
        Lib.emitEvent(Event.EVENT_PAY_MONEY_SUCCESS, player, coinId, price)
        GameAnalytics.OnPlayerCostMoneyExchangeItems(player, uniqueId, coinId, price, goodsNum, reason)
        Lib.reportPayMoney(player, uniqueId, coinId, price, goodsNum, reason)
      end
      return callbackResult
    end)
    return
  end
  local coinName = Coin:coinNameByCoinId(coinId)
  player:payCurrency(coinName, price, false, false, uniqueId)
  Lib.emitEvent(Event.EVENT_PAY_MONEY_SUCCESS, player, coinId, price)
  callback(true)
  GameAnalytics.OnPlayerCostMoneyExchangeItems(player, uniqueId, coinId, price, goodsNum, reason)
  Lib.reportPayMoney(player, uniqueId, coinId, price, goodsNum, reason)
end

function Lib.reportPayMoney(player, uniqueId, coinId, price, goodsNum, reason)
  if World.isClient then
    return
  end
  local currency_balance_num = player:getCurrency(Coin:coinNameByCoinId(coinId)) and player:getCurrency(Coin:coinNameByCoinId(coinId)).count or 0
  if type(currency_balance_num) ~= "number" or type(price) ~= "number" then
    return
  end
  local reportData = {
    g2052_pay_coin_id = coinId,
    g2052_pay_coin_num = currency_balance_num,
    g2052_pay_price = price,
    g2052_pay_unique_id = tostring(uniqueId),
    g2052_pay_goods_num = goodsNum or 1,
    g2052_pay_reason = reason or Define.ExchangeItemsReason.BuyShop
  }
  Plugins.CallTargetPluginFunc("report", "report", "g2052_pay_money", reportData, player)
end
