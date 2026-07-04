local widget_base = require("ui.widget.widget_base")
local WidgetModSelectTopItem = Lib.derive(widget_base)
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModSelectTopItem:init()
  widget_base.init(self, "ModSelectTopItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModSelectTopItem:initUI()
  self.imgNormalIcon = self:child("ModSelectTopItem-NormalIcon")
  self.txtEventTitle = self:child("ModSelectTopItem-EventTitle")
end

function WidgetModSelectTopItem:initEvent()
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.MainBannerL1)
    Lib.emitEvent(Event.EVENT_MOD_HANDLE_MAIN_BANNER, self.data)
  end)
end

function WidgetModSelectTopItem:updateModEventShow(data)
  self.data = data
  self.imgNormalIcon:SetImageUrl(data.imagePic)
  self.txtEventTitle:SetText(data.eventDesc)
end

function WidgetModSelectTopItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModSelectTopItem
