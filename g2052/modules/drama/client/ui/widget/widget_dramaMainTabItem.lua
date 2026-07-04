local widget_base = require("ui.widget.widget_base")
local WidgetDramaMainTabItem = Lib.derive(widget_base)

function WidgetDramaMainTabItem:init()
  widget_base.init(self, "DramaMainTabItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetDramaMainTabItem:initUI()
  self.imgNormalBg = self:child("DramaMainTabItem-NormalBg")
  self.imgSelectBg = self:child("DramaMainTabItem-SelectBg")
  self.txtLabel = self:child("DramaMainTabItem-Label")
end

function WidgetDramaMainTabItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetDramaMainTabItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  self.select = data.select
  if self.info then
    self:updateView()
  end
end

function WidgetDramaMainTabItem:updateView()
  local lang = self.info.lang
  self.txtLabel:SetText(Lang:toText(lang))
  self.imgSelectBg:SetVisible(self.select)
  self.imgNormalBg:SetVisible(not self.select)
  if self.select then
    self.txtLabel:SetTextColor(Lib.getTextColor("000000"))
  else
    self.txtLabel:SetTextColor(Lib.getTextColor("646567"))
  end
end

function WidgetDramaMainTabItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetDramaMainTabItem
