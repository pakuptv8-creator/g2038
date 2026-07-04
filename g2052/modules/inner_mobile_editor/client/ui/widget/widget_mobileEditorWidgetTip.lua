local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetTip = Lib.derive(widget_base)
local LuaTimer = T(Lib, "LuaTimer")

function WidgetMobileEditorWidgetTip:init()
  widget_base.init(self, "MobileEditorWidgetTip.json")
  self.updateTimer = nil
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetMobileEditorWidgetTip:initUI()
  self.txtText = self:child("MobileEditorWidgetTip-text")
  self.txtText:SetVisible(false)
end

function WidgetMobileEditorWidgetTip:setContent(content)
  self.txtText:SetVisible(true)
  if self.updateTimer then
    LuaTimer:cancel(self.updateTimer)
    self.updateTimer = nil
  end
  self.txtText:SetText(Lang:toText(content))
  self.updateTimer = LuaTimer:schedule(function()
    LuaTimer:cancel(self.updateTimer)
    self.updateTimer = nil
    self.txtText:SetVisible(false)
  end, 2000)
end

function WidgetMobileEditorWidgetTip:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_NOTIFICATION, function(content)
    self:setContent(content)
  end)
end

function WidgetMobileEditorWidgetTip:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorWidgetTip
