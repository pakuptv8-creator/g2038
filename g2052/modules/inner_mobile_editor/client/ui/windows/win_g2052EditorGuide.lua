local WinG2052EditorGuide = M
local GameManager = T(MobileEditor, "GameManager")
local m_posx, m_posy, m_radius = 0, 0, 0
local checkPos = false

local function fetchImg(png, program)
  local img = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "")
  img:SetImage(png)
  img:setProgram(program)
  img:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  img:SetAlwaysOnTop(true)
  return img
end

function WinG2052EditorGuide:init()
  WinBase.init(self, "G2052EditorGuide.json")
  self._allEvent = {}
  self.index = 1
  self:initUI()
  self:initEvent()
end

function WinG2052EditorGuide:initUI()
  self:root():setBelongWhitelist(true)
  self:root():SetAlwaysOnTop(true)
  self:root():SetLevel(1)
  self.imgTrigger = self:child("G2052EditorGuide-trigger")
  self.lytInitInfo = self:child("G2052EditorGuide-initInfo")
  self.mask = self:child("G2052EditorGuide-guideMask")
  self:child("G2052EditorGuide-tip1"):SetText(Lang:toText("g2052.gui.save.and.undo"))
  self:child("G2052EditorGuide-tip2"):SetText(Lang:toText("g2052.gui.cinnabar.area"))
  self.txtControlTip = self:child("G2052EditorGuide-tip3")
  self.lytScreenGuide = self:child("G2052EditorGuide-screen_guide")
  self.lytRotateGuide = self:child("G2052EditorGuide-rotate")
  self.lytZoomGuide = self:child("G2052EditorGuide-zoom")
end

function WinG2052EditorGuide:initEvent()
  self:subscribe(self.lytInitInfo, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    if self.index == 1 then
      self.lytInitInfo:SetVisible(false)
      local trigger = UI:findChild("mobileEditorMain/MobileEditorWidgetModelButton-guide", 1)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    end
    self.index = self.index + 1
    self.txtControlTip:SetText(Lang:toText("g2052.gui.guide.tip." .. self.index))
  end)
  self:subscribe(self.imgTrigger, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
    if self.index == 2 then
      Lib.emitEvent(Event.EVENT_SHOW_MODEL_EDITOR, "geometry")
      local trigger = UI:findChild("mobileEditorMain/MobileEditorWidgetModelButtonSecondary-bg", 0)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    elseif self.index == 3 then
      Lib.emitEvent(Event.EVENT_GUIDE_SELECT_DROP_TARGET, 30016)
      local area = {
        [1] = 495.0,
        [2] = 455.0,
        [3] = 695,
        [4] = 655
      }
      self:setMask(area, true, area[3] - 100, area[4] - 100)
    elseif self.index == 4 then
      Lib.emitEvent(Event.EVENT_TOUCH_BEGIN, 0, 595.0, 555.0)
      Lib.emitEvent(Event.EVENT_TOUCH_END, 0, 595.0, 555.0)
      local trigger = UI:findChild("mobileEditorMain/MobileEditorTopBar-undoBtn", 0)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    elseif self.index == 5 then
      if GameManager:instance():getCurrentState() == "Create" then
        return
      end
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.undo"))
      Lib.emitEvent(Event.EVENT_UNDO_COMMAND)
      local trigger = UI:findChild("mobileEditorMain/MobileEditorTopBar-redoBtn", 0)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    elseif self.index == 6 then
      if GameManager:instance():getCurrentState() == "Create" then
        return
      end
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.select.redo"))
      Lib.emitEvent(Event.EVENT_REDO_COMMAND)
      local trigger = UI:findChild("mobileEditorMain/MobileEditorTopBar-saveBtn", 0)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    elseif self.index == 7 then
      if GameManager:instance():getCurrentState() == "Create" then
        return
      end
      Lib.emitEvent(Event.EVENT_SAVE_MAP_CHANGE)
      Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText("ui.setting.save.success"))
      local trigger = UI:findChild("mobileEditorMain/MobileEditorTopBar-settingBtn", 0)
      local area = trigger:GetRenderArea()
      local size = trigger:GetPixelSize()
      self:setMask(area, true, area[3] - size.x / 2, area[4] - size.y / 2)
    elseif self.index == 8 then
      if GameManager:instance():getCurrentState() == "Create" then
        return
      end
      Lib.emitEvent(Event.EVENT_OPEN_WINDOW, "mobile_editor_setting")
      Lib.emitEvent(Event.EVENT_UNSELECT_TARGET)
      Lib.emitEvent(Event.EVENT_RESET_TARGET)
      UI:openWnd("mobileEditorSetting")
      self.mask:SetVisible(false)
      self.imgTrigger:SetVisible(false)
      self.lytScreenGuide:SetVisible(true)
      self.lytRotateGuide:SetVisible(true)
      self.lytZoomGuide:SetVisible(false)
    end
    self.index = self.index + 1
    self.txtControlTip:SetText(Lang:toText("g2052.gui.guide.tip." .. self.index))
  end)
end

function WinG2052EditorGuide:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PINCH_CAMERA, function(delta)
    self.lytRotateGuide:SetVisible(false)
    self.lytZoomGuide:SetVisible(true)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_TURN_CAMERA, function(delta)
    self:onHide()
  end)
end

function WinG2052EditorGuide:setMask(area, needForce, posx, posy, radius)
  self:setRectangleMask(self.mask, area)
  self.mask:SetVisible(true)
  self.mask:SetTouchable(needForce)
  self.imgTrigger:SetVisible(true)
  self.imgTrigger:SetTouchable(true)
  self.imgTrigger:SetArea({
    0,
    area[1]
  }, {
    0,
    area[2]
  }, {
    0,
    area[3] - area[1]
  }, {
    0,
    area[4] - area[2]
  })
  UI.guideMask = {
    x = tonumber(posx),
    y = tonumber(posy),
    r = tonumber(radius)
  }
end

function WinG2052EditorGuide:initView()
  self.index = 1
  self.txtControlTip:SetText(Lang:toText("g2052.gui.guide.tip." .. self.index))
  self.lytScreenGuide:SetVisible(false)
end

function WinG2052EditorGuide:onHide()
  UI:closeWnd("g2052EditorGuide")
end

function WinG2052EditorGuide:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052EditorGuide")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinG2052EditorGuide:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinG2052EditorGuide:setRectangleMask(node, area)
  local maskName = "{0D2D61DC-8DF6-47A0-BA88-892C66979CFB}"
  local img = node:child(maskName)
  if not img then
    img = fetchImg("empty.png", "RECTANGLEMASK")
    img:SetTouchable(false)
    node:AddChildWindow(img, maskName)
  end
  local size = img:GetPixelSize()
  img:material():iSize(size.x, size.y)
  img:material():iColor(0, 0, 0, 0.5)
  img:material():iTopleft(area[1], area[2], 0, 0)
  img:material():iBottomright(area[3], area[4], 0, 0)
end

function WinG2052EditorGuide:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  UI.guideMask = {}
  local count = self.mask:GetChildCount()
  for i = 1, count do
    local child = self.mask:GetChildByIndex(0)
    self.mask:RemoveChildWindow1(child)
  end
  self.clickEffect = nil
end

return WinG2052EditorGuide
