local widget_base = require("ui.widget.widget_base")
local WidgetG2052ShopCell = Lib.derive(widget_base)
local BusinessHelper = T(Lib, "BusinessHelper")

function WidgetG2052ShopCell:init()
  widget_base.init(self, "G2052ShopCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetG2052ShopCell:initUI()
  self.imgShade = self:child("G2052ShopCell-shade")
  self.imgInfo = self:child("G2052ShopCell-Info")
  self.txtName = self:child("G2052ShopCell-name")
  self.imgIcon = self:child("G2052ShopCell-icon")
  self.lytDecList = self:child("G2052ShopCell-dec_list")
  self.btnBuyBtn = self:child("G2052ShopCell-BuyBtn")
  self.imgCurrency = self:child("G2052ShopCell-currency")
  self.txtPrice = self:child("G2052ShopCell-price")
  self.lytHaveBuy = self:child("G2052ShopCell-have_buy")
  self.txtHaveBuyText = self:child("G2052ShopCell-have_buy_text")
  local haveText = Lang:toText("gui.goods.already.have")
  self.txtHaveBuyText:SetText(haveText)
  local strW = self.txtHaveBuyText:GetFont():GetStringWidth(haveText)
  self.txtHaveBuyText:SetWidth({0, strW})
  self.imgHotIcon = self:child("G2052ShopCell-HotIcon")
  self.txtPrice2 = self:child("G2052ShopCell-price2")
  self.txtPercentText = self:child("G2052ShopCell-PercentText")
  self.txtOFFText = self:child("G2052ShopCell-OFFText")
  self.txtOFFText:SetText("OFF")
  self:initList()
end

function WidgetG2052ShopCell:initList()
  self.decTextGridView = UIMgr:new_widget("grid_view")
  self.decTextGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.decTextGridView:InitConfig(0, 0, 1)
  self.lytDecList:AddChildWindow(self.decTextGridView)
end

function WidgetG2052ShopCell:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    if self.data then
      self.data.productType = Define.PRODUCT_TYPE.PRIVILEGE
      BusinessHelper:onClientBuy(self.data)
    end
  end)
end

function WidgetG2052ShopCell:updateShowCellShow(data)
  self.data = data
  self.info = data
  self.fun = data.clickCb
  self.index = data.index
  if self.info then
    self:updateView()
  else
    self:empty()
  end
end

function WidgetG2052ShopCell:updateView()
  self.txtName:SetText(Lang:toText(self.info.name))
  self.txtPrice:SetText(self.info.price)
  self.imgShade:SetImage(self.info.bgImg)
  self.btnBuyBtn:SetVisible(not self.info.isHave)
  self.lytHaveBuy:SetVisible(self.info.isHave)
  self:updateDecView(self.info.dec)
  if self.info.initPrice > 0 and 0 < self.info.percent then
    self.imgHotIcon:SetVisible(true)
    self.txtPrice2:SetText(self.info.initPrice)
    self.txtPercentText:SetText(self.info.percent .. "%")
  else
    self.imgHotIcon:SetVisible(false)
  end
end

function WidgetG2052ShopCell:updateDecView(info)
  self.decTextGridView:RemoveAllItems()
  for _, v in pairs(info or {}) do
    local decCell = UIMgr:new_widget("g2052ShopDecCell")
    decCell:invoke("updateText", v)
    local w = self.decTextGridView:GetWidth()
    decCell:SetWidth(w)
    self.decTextGridView:AddItem(decCell)
  end
end

function WidgetG2052ShopCell:empty()
  self.btnBuyBtn:SetVisible(not self.info.isHave)
  self.lytHaveBuy:SetVisible(self.info.isHave)
end

function WidgetG2052ShopCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetG2052ShopCell
