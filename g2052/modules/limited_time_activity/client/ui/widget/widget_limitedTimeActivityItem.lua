local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeActivityItem = Lib.derive(widget_base)
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")

function WidgetLimitedTimeActivityItem:init()
  widget_base.init(self, "LimitedTimeActivityItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeActivityItem:initUI()
  self.imgFrame = self:child("LimitedTimeActivityItem-frame")
  self.imgIcon = self:child("LimitedTimeActivityItem-icon")
  self.txtName = self:child("LimitedTimeActivityItem-name")
  self.txtNum = self:child("LimitedTimeActivityItem-num")
  self.lytEffect = self:child("LimitedTimeActivityItem-effect")
end

function WidgetLimitedTimeActivityItem:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self.imgFrame, UIEvent.EventWindowClick, function(window, dx, dy)
    if self.data and self.isClick then
      LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(self.data, dx, dy)
    end
  end)
end

function WidgetLimitedTimeActivityItem:updateInfo(item)
  local info = LimitedTimeActivityGameMgr:getItemInfo(item)
  if item.showName and item.showName ~= "" then
    self.txtName:SetText(Lang:toText(item.showName or ""))
  else
    self.txtName:SetText(Lang:toText(info.itemName))
  end
  local quality = info.quality or 1
  self.lytEffect:SetVisible(quality == 5 and item.isShowEffect)
  local isNeedSpecialCell = LimitedTimeActivityGameMgr:addSpecialCell(self._root, item)
  if isNeedSpecialCell then
    self:setSpecialModel()
    return
  end
  self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
  self.imgIcon:SetImage(info.itemIcon)
  local count = info.itemCount or 0
  if item.combinedNum then
    count = count * item.combinedNum
  end
  if count <= 1 then
    self.txtNum:SetText("")
  else
    self.txtNum:SetText("x" .. count)
  end
end

function WidgetLimitedTimeActivityItem:setSpecialModel()
  self.imgFrame:SetImage()
  self.imgIcon:SetImage()
  self.txtNum:SetText()
end

function WidgetLimitedTimeActivityItem:onDataChanged(data)
  self.data = data
  self.isClick = data.isClick
  self:updateInfo(data)
end

function WidgetLimitedTimeActivityItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeActivityItem
