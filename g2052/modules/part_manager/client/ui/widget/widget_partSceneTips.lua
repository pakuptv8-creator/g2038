local widget_base = require("ui.widget.widget_base")
local WidgetPartSceneTips = Lib.derive(widget_base)

function WidgetPartSceneTips:init()
  widget_base.init(self, "PartSceneTips.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetPartSceneTips:initUI()
  self.imgContentPanel = self:child("PartSceneTips-ContentPanel")
  self.txtContentStr = self:child("PartSceneTips-ContentStr")
end

function WidgetPartSceneTips:initEvent()
end

function WidgetPartSceneTips:updatePartTipsInfo(cfgInfo)
  self.txtContentStr:SetText(Lang:toText(cfgInfo.showName))
end

function WidgetPartSceneTips:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetPartSceneTips
