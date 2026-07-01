local Shop = T(Store, "Shop")
local M = {}
local shop_item = require("script_server.shop.shop_item")
local itemShop = {}

function M:init()
  itemShop = Lib.derive(shop_item)
end

function Shop:operationByType(player, params)
  if params.shopType == Define.SHOP_TYPE.ITEM then
    itemShop:operation(player, params)
  else
  end
end

function Shop:initShopInfo(player)
  itemShop:initShopItem(player)
end

M:init()
return M
