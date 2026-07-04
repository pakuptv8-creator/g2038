local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeCardCell = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitedTimeCardCell:init()
  widget_base.init(self, "LimitedTimeCardCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeCardCell:initUI()
  self.imgCard = self:child("LimitedTimeCardCell-card")
  self.txtCardTitle = self:child("LimitedTimeCardCell-card_title")
  self.imgCardIcon = self:child("LimitedTimeCardCell-card_icon")
  self.imgCardItemOnly = self:child("LimitedTimeCardCell-card_item_only")
  self.txtCardItemOnlyTip = self:child("LimitedTimeCardCell-card_item_only_tip")
  self.txtCardItemOnlyNum = self:child("LimitedTimeCardCell-card_item_only_num")
  self.imgCardItemSum = self:child("LimitedTimeCardCell-card_item_sum")
  self.txtCardItemSumTip = self:child("LimitedTimeCardCell-card_item_sum_tip")
  self.txtCardItemSumNum = self:child("LimitedTimeCardCell-card_item_sum_num")
  self.btnBuy = self:child("LimitedTimeCardCell-buy")
  self.imgCurrencyIcon = self:child("LimitedTimeCardCell-currency_icon")
  self.txtPrice = self:child("LimitedTimeCardCell-price")
  self.txtPurchased = self:child("LimitedTimeCardCell-purchased")
  self.txtResidue = self:child("LimitedTimeCardCell-residue")
  self.imgTag = self:child("LimitedTimeCardCell-tag")
  self.txtTagTxt = self:child("LimitedTimeCardCell-tag_txt")
  self.txtCardItemOnlyTip:SetText(Lang:toText("gui.limit.time.activity.card.tip1"))
  self.txtCardItemSumTip:SetText(Lang:toText("gui.limit.time.activity.card.tip2"))
  self.txtPurchased:SetText(Lang:toText("gui.limit.time.combined.purchased"))
end

function WidgetLimitedTimeCardCell:initEvent()
  self:subscribe(self.btnBuy, UIEvent.EventButtonClick, function()
    if not self.data then
      return
    end
    local params = {}
    params.cardType = self.data.type
    params.id = self.data.activityId
    params.price = self.data.price
    Me:playLimitedTimeCard(params)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LIMITED_TIME_CARD_INFO, function()
    self:updateView()
  end)
end

function WidgetLimitedTimeCardCell:onDataChanged(data)
  self.data = data
  self:updateView()
end

function WidgetLimitedTimeCardCell:updateView()
  if not self.data then
    return
  end
  local limitedTimeCardData = Me:getLimitedTimeCardData()
  self.imgCard:SetVisible(true)
  self.imgCard:SetImage(self.data.bgFrame)
  self.txtCardTitle:SetText(Lang:toText(self.data.title))
  self.imgCardIcon:SetImage(self.data.icon)
  self.btnBuy:SetVisible(false)
  self.txtPurchased:SetVisible(false)
  self.txtResidue:SetVisible(false)
  self.txtTagTxt:SetText(self.data.tag)
  local giftContent = self.data.giftContent
  for _, id in pairs(giftContent or {}) do
    local item = LimitedTimeGiftItemConfig:getCfgById(id)
    if item then
      local info = LimitedTimeActivityGameMgr:getItemInfo(item)
      self.imgCardItemOnly:SetImage(info.itemIcon)
      self.imgCardItemSum:SetImage(info.itemIcon)
      self.txtCardItemOnlyNum:SetText(info.itemCount)
      self.txtCardItemSumNum:SetText(info.itemCount * self.data.awardCount)
    end
  end
  if limitedTimeCardData[self.data.id] then
    self.txtPurchased:SetVisible(true)
    self.txtResidue:SetVisible(true)
    self.txtResidue:SetText(Lang:toText({
      "gui.limit.time.card.residue",
      limitedTimeCardData[self.data.id].count
    }))
  else
    self.btnBuy:SetNormalImage(self.data.buyIcon)
    self.btnBuy:SetPushedImage(self.data.buyIcon)
    self.txtPrice:SetText(self.data.price)
    self.btnBuy:SetVisible(true)
  end
end

function WidgetLimitedTimeCardCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeCardCell
