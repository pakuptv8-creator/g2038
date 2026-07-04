local handles = T(Player, "PackageHandlers")
local BusinessHelper = T(Lib, "BusinessHelper")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")

function handles:SyncAllPlayerPrivilegeInfo(packet)
  BusinessHelper:setAllPlayerPrivilegeInfo(packet.info or {})
end

function handles:UpdateAllPlayerPrivilegeInfo(packet)
  local params = packet.params
  if params.platformUserId then
    BusinessHelper:updateAllPlayerPrivilegeInfo(params.platformUserId, params.data)
  end
end

function handles:SyncBuySuccess(packet)
  BusinessHelper:syncBuySuccess(packet.params)
end

function handles:openBuyPrivilegeDialog(packet)
  self:showBuyPrivilegeDialog(packet.needPrivilege)
end

function handles:ShowMarketUI(packet)
  local productType = packet.productType
  local subType = packet.subType
  if productType and subType then
    UI:openWnd("g2052Marketing", productType, subType)
  end
end

function handles:SCBuyBusinessSuccess(packet)
  if packet.isSucceed then
    local goodsCfg = BusinessGoodsConfig:getCfgById(packet.goodsId)
    if goodsCfg then
      UI:openWnd("businessAwardPopup", packet.goodsId)
    end
    local buy_type = 2
    if packet.goodsId then
      buy_type = 1
    end
    local reportData = {
      shop_goodsId = packet.goodsId or 0,
      buy_type = buy_type or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "shop_item_buy", reportData, Me)
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "gui.do.not.repeat.purchase")
  end
  Me.isBusinessBuying = false
end
