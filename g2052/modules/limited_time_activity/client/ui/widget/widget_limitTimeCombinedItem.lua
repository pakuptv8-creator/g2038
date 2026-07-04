local widget_base = require("ui.widget.widget_base")
local WidgetLimitTimeCombinedItem = Lib.derive(widget_base)

function WidgetLimitTimeCombinedItem:init()
  widget_base.init(self, "LimitTimeCombinedItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitTimeCombinedItem:initUI()
  self.lytGoodItem = self:child("LimitTimeCombinedItem-goodItem")
  self.imgGoodsBg = self:child("LimitTimeCombinedItem-goodsBg")
  self.imgGoodsIcon = self:child("LimitTimeCombinedItem-goodsIcon")
  self.txtGoodsNum = self:child("LimitTimeCombinedItem-goodsNum")
  self.lytIsHave = self:child("LimitTimeCombinedItem-isHave")
  self:child("LimitTimeCombinedItem-isHaveText"):SetText(Lang:toText("gui.limit.time.activity.is.have"))
end

function WidgetLimitTimeCombinedItem:initEvent()
  self:subscribe(self.lytGoodItem, UIEvent.EventWindowClick, function(window, dx, dy)
    LimitedTimeActivityGameMgr:limitTimeExtraItemClickFunc(self.data, dx, dy)
  end)
end

function WidgetLimitTimeCombinedItem:updateInfo(data)
  self.data = data
  if data.itemCount <= 1 then
    self.txtGoodsNum:SetText("")
  else
    self.txtGoodsNum:SetText("x" .. data.itemCount)
  end
  local itemData = LimitedTimeActivityGameMgr:getItemInfo(data)
  if data.itemIcon and data.itemIcon ~= "" then
    self.imgGoodsIcon:SetImage(data.itemIcon)
  else
    self.imgGoodsIcon:SetImage(itemData.itemIcon or "")
  end
  self.lytIsHave:SetVisible(itemData.isHave)
end

function WidgetLimitTimeCombinedItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WidgetLimitTimeCombinedItem
