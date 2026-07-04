local RedDotConfig = T(Config, "RedDotConfig")
local RED_DOT_KEY = {
  [1] = RedDotConfig.RD_KEY.ClothingTab,
  [2] = RedDotConfig.RD_KEY.AccessoriesTab,
  [3] = RedDotConfig.RD_KEY.BodyTab,
  [4] = RedDotConfig.RD_KEY.ExpressionTab
}
local widget_base = require("ui.widget.widget_base")
local WidgetCategoryItem = Lib.derive(widget_base)

function WidgetCategoryItem:init()
  widget_base.init(self, "CategoryItem.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetCategoryItem:initUI()
  self.btnChoose = self:child("CategoryItem-Choose")
  self.imgIcon = self:child("CategoryItem-icon")
  self.imgRedDot = self:child("CategoryItem-redDot")
end

function WidgetCategoryItem:initEvent()
  self:subscribe(self.btnChoose, UIEvent.EventButtonClick, function()
    if self.clickCb then
      self.clickCb()
    end
  end)
end

function WidgetCategoryItem:onDataChanged(params)
  self.data = params.data
  self.clickCb = params.clickCb
  self.imgIcon:SetImage(self.data.icon)
  self:updateBtnSelectStatus(params.select)
  if not self.hasRegisterRed and self.data.category and RED_DOT_KEY[self.data.category] then
    local key = RED_DOT_KEY[self.data.category]
    Plugins.CallPluginFunc("linkRedDotAction", key, function(show)
      self:updateRedDotVisible(show ~= 0)
    end)
    self.hasRegisterRed = true
  end
end

function WidgetCategoryItem:updateBtnSelectStatus(isSelect)
  self.btnChoose:SetNormalImage(isSelect and "set:g2052_function.json image:img_0_roles02" or "set:g2052_function.json image:img_0_roles01")
  self.btnChoose:SetPushedImage(isSelect and "set:g2052_function.json image:img_0_roles02" or "set:g2052_function.json image:img_0_roles01")
end

function WidgetCategoryItem:updateRedDotVisible(isVisible)
  self.imgRedDot:SetVisible(isVisible)
end

function WidgetCategoryItem:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetCategoryItem
