local Player = _ENV.Player
local BusinessHelper = T(Lib, "BusinessHelper")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")
local CarConfig = T(Config, "CarConfig")
local HouseConfig = T(Config, "HouseConfig")

function Player:getWalletBalance(coinName)
  local wallet = self:data("wallet")
  return wallet[coinName] and wallet[coinName].count or 0
end

function Player:showBuyPrivilegeDialog(needPrivilege)
  if needPrivilege then
    local privilegeCfg = BusinessHelper:getProductCfg(Define.PRODUCT_TYPE.PRIVILEGE, true)
    if privilegeCfg then
      local data = privilegeCfg:getCfgByType(needPrivilege)
      if not data then
        return
      end
      data.productType = Define.PRODUCT_TYPE.PRIVILEGE
      BusinessHelper:onClientBuy(data)
    end
  end
end

function Player:showBuyBusinessItemTips(goodsType, data, fromShop)
  if self.isBusinessBuying then
    return
  end
  local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(goodsType, data.id)
  if goodsCfg then
    local businessData = Me:getBusinessData()
    if businessData[goodsCfg.goodsId] then
      return
    end
    local params = {
      icon = data.icon,
      price = goodsCfg.price,
      goodsId = goodsCfg.goodsId,
      fromShop = fromShop
    }
    UI:openWnd("g2052PayDialog", {
      useCashCoupon = true,
      title = "g2052.gui.tendering.tips",
      data = params,
      confirmFun = function()
        if Lib.checkMoney(Me, 0, goodsCfg.price, true) then
          Me.isBusinessBuying = true
          Me:sendPacket({
            pid = "CSBuyBusinessItem",
            goodsId = goodsCfg.goodsId,
            fromShop = fromShop
          })
        else
          Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "gui.insufficient.funds")
          Interface.onRecharge(1)
        end
      end
    })
  end
end

function Player:getBusinessItemIconInfo(goodsCfg)
  if goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Dress then
    return AppearanceConfig:getCfgById(goodsCfg.itemId)
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Pet then
    return PetConfig:getCfgById(goodsCfg.itemId)
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.Car then
    return CarConfig:getCfgById(goodsCfg.itemId)
  elseif goodsCfg.goodsType == Define.BUSINESS_ITEM_TYPE.House then
    return HouseConfig:getCfgById(goodsCfg.itemId)
  end
end

function Player:getBusinessItemCfg(goodsType, itemId)
  if goodsType == Define.BUSINESS_ITEM_TYPE.Dress then
    return AppearanceConfig:getCfgById(itemId)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Pet then
    return PetConfig:getCfgById(itemId)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Car then
    return CarConfig:getCfgById(itemId)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.House then
    return HouseConfig:getCfgById(itemId)
  end
end

function Player:checkBusinessItemUnlock(goodsType, itemId)
  local canUse = false
  local itemCfg = self:getBusinessItemCfg(goodsType, itemId)
  if itemCfg == nil then
    return false
  end
  if goodsType == Define.BUSINESS_ITEM_TYPE.Dress then
    canUse = self:checkAppearanceUnlock(itemCfg)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Pet then
    canUse = self:checkPetUnlock(itemCfg)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.Car then
    canUse = self:checkCarUnlock(itemCfg)
  elseif goodsType == Define.BUSINESS_ITEM_TYPE.House then
    canUse = self:checkHouseUnlock(itemCfg)
  end
  return canUse
end
