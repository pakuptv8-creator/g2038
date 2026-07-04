local widget_base = require("ui.widget.widget_base")
local WidgetDramaSelectCoverItem = Lib.derive(widget_base)

function WidgetDramaSelectCoverItem:init()
  widget_base.init(self, "DramaSelectCoverItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaSelectCoverItem:initUI()
  self.imgImg = self:child("DramaSelectCoverItem-img")
  self.imgSelectImg = self:child("DramaSelectCoverItem-SelectImg")
end

function WidgetDramaSelectCoverItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetDramaSelectCoverItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.imgImg:SetImage(self.info.img)
  self.imgSelectImg:SetVisible(self.data.select)
end

function WidgetDramaSelectCoverItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaSelectCoverItem
