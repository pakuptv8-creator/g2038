local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeDiscountItem = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitTimeDiscountItem:init()
  widget_base.init(self, "LimitTimeDiscountItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeDiscountItem:initUI()
  self.imgBG = self:child("LimitTimeDiscountItem-BG")
  self.lytContentPanel = self:child("LimitTimeDiscountItem-ContentPanel")
  self.lytClickPanel = self:child("LimitTimeDiscountItem-ClickPanel")
  self.txtNameText = self:child("LimitTimeDiscountItem-NameText")
  self.lytGoodsItem = self:child("LimitTimeDiscountItem-GoodsItem")
  self.imgGoodsBg = self:child("LimitTimeDiscountItem-GoodsBg")
  self.imgGoodsIcon = self:child("LimitTimeDiscountItem-GoodsIcon")
  self.txtGoodsNum = self:child("LimitTimeDiscountItem-GoodsNum")
  self.imgRedIcon = self:child("LimitTimeDiscountItem-RedIcon")
  self.txtLimitText = self:child("LimitTimeDiscountItem-LimitText")
  self.imgPerIcon = self:child("LimitTimeDiscountItem-PerIcon")
  self.txtPerText = self:child("LimitTimeDiscountItem-PerText")
  self.btnBuyBtn = self:child("LimitTimeDiscountItem-BuyBtn")
  self.imgDiaIcon = self:child("LimitTimeDiscountItem-DiaIcon")
  self.txtInitPrice = self:child("LimitTimeDiscountItem-InitPrice")
  self.imgLine = self:child("LimitTimeDiscountItem-Line")
  self.txtFinalPrice = self:child("LimitTimeDiscountItem-finalPrice")
  self.imgSoulMask = self:child("LimitTimeDiscountItem-SoulMask")
  self.imgSoulIcon = self:child("LimitTimeDiscountItem-SoulIcon")
  self.txtSoulText = self:child("LimitTimeDiscountItem-SoulText")
  self.txtHaveText = self:child("LimitTimeDiscountItem-HaveText")
  self.btnFreeBtn = self:child("LimitTimeDiscountItem-FreeBtn")
  self.txtFreeText = self:child("LimitTimeDiscountItem-FreeText")
  self.txtFreeText:SetText(Lang:toText("gui.limit.time.activity.free.bought"))
  self.txtSoulText:SetText(Lang:toText("gui.limit.time.activity.soul.out"))
  self.txtHaveText:SetText(Lang:toText("gui.limit.time.activity.is.have"))
  self.txtHaveText:SetVisible(false)
end

function WidgetLimitTimeDiscountItem:initEvent()
  self:subscribe(self.btnFreeBtn, UIEvent.EventButtonClick, function()
    if self.imgSoulMask:IsVisible() then
      return
    end
    Me:clientBuyLimitDiscountGift(self.data)
  end)
  self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    if self.imgSoulMask:IsVisible() then
      return
    end
    if self.data.finalPrice <= 0 then
      Me:clientBuyLimitDiscountGift(self.data)
    else
      UI:openWnd("limitedTimeConfirmCommon", Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT, self.data)
    end
  end)
  self:subscribe(self.lytClickPanel, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.imgSoulMask:IsVisible() then
      return
    end
    if not self.data then
      return
    end
    if self.data.finalPrice <= 0 then
      return
    else
      UI:openWnd("limitedTimeConfirmCommon", Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT, self.data)
    end
  end)
  self:subscribe(self.imgGoodsIcon, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.goodData then
      return
    end
    LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.goodData, dx, dy)
  end)
end

function WidgetLimitTimeDiscountItem:onDataChanged(data)
  self.data = data
  self.txtPerText:SetText(data.percent .. " " .. Lang:toText("gui.limit.time.combined.off"))
  self.txtFinalPrice:SetText(data.finalPrice)
  self.txtInitPrice:SetText(data.initPrice)
  local strW = self.txtInitPrice:GetFont():GetStringWidth(data.initPrice)
  self.imgLine:SetWidth({
    0,
    strW + 6
  })
  self.goodData = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[1])
  local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData)
  local limitedTimeDiscountData = Me:getLimitedTimeDiscountData()
  local boughtCounts = limitedTimeDiscountData[data.giftKey] or 0
  self.txtLimitText:SetText(Lang:toText({
    "gui.limit.time.activity.limit.counts",
    data.limitCounts - boughtCounts
  }))
  if boughtCounts >= data.limitCounts then
    self.imgSoulMask:SetVisible(true)
    self.btnBuyBtn:SetVisible(false)
    self.btnFreeBtn:SetVisible(false)
    self.txtHaveText:SetVisible(false)
    self.txtSoulText:SetVisible(true)
  elseif itemData and itemData.isHave then
    self.imgSoulMask:SetVisible(true)
    self.btnBuyBtn:SetVisible(false)
    self.btnFreeBtn:SetVisible(false)
    self.txtHaveText:SetVisible(true)
    self.txtSoulText:SetVisible(false)
  else
    self.imgSoulMask:SetVisible(false)
    if data.finalPrice <= 0 then
      self.btnBuyBtn:SetVisible(false)
      self.btnFreeBtn:SetVisible(true)
    else
      self.btnBuyBtn:SetVisible(true)
      self.btnFreeBtn:SetVisible(false)
    end
  end
  if self.goodData then
    self.lytGoodsItem:SetVisible(true)
    if self.goodData.itemIcon and self.goodData.itemIcon ~= "" then
      self.imgGoodsIcon:SetImage(self.goodData.itemIcon)
    else
      self.imgGoodsIcon:SetImage(itemData.itemIcon or "")
    end
    local count = itemData.itemCount
    if count <= 1 then
      self.txtGoodsNum:SetText("")
    else
      self.txtGoodsNum:SetText("x" .. count)
    end
    local quality = itemData.quality or 1
    self.imgGoodsBg:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
    if data.giftName and data.giftName ~= "" then
      self.txtNameText:SetText(Lang:toText(data.giftName))
    elseif self.goodData.showName and self.goodData.showName ~= "" then
      self.txtNameText:SetText(Lang:toText(self.goodData.showName or ""))
    else
      self.txtNameText:SetText(Lang:toText(itemData.itemName or ""))
    end
  else
    self.lytGoodsItem:SetVisible(false)
  end
end

function WidgetLimitTimeDiscountItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitTimeDiscountItem
