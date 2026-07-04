local widget_base = require("ui.widget.widget_base")
local WidgetG2052ShopTab = Lib.derive(widget_base)
local BusinessHelper = T(Lib, "BusinessHelper")

function WidgetG2052ShopTab:init()
  widget_base.init(self, "G2052ShopTab.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetG2052ShopTab:initUI()
  self.lytContentPanel = self:child("G2052ShopTab-ContentPanel")
  self.imgNormalBg = self:child("G2052ShopTab-NormalBg")
  self.imgSelectBg = self:child("G2052ShopTab-SelectBg")
  self.imgTabIcon = self:child("G2052ShopTab-TabIcon")
  self.redIcon = self:child("G2052ShopTab-redIcon")
  self.redIcon:SetVisible(false)
end

function WidgetG2052ShopTab:initEvent()
  self:subscribe(self._root, UIEvent.EventWindowClick, function()
    if self.fun then
      self.fun()
      if not self.info.isItemShop then
        self.redIcon:SetVisible(false)
        BusinessHelper:updatePrivilegeClickState(true)
      end
    end
  end)
end

function WidgetG2052ShopTab:onDataChanged(data)
  self.data = data
  self.info = data.data
  self.fun = data.clickCb
  self.select = data.select
  if self.info then
    self.imgTabIcon:SetImage(self.info.icon)
    if not self.info.isItemShop then
      local needShow = BusinessHelper:getPrivilegeRedShowState()
      self.redIcon:SetVisible(needShow)
    else
      self.redIcon:SetVisible(false)
    end
  end
  self.imgNormalBg:SetVisible(not self.select)
  self.imgSelectBg:SetVisible(self.select)
end

function WidgetG2052ShopTab:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetG2052ShopTab
