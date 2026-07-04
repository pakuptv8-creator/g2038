local WinDramaMain = M
local DramaClientHelper = T(Lib, "DramaClientHelper")
local MainTab = {
  {
    index = 1,
    lang = "g2052.gui.drama.hot",
    tabType = Define.DramaTabType.Hot
  },
  {
    index = 2,
    lang = "g2052.gui.drama.likes",
    tabType = Define.DramaTabType.Likes
  },
  {
    index = 3,
    lang = "g2052.gui.drama.news",
    tabType = Define.DramaTabType.News
  },
  {
    index = 4,
    lang = "g2052.gui.drama.friend",
    tabType = Define.DramaTabType.Friend
  }
}
local CurMainTabIndex = -1
local DefaultMainTabIndex = 1

function WinDramaMain:init()
  WinBase.init(self, "DramaMain.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:initMainTab()
end

function WinDramaMain:initUI()
  self.lytMainPanel = self:child("DramaMain-MainPanel")
  self.imgTopBg = self:child("DramaMain-TopBg")
  self.txtTitleText = self:child("DramaMain-TitleText")
  self.btnCloseBtn = self:child("DramaMain-CloseBtn")
  self.btnRankBtn = self:child("DramaMain-RankBtn")
  self.lytLeftPanel = self:child("DramaMain-LeftPanel")
  self.lytTabPanel = self:child("DramaMain-TabPanel")
  self.btnCreateScript = self:child("DramaMain-CreateScript")
  self.btnLeaveScript = self:child("DramaMain-LeaveScript")
  self.lytRightPanel = self:child("DramaMain-RightPanel")
  self.imgRightBg = self:child("DramaMain-RightBg")
  self.lytRightContent = self:child("DramaMain-RightContent")
  self.btnMyScript = self:child("DramaMain-MyScript")
  self.btnDissolveScript = self:child("DramaMain-DissolveScript")
  self.txtTitleText:SetText(Lang:toText("g2052.gui.drama.title"))
  self.btnCreateScript:SetText(Lang:toText("g2052.gui.drama.create"))
  self.btnLeaveScript:SetText(Lang:toText("g2052.gui.drama.leave"))
  self.btnMyScript:SetText(Lang:toText("g2052.gui.drama.mine"))
  self.btnDissolveScript:SetText(Lang:toText("g2052.gui.drama.dissolve"))
  self.btnPrePageBtn = self:child("DramaMain-PrePageBtn")
  self.btnNextPageBtn = self:child("DramaMain-NextPageBtn")
  self.txtPageNum = self:child("DramaMain-PageNum")
  self:initContentTab()
end

function WinDramaMain:initContentTab()
  local params = {
    xDis = 0,
    yDis = 5,
    xCellNum = 1,
    widgetWidth = 499,
    widgetHeight = 90,
    widgetJson = "DramaItem.json",
    widgetName = "dramaItem",
    gvParent = self.lytRightContent,
    dataList = {}
  }
  self.dramaListView = {}
  self.dramaGridView = {}
  self.dramaAdapter = {}
  self.curPageNo = {}
  self.isRequestingData = {}
  self.lastRequestTime = {}
  self.prePageLastInfo = {}
  for index, info in pairs(MainTab) do
    self.dramaListView[index] = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
    self.dramaGridView[index] = self.dramaListView[index]:getGridView()
    self.dramaGridView[index]:SetMoveAble(false)
    self.dramaGridView[index]:SetvScorllMoveAble(false)
    self.dramaGridView[index]:SetAutoColumnCount(false)
    self.dramaAdapter[index] = self.dramaListView[index]:getAdapter()
    self.dramaGridView[index]:SetVisible(false)
    self.curPageNo[index] = 0
    self.lastRequestTime[index] = 0
    self.prePageLastInfo[index] = {}
  end
end

function WinDramaMain:initMainTab()
  self.gvMainTab = GridViewHelper.new({
    name = "gvDramaMainTab",
    xCellNum = 1,
    yDis = 5,
    xDis = 0,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = false,
    widgetWidth = 218,
    widgetHeight = 63,
    widgetJson = "DramaMainTabItem.json",
    widgetName = "dramaMainTabItem",
    gvParent = self.lytTabPanel,
    cellSelectedCb = function(data, dx, dy, index)
      self:onMainTabBtnClick(index)
    end
  })
  self.gvMainTab:setData(MainTab, 1, nil, true)
end

function WinDramaMain:initEvent()
  self:subscribe(self.btnCloseBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnRankBtn, UIEvent.EventButtonClick, function()
    UI:openWnd("dramaLikeRanking")
  end)
  self:subscribe(self.btnCreateScript, UIEvent.EventButtonClick, function()
    UI:openWnd("dramaTemplate")
  end)
  self:subscribe(self.btnMyScript, UIEvent.EventButtonClick, function()
    if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.userId == Me.platformUserId then
      UI:openWnd("dramaTemplateEdit", DramaClientHelper.curDramaInfo)
    else
      UI:openWnd("dramaTemplateInfo", DramaClientHelper.curDramaInfo)
    end
  end)
  self:subscribe(self.btnLeaveScript, UIEvent.EventButtonClick, function()
    DramaClientHelper:requestLeaveDrama()
    self:onHide()
  end)
  self:subscribe(self.btnDissolveScript, UIEvent.EventButtonClick, function()
    DramaClientHelper:requestDissolveDrama()
    self:onHide()
  end)
  self:subscribe(self.btnPrePageBtn, UIEvent.EventButtonClick, function()
    if not self:isInRequestCD(CurMainTabIndex) then
      self:getDramaListByPage(CurMainTabIndex, self.curPageNo[CurMainTabIndex] - 1)
    end
  end)
  self:subscribe(self.btnNextPageBtn, UIEvent.EventButtonClick, function()
    if not self:isInRequestCD(CurMainTabIndex) then
      self:getDramaListByPage(CurMainTabIndex, self.curPageNo[CurMainTabIndex] + 1)
    end
  end)
end

function WinDramaMain:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_CONTENT_UPDATE, function(tabType, data, pageNo)
    for index, info in pairs(MainTab) do
      if info.tabType == tabType then
        self:updateContentTab(index, data, pageNo)
        if pageNo ~= 1 and #data == 0 then
          self:getDramaListByPage(index, 1)
        end
        World.Timer(1, function()
          Lib.emitEvent(Event.EVENT_GUIDE_ACTIVE_CONDITION, "dramaItemListShowed")
        end)
        return
      end
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO, function()
    self:getDramaListByPage(CurMainTabIndex, self.curPageNo[CurMainTabIndex])
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_CUR_DETAIL, function()
    self:updateDramaBtnState()
  end)
end

function WinDramaMain:initView()
  self.refreshPassTime = -1
  self.isRequestingData = {}
  self:forceJumpToTab(DefaultMainTabIndex)
  self:startAutoRefreshTimer()
  self:updateDramaBtnState()
end

function WinDramaMain:updateDramaBtnState()
  if Lib.isGameDrama() then
    if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.userId == Me.platformUserId then
      self.btnCreateScript:SetVisible(false)
      self.btnMyScript:SetVisible(true)
      self.btnDissolveScript:SetVisible(true)
      self.btnLeaveScript:SetVisible(false)
    else
      self.btnCreateScript:SetVisible(true)
      self.btnMyScript:SetVisible(false)
      self.btnDissolveScript:SetVisible(false)
      self.btnLeaveScript:SetVisible(true)
    end
  else
    self.btnCreateScript:SetVisible(true)
    self.btnMyScript:SetVisible(false)
    self.btnDissolveScript:SetVisible(false)
    self.btnLeaveScript:SetVisible(false)
  end
  self.btnDissolveScript:SetVisible(false)
  self.btnLeaveScript:SetVisible(false)
end

function WinDramaMain:isInRequestCD(index)
  if self.isRequestingData[index] then
    return true
  else
    if self.lastRequestTime[index] == 0 then
      return false
    end
    if os.time() - self.lastRequestTime[index] < 1 then
      return true
    end
  end
  return false
end

function WinDramaMain:getCurSelectTabIndex()
  return CurMainTabIndex
end

function WinDramaMain:onMainTabBtnClick(index)
  if not index then
    return
  end
  for key, info in pairs(MainTab) do
    if self.dramaGridView[key] then
      self.dramaGridView[key]:SetVisible(false)
    end
  end
  CurMainTabIndex = index
  if not self.dramaGridView[index] then
    return
  end
  self.dramaGridView[index]:SetVisible(true)
  self:getDramaListByPage(index, 1)
end

function WinDramaMain:getDramaListByPage(index, pageNo, isForce)
  if pageNo < 1 then
    return
  end
  self.refreshPassTime = -1
  self.lastRequestTime[index] = os.time()
  self.isRequestingData[index] = true
  if pageNo == 1 then
    DramaClientHelper:requestDramaInfoList(MainTab[index].tabType, pageNo)
  else
    DramaClientHelper:requestDramaInfoList(MainTab[index].tabType, pageNo, World.cfg.dramaSetting.dramaPageSize, self.prePageLastInfo[index].lastRecordCreateTimeLong, self.prePageLastInfo[index].lastRecordCurrentNumber, self.prePageLastInfo[index].lastRecordId)
  end
end

function WinDramaMain:forceJumpToTab(index)
  if not index then
    return
  end
  self.gvMainTab:setClickByOrder(index)
end

function WinDramaMain:updateContentTab(index, data, pageNo)
  self.dramaAdapter[index]:clearItems()
  self.dramaGridView[index]:ResetPos()
  local count = #data
  if count <= 0 then
    self.curPageNo[index] = 0
    self.prePageLastInfo[index] = {}
  else
    self.prePageLastInfo[index] = {
      lastRecordCreateTimeLong = data[count].createTimeLong,
      lastRecordCurrentNumber = data[count].currentNumber,
      lastRecordId = data[count].id or ""
    }
    self.curPageNo[index] = pageNo
  end
  self.isRequestingData[index] = false
  self.refreshPassTime = 0
  local showData = {}
  for key, val in pairs(data) do
    data[key].index = index
    data[key].tabType = MainTab[index].tabType
    table.insert(showData, val)
  end
  self.dramaAdapter[index]:setData(showData)
  local curPageNum = self.curPageNo[CurMainTabIndex]
  if curPageNum and 0 < curPageNum then
    self.txtPageNum:SetText(tostring(curPageNum))
  end
end

function WinDramaMain:removeContentItem(index, itemData)
  self.dramaAdapter[index]:removeItem(itemData)
end

function WinDramaMain:onHide()
  UI:closeWnd("dramaMain")
end

function WinDramaMain:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaMain:startAutoRefreshTimer()
  self:stopAutoRefreshTimer()
  self.refreshTimer = World.Timer(20, function()
    if self.refreshPassTime >= 0 then
      self.refreshPassTime = self.refreshPassTime + 1
      if self.refreshPassTime >= World.cfg.dramaSetting.refreshTime then
        if self:isInRequestCD(CurMainTabIndex) then
          self:getDramaListByPage(CurMainTabIndex, self.curPageNo[CurMainTabIndex], true)
        else
          self.refreshPassTime = 0
        end
      end
    end
    return true
  end)
end

function WinDramaMain:stopAutoRefreshTimer()
  if self.refreshTimer then
    self.refreshTimer()
    self.refreshTimer = nil
  end
end

function WinDramaMain:onOpen()
  self:initView()
  self:subscribeEvent()
  self.openWndTime = os.time()
end

function WinDramaMain:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  self:stopAutoRefreshTimer()
  CurMainTabIndex = -1
  for index, info in pairs(MainTab) do
    self.curPageNo[index] = 0
    self.lastRequestTime[index] = 0
  end
  if self.openWndTime then
    local reportData = {
      stay_drama_main_time = os.time() - self.openWndTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "g2052script", reportData, Me)
  end
end

return WinDramaMain
