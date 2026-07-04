local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeOptionalCustomCell = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitTimeOptionalCustomCell:init()
  widget_base.init(self, "LimitTimeOptionalCustomCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeOptionalCustomCell:initUI()
  self.imgGoodsBg = self:child("LimitTimeOptionalCustomCell-GoodsBg")
  self.imgGoodsIcon = self:child("LimitTimeOptionalCustomCell-GoodsIcon")
  self.txtGoodsNum = self:child("LimitTimeOptionalCustomCell-GoodsNum")
  self.imgSelectIcon = self:child("LimitTimeOptionalCustomCell-SelectIcon")
end

function WidgetLimitTimeOptionalCustomCell:initEvent()
  self:subscribe(self.imgGoodsBg, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_LIMITED_TIME_OPTIONAL_SELECT, self.goodData.awardId)
  end)
end

function WidgetLimitTimeOptionalCustomCell:onDataChanged(data)
  self.goodData = LimitedTimeGiftItemConfig:getCfgById(data.awardId)
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
  self.imgSelectIcon:SetVisible(data.isSelect)
end

function WidgetLimitTimeOptionalCustomCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitTimeOptionalCustomCell
