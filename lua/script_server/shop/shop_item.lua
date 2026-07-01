local shopbase = require("script_server.shop.shop_base")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local M = Lib.derive(shopbase)

function M:init()
  local config = T(Config, "PayShopConfig")
  shopbase.init(self, Define.SHOP_TYPE.ITEM, config)
end

function M:initShopItem(player)
  local itemShopInfo = player:getShopBuyInfo()
  local curTime = os.time()
  local oldTime
  for time, _ in pairs(itemShopInfo) do
    if Lib.confirmDateChanged(time, curTime, World.cfg.offsetTime) then
      oldTime = time
    end
  end
  if oldTime then
    itemShopInfo[oldTime] = nil
    itemShopInfo[curTime] = {
      haveBuy = {},
      randomItem = self.config:getNewRandomItems()
    }
  end
  if not next(itemShopInfo) then
    itemShopInfo[curTime] = {
      haveBuy = {},
      randomItem = self.config:getNewRandomItems()
    }
  end
  self:updateShopBuyInfo(player, itemShopInfo)
end

function M:updateShopBuyInfo(player, data)
  player:setShopBuyInfo(data)
end

function M:onBuySuccess(player, item, items, params)
  for fullName, count in pairs(items) do
    player:obtainItemsByFullName(fullName, count, "shop_buy")
  end
  local itemShopInfo = player:getShopBuyInfo()
  for _, data in pairs(itemShopInfo) do
    if data.haveBuy[params.itemId] then
      data.haveBuy[params.itemId] = data.haveBuy[params.itemId] + params.count
    else
      data.haveBuy[params.itemId] = params.count
    end
  end
  Lib.logInfo("onBuySuccess params.itemId = ", params.itemId)
  player:updateTaskStatus(Define.TASK_TYPE.SHOP_PURCHASE, 1, params.itemId, params.count)
  self:updateShopBuyInfo(player, itemShopInfo)
  self:sendBuyResult(player, Define.BuyingTips.buy_finish, params.itemId, params.count)
  GameAnalytics.Design(player.platformUserId, params.count, {
    "shop_success_" .. Define.SHOP_BEHAVIOR_NAME[item.tabId] .. "_" .. item.subTabId,
    params.itemId
  })
  local price = math.ceil(item.originalPrice * item.discount)
  local costParts = {
    unit_price = price,
    total_price = price * params.count,
    counts = params.count,
    change_key = params.itemId,
    tab_type_key = Define.SHOP_BEHAVIOR_NAME[item.tabId] .. "_" .. item.subTabId
  }
  if item.isPay then
    player:diamondCostNewDesign(Define.newDesignEventKey.SHOP_DIAMOND_COST, costParts)
  else
    player:coinCostNewDesign(Define.newDesignEventKey.SHOP_COIN_COST, costParts)
  end
end

function M:onCheckTheGoods(player, params)
  local item = self.config:getItemByItemId(params.itemId)
  local isCanBuy = true
  local canBuyCount = item.buyCount
  if item.buyCount > 0 then
    local itemShopInfo = player:getShopBuyInfo()
    for _, data in pairs(itemShopInfo or {}) do
      for itemId, count in pairs(data.haveBuy or {}) do
        if item.id == itemId then
          canBuyCount = item.buyCount - count
        end
      end
    end
    if canBuyCount < params.count then
      isCanBuy = false
    end
  end
  if not isCanBuy then
    self:sendBuyResult(player, Define.BuyingTips.item_error)
    return
  end
  local items = {}
  for fullName, count in pairs(item.items) do
    items[fullName] = count * params.count
  end
  isCanBuy = player:determineBackpackCapacity(items)
  if not isCanBuy then
    self:sendBuyResult(player, Define.BuyingTips.not_get)
    return
  end
  return item, items
end

M:init()
return M
