local widget_base = require("ui.widget.widget_base")
local WidgetDramaTemplateNumItem = Lib.derive(widget_base)

function WidgetDramaTemplateNumItem:init()
  widget_base.init(self, "DramaTemplateNumItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaTemplateNumItem:initUI()
  self.imgBg = self:child("DramaTemplateNumItem-Bg")
  self.txtName = self:child("DramaTemplateNumItem-Name")
end

function WidgetDramaTemplateNumItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetDramaTemplateNumItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.txtName:SetText(Lang:toText(self.info))
end

function WidgetDramaTemplateNumItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaTemplateNumItem
