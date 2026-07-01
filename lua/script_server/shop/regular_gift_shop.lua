local RegularGiftShop = T(Store, "RegularGiftShop")
local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local M = RegularGiftShop

function M:init()
  self.config1 = RegularGiftConfig
  self.config2 = RegularGiftItemConfig
end

function M:checkIsCanBuy(player, item, buyCount)
  if not item then
    self:sendBuyRegularResult(player, "ui.chat.voiceBuyFail", false)
    return false
  end
  local buyCount = 1
  local buyInfo = player:getRegularBuyInfo()
  local isBuy = false
  for ids, status in pairs(buyInfo) do
    if ids == tostring(item.id) then
      isBuy = true
      if item.buyCount > 0 and buyInfo[tostring(item.id)].curBuyNum + buyCount > item.buyCount then
        self:sendBuyRegularResult(player, "regular_buy_count_fail", false)
        return false
      end
    end
  end
  local items = {}
  for key, val in pairs(item.giftContent) do
    local goodInfo = self.config2:getConfigById(val)
    if goodInfo.itemType == 1 then
      items[goodInfo.itemName] = goodInfo.itemCount
    end
  end
  local isPutBag = player:determineBackpackCapacity(items)
  if not isPutBag then
    self:sendBuyRegularResult(player, "gui_bag_not_enough", false)
    return false
  end
  return true
end

function M:operationBuy(player, itemId, buyCount)
  if player.isBuyingRegularGift then
    return
  end
  player.isBuyingRegularGift = true
  local buyCount = 1
  local item = self.config1:getConfigById(itemId)
  local isCanBuy = self:checkIsCanBuy(player, item, buyCount)
  if isCanBuy then
    local totalPrice = buyCount * item.finalPrice
    if totalPrice < 0 then
      self:sendBuyRegularResult(player, "ui.chat.voiceBuyFail", false)
      return false
    end
    local costParts = {
      unit_price = item.finalPrice,
      total_price = totalPrice,
      counts = totalPrice,
      change_key = itemId,
      tab_type = item.tabId
    }
    if totalPrice == 0 then
      self:onBuySuccess(player, item, buyCount)
      player:diamondCostNewDesign(Define.newDesignEventKey.REGULAR_GIFT_COST, costParts)
      return true
    elseif item.isPay then
      local success
      player:doConsumeDiamonds("gDiamonds", totalPrice, function(ret)
        success = ret
        if ret then
          self:onBuySuccess(player, item, buyCount)
          player:diamondCostNewDesign(Define.newDesignEventKey.REGULAR_GIFT_COST, costParts)
        end
      end, Define.GAME_GIFT_UNIQUE_ID .. itemId)
      if success then
        return true
      end
    else
      do
        local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.currencyType), totalPrice, false, false, "regularGiftShop")
        if checkMoney then
          self:onBuySuccess(player, item, buyCount)
          return true
        end
      end
    end
  end
  local parts = {
    "RegularGift_click",
    itemId
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
  return false
end

function M:onBuySuccess(player, item, count)
  local buyInfo = player:getRegularBuyInfo()
  if buyInfo[tostring(item.id)] == nil then
    buyInfo[tostring(item.id)] = {}
    buyInfo[tostring(item.id)].curBuyNum = count
    buyInfo[tostring(item.id)].firstBuyTime = os.time()
  else
    buyInfo[tostring(item.id)].curBuyNum = buyInfo[tostring(item.id)].curBuyNum + count
  end
  for key, val in pairs(item.giftContent) do
    local goodInfo = self.config2:getConfigById(val)
    if goodInfo.itemType == 1 then
      player:obtainItemsByFullName(goodInfo.itemName, goodInfo.itemCount * count, "regular_gift_item")
    elseif goodInfo.itemType == 2 then
      player:addCurrency("gold_coin", goodInfo.itemCount, "regular_gift_item")
    end
  end
  player:setRegularBuyInfo(buyInfo)
  self:sendBuyRegularResult(player, item.id, "ui_buy_finish", true)
  local parts = {
    "RegularGift_success",
    item.id
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
end

function M:sendBuyRegularResult(player, itemId, msg, result)
  player.isBuyingRegularGift = false
  player:sendPacket({
    pid = "sendBuyRegularResult",
    message = msg,
    itemId = itemId,
    result = result,
    time = 40
  })
end

function M:updateRegularGiftTime(player)
  local buyInfo = player:getRegularBuyInfo()
  local curTime = os.time()
  for key, val in pairs(buyInfo) do
    local item = self.config1:getConfigById(key)
    if item then
      if item.tabId == 1 then
        if curTime == Lib.getDayStartTime(curTime) then
          buyInfo[key] = nil
        elseif not Lib.isSameDay(curTime, buyInfo[key].firstBuyTime) then
          buyInfo[key] = nil
        end
      elseif item.tabId == 2 then
        if curTime == Lib.getWeekStartTime(curTime) + 86400 then
          buyInfo[key] = nil
        elseif not Lib.isSameWeek(curTime - 86400, buyInfo[key].firstBuyTime - 86400) then
          buyInfo[key] = nil
        end
      elseif item.tabId == 3 then
        if curTime == Lib.getMonthStartTime(curTime) then
          buyInfo[key] = nil
        elseif not self:isSameMonth(curTime, buyInfo[key].firstBuyTime) then
          buyInfo[key] = nil
        end
      end
    else
      buyInfo[key] = nil
    end
  end
  player:setRegularBuyInfo(buyInfo)
  player:sendPacket({
    pid = "sendRegularServerTime",
    curServerTime = curTime
  })
end

function M:isSameMonth(time1, time2)
  return Lib.getMonthEndTime(time1) == Lib.getMonthEndTime(time2)
end

M:init()
return M
