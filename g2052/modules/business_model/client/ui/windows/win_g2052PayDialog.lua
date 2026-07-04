local WinG2052PayDialog = M
local serialNumber = 10000

function WinG2052PayDialog:init()
  WinBase.init(self, "G2052PayDialog.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinG2052PayDialog:initUI()
  self.lytWnd = self:child("G2052PayDialog-wnd")
  self.imgTop = self:child("G2052PayDialog-top")
  self.txtTitle = self:child("G2052PayDialog-title")
  self.imgBg = self:child("G2052PayDialog-bg")
  self.btnClose = self:child("G2052PayDialog-close")
  self.lytPay = self:child("G2052PayDialog-pay")
  self.imgPayIcon = self:child("G2052PayDialog-pay_icon")
  self.txtPayDec = self:child("G2052PayDialog-pay_dec")
  self.lytPayFail = self:child("G2052PayDialog-pay_fail")
  self.imgPayFailIcon = self:child("G2052PayDialog-pay_fail_icon")
  self.txtPayFailDec = self:child("G2052PayDialog-pay_fail_dec")
  self.txtLackDec = self:child("G2052PayDialog-lack_dec")
  self.imgMImg = self:child("G2052PayDialog-mImg")
  self.btnCancel = self:child("G2052PayDialog-cancel")
  self.btnConfirm = self:child("G2052PayDialog-confirm")
  self.imgPayCurrency = self:child("G2052PayDialog-pay_currency")
  self.txtPayPrice = self:child("G2052PayDialog-pay_price")
  self.txtPayFailName = self:child("G2052PayDialog-pay_fail_name")
  self.txtPayFailPrice = self:child("G2052PayDialog-pay_fail_price")
  self.imgCashCoupon = self:child("G2052PayDialog-cash_coupon")
  self.txtCashCoupon = self:child("G2052PayDialog-cash_coupon_count")
  self.txtPreText = self:child("G2052PayDialog-pre_text")
  self.imgPreGoods = self:child("G2052PayDialog-pre_goods")
  self.btnCancel:SetText(Lang:toText("g2052.gui.cancel"))
  self.txtPreText:SetText(Lang:toText("g2052.gui.buy_shop.preview_tip"))
end

function WinG2052PayDialog:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
    if self.cancelFun then
      self.cancelFun()
    end
  end)
  self:subscribe(self.btnCancel, UIEvent.EventButtonClick, function()
    self:onHide()
    if self.cancelFun then
      serialNumber = serialNumber + 1
      self.cancelFun(serialNumber)
    end
  end)
  self:subscribe(self.btnConfirm, UIEvent.EventButtonClick, function()
    self:onHide()
    if self.confirmFun then
      self.confirmFun()
    end
  end)
  self:subscribe(self.imgPreGoods, UIEvent.EventWindowClick, function()
    self:onHide()
    UI:openWnd("g2052Shop", self.param.data.goodsId)
    local reportData = {
      shop_goodsId = self.param.data.goodsId or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "main_item_preview", reportData, Me)
    if self.cancelFun then
      self.cancelFun()
    end
  end)
end

function WinG2052PayDialog:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_CURRENCY, function()
    self:onChangeCurrency()
  end)
end

function WinG2052PayDialog:onChangeCurrency()
  if self.param and not self.param.isPayFail then
    self:_updatePayPrice()
  end
end

function WinG2052PayDialog:_updatePayPrice()
  local cost = self.param and self.param.data and self.param.data.price or 0
  self.imgCashCoupon:SetVisible(false)
  if self.param and self.param.useCashCoupon and 0 < cost then
    local wallet = Me:data("wallet")
    local gameCashCoupon = wallet and wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0
    if 0 < gameCashCoupon then
      local origin = cost
      cost = math.max(cost - gameCashCoupon, 0)
      self.imgCashCoupon:SetVisible(true)
      self.txtCashCoupon:SetText(-(origin - cost))
    end
  end
  self.txtPayPrice:SetText(cost)
end

function WinG2052PayDialog:initView(param)
  self.param = param
  self.lytPay:SetVisible(false)
  self.lytPayFail:SetVisible(false)
  self.imgPayCurrency:SetVisible(false)
  self.btnConfirm:SetText()
  self.confirmFun = param.confirmFun
  self.cancelFun = param.cancelFun
  self.txtTitle:SetText(Lang:toText(param.title))
  if not param.isPayFail then
    self.lytPay:SetVisible(true)
    self.imgPayCurrency:SetVisible(true)
    self.imgCashCoupon:SetVisible(false)
    if param.data then
      self.imgPayIcon:SetImage(param.data.icon)
      if param.data.name then
        self.txtPayDec:SetText(Lang:toText({
          "gui.whether.confirm.buy",
          param.data.name
        }))
      else
        self.txtPayDec:SetText(Lang:toText("g2052.gui.business.confirm_buy"))
      end
      self:_updatePayPrice()
      if param.data.fromShop == true then
        self.imgPreGoods:SetVisible(false)
      else
        self.imgPreGoods:SetVisible(true)
      end
    end
  else
    self.imgCashCoupon:SetVisible(false)
    self.lytPayFail:SetVisible(true)
    self.btnConfirm:SetText(Lang:toText("g2052.gui.confirm"))
    if param.data then
      self.imgPayFailIcon:SetImage(param.data.icon)
      self.txtPayFailName:SetText(Lang:toText(param.data.name))
      self.txtPayFailPrice:SetText(param.data.price)
      local coinName = Coin:coinNameByCoinId(param.data.currency)
      local count = Me:getWalletBalance(coinName)
      local lack = param.data.price - count
      local text = Lang:toText({
        "gui.still.missing",
        lack
      })
      local length = self.txtLackDec:GetFont():GetTextExtent(text, 1.0)
      self.txtLackDec:SetWidth({0, length})
      self.txtLackDec:SetText(text)
      self.txtPayFailDec:SetText(Lang:toText("gui.whether.enter.recharge"))
    end
  end
end

function WinG2052PayDialog:onHide()
  UI:closeWnd("g2052PayDialog")
end

function WinG2052PayDialog:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052PayDialog")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052PayDialog:onOpen(params)
  self:initView(params)
  self:subscribeEvent()
end

function WinG2052PayDialog:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinG2052PayDialog
