local widget_base = require("ui.widget.widget_base")
local M = Lib.derive(widget_base)

function M:init()
  widget_base.init(self, "common_currency.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgCommonCurrencyIcon = self:child("common_currency-Icon")
  self.txtCommonCurrencyValue = self:child("common_currency-Value")
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client widget_common_currency self:root() event : EventWindowClick", self:root(), UIEvent.EventWindowClick, function()
    if self.coinName == "gold_coin" then
      Me:gameBehaviorReport("ui", "coins")
      UI:openWnd("pokemon_gold_exchange")
    elseif self.coinName == "gDiamonds" then
      Interface.onRecharge(1)
    elseif self.coinName == "gameCashCoupon" then
      Interface.onRecharge(5)
    end
  end)
  self.lvCallCancel = Lib.lightSubscribeEvent("error!!!!! script_client widget_common_currency Lib event : EVENT_CHANGE_CURRENCY", Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
end

function M:changeCurrency()
  local currency = Me:data("wallet")[self.coinName]
  local count = currency and currency.count or 0
  self.txtCommonCurrencyValue:SetText(tostring(count) or 0)
end

function M:setCurrencyType(coinName)
  self.coinName = coinName
  self.imgCommonCurrencyIcon:SetImage(Coin:iconByCoinName(coinName))
  self:changeCurrency()
end

function M:onInvoke(key, ...)
  local fn = M[key]
  assert(type(fn) == "function", key)
  return fn(self, ...)
end

function M:onDestroy()
  if self.lvCallCancel then
    self.lvCallCancel()
  end
end

return M
