local widget_base = require("ui.widget.widget_base")
local WidgetPhoneCallItem = Lib.derive(widget_base)

function WidgetPhoneCallItem:init()
  widget_base.init(self, "PhoneCallItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPhoneCallItem:initUI()
  self.imgEffectIcon = self:child("PhoneCallItem-EffectIcon")
  self.txtDistanceStr = self:child("PhoneCallItem-DistanceStr")
end

function WidgetPhoneCallItem:initEvent()
end

function WidgetPhoneCallItem:updateDistanceShow(dis)
  local str = math.floor(dis * 100) / 100 .. " m"
  self.txtDistanceStr:SetText(str)
end

function WidgetPhoneCallItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPhoneCallItem
