local WinModMain = M
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")
local MainTab = {
  [Define.ModTabType.Main] = {
    lang = "g2052.gui.mod_main.tab.main",
    widget = "modMainSelect"
  },
  [Define.ModTabType.Follow] = {
    lang = "g2052.gui.mod_main.tab.follow",
    widget = "modFollow"
  },
  [Define.ModTabType.Topic] = {
    lang = "g2052.gui.mod_main.tab.topic",
    widget = "modTopic"
  },
  [Define.ModTabType.Friend] = {
    lang = "g2052.gui.mod_main.tab.friend",
    widget = "modFriend"
  },
  [Define.ModTabType.MyMap] = {
    lang = "g2052.gui.mod_main.tab.my",
    widget = "modMy"
  },
  [Define.ModTabType.Rank] = {
    lang = "g2052.gui.mod_main.tab.rank",
    widget = "modRankWnd"
  }
}
local CurMainTabIndex = -1
local DefaultMainTabIndex = Define.ModTabType.Main

function WinModMain:init()
  WinBase.init(self, "ModMain.json")
  self._allEvent = {}
  self:initUI()
  self.reqCraftKey = "ModMain_Craft"
  ModAsyncProxy:regDelegateRequest(self.reqCraftKey, AsyncProcess.GetModImageUrlByType, Event.EVENT_MOD_RESPONSE_CRAFT_IMAGE)
  self:initEvent()
end

function WinModMain:initUI()
  self.lytMainPanel = self:child("ModMain-MainPanel")
  self.lytLeftPanel = self:child("ModMain-LeftPanel")
  self.imgLeftBg = self:child("ModMain-LeftBg")
  self.lytTabPanel = self:child("ModMain-TabPanel")
  self.btnCreateGame = self:child("ModMain-CreateGame")
  self.txtCreateTxt = self:child("ModMain-CreateTxt")
  self.lytRightPanel = self:child("ModMain-RightPanel")
  self.imgRightBg = self:child("ModMain-RightBg")
  self.lytRightContent = self:child("ModMain-RightContent")
  self.btnBackBtn = self:child("ModMain-BackBtn")
  self.imgCraftIcon = self:child("ModMain-MyMapIcon")
  self:initMainTab()
end

function WinModMain:initEvent()
  self:subscribe(self.btnCreateGame, UIEvent.EventButtonClick, function()
    ModReportProxy:btnClickReport(World.cfg.modUIInfo.modBtnNameMappings.MainCraft)
    UI:openWnd("modMapAds")
  end)
  self:subscribe(self.btnBackBtn, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, function(targetId, followStatus)
    self.mainTabList[Define.ModTabType.Follow]:invoke("reload", true)
  end)
  Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_CRAFT_IMAGE, function(data)
    self:onResponseCraftImage(data)
  end)
end

function WinModMain:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_JUMP_TO_SEARCH, function(keyWord)
    self:jumpToSearchAndSearch(keyWord)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_JUMP_TO_TOPIC, function(data)
    self:jumpToTopicDetail(data)
  end)
end

function WinModMain:jumpToSearchAndSearch(keyWord)
  local index = Define.ModTabType.Main
  self:forceJumpToTab(index)
  self.mainTabList[index]:invoke("openSearchUI", keyWord)
end

function WinModMain:jumpToTopicDetail(data)
  if not data or not data.id then
    return
  end
  local index = Define.ModTabType.Topic
  self:forceJumpToTab(index)
  self.mainTabList[index]:invoke("updateSmallWndShow", true, {
    id = data.id,
    title = data.title or ""
  })
end

function WinModMain:initView()
  for index, info in pairs(MainTab) do
    self.needInitData[index] = true
  end
  self:reloadTabUI()
  self:tryOpenMapDetailOnModMode()
end

function WinModMain:tryOpenMapDetailOnModMode()
  if Lib.isG2052Mod() then
    local gameId = Lib.getGameId()
    local parentGameId = Lib.getG2052MainGameId()
    ModAsyncProxy:requestOpenModDetailsUI(gameId, parentGameId, World.cfg.modUIInfo.modItemFromPathMappings.GameMain)
  end
end

function WinModMain:onHide()
  UI:closeWnd("modMain")
end

function WinModMain:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("modMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinModMain:onOpen()
  self.openTimeStamp = os.time()
  self:initView()
  self:subscribeEvent()
  self:tryRequestCraftImage()
end

function WinModMain:tryRequestCraftImage()
  if self.hasInitCraftImage then
    return
  end
  ModAsyncProxy:request(self.reqCraftKey, Define.Mod.ImageUrlTypeKey.Craft)
end

function WinModMain:onResponseCraftImage(data)
  if self.hasInitCraftImage then
    return
  end
  local picUrl = data or ""
  self.imgCraftIcon:SetImageUrl(picUrl)
  self.hasInitCraftImage = true
end

function WinModMain:onClose()
  if self.mainTabList[CurMainTabIndex] then
    self.mainTabList[CurMainTabIndex]:invoke("onClose")
  end
  if self.openTimeStamp then
    local inv = os.time() - self.openTimeStamp
    ModReportProxy:closeUIReport(World.cfg.modUIInfo.modUINameMappings.ModMain, inv)
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

function WinModMain:initMainTab()
  self.mainTabList = {}
  self.needInitData = {}
  for index, info in pairs(MainTab) do
    local widgetName = info.widget
    if widgetName and widgetName ~= "" then
      local widget = UIMgr:new_widget(widgetName)
      widget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
      self.lytRightContent:AddChildWindow(widget)
      self.mainTabList[index] = widget
      self.mainTabList[index]:SetVisible(false)
      self.needInitData[index] = true
    end
  end
  self.gvMainTab = GridViewHelper.new({
    name = "gvMainTab",
    xCellNum = 1,
    yDis = 18,
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
    widgetWidth = 207,
    widgetHeight = 47,
    widgetJson = "ModMainTabItem.json",
    widgetName = "modMainTabItem",
    gvParent = self.lytTabPanel,
    cellSelectedCb = function(data, dx, dy, index)
      self:onMainTabBtnClick(index)
    end
  })
  self.gvMainTab:setData(MainTab, 1, nil, true)
end

function WinModMain:onMainTabBtnClick(index)
  self:switchTabUI(index)
end

function WinModMain:switchTabUI(index)
  if not index then
    return
  end
  if CurMainTabIndex and self.mainTabList[CurMainTabIndex] then
    self.mainTabList[CurMainTabIndex]:invoke("onClose")
    self.mainTabList[CurMainTabIndex]:SetVisible(false)
  end
  CurMainTabIndex = index
  if not self.mainTabList[index] then
    return
  end
  self.mainTabList[index]:SetVisible(true)
  self.mainTabList[index]:invoke("reload", self.needInitData[index])
  self.needInitData[index] = false
end

function WinModMain:reloadTabUI()
  self:forceJumpToTab(DefaultMainTabIndex)
end

function WinModMain:forceJumpToTab(index)
  if not index then
    return
  end
  self.gvMainTab:setClickByOrder(index)
end

return WinModMain
