local WinGiftWnd = M
local tabIcon = {
  {
    tabIcon = "set:g2052_function.json image:icon_0_all",
    type = 0
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_life",
    type = 1
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_career01",
    type = 3
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_games",
    type = 2
  },
  {
    tabIcon = "set:g2052_function.json image:icon_0_food",
    type = 4
  }
}

function WinGiftWnd:init()
  WinBase.init(self, "GiftWnd.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinGiftWnd:initData()
  self._allEvent = {}
  self.curSelect = 0
end

function WinGiftWnd:initUI()
  self.lytMask = self:child("GiftWnd-mask")
  self.imgInterface = self:child("GiftWnd-Interface")
  self.imgBg = self:child("GiftWnd-bg")
  self.imgTitleBg = self:child("GiftWnd-titleBg")
  self.txtBagTitle = self:child("GiftWnd-BagTitle")
  self.lytInterfaceDataList = self:child("GiftWnd-Interface-Data-List")
  self.lytLeftTab = self:child("GiftWnd-leftTab")
  self.btnClose = self:child("GiftWnd-Close")
  self.txtBagTitle:SetText(Lang:toText("g2052.gui.gift.send.title"))
  self:initBagList()
  self:initPagingList()
end

function WinGiftWnd:initPagingList()
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

function WinGiftWnd:initBagList()
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
    widgetJson = "GiftBtnItem.json",
    widgetName = "giftBtnItem",
    gvParent = self.lytInterfaceDataList,
    cellSelectedCb = function(data, dx, dy, index)
      self:clientDoSendGift(data.id)
    end
  })
  self.bagGV = self.bagGridView:getGridView()
end

function WinGiftWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
end

function WinGiftWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_UNLOCK_PROP, function()
    self:updateBagData(self.curSelect)
  end)
end

function WinGiftWnd:updateBagData(type)
  self.bagData = Me:getGiftUnlockedByType(type)
  self.bagGridView:setData(self.bagData, -1, nil, true)
end

function WinGiftWnd:updateTabContent(data)
  if not data then
    return
  end
  self.curSelect = data.type
  self:updateBagData(self.curSelect)
  self.bagGridView:getAdapter():setScrollOffset(0)
end

function WinGiftWnd:initView(targetID)
  self.targetID = targetID
  self:updateBagData(self.curSelect)
end

function WinGiftWnd:clientDoSendGift(itemId)
  local entity = World.CurWorld:getObject(self.targetID)
  if not entity or not entity:isValid() then
    self:onHide()
    return
  end
  Me:requestGiveProp(entity.platformUserId, itemId)
  self:onHide()
end

function WinGiftWnd:onHide()
  UI:closeWnd("giftWnd")
end

function WinGiftWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("giftWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinGiftWnd:recoverScroll()
  if self.bagGVOffset then
    self.bagGV:setScrollOffset(self.bagGVOffset)
  end
end

function WinGiftWnd:onOpen(targetID)
  Me:uiMutualExclusion("giftWnd")
  self:initView(targetID)
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
  self:recoverScroll()
end

function WinGiftWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
end

return WinGiftWnd
