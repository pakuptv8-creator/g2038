local Shop = T(Store, "Shop")
local M = {}

function M:init(type, config, extraConfig)
  self.type = type
  self.config = config
  self.extraConfig = extraConfig or nil
end

function M:operation(player, params)
  if player.onBuyShopItem then
    return
  end
  player.onBuyShopItem = true
  local item, items = self:onCheckTheGoods(player, params)
  if item then
    local price = math.ceil(item.originalPrice * item.discount)
    price = price * params.count
    if item.isPay then
      player:doConsumeDiamonds("gDiamonds", price, function(ret)
        if ret then
          self:onBuySuccess(player, item, items, params)
        else
          self:sendBuyResult(player, Define.BuyingTips.no_gDiamonds)
        end
        player.onBuyShopItem = false
      end, params.itemId)
    else
      local checkMoney = player:payCurrency(Coin:coinNameByCoinId(item.currencyType), price, false, false, "ItemShop")
      if checkMoney then
        self:onBuySuccess(player, item, items, params)
      else
        self:sendBuyResult(player, Define.BuyingTips.no_gold)
      end
      player.onBuyShopItem = false
    end
  else
    player.onBuyShopItem = false
  end
end

function M:onBuySuccess(player, item, items, params)
end

function M:sendBuyResult(player, result, itemId, count)
  local packet = {
    pid = "ItemShopBuyResult",
    params = {
      result = result,
      itemId = itemId,
      count = count
    }
  }
  player:sendPacket(packet)
end

function M:onCheckTheGoods(player, params)
  local item = self.config:getItemByItemId(params.itemId)
  local items = {}
  for fullName, count in pairs(item.items) do
    items[fullName] = count * params.count
  end
  return item, items
end

function M:initShopItem(player)
end

return M
