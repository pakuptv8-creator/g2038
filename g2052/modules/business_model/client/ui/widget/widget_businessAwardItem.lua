local widget_base = require("ui.widget.widget_base")
local WidgetBusinessAwardItem = Lib.derive(widget_base)

function WidgetBusinessAwardItem:init()
  widget_base.init(self, "BusinessAwardItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBusinessAwardItem:initUI()
  self.imgEffect = self:child("BusinessAwardItem-effect")
  self.imgFrame = self:child("BusinessAwardItem-frame")
  self.imgIcon = self:child("BusinessAwardItem-icon")
  self.txtNum = self:child("BusinessAwardItem-num")
  self.txtName = self:child("BusinessAwardItem-name")
end

function WidgetBusinessAwardItem:initEvent()
end

function WidgetBusinessAwardItem:onDataChanged(item)
  self.data = item
  self.txtName:SetText(Lang:toText(""))
  self.imgEffect:SetVisible(false)
  self.imgFrame:SetImage("set:limited_time_activity.json image:img_frame_quality01")
  self.txtNum:SetText("")
  self.imgIcon:SetImage(item.icon)
end

function WidgetBusinessAwardItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetBusinessAwardItem
