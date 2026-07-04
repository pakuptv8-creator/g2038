local widget_base = require("ui.widget.widget_base")
local WidgetGiftBtnItem = Lib.derive(widget_base)

function WidgetGiftBtnItem:init()
  widget_base.init(self, "GiftBtnItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetGiftBtnItem:initUI()
  self.imgNormalIcon = self:child("GiftBtnItem-NormalIcon")
  self.imgIcon = self:child("GiftBtnItem-icon")
end

function WidgetGiftBtnItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
    end
  end)
end

function WidgetGiftBtnItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  if self.info then
    self:updateView()
  end
end

function WidgetGiftBtnItem:updateView()
  self.imgIcon:SetImage(self.info.icon)
end

function WidgetGiftBtnItem:empty()
  self.imgIcon:SetImage()
end

function WidgetGiftBtnItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WidgetGiftBtnItem
