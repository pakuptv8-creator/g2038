local ProductBase = Lib.class("ProductBase")
local productCfg = {
  [Define.PRODUCT_TYPE.PRIVILEGE] = T(Config, "PrivilegeConfig")
}

function ProductBase:pushTip(player, tip)
  if World.isClient then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tip)
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, tip)
  end
end

function ProductBase:getCfg(needFun)
end

function ProductBase:checkWhetherCanBuy(player, params)
  if self.inTrading and self.inTrading[player.platformUserId] then
    return
  end
  local isEnough = self:verifyMoney(player, params)
  if not isEnough then
    self:pushTip(player, "gui.insufficient.funds")
    return false, Define.BUY_FAILURE_TYPE.MONEY
  end
  return true
end

function ProductBase:verifyMoney(player, params)
  local coinName = Coin:coinNameByCoinId(params.currency)
  local balance = player:getWalletBalance(coinName)
  local cfg = productCfg[params.productType]:getCfgById(params.id)
  if cfg and balance >= cfg.price then
    return true
  end
  return false
end

function ProductBase:getHaveStatus(player, params)
end

if World.isClient then
  function ProductBase:onClientBuy(params)
    local isCan, type = self:checkWhetherCanBuy(Me, params)
    
    if isCan then
      UI:openWnd("g2052PayDialog", {
        title = "gui.confirm.purchase",
        data = params,
        confirmFun = function(serialNumber)
          Me:sendPacket({
            pid = "OnRequestBuy",
            params = params
          })
        end
      })
    elseif type == Define.BUY_FAILURE_TYPE.MONEY then
      UI:openWnd("g2052PayDialog", {
        title = "gui.insufficient.funds",
        data = params,
        isPayFail = true,
        confirmFun = function()
          Interface.onRecharge(1)
        end
      })
    end
  end
  
  function ProductBase:syncBuySuccess(params)
  end
else
  function ProductBase:onBuy(player, params)
    local isCan = self:checkWhetherCanBuy(player, params)
    
    if isCan then
      if not self.inTrading then
        self.inTrading = {}
      end
      self.inTrading[player.platformUserId] = true
      local cfg = productCfg[params.productType]:getCfgById(params.id)
      if cfg then
        local uniqueId = tostring(params.productType) .. tostring(params.type) .. tostring(params.id)
        Lib.payMoney(player, uniqueId, cfg.currency, cfg.price, function(isSucceed)
          if isSucceed then
            self:onBuySuccess(player, params)
          end
          self.inTrading[player.platformUserId] = false
        end, params.count or 1, 6)
      end
    end
  end
  
  function ProductBase:onBuySuccess(player, params)
  end
end
return ProductBase
