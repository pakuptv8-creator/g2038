local widget_base = require("ui.widget.widget_base")
local WidgetDramaTemplateModItem = Lib.derive(widget_base)

function WidgetDramaTemplateModItem:init()
  widget_base.init(self, "DramaTemplateModItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaTemplateModItem:initUI()
  self.imgBg = self:child("DramaTemplateModItem-Bg")
  self.txtName = self:child("DramaTemplateModItem-Name")
end

function WidgetDramaTemplateModItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetDramaTemplateModItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.txtName:SetText(Lang:toText(self.info.templateName))
end

function WidgetDramaTemplateModItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaTemplateModItem
