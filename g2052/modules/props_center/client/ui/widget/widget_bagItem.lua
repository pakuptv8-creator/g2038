local PropsConfig = T(Config, "PropsConfig")
local widget_base = require("ui.widget.widget_base")
local WidgetBagItem = Lib.derive(widget_base)

function WidgetBagItem:init()
  widget_base.init(self, "BagItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBagItem:initUI()
  self.imgNormalIcon = self:child("BagItem-NormalIcon")
  self.imgSelectIcon = self:child("BagItem-SelectIcon")
  self.txtActionTitle = self:child("BagItem-ActionTitle")
  self.imgIcon = self:child("BagItem-icon")
  self.imgRedDot = self:child("BagItem-RedDot")
end

function WidgetBagItem:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self:updateRedDotStatus(false)
      if self.info.isNew == 1 then
        PropsConfig:updateIsNewStatusById(self.info.id)
        Me:updatePropsRedDotStatus()
        if Me.newPropsScanRecord then
          Me.newPropsScanRecord[tostring(self.info.id)] = 1
        end
        Me:saveNewPropsScanRecord()
      end
      self.fun()
    end
  end)
end

function WidgetBagItem:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.index = data.index
  if self.info then
    self:updateView()
  end
  self.imgSelectIcon:SetVisible(self.info.isHave)
  self:updateRedDotStatus(self.info.isNew == 1)
end

function WidgetBagItem:updateRedDotStatus(isVisible)
  self.imgRedDot:SetVisible(isVisible)
end

function WidgetBagItem:updateView()
  self.txtActionTitle:SetText(Lang:toText(self.info.name))
  self.imgIcon:SetImage(self.info.icon)
end

function WidgetBagItem:empty()
  self.txtActionTitle:SetText("")
  self.imgIcon:SetImage()
end

function WidgetBagItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetBagItem:hideNormalImage()
  self.imgNormalIcon:SetVisible(false)
end

return WidgetBagItem
