local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeOptionalCell = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitTimeOptionalCell:init()
  widget_base.init(self, "LimitTimeOptionalCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeOptionalCell:initUI()
  self.imgGoodsBg = self:child("LimitTimeOptionalCell-GoodsBg")
  self.imgGoodsIcon = self:child("LimitTimeOptionalCell-GoodsIcon")
  self.txtGoodsNum = self:child("LimitTimeOptionalCell-GoodsNum")
  self.imgChangeIcon = self:child("LimitTimeOptionalCell-ChangeIcon")
  self.imgAddIcon = self:child("LimitTimeOptionalCell-AddIcon")
end

function WidgetLimitTimeOptionalCell:initEvent()
  self:subscribe(self.imgGoodsIcon, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.imgChangeIcon:IsVisible() then
      UI:openWnd("limitTimeOptionalCustomWnd", true, self.giftId, self.index)
    else
      if not self.goodData then
        return
      end
      LimitedTimeActivityGameMgr:limitTimeExtraItemClickFunc(self.goodData, dx, dy)
    end
  end)
  self:subscribe(self.imgAddIcon, UIEvent.EventWindowClick, function()
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.giftId, self.index)
  end)
  self:subscribe(self.imgChangeIcon, UIEvent.EventWindowClick, function()
    UI:openWnd("limitTimeOptionalCustomWnd", true, self.giftId, self.index)
  end)
end

function WidgetLimitTimeOptionalCell:updateGoodsInfo(isFixed, goodsId, giftId, index)
  self.giftId = giftId
  self.index = index
  self.goodsId = goodsId
  if goodsId then
    self.imgAddIcon:SetVisible(false)
    self.imgGoodsBg:SetVisible(true)
    self.imgChangeIcon:SetVisible(not isFixed)
    self.goodData = LimitedTimeGiftItemConfig:getCfgById(goodsId)
    local itemData = LimitedTimeActivityGameMgr:getItemInfo(self.goodData)
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
  else
    self.imgAddIcon:SetVisible(true)
    self.imgChangeIcon:SetVisible(false)
    self.imgGoodsBg:SetVisible(false)
  end
end

function WidgetLimitTimeOptionalCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitTimeOptionalCell
