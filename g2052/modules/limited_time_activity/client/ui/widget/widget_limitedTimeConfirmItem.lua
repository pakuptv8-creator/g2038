local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeConfirmItem = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitedTimeConfirmItem:init()
  widget_base.init(self, "LimitedTimeConfirmItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeConfirmItem:initUI()
  self.lytGoodsItem = self:child("LimitedTimeConfirmItem-GoodsItem")
  self.imgGoodsBg = self:child("LimitedTimeConfirmItem-GoodsBg")
  self.imgGoodsIcon = self:child("LimitedTimeConfirmItem-GoodsIcon")
  self.txtGoodsNum = self:child("LimitedTimeConfirmItem-GoodsNum")
end

function WidgetLimitedTimeConfirmItem:initEvent()
  self:subscribe(self.imgGoodsIcon, UIEvent.EventWindowClick, function(window, dx, dy)
    if not self.goodData then
      return
    end
    LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.goodData, dx, dy)
  end)
end

function WidgetLimitedTimeConfirmItem:onDataChanged(goodsId)
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
end

function WidgetLimitedTimeConfirmItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeConfirmItem
