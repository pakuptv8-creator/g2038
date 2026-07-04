local RedDotConfig = T(Config, "RedDotConfig")
local RED_DOT_KEY = {
  [11] = RedDotConfig.RD_KEY.SuitsTab,
  [12] = RedDotConfig.RD_KEY.TopsTab,
  [13] = RedDotConfig.RD_KEY.PantsTab,
  [14] = RedDotConfig.RD_KEY.TopsGirlTab,
  [15] = RedDotConfig.RD_KEY.PantsGirlTab,
  [16] = RedDotConfig.RD_KEY.ShoesTab,
  [21] = RedDotConfig.RD_KEY.HatTab,
  [22] = RedDotConfig.RD_KEY.HairTab,
  [23] = RedDotConfig.RD_KEY.HeadTab,
  [24] = RedDotConfig.RD_KEY.BagTab,
  [25] = RedDotConfig.RD_KEY.WaistTab
}
local widget_base = require("ui.widget.widget_base")
local WidgetTabItem = Lib.derive(widget_base)

function WidgetTabItem:init()
  widget_base.init(self, "TabItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetTabItem:initUI()
  self.btnChoose = self:child("TabItem-Choose")
  self.imgIcon = self:child("TabItem-icon")
  self.imgRedDot = self:child("TabItem-redDot")
  self.txtName = self:child("TabItem-txtName")
end

function WidgetTabItem:initEvent()
  self:subscribe(self.btnChoose, UIEvent.EventButtonClick, function()
    if self.clickCb then
      self.clickCb()
    end
  end)
end

function WidgetTabItem:onDataChanged(params)
  self.data = params.data
  self.clickCb = params.clickCb
  self.imgIcon:SetImage(self.data.tabIcon)
  self:updateSelectStatus(params.select)
  if self.data.text then
    self.txtName:SetVisible(true)
    self.txtName:SetText(self.data.text)
  else
    self.txtName:SetVisible(false)
  end
  if not self.hasRegisterRed then
    if self.data.id and RED_DOT_KEY[self.data.id] then
      local key = RED_DOT_KEY[self.data.id]
      Plugins.CallPluginFunc("linkRedDotAction", key, function(show)
        self:updateRedDotVisible(show ~= 0)
      end)
      self.hasRegisterRed = true
    elseif self.data.redDotKey then
      Plugins.CallPluginFunc("linkRedDotAction", self.data.redDotKey, function(show)
        self:updateRedDotVisible(show ~= 0)
      end)
      self.hasRegisterRed = true
    end
  end
end

function WidgetTabItem:updateSelectStatus(isSelect)
  self.btnChoose:SetNormalImage(isSelect and "set:g2052_function.json image:img_0_roles04" or "set:g2052_function.json image:img_0_roles03")
  self.btnChoose:SetPushedImage(isSelect and "set:g2052_function.json image:img_0_roles04" or "set:g2052_function.json image:img_0_roles03")
  self.imgIcon:SetAlpha(isSelect and 1 or 0.5)
  self.imgIcon:SetDrawColor(isSelect and {
    0.23529411764705882,
    0.7019607843137254,
    1.0,
    1
  } or {
    1.0,
    1.0,
    1.0,
    1
  })
end

function WidgetTabItem:updateRedDotVisible(isVisible)
  self.imgRedDot:SetVisible(isVisible)
end

function WidgetTabItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetTabItem
