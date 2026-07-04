local RedDotConfig = T(Config, "RedDotConfig")
local WinBag = M
local PropsConfig = T(Config, "PropsConfig")
local tabIcon = {
  {
    tabIcon = "set:g2052_function.json image:icon_0_all",
    type = 0,
    redDotKey = RedDotConfig.RD_KEY.BagAllTab
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_life",
    type = 1,
    redDotKey = RedDotConfig.RD_KEY.BagLifeTab
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_career01",
    type = 3,
    redDotKey = RedDotConfig.RD_KEY.BagCareerTab
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_games",
    type = 2,
    redDotKey = RedDotConfig.RD_KEY.BagGamesTab
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_food",
    type = 4,
    redDotKey = RedDotConfig.RD_KEY.BagFoodTab
  }
}

function WinBag:init()
  WinBase.init(self, "Bag.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinBag:initData()
  self._allEvent = {}
  self.curSelect = 0
end

function WinBag:initUI()
  self.lytMask = self:child("Bag-mask")
  self.imgInterface = self:child("Bag-Interface")
  self.imgTitleBg = self:child("Bag-titleBg")
  self.txtTitle = self:child("Bag-BagTitle")
  self.lytInterfaceDataList = self:child("Bag-Interface-Data-List")
  self.btnClose = self:child("Bag-Close")
  self.btnClearHandbag = self:child("Bag-Clear-Handbag-Btn")
  self.lytLeftTab = self:child("Bag-leftTab")
  self.txtTitle:SetText(Lang:toText("g2052.gui.bag.title"))
  self:initBagList()
  self:initPagingList()
end

function WinBag:initPagingList()
  self._tabGridView = GridViewHelper.new({
    name = "tabGridView",
    xCellNum = 1,
    yDis = 10,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    vScorllMoveAble = true,
    hScorllMoveAble = false,
    widgetWidth = 45,
    widgetHeight = 45,
    widgetJson = "TabItem.json",
    widgetName = "tabItem",
    gvParent = self.lytLeftTab,
    cellSelectedCb = function(data, dx, dy, index)
      self:updateTabContent(data)
    end
  })
  self._tabGridView:setData(tabIcon, 1, nil, true)
end

function WinBag:initBagList()
  self.bagGridView = GridViewHelper.new({
    name = "bagGridView",
    xCellNum = 3,
    yDis = 6,
    xDis = 6,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = true,
    vScorllMoveAble = true,
    autoColumnCount = false,
    widgetWidth = 90,
    widgetHeight = 90,
    widgetJson = "BagItem.json",
    widgetName = "bagItem",
    gvParent = self.lytInterfaceDataList,
    cellSelectedCb = function(data, dx, dy, index)
      Me:selectPropLogic(data)
    end
  })
  self.bagGV = self.bagGridView:getGridView()
end

function WinBag:initEvent()
  self:subscribe(self.btnClearHandbag, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "RemoveAllHandItem"
    })
  end)
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
  self:subscribe(self.bagGV, UIEvent.EventScrollMoveChange, function()
  end)
end

function WinBag:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_HAND_BAG_INFO, function()
    self:updateBagData(self.curSelect)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_UNLOCK_PROP, function()
    self:updateBagData(self.curSelect)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_CLIENT_BAG_INFO, function()
    self:updateClientBagData(self.curSelect)
  end)
end

function WinBag:updateBagData(type, initItemId)
  self.bagData = Me:getPropUnlockedByType(type)
  local handBagInfo = Me:getHandbagsInfo()
  local initIndex = -1
  for index, info in pairs(self.bagData) do
    info.isHave = false
    for i, v in pairs(handBagInfo) do
      if info.id == v.itemId then
        info.isHave = true
      end
    end
    if info.id == initItemId then
      initIndex = index
    end
  end
  self.bagGridView:setData(self.bagData, initIndex, nil, true)
end

function WinBag:updateClientBagData(type)
  self.bagData = Me:getPropUnlockedByType(type)
  local handBagInfo = Me.clientBagsInfo or {}
  for _, info in pairs(self.bagData) do
    info.isHave = false
    for i, v in pairs(handBagInfo) do
      if info.id == v.itemId then
        info.isHave = true
      end
    end
  end
  self.bagGridView:setData(self.bagData, -1, nil, true)
end

function WinBag:updateTabContent(data)
  if not data then
    return
  end
  self.curSelect = data.type
  self:updateBagData(self.curSelect)
  self.bagGridView:getAdapter():setScrollOffset(0)
end

function WinBag:initView(initItemId)
  self:updateBagData(self.curSelect, initItemId)
end

function WinBag:onHide()
  UI:closeWnd("g2052Bag")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinBag:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("g2052Bag")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBag:recoverScroll()
  if self.bagGVOffset then
    self.bagGV:setScrollOffset(self.bagGVOffset)
  end
end

function WinBag:onOpen(initItemId)
  Me:uiMutualExclusion("g2052Bag")
  self:initView(initItemId)
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
  self:recoverScroll()
end

function WinBag:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
end

return WinBag
