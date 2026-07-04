local handles = T(Player, "PackageHandlers")
local BusinessHelper = T(Lib, "BusinessHelper")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")

function handles:OnRequestBuy(packet)
  if self.isPlayer then
    BusinessHelper:onRequestBuy(self, packet.params)
  end
end

function handles:CSBuyBusinessItem(packet)
  if self.isBusinessBuying then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "gui.do.not.repeat.purchase")
    return
  end
  local goodsCfg = BusinessGoodsConfig:getCfgById(packet.goodsId)
  if goodsCfg then
    local businessData = self:getBusinessData()
    if businessData[goodsCfg.goodsId] then
      self:sendPacket({
        pid = "SCBuyBusinessSuccess",
        isSucceed = false
      })
      return
    end
    self.isBusinessBuying = true
    local goodsType = goodsCfg.goodsType
    local uniqueId = tostring(packet.goodsId) .. tostring(goodsCfg.goodsType) .. tostring(goodsCfg.itemId)
    Lib.payMoney(self, uniqueId, 0, goodsCfg.price, function(isSucceed)
      if isSucceed then
        businessData[goodsCfg.goodsId] = true
        self:setBusinessData(businessData)
        self:sendPacket({
          pid = "SCBuyBusinessSuccess",
          isSucceed = true,
          goodsId = goodsCfg.goodsId,
          fromShop = packet.fromShop
        })
        if goodsType == Define.BUSINESS_ITEM_TYPE.Car then
          self:updateAllVehicleFlag()
        elseif goodsType == Define.BUSINESS_ITEM_TYPE.House then
          self:updateAllHouseFlag()
        end
      else
        self:sendPacket({
          pid = "SCBuyBusinessSuccess",
          isSucceed = false
        })
      end
      self.isBusinessBuying = false
    end, 1, 6)
  else
    self:sendPacket({
      pid = "SCBuyBusinessSuccess",
      isSucceed = false
    })
  end
end
