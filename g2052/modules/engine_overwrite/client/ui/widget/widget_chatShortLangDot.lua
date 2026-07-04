local widget_base = require("ui.widget.widget_base")
local WidgetChatShortLangDot = Lib.derive(widget_base)

function WidgetChatShortLangDot:init()
  widget_base.init(self, "ChatShortLangDot.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatShortLangDot:initUI()
  self.imgSelectBg = self:child("ChatShortLangDot-SelectBg")
  self.imgNormalBg = self:child("ChatShortLangDot-NormalBg")
end

function WidgetChatShortLangDot:initEvent()
end

function WidgetChatShortLangDot:updateSelectState(value)
  self.imgSelectBg:SetVisible(value)
  self.imgNormalBg:SetVisible(not value)
end

function WidgetChatShortLangDot:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetChatShortLangDot
