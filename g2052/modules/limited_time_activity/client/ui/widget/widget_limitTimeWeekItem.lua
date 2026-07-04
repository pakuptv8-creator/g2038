local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeWeekItem = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitTimeWeekItem:init()
  widget_base.init(self, "LimitTimeWeekItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeWeekItem:initUI()
  self.lytContentPanel = self:child("LimitTimeWeekItem-ContentPanel")
  self.txtNameText = self:child("LimitTimeWeekItem-NameText")
  self.lytGoodsPanel = self:child("LimitTimeWeekItem-GoodsPanel")
  self.btnFreeBtn = self:child("LimitTimeWeekItem-FreeBtn")
  self.imgRedIcon = self:child("LimitTimeWeekItem-RedIcon")
  self.btnBuyBtn = self:child("LimitTimeWeekItem-BuyBtn")
  self.imgDiaIcon = self:child("LimitTimeWeekItem-DiaIcon")
  self.txtInitPrice = self:child("LimitTimeWeekItem-InitPrice")
  self.imgLine = self:child("LimitTimeWeekItem-Line")
  self.txtFinalPrice = self:child("LimitTimeWeekItem-finalPrice")
  self.imgPerIcon = self:child("LimitTimeWeekItem-PerIcon")
  self.txtPerText1 = self:child("LimitTimeWeekItem-PerText1")
  self.txtPerText2 = self:child("LimitTimeWeekItem-PerText2")
  self.txtLimitText = self:child("LimitTimeWeekItem-LimitText")
  self.imgSoulMask = self:child("LimitTimeWeekItem-SoulMask")
  self.imgSoulIcon = self:child("LimitTimeWeekItem-SoulIcon")
  self.txtSoulText = self:child("LimitTimeWeekItem-SoulText")
  self.lytClickPanel = self:child("LimitTimeWeekItem-ClickPanel")
  self.txtPerText2:SetText(Lang:toText("gui.limit.time.combined.off"))
  self.btnFreeBtn:SetText(Lang:toText("gui.limit.time.activity.free.bought"))
  self.txtSoulText:SetText(Lang:toText("gui.limit.time.activity.soul.out"))
  self.lytGoodsItem = {}
  self.imgGoodsIcon = {}
  self.txtGoodsNum = {}
  self.imgGoodsBg = {}
  for i = 1, 3 do
    self.lytGoodsItem[i] = self:child("LimitTimeWeekItem-GoodsItem" .. i)
    self.imgGoodsIcon[i] = self:child("LimitTimeWeekItem-GoodsIcon" .. i)
    self.txtGoodsNum[i] = self:child("LimitTimeWeekItem-GoodsNum" .. i)
    self.imgGoodsBg[i] = self:child("LimitTimeWeekItem-GoodsBg" .. i)
  end
end

function WidgetLimitTimeWeekItem:initEvent()
  self:subscribe(self.btnFreeBtn, UIEvent.EventButtonClick, function()
    if self.data.dataType == "week" then
      Me:clientBuyLimitTimeWeekGift(self.data)
    else
      Me:clientBuyLimitTimeMonthGift(self.data)
    end
  end)
  self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("limitedTimeWeekConfirm", self.data)
  end)
  self:subscribe(self.lytClickPanel, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.data then
      return
    end
    if self.data.finalPrice <= 0 then
      return
    else
      UI:openWnd("limitedTimeWeekConfirm", self.data)
    end
  end)
  for i = 1, 3 do
    self:subscribe(self.imgGoodsIcon[i], UIEvent.EventWindowClick, function(window, dx, dy)
      if not self.goodData then
        return
      end
      if not self.goodData[i] then
        return
      end
      LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.goodData[i], dx, dy)
    end)
  end
end

function WidgetLimitTimeWeekItem:onDataChanged(data)
  self.data = data
  if data.dataType == "week" then
    self._root:SetImage("set:limit_time_week_month.json image:img_0_gift_packages01")
  else
    self._root:SetImage("set:limit_time_week_month.json image:img_0_gift_packages02")
  end
  self.txtPerText1:SetText(data.percent)
  self.txtNameText:SetText(Lang:toText(data.giftName))
  if data.finalPrice <= 0 then
    self.btnFreeBtn:SetVisible(true)
    self.btnBuyBtn:SetVisible(false)
  else
    self.btnFreeBtn:SetVisible(false)
    self.btnBuyBtn:SetVisible(true)
    self.txtFinalPrice:SetText(data.finalPrice)
    self.txtInitPrice:SetText(data.initPrice)
    local strW = self.txtInitPrice:GetFont():GetStringWidth(data.initPrice)
    self.imgLine:SetWidth({
      0,
      strW + 10
    })
  end
  self.txtLimitText:SetText(Lang:toText({
    "gui.limit.time.activity.limit.counts",
    data.limitCounts - data.boughtCounts
  }))
  if data.boughtCounts >= data.limitCounts then
    self.imgSoulMask:SetVisible(true)
    self.imgPerIcon:SetVisible(false)
    self.imgRedIcon:SetVisible(false)
    self.btnFreeBtn:SetEnabled(false)
    self.btnFreeBtn:SetTouchable(false)
    self.btnBuyBtn:SetEnabled(false)
    self.btnBuyBtn:SetTouchable(false)
  else
    self.imgSoulMask:SetVisible(false)
    self.imgPerIcon:SetVisible(true)
    self.imgRedIcon:SetVisible(true)
    self.btnFreeBtn:SetEnabled(true)
    self.btnFreeBtn:SetTouchable(true)
    self.btnBuyBtn:SetEnabled(true)
    self.btnBuyBtn:SetTouchable(true)
  end
  self.goodData = {}
  if #data.giftContent == 1 then
    self.lytGoodsItem[1]:SetXPosition({0, 70})
  elseif #data.giftContent == 2 then
    self.lytGoodsItem[1]:SetXPosition({0, 35})
    self.lytGoodsItem[2]:SetXPosition({0, 35})
  else
    self.lytGoodsItem[1]:SetXPosition({0, 0})
    self.lytGoodsItem[2]:SetXPosition({0, 0})
  end
  for i = 1, 3 do
    if data.giftContent[i] then
      local itemInfo = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[i])
      if itemInfo then
        self.goodData[i] = itemInfo
        self.lytGoodsItem[i]:SetVisible(true)
        local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData[i])
        if self.goodData[i].itemIcon and self.goodData[i].itemIcon ~= "" then
          self.imgGoodsIcon[i]:SetImage(self.goodData[i].itemIcon)
        else
          self.imgGoodsIcon[i]:SetImage(itemData.itemIcon or "")
        end
        local count = itemData.itemCount
        if count <= 1 then
          self.txtGoodsNum[i]:SetText("")
        else
          self.txtGoodsNum[i]:SetText("x" .. count)
        end
        local quality = itemData.quality or 1
        self.imgGoodsBg[i]:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
      else
        self.lytGoodsItem[i]:SetVisible(false)
      end
    else
      self.lytGoodsItem[i]:SetVisible(false)
    end
  end
end

function WidgetLimitTimeWeekItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitTimeWeekItem
