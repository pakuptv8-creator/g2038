local OPERATION_BTN_CONFIG = {
  house = {
    icon = "set:g2052_main.json image:icon_0_house",
    widget_name = "houseOperationItem",
    updateCurrent = true
  },
  car = {
    icon = "set:g2052_main.json image:icon_0_carriers",
    hideTxt = true,
    widget_name = "carOperationItem"
  }
}
local BTN_RES = {
  normal = "set:g2052_function.json image:img_9_box_bg03",
  selected = "set:g2052_function.json image:img_9_box_bg04"
}
local table_insert = table.insert
local table_remove = table.remove
local WinHouseAndCarOperation = M

function WinHouseAndCarOperation:init()
  WinBase.init(self, "HouseAndCarOperation.json")
  self._operationList = {}
  self._widgets = {}
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:updateHouseOperationShow(false)
end

function WinHouseAndCarOperation:initUI()
  self.lytContentPanel = self:child("HouseAndCarOperation-ContentPanel")
  for i = 1, 2 do
    self["imgOperationBtn" .. i] = self:child("HouseAndCarOperation-operationBtn" .. i)
    self["imgOBtnIcon" .. i] = self:child("HouseAndCarOperation-oBtnIcon" .. i)
    self["txtIntro" .. i] = self:child("HouseAndCarOperation-text" .. i)
  end
  self.lytContainer = self:child("HouseAndCarOperation-Container")
end

function WinHouseAndCarOperation:initEvent()
  for i = 1, 2 do
    self:subscribe(self["imgOperationBtn" .. i], UIEvent.EventWindowClick, function()
      local cfg = self._operationList[i]
      cfg.visible = not cfg.visible
      if cfg.visible then
        for i, v in ipairs(self._operationList) do
          if v.visible == true and cfg.name ~= v.name then
            v.visible = false
            self._widgets[v.name]:SetVisible(false)
          end
        end
      end
      self:updateLeftBtnShow()
      if self._widgets[cfg.name] then
        self._widgets[cfg.name]:SetVisible(cfg.visible)
      end
      Lib.emitEvent(Event.EVENT_OPERATION_PANEL_VISIBLE, cfg.visible)
    end)
  end
end

function WinHouseAndCarOperation:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_SHOW_OPERATION_PANEL, function(operationType, params)
    if not operationType then
      return
    end
    local isHas = self:hasOperation(operationType)
    if isHas then
      return
    end
    local res = self:addOneOperation(operationType, params)
    if res then
      self:updateLeftBtnShow()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_REMOVE_OPERATION_PANEL, function(operationType)
    if not operationType then
      return
    end
    local res = self:removeOneOperation(operationType)
    if res then
      self:updateLeftBtnShow()
    else
      Lib.emitEvent(Event.EVENT_OPERATION_PANEL_VISIBLE, false)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_RECEIVE_HOUSE_INFO, function(houseInfo)
    if self._widgets.house then
      self._widgets.house:invoke("updateHouseInfo", houseInfo)
      for i, v in ipairs(self._operationList) do
        if v.name == "house" then
          self["txtIntro" .. i]:SetText("#" .. houseInfo.landIndex or 1)
        end
      end
    else
      local res = self:addOneOperation("house", houseInfo)
      if res then
        self:updateLeftBtnShow()
      end
    end
  end)
end

function WinHouseAndCarOperation:addOneOperation(operationType, params, initVisible)
  if not OPERATION_BTN_CONFIG[operationType] then
    return false
  end
  local content, idx
  for i, v in ipairs(self._operationList) do
    if v.name == operationType then
      content = v
      idx = i
    end
  end
  if not content then
    local isVisible = true
    if initVisible ~= nil then
      isVisible = initVisible
    end
    if operationType == "house" then
      table_insert(self._operationList, 1, {name = operationType, visible = isVisible})
    else
      table_insert(self._operationList, {name = operationType, visible = isVisible})
    end
    for _, v in ipairs(self._operationList) do
      if v.name ~= operationType then
        v.visible = false
      end
    end
  else
    for i, v in ipairs(self._operationList) do
      if i == idx then
        v.visible = true
      else
        v.visible = false
      end
    end
  end
  local isUpdateCurrent = OPERATION_BTN_CONFIG[operationType].updateCurrent
  if self._widgets[operationType] then
    if not isUpdateCurrent then
      self.lytContainer:RemoveChildWindow1(self._widgets[operationType])
      GUIWindowManager.instance:DestroyGUIWindow(self._widgets[operationType])
      self._widgets[operationType] = nil
    else
      return true
    end
  end
  local widget = UIMgr:new_widget(OPERATION_BTN_CONFIG[operationType].widget_name, params)
  self.lytContainer:AddChildWindow(widget)
  self._widgets[operationType] = widget
  return true
end

function WinHouseAndCarOperation:removeOneOperation(operationType)
  if not OPERATION_BTN_CONFIG[operationType] then
    return false
  end
  local content, idx
  for i, v in ipairs(self._operationList) do
    if v.name == operationType then
      content = v
      idx = i
    end
  end
  if not content then
    return false
  else
    if self._widgets[operationType] then
      self.lytContainer:RemoveChildWindow1(self._widgets[operationType])
      GUIWindowManager.instance:DestroyGUIWindow(self._widgets[operationType])
      self._widgets[operationType] = nil
    end
    table_remove(self._operationList, idx)
    if #self._operationList == 0 then
      self:updateHouseOperationShow(false)
      return false
    else
      for _, v in pairs(self._operationList) do
        v.visible = true
        break
      end
    end
    return true
  end
end

function WinHouseAndCarOperation:updateLeftBtnShow()
  local visible = false
  for i = 1, 2 do
    local content = self._operationList[i]
    if content then
      self["imgOperationBtn" .. i]:SetVisible(true)
      local cfg = OPERATION_BTN_CONFIG[content.name]
      self["imgOBtnIcon" .. i]:SetImage(cfg.icon)
      self["txtIntro" .. i]:SetVisible(cfg.hideTxt ~= true)
      self["imgOperationBtn" .. i]:SetImage(content.visible and BTN_RES.selected or BTN_RES.normal)
      if self._widgets[content.name] then
        self._widgets[content.name]:SetVisible(content.visible)
        visible = content.visible
      end
    else
      self["imgOperationBtn" .. i]:SetVisible(false)
    end
  end
  Lib.emitEvent(Event.EVENT_OPERATION_PANEL_VISIBLE, visible)
  self:updateHouseOperationShow(true)
end

function WinHouseAndCarOperation:updateHouseOperationShow(value)
  if #self._operationList == 0 then
    self.lytContentPanel:SetVisible(false)
    return
  end
  self.lytContentPanel:SetVisible(value)
end

function WinHouseAndCarOperation:hasOperation(operationType)
  for _, v in ipairs(self._operationList) do
    if v.name == operationType then
      return true
    end
  end
  return false
end

function WinHouseAndCarOperation:initView()
end

function WinHouseAndCarOperation:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinHouseAndCarOperation:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

function WinHouseAndCarOperation:isOperationPanelShowed()
  for _, v in pairs(self._widgets) do
    if v:IsVisible() then
      return true
    end
  end
  return false
end

return WinHouseAndCarOperation
