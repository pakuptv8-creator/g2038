local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetModelButton = Lib.derive(widget_base)

function WidgetMobileEditorWidgetModelButton:init()
  widget_base.init(self, "MobileEditorWidgetModelButton.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetMobileEditorWidgetModelButton:initUI()
  self.imgSelectBg = self:child("MobileEditorWidgetModelButton-selectBg")
  self.btnButton = self:child("MobileEditorWidgetModelButton-button")
  self.imgSelectBg:SetVisible(false)
end

function WidgetMobileEditorWidgetModelButton:setContent(content)
  self.name = content.name
  self.icon = content.icon
  self.imgSelectBg:SetVisible(false)
  self.btnButton:SetNormalImage(self.icon)
  self.btnButton:SetPushedImage(self.icon)
end

function WidgetMobileEditorWidgetModelButton:initEvent()
  self:subscribe(self.btnButton, UIEvent.EventButtonClick, function()
    local selectModelType = ""
    if not self.imgSelectBg:IsVisible() then
      selectModelType = self.name
    end
    Lib.emitEvent(Event.EVENT_SHOW_MODEL_EDITOR, selectModelType)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_MODEL_EDITOR, function(className)
    if className == self.name then
      self.imgSelectBg:SetVisible(true)
    else
      self.imgSelectBg:SetVisible(false)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LEAVE_EDIT_MODE, function()
    self.imgSelectBg:SetVisible(false)
  end)
end

function WidgetMobileEditorWidgetModelButton:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorWidgetModelButton
