local widget_base = require("ui.widget.widget_base")
local WidgetModAuthorMedalItem = Lib.derive(widget_base)

function WidgetModAuthorMedalItem:init()
  widget_base.init(self, "ModAuthorMedalItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModAuthorMedalItem:initUI()
  self.imgBg = self:child("ModAuthorMedalItem-Bg")
end

function WidgetModAuthorMedalItem:initEvent()
end

function WidgetModAuthorMedalItem:onDataChanged(data)
  self.data = data
end

function WidgetModAuthorMedalItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModAuthorMedalItem
