local widget_base = require("ui.widget.widget_base")
local WidgetLimitedTimeGoldWheelCell = Lib.derive(widget_base)

function WidgetLimitedTimeGoldWheelCell:init()
  widget_base.init(self, "LimitedTimeGoldWheelCell.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetLimitedTimeGoldWheelCell:initUI()
  self.imgFrame = self:child("LimitedTimeGoldWheelCell-frame")
  self.imgIcon = self:child("LimitedTimeGoldWheelCell-icon")
  self.txtNum = self:child("LimitedTimeGoldWheelCell-num")
  self.imgTag = self:child("LimitedTimeGoldWheelCell-tag")
  self.txtTagTxt = self:child("LimitedTimeGoldWheelCell-tag_txt")
end

function WidgetLimitedTimeGoldWheelCell:initEvent()
  self._allEvent[#self._allEvent + 1] = self:subscribe(self.imgFrame, UIEvent.EventWindowClick, function()
    if self.data and self.info then
      local params = {}
      params.name = self.data.showName or self.info.name
      params.icon = self.info.itemIcon
      params.count = self.info.itemCount
      params.dec = self.data.showDesc or self.info.dec
      params.quality = self.info.quality
      UI:openWnd("limitedTimeActivityItemDialog", params)
    end
  end)
end

function WidgetLimitedTimeGoldWheelCell:updateView(data)
  self.data = data
  local info = LimitedTimeActivityGameMgr:getItemInfo(data)
  self.info = info
  local quality = info.quality or 1
  self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality0" .. quality)
  self.imgIcon:SetImage(info.itemIcon)
  local count = info.itemCount or 0
  if count <= 1 then
    self.txtNum:SetText("")
  else
    self.txtNum:SetText("x" .. count)
  end
  self.imgTag:SetVisible(false)
  if data.tag then
    self.imgTag:SetVisible(true)
    self.txtTagTxt:SetText(data.tag)
  end
end

function WidgetLimitedTimeGoldWheelCell:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetLimitedTimeGoldWheelCell
