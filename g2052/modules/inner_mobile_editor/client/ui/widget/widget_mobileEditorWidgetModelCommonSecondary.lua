local widget_base = require("ui.widget.widget_base")
local WidgetMobileEditorWidgetModelCommonSecondary = Lib.derive(widget_base)
local ConfigManager = T(MobileEditor, "ConfigManager")
local GameManager = T(MobileEditor, "GameManager")

function WidgetMobileEditorWidgetModelCommonSecondary:init()
  widget_base.init(self, "MobileEditorWidgetModelCommonSecondary.json")
  self.lw, self.lh = GUISystem.instance:GetLogicWidth(), GUISystem.instance:GetLogicHeight()
  self.touchDownY = nil
  self.touchUpY = nil
  self.isScroll = false
  self.cfgId = nil
  self.inside = true
  self.isDrag = false
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetMobileEditorWidgetModelCommonSecondary:initUI()
  self.imgBg = self:child("MobileEditorWidgetModelCommonSecondary-bg")
  self.imgEditorIcon = self:child("MobileEditorWidgetModelCommonSecondary-editorIcon")
  self.txtEditorName = self:child("MobileEditorWidgetModelCommonSecondary-editorName")
  self.gvGridView = self:child("MobileEditorWidgetModelCommonSecondary-gridView")
  self.gvGridView:InitConfig(5, 5, 2)
  self.gvGridView:setEnableSilpOutOfBounds(true)
  self.wnd = self.gvGridView:getContainerWindow()
  self.wnd:setEnableDrag(true)
end

function WidgetMobileEditorWidgetModelCommonSecondary:initScrollableView(className)
  self.gvGridView:RemoveAllItems()
  local count = 0
  if self.cfgId then
    self.cfgId = nil
    Lib.emitEvent(Event.EVENT_TOUCH_DOWN_NODE, self.cfgId)
  end
  for _, config in pairs(ConfigManager:instance().modConfig[className] or {}) do
    count = count + 1
    local item = UIMgr:new_widget("mobileEditorWidgetModelButtonSecondary")
    item:invoke("setContent", config)
    self.gvGridView:AddItem(item)
    self:subscribe(item:child("MobileEditorWidgetModelButtonSecondary-icon"), UIEvent.EventWindowTouchDown, function(window, x, y)
      Lib.emitEvent(Event.EVENT_PLAY_SOUND, "plugin/myplugin/sound/g2052_ui_click.mp3", false, 1.0)
      Lib.logDebug("onWindowTouchDown id = ", config.id)
      self.touchDownY = y
    end)
    self:subscribe(item:child("MobileEditorWidgetModelButtonSecondary-icon"), UIEvent.EventWindowTouchMove, function(window, x, y)
      local area = self.gvGridView:GetScreenRenderArea()
      local extraWidth = 10
      if count % 2 == 0 then
        extraWidth = 100
      end
      local width = area[3] - area[1] + extraWidth
      if 0 <= x and x < self.lw - width then
        self.inside = false
      elseif x >= self.lw - width and x <= self.lw then
        self.inside = true
      end
      if self.inside then
        self.isDrag = false
        self.gvGridView:SetMoveAble(true)
      else
        self.gvGridView:SetMoveAble(false)
        if self.isDrag == false then
          self.isDrag = true
          item:invoke("setDrawColor", {
            0,
            1,
            0,
            1
          })
          GameManager:instance():pushState("Create", config.id)
        end
        Lib.emitEvent(Event.EVENT_TOUCH_MOVE_NODE, x, y)
      end
    end)
    self:subscribe(item:child("MobileEditorWidgetModelButtonSecondary-icon"), UIEvent.EventWindowTouchUp, function(window, x, y)
      self.touchUpY = y
      if self.isDrag == true then
        Lib.logDebug("move to create")
        self.cfgId = nil
        self:resetView()
        Lib.emitEvent(Event.EVENT_TOUCH_END_NODE, x, y)
      elseif self.touchUpY ~= self.touchDownY then
        self.cfgId = nil
        self:resetView()
        Lib.emitEvent(Event.EVENT_TOUCH_END_NODE, x, y)
      else
        if self.cfgId == config.id then
          self.cfgId = nil
          item:invoke("setDrawColor", {
            1,
            1,
            1,
            1
          })
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText({
            "ui.unselect",
            config.name
          }))
        else
          if self.cfgId then
            Lib.emitEvent(Event.EVENT_TOUCH_DOWN_NODE, nil)
          end
          self.cfgId = config.id
          self:resetView()
          item:invoke("setDrawColor", {
            0,
            1,
            0,
            1
          })
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText({
            "ui.select",
            config.name
          }))
        end
        Lib.emitEvent(Event.EVENT_TOUCH_DOWN_NODE, self.cfgId)
      end
      self.touchUpY = nil
      self.touchDownY = nil
      self.inside = false
      self.isDrag = false
    end)
  end
end

function WidgetMobileEditorWidgetModelCommonSecondary:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_MODEL_EDITOR, function(className)
    self:initScrollableView(className)
    self.curClassName = className
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_RESET_GEOMETRY, function(name)
    self.cfgId = nil
    self:resetView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_GUIDE_SELECT_DROP_TARGET, function(id)
    self:selectContentByIndex(id)
  end)
end

function WidgetMobileEditorWidgetModelCommonSecondary:resetView()
  local childCount = self.gvGridView:GetItemCount()
  for i = 1, childCount do
    local item = self.gvGridView:GetItem(i - 1)
    if item then
      item:invoke("setDrawColor", {
        1,
        1,
        1,
        1
      })
    end
  end
end

function WidgetMobileEditorWidgetModelCommonSecondary:refreshTitle(title, icon)
  self.imgEditorIcon:SetImage(icon)
  self.txtEditorName:SetText(Lang:toText(title))
end

function WidgetMobileEditorWidgetModelCommonSecondary:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WidgetMobileEditorWidgetModelCommonSecondary:selectContentByIndex(id)
  if self:isvisible() and self.curClassName then
    local count = 0
    for i, config in pairs(ConfigManager:instance().modConfig[self.curClassName] or {}) do
      if i == id then
        local childCount = self.gvGridView:GetItemCount()
        if count <= childCount - 1 then
          local item = self.gvGridView:GetItem(count)
          if self.cfgId then
            Lib.emitEvent(Event.EVENT_TOUCH_DOWN_NODE, nil)
          end
          self.cfgId = config.id
          self:resetView()
          item:invoke("setDrawColor", {
            0,
            1,
            0,
            1
          })
          Lib.emitEvent(Event.EVENT_SHOW_NOTIFICATION, Lang:toText({
            "ui.select",
            config.name
          }))
          Lib.emitEvent(Event.EVENT_TOUCH_DOWN_NODE, self.cfgId)
        end
        break
      end
      count = count + 1
    end
  end
end

return WidgetMobileEditorWidgetModelCommonSecondary
