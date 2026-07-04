local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")
local CarConfig = T(Config, "CarConfig")
local HouseConfig = T(Config, "HouseConfig")
local Player = _ENV.Player

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
