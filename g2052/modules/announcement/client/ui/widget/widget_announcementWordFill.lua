local widget_base = require("ui.widget.widget_base")
local WidgetAnnouncementWordFill = Lib.derive(widget_base)

function WidgetAnnouncementWordFill:init()
  widget_base.init(self, "AnnouncementWordFill.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetAnnouncementWordFill:initUI()
end

function WidgetAnnouncementWordFill:initEvent()
end

function WidgetAnnouncementWordFill:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetAnnouncementWordFill
