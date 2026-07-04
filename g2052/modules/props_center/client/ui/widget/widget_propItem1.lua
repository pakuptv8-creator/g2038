local widget_base = require("ui.widget.widget_base")
local WidgetPropItem1 = Lib.derive(widget_base)
local PropsConfig = T(Config, "PropsConfig")

function WidgetPropItem1:init()
  widget_base.init(self, "PropItem1.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPropItem1:initUI()
  self.imgBg = self:child("PropItem1-Bg")
  self.imgIcon = self:child("PropItem1-Icon")
end

function WidgetPropItem1:initEvent()
end

function WidgetPropItem1:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetPropItem1:reload(itemId)
  if not itemId then
    return
  end
  self.itemId = itemId
  local cfg = PropsConfig:getCfgById(itemId)
  if not cfg then
    return
  end
  self.imgIcon:SetImage(cfg.icon)
end

return WidgetPropItem1
