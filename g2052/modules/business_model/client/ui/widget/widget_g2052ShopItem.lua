local widget_base = require("ui.widget.widget_base")
local WidgetG2052ShopItem = Lib.derive(widget_base)

function WidgetG2052ShopItem:init()
  widget_base.init(self, "G2052ShopItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetG2052ShopItem:initUI()
  self.imgBg = self:child("G2052ShopItem-bg")
  self.selectIcon = self:child("G2052ShopItem-SelectIcon")
  self.imgIcon = self:child("G2052ShopItem-Icon")
  self.btnBuyItem = self:child("G2052ShopItem-BuyItem")
  self.imgDiaIcon = self:child("G2052ShopItem-DiaIcon")
  self.txtPriceText = self:child("G2052ShopItem-PriceText")
  self.imgMaskPanel = self:child("G2052ShopItem-MaskPanel")
  self.txtHaveText = self:child("G2052ShopItem-HaveText")
  self.txtHaveText:SetText(Lang:toText("gui.goods.already.have"))
end

function WidgetG2052ShopItem:initEvent()
  self:subscribe(self.btnBuyItem, UIEvent.EventButtonClick, function()
    Me:showBuyBusinessItemTips(self.info.goodsType, self.info, true)
  end)
  self:subscribe(self.imgMaskPanel, UIEvent.EventWindowClick, function()
    if self.fun then
      local reportData = {
        shop_goodsId = self.info.goodsId or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "shop_item_preview", reportData, Me)
      self.fun()
    end
  end)
  self:subscribe(self.imgBg, UIEvent.EventWindowClick, function()
    if self.fun then
      local reportData = {
        shop_goodsId = self.info.goodsId or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "shop_item_preview", reportData, Me)
      self.fun()
    end
  end)
end

function WidgetG2052ShopItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.select = data.select
  self.imgIcon:SetImage(self.info.icon)
  self.txtPriceText:SetText(self.info.price)
  self.selectIcon:SetVisible(self.select)
  local canUse = Me:checkBusinessItemUnlock(self.info.goodsType, self.info.itemId)
  if canUse then
    self.btnBuyItem:SetVisible(false)
    self.imgMaskPanel:SetVisible(true)
  else
    self.btnBuyItem:SetVisible(true)
    self.imgMaskPanel:SetVisible(false)
  end
end

function WidgetG2052ShopItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetG2052ShopItem
