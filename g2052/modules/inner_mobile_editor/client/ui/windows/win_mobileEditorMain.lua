local WinMobileEditorMain = M

function WinMobileEditorMain:init()
  WinBase.init(self, "MobileEditorMain.json")
  self._allEvent = {}
  self:initUI()
end

function WinMobileEditorMain:initUI()
  self.selector = self:child("MobileEditorMain-selector")
  local toolMain = UIMgr:new_widget("mobileEditorToolMain")
  self._root:AddChildWindow(toolMain)
  self.topBar = UIMgr:new_widget("mobileEditorTopBar")
  self._root:AddChildWindow(self.topBar)
  local tip = UIMgr:new_widget("mobileEditorWidgetTip")
  self._root:AddChildWindow(tip)
  self.startPos = nil
  self.selector:SetVisible(false)
end

function WinMobileEditorMain:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_START_SELECTION, function(pos)
    self.startPos = pos
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_SELECTION, function(pos)
    self.selector:SetVisible(true)
    local diffX = pos.x - self.startPos.x
    local diffY = pos.y - self.startPos.y
    local offsetX = 0
    local offsetY = 0
    if diffX < 0 then
      offsetX = diffX
    end
    if diffY < 0 then
      offsetY = diffY
    end
    self.selector:SetArea({
      0,
      self.startPos.x + offsetX
    }, {
      0,
      self.startPos.y + offsetY
    }, {
      0,
      math.abs(diffX)
    }, {
      0,
      math.abs(diffY)
    })
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_END_SELECTION, function(pos)
    self.startPos = nil
    self.selector:SetVisible(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CLOSE_TOP, function()
    self.topBar:invoke("setVisible", false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_OPEN_TOP, function()
    self.topBar:invoke("setVisible", true)
  end)
end

function WinMobileEditorMain:onOpen()
  self.startPos = nil
  self.selector:SetVisible(false)
  self:initEvent()
  self.topBar:invoke("initViewShow")
end

function WinMobileEditorMain:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinMobileEditorMain
