local WinBiddingRankList = M
local BiddingRankManager = T(Lib, "BiddingRankManager")
local titleList = {
  [Define.BIDDING_STATUS.ELECTION] = "g2052.gui.bidding_rank.title01",
  [Define.BIDDING_STATUS.SELECT] = "g2052.gui.bidding_rank.title01",
  [Define.BIDDING_STATUS.FINALS] = "g2052.gui.bidding_rank.title02"
}
local MainTab = {
  [Define.BiddingRankTab.Recommend] = {
    lang = "g2052.gui.bidding_rank.recommend",
    widget = "biddingRankRecommend",
    tabType = Define.BiddingRankTab.Recommend
  },
  [Define.BiddingRankTab.Popularity] = {
    lang = "g2052.gui.bidding_rank.popularity",
    widget = "biddingRankAll",
    tabType = Define.BiddingRankTab.Popularity
  },
  [Define.BiddingRankTab.Mine] = {
    lang = "g2052.gui.bidding_rank.mine",
    widget = "biddingRankMy",
    tabType = Define.BiddingRankTab.Mine
  }
}
local CurMainTabIndex = -1

function WinBiddingRankList:init()
  WinBase.init(self, "BiddingRankList.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinBiddingRankList:initData()
  self.blockId = ""
end

function WinBiddingRankList:initUI()
  self.lytRankBg = self:child("BiddingRankList-RankBg")
  self.lytRankRightBg = self:child("BiddingRankList-RankRightBg")
  self.lytRightPanel = self:child("BiddingRankList-RightPanel")
  self.lytTitle = self:child("BiddingRankList-Title")
  self.imgTitleBg = self:child("BiddingRankList-Title-Bg")
  self.imgTitleCloseBg = self:child("BiddingRankList-Title-CloseBg")
  self.imgTitleCloseImg = self:child("BiddingRankList-Title-CloseImg")
  self.btnTitleClose = self:child("BiddingRankList-Title-Close")
  self.txtTitleTitleName = self:child("BiddingRankList-Title-TitleName")
  self.lytTabPanel = self:child("BiddingRankList-TabPanel")
  self.txtTitleTitleName = self:child("BiddingRankList-Title-TitleName")
  self.txtTitleTitleName:SetText(Lang:toText("g2052.gui.bidding_rank.title01"))
  self:initMainTab()
end

function WinBiddingRankList:initMainTab()
  self.mainTabList = {}
  for tabType, info in pairs(MainTab) do
    local widgetName = info.widget
    if widgetName and widgetName ~= "" then
      local widget = UIMgr:new_widget(widgetName)
      widget:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
      self.lytRightPanel:AddChildWindow(widget)
      self.mainTabList[tabType] = widget
      self.mainTabList[tabType]:SetVisible(false)
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
    widgetWidth = 196,
    widgetHeight = 46,
    widgetJson = "BiddingTabItem.json",
    widgetName = "biddingTabItem",
    gvParent = self.lytTabPanel,
    cellSelectedCb = function(data, dx, dy, index)
      self:onMainTabBtnClick(index)
    end
  })
  self.mapAdapter = self.gvMainTab:getAdapter()
  self.mapGridView = self.gvMainTab:getGridView()
end

function WinBiddingRankList:initEvent()
  self:subscribe(self.btnTitleClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function WinBiddingRankList:subscribeEvent()
end

function WinBiddingRankList:initView()
  local blockStatus = Plugins.CallTargetPluginFunc("bidding", "getBlockStatus", self.blockId)
  local title = titleList[blockStatus] or "g2052.gui.bidding_rank.title01"
  self.txtTitleTitleName:SetText(Lang:toText(title))
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
  self.showTabList = {}
  if blockStatus == Define.BIDDING_STATUS.ELECTION then
    self.showTabList = {
      MainTab[Define.BiddingRankTab.Recommend],
      MainTab[Define.BiddingRankTab.Popularity],
      MainTab[Define.BiddingRankTab.Mine]
    }
  else
    self.showTabList = {
      MainTab[Define.BiddingRankTab.Popularity],
      MainTab[Define.BiddingRankTab.Mine]
    }
  end
  self.gvMainTab:setData(self.showTabList, -1, nil, true)
  self.gvMainTab:setClickByOrder(1)
end

function WinBiddingRankList:onMainTabBtnClick(index)
  if not index then
    return
  end
  if not self.showTabList[index] then
    return
  end
  local tabType = self.showTabList[index].tabType
  if not self.mainTabList[tabType] then
    return
  end
  if CurMainTabIndex == index then
    return
  end
  for tabType, info in pairs(MainTab) do
    if self.mainTabList[tabType] then
      self.mainTabList[tabType]:SetVisible(false)
    end
  end
  CurMainTabIndex = index
  self.mainTabList[tabType]:SetVisible(true)
  self.mainTabList[tabType]:invoke("initInfoView", self.blockId)
end

function WinBiddingRankList:onHide()
  UI:closeWnd("biddingRankList")
end

function WinBiddingRankList:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("biddingRankList")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBiddingRankList:onOpen(blockId, fromClick)
  CurMainTabIndex = -1
  self.fromClick = fromClick
  self.blockId = blockId
  self:subscribeEvent()
  BiddingRankManager:initRankList(self.blockId)
  self:initView()
end

function WinBiddingRankList:onClose(notOpen)
  for tabType, info in pairs(MainTab) do
    if self.mainTabList[tabType] then
      self.mainTabList[tabType]:invoke("onClose")
    end
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if not notOpen and self.fromClick == "tenderSign" then
    Plugins.CallTargetPluginFunc("tendering_land", "openTenderSignWnd")
  end
  self.fromClick = nil
end

return WinBiddingRankList
