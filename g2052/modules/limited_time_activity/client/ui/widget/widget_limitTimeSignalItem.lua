local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeSignalItem = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")

function WidgetLimitTimeSignalItem:init()
  widget_base.init(self, "LimitTimeSignalItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeSignalItem:initUI()
  self.lytContentPanel = self:child("LimitTimeSignalItem-ContentPanel")
  self.txtTitleText = self:child("LimitTimeSignalItem-TitleText")
  self.imgBG = self:child("LimitTimeSignalItem-BG")
  self.btnBuyBtn = self:child("LimitTimeSignalItem-BuyBtn")
  self.imgFinalDiaIcon = self:child("LimitTimeSignalItem-FinalDiaIcon")
  self.txtFinalPrice = self:child("LimitTimeSignalItem-FinalPrice")
  self.imgInitDiaIcon = self:child("LimitTimeSignalItem-InitDiaIcon")
  self.txtInitPrice = self:child("LimitTimeSignalItem-InitPrice")
  self.imgInitLine = self:child("LimitTimeSignalItem-InitLine")
  self.imgGoodsBg = self:child("LimitTimeSignalItem-GoodsBg")
  self.imgGoodsIcon = self:child("LimitTimeSignalItem-GoodsIcon")
  self.txtGoodsNum = self:child("LimitTimeSignalItem-GoodsNum")
  self.imgBubbleIcon = self:child("LimitTimeSignalItem-BubbleIcon")
  self.txtOFFText = self:child("LimitTimeSignalItem-OFFText")
  self.txtPerText = self:child("LimitTimeSignalItem-PerText")
  self.txtOFFText:SetText(Lang:toText("gui.limit.time.combined.off"))
end

function WidgetLimitTimeSignalItem:initEvent()
  self:subscribe(self.btnBuyBtn, UIEvent.EventButtonClick, function()
    if not self.data then
      return
    end
    if Lib.checkMoney(Me, 0, self.data.finalPrice, true) then
      local params = {
        activityId = self.data.activityId,
        id = self.data.id
      }
      LimitedTimeActivityGameMgr:clientClickBoughtBtn(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT, params)
    else
      LimitedTimeActivityGameMgr:showBuyFailTip()
    end
  end)
  self:subscribe(self.imgGoodsIcon, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.goodData then
      return
    end
    LimitedTimeActivityGameMgr:limitTimeExtraItemClickFunc(self.goodData, dx, dy)
  end)
end

function WidgetLimitTimeSignalItem:updateItemViewShow(data)
  self.data = data
  self.txtPerText:SetText(self.data.percent)
  self.txtGoodsNum:SetText("")
  if #data.giftContent == 1 then
    self.goodData = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[1])
    if self.goodData then
      local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData)
      if self.goodData.itemIcon and self.goodData.itemIcon ~= "" then
        self.imgGoodsIcon:SetImage(self.goodData.itemIcon)
      else
        self.imgGoodsIcon:SetImage(itemData.itemIcon or "")
      end
      if self.data.giftName and self.data.giftName ~= "" then
        self.txtTitleText:SetText(Lang:toText(self.data.giftName))
      elseif self.goodData.showName and self.goodData.showName ~= "" then
        self.txtTitleText:SetText(Lang:toText(self.goodData.showName or ""))
      else
        self.txtTitleText:SetText(Lang:toText(itemData.itemName or "gui.limit.time.combined.title"))
      end
      local count = itemData.itemCount
      if data.giftNum and data.giftNum > 0 then
        count = count * data.giftNum
      end
      if count <= 1 then
        self.txtGoodsNum:SetText("")
      else
        self.txtGoodsNum:SetText("x" .. count)
      end
    end
  else
    self.goodData = nil
    if self.data.giftName and self.data.giftName ~= "" then
      self.txtTitleText:SetText(Lang:toText(self.data.giftName))
    else
      self.txtTitleText:SetText(Lang:toText("gui.limit.time.combined.title"))
    end
    if data.giftIcon and data.giftIcon ~= "" then
      self.imgGoodsIcon:SetImage(data.giftIcon)
    end
    if data.giftNum and data.giftNum > 0 then
      if 1 >= data.giftNum then
        self.txtGoodsNum:SetText("")
      else
        self.txtGoodsNum:SetText("x" .. data.giftNum)
      end
    end
  end
  self:updateBoughtBtnShow()
end

function WidgetLimitTimeSignalItem:updateBoughtBtnShow()
  if not self.data then
    return
  end
  if self.data.canBuyState <= 0 then
    self.btnBuyBtn:SetText(Lang:toText("gui.limit.time.activity.soul.out"))
    self.imgInitDiaIcon:SetVisible(false)
    self.imgFinalDiaIcon:SetVisible(false)
    self.btnBuyBtn:SetEnabled(false)
    self.btnBuyBtn:SetTouchable(false)
  else
    self.btnBuyBtn:SetEnabled(true)
    self.btnBuyBtn:SetTouchable(true)
    self.btnBuyBtn:SetText("")
    self.imgInitDiaIcon:SetVisible(true)
    self.imgFinalDiaIcon:SetVisible(true)
    self.txtFinalPrice:SetText(self.data.finalPrice)
    self.txtInitPrice:SetText(self.data.initPrice)
    local strW = self.txtInitPrice:GetFont():GetStringWidth(self.data.initPrice)
    self.imgInitLine:SetWidth({
      0,
      strW + 35
    })
  end
end

function WidgetLimitTimeSignalItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitTimeSignalItem
