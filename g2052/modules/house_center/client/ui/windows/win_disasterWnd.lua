local WinDisasterWnd = M
local DisasterConfig = T(Config, "DisasterConfig")

function WinDisasterWnd:init()
  WinBase.init(self, "DisasterWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDisasterWnd:initUI()
  self.lytMask = self:child("DisasterWnd-mask")
  self.imgInterface = self:child("DisasterWnd-Interface")
  self.imgBg = self:child("DisasterWnd-bg")
  self.imgTitleBg = self:child("DisasterWnd-titleBg")
  self.txtTitle = self:child("DisasterWnd-DisasterWndTitle")
  self.lytInterfaceDataList = self:child("DisasterWnd-Interface-Data-List")
  self.btnClose = self:child("DisasterWnd-Close")
  self:initAdapter()
  self.txtTitle:SetText(Lang:toText("g2052.gui.house.disaster.title"))
end

function WinDisasterWnd:initAdapter()
  local params = {
    xDis = 12,
    yDis = 20,
    xCellNum = 3,
    widgetWidth = 130,
    widgetHeight = 64,
    widgetJson = "DisasterItem.json",
    widgetName = "disasterItem",
    gvParent = self.lytInterfaceDataList,
    dataList = {}
  }
  self.disasterListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.disasterListView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(false)
  self.disasterAdapter = self.disasterListView:getAdapter()
end

function WinDisasterWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    self:onHide()
  end)
end

function WinDisasterWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_DISASTER_SELECT, function(disasterId)
    if not self.selectInfo then
      return
    end
    self:clickDisasterItem(disasterId)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, function(value)
    self:getNewDisasterState()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_DISASTER_CD, function()
    self:updateViewShow(self.selectInfo)
  end)
end

function WinDisasterWnd:doSelectDisasterItem(disasterId)
  if not self.selectInfo then
    self:getNewDisasterState(disasterId)
  else
    if self.selectInfo.disasterSelectList[disasterId] then
      return
    end
    self:clickDisasterItem(disasterId)
  end
end

function WinDisasterWnd:isSelectDisaster(disasterId)
  if not self.selectInfo then
    return false
  else
    if not self.selectInfo.disasterSelectList then
      return false
    end
    if self.selectInfo.disasterSelectList[disasterId] then
      return true
    end
  end
  return false
end

function WinDisasterWnd:clickDisasterItem(disasterId)
  if self.isInWaiting then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.prop.send.CDTime"))
    return
  end
  local remainCD = Me:getDisasterSelectRemainCD(disasterId)
  if remainCD and 0 < remainCD then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.prop.send.CDTime"))
    return
  end
  if not self.selectInfo.disasterSelectList[disasterId] then
    local hasNum = 0
    for _, val in pairs(self.selectInfo.disasterSelectList) do
      if val then
        hasNum = hasNum + 1
      end
    end
    if hasNum >= self.selectInfo.maxDisasterNum then
      local tips = Lang:toText({
        "g2052.gui.house.disaster.limit",
        self.selectInfo.maxDisasterNum
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tips)
      return
    end
  end
  self.selectInfo.disasterSelectList[disasterId] = not self.selectInfo.disasterSelectList[disasterId]
  if not self.selectInfo.disasterSelectList[disasterId] then
    Me:disasterSelectCDRecord(disasterId)
  end
  self:updateViewShow(self.selectInfo)
  self.isInWaiting = true
  Me:sendPacket({
    pid = "UpdateDisasterState",
    disasterId = disasterId
  }, function(info)
    self.isInWaiting = false
    self:updateViewShow(info)
  end)
end

function WinDisasterWnd:initView()
  self.selectInfo = nil
  self:getNewDisasterState()
end

function WinDisasterWnd:getNewDisasterState(disasterId)
  self.isInWaiting = true
  Me:sendPacket({
    pid = "RequestDisasterState"
  }, function(info)
    self.isInWaiting = false
    self:updateViewShow(info)
    if disasterId then
      self:clickDisasterItem(disasterId)
    end
  end)
end

function WinDisasterWnd:updateViewShow(info)
  if not info then
    return
  end
  if not self.initGridView then
    self.initGridView = true
    local disasterCfg = Lib.copy(DisasterConfig:getAllCfgs())
    self.disasterAdapter:clearItems()
    self.disasterListView:getGridView():ResetPos()
    local data = {}
    for _, val in pairs(disasterCfg) do
      if info then
        val.select = info.disasterSelectList[val.id]
      end
      val.remainCD = Me:getDisasterSelectRemainCD(val.id)
      table.insert(data, val)
    end
    self.disasterAdapter:setData(data)
  else
    for key, val in pairs(self.disasterAdapter.data) do
      self.disasterAdapter.data[key].select = false
      if info then
        self.disasterAdapter.data[key].select = info.disasterSelectList[val.id]
      end
      self.disasterAdapter.data[key].remainCD = Me:getDisasterSelectRemainCD(key)
    end
    self.disasterAdapter:notifyDataChange()
  end
  self.selectInfo = info
end

function WinDisasterWnd:onHide()
  UI:closeWnd("disasterWnd")
end

function WinDisasterWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("disasterWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDisasterWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinDisasterWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDisasterWnd
