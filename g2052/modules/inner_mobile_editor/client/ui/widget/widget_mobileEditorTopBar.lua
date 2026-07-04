local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorTopBar = Lib.derive(widget_base)
local GameManager = T(MobileEditor, "GameManager")
local CommandManager = T(MobileEditor, "CommandManager")

function WidgetMobileEditorTopBar:init()
  widget_base.init(self, "MobileEditorTopBar.json")
  self.enableMultiple = false
  self.isExit = false
  self.isPlay = false
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:subscribeEvents()
  self:checkUndo()
  self:checkRedo()
end

function WidgetMobileEditorTopBar:initUI()
  self.btnSettingBtn = self:child("MobileEditorTopBar-settingBtn")
  self.btnSaveBtn = self:child("MobileEditorTopBar-saveBtn")
  self.btnUndoBtn = self:child("MobileEditorTopBar-undoBtn")
  self.btnRedoBtn = self:child("MobileEditorTopBar-redoBtn")
  self.btnPlayBtn = self:child("MobileEditorTopBar-playBtn")
  self.txtPlayBtnTxt = self:child("MobileEditorTopBar-playBtnTxt")
  self.txtPlayBtnTxt:SetText(Lang:toText("g2052.gui.mod_map.play"))
end

function WidgetMobileEditorTopBar:initEvent()
  self:subscribe(self.btnSettingBtn, UIEvent.EventButtonClick, function()
    if GameManager:instance():getCurrentState() == "Create" then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_OPEN_WINDOW, "mobile_editor_setting")
    Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
    Lib.emitEvent(Event.EVENT_RESET_TARGET)
    UI:openWnd("mobileEditorSetting")
  end)
  self:subscribe(self.btnSaveBtn, UIEvent.EventButtonClick, function()
    if GameManager:instance():getCurrentState() == "Create" then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.setting.save.success"))
  end)
  self:subscribe(self.btnUndoBtn, UIEvent.EventButtonClick, function()
    if GameManager:instance():getCurrentState() == "Create" then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.undo"))
    Lib.emitEvent(Event.EVENT_UNDO_COMMAND)
  end)
  self:subscribe(self.btnRedoBtn, UIEvent.EventButtonClick, function()
    if GameManager:instance():getCurrentState() == "Create" then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.redo"))
    Lib.emitEvent(Event.EVENT_REDO_COMMAND)
  end)
  self:subscribe(self.btnPlayBtn, UIEvent.EventButtonClick, function()
    if GameManager:instance():getCurrentState() == "Create" then
      return
    end
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    Lib.logDebug("BtnPlay")
    self.isPlay = true
    Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
    Lib.emitEvent(Event.EVENT_ENTER_PLAY_MODE)
    Plugins.CallTargetPluginFunc("inner_mobile_editor", "enterEditorPlayerMode")
  end)
end

function WidgetMobileEditorTopBar:subscribeEvents()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHANGE_TOOL_BAR, function(state)
    if state == "Edit" then
      self.btnSettingBtn:SetVisible(true)
      self.btnSaveBtn:SetVisible(true)
      self.btnUndoBtn:SetVisible(true)
      self.btnRedoBtn:SetVisible(true)
      self.btnPlayBtn:SetVisible(true)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CHECK_UNDO_REDO, function()
    self:checkUndo()
    self:checkRedo()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_MODEL_EDITOR, function(modelName)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_TOOL_PANEL, function(name)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_LEAVE_EDIT_MODE, function()
    self:checkRedo()
    self:checkUndo()
    self.enableMultiple = false
    Lib.emitEvent(Event.EVENT_ENABLE_MULTIPLE, self.enableMultiple)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_EDIT_PLAY_SHOW, function(isShow)
    self:updatePlayBtnShow(isShow)
  end)
end

function WidgetMobileEditorTopBar:updatePlayBtnShow(isShow)
  self.btnPlayBtn:SetVisible(isShow)
end

function WidgetMobileEditorTopBar:setVisible(isShow)
  self._root:SetVisible(isShow)
end

function WidgetMobileEditorTopBar:initViewShow()
  self:updatePlayBtnShow(true)
end

function WidgetMobileEditorTopBar:checkRedo()
  local status = CommandManager:instance():checkRedo()
  Lib.logDebug("EVENT_UPDATE_REDO status = ", status)
  if status then
    self.btnRedoBtn:SetEnabled(true)
    self.btnRedoBtn:SetProperty("Alpha", 1.0)
  else
    self.btnRedoBtn:SetEnabled(false)
    self.btnRedoBtn:SetProperty("Alpha", 0.5)
  end
end

function WidgetMobileEditorTopBar:checkUndo()
  local status = CommandManager:instance():checkUndo()
  Lib.logDebug("EVENT_UPDATE_UNDO status = ", status)
  if status then
    self.btnUndoBtn:SetEnabled(true)
    self.btnUndoBtn:SetProperty("Alpha", 1.0)
  else
    self.btnUndoBtn:SetEnabled(false)
    self.btnUndoBtn:SetProperty("Alpha", 0.5)
  end
end

function WidgetMobileEditorTopBar:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetMobileEditorTopBar
