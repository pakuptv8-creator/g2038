local widget_base = require("ui.widget.widget_base")
local WidgetCurrencyItem = Lib.derive(widget_base)

function WidgetCurrencyItem:init(x, y)
  widget_base.init(self, "CurrencyItem.json")
  self._allEvent = {}
  self.lastGoldCount = -1
  self:initUI()
  self:initEvent()
  self:setSize(x, y)
end

function WidgetCurrencyItem:initUI()
  self.imgBG = self:child("CurrencyItem-BG")
  self.btnGDiamondsBg = self:child("CurrencyItem-gDiamondsBg")
  self.imgGDiamondsImg = self:child("CurrencyItem-gDiamondsImg")
  self.txtGDiamondsTxt = self:child("CurrencyItem-gDiamondsTxt")
  self.imgAdd2 = self:child("CurrencyItem-addImg2")
  self.btnCashCouponBg = self:child("CurrencyItem-cash_coupon_bg")
  self.imgCashCouponIcon = self:child("CurrencyItem-cash_coupon_icon")
  self.txtCashCouponCount = self:child("CurrencyItem-cash_coupon_count")
  self:changeCurrency()
end

function WidgetCurrencyItem:initEvent()
  self:subscribe(self.btnGDiamondsBg, UIEvent.EventButtonClick, function()
    Interface.onRecharge(1)
  end)
  self:subscribe(self.btnCashCouponBg, UIEvent.EventButtonClick, function()
    Interface.onRecharge(5)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
    self:changeCurrency()
  end)
end

function WidgetCurrencyItem:setSize(x, y)
  self.imgBG:SetXPosition({x, 0})
  self.imgBG:SetYPosition({y, 0})
end

function WidgetCurrencyItem:changeCurrency()
  local wallet = Me:data("wallet")
  if not next(wallet) then
    return
  end
  if wallet.gDiamonds then
    self.txtGDiamondsTxt:SetText(Plugins.CallTargetPluginFunc("engine_overwrite", "toBigIntegerString", math.floor(wallet.gDiamonds.count)))
  end
  local gameCashCoupon = 0
  if wallet.gameCashCoupon and wallet.gameCashCoupon.count then
    gameCashCoupon = wallet.gameCashCoupon.count or 0
  end
  self.btnCashCouponBg:SetVisible(true)
  self.txtCashCouponCount:SetText(gameCashCoupon)
end

function WidgetCurrencyItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetCurrencyItem
