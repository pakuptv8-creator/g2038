local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorToolMain = Lib.derive(widget_base)

function WidgetMobileEditorToolMain:init()
  widget_base.init(self, "MobileEditorToolMain.json")
  self.lastSelectPanel = "model"
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:subscribeEvent()
end

function WidgetMobileEditorToolMain:initUI()
  self.imgBg = self:child("MobileEditorToolMain-bg")
  self.lytModelLayout = self:child("MobileEditorToolMain-modelLayout")
  self.lytObjectLayout = self:child("MobileEditorToolMain-objectLayout")
  self.lytMask = self:child("MobileEditorToolMain-mask")
  self.modelWidget = UIMgr:new_widget("mobileEditorToolModel")
  self.lytModelLayout:AddChildWindow(self.modelWidget)
  self.objectWidget = UIMgr:new_widget("mobileEditorToolObject")
  self.lytObjectLayout:AddChildWindow(self.objectWidget)
  self.lytModelLayout:SetVisible(true)
  self.lytObjectLayout:SetVisible(false)
  self.lytMask:SetVisible(false)
  self.uiList = {
    model = {
      layout = self.lytModelLayout,
      widget = self.modelWidget
    },
    object = {
      layout = self.lytObjectLayout,
      widget = self.objectWidget
    }
  }
end

function WidgetMobileEditorToolMain:initEvent()
end

function WidgetMobileEditorToolMain:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_TOOL_PANEL, function(name, targets)
    if name ~= "object" then
      self.lastSelectPanel = name
    end
    for key, ui in pairs(self.uiList) do
      if key == name then
        ui.layout:SetVisible(true)
        if ui.widget then
          ui.widget:invoke("setTargets", targets)
        end
      else
        ui.layout:SetVisible(false)
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_LAST_TOOL_PANEL, function()
    Lib.emitEvent(Event.EVENT_SHOW_TOOL_PANEL, self.lastSelectPanel)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LEAVE_EDIT_MODE, function()
    self.lytModelLayout:SetVisible(true)
    self.lytObjectLayout:SetVisible(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTER_PLAY_MODE, function()
    self.lytMask:SetVisible(true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_ENTER_EDIT_MODE, function()
    self.lytMask:SetVisible(false)
  end)
end

function WidgetMobileEditorToolMain:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorToolMain
