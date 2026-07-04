local widget_base = require("ui.widget.widget_base")
local WidgetModMapReportDropDownItem = Lib.derive(widget_base)

function WidgetModMapReportDropDownItem:init()
  widget_base.init(self, "ModMapReportDropDownItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModMapReportDropDownItem:initUI()
  self.imgBg = self:child("ModMapReportDropDownItem-Bg")
  self.txtText = self:child("ModMapReportDropDownItem-Text")
end

function WidgetModMapReportDropDownItem:initEvent()
  self:subscribe(self:root(), UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetModMapReportDropDownItem:onDataChanged(data)
  print("----data---", Lib.v2s(data))
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  self.select = data.select
  if self.info then
    self.txtText:SetText(Lang:toText(self.info.lang or ""))
  end
end

function WidgetModMapReportDropDownItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModMapReportDropDownItem
