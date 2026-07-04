local widget_base = require("ui.widget.widget_base")
local WidgetBiddingRankAll = Lib.derive(widget_base)
local BiddingRankManager = T(Lib, "BiddingRankManager")

function WidgetBiddingRankAll:init()
  widget_base.init(self, "BiddingRankAll.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
  self:initData()
end

function WidgetBiddingRankAll:initUI()
  self.lytRankLyt = self:child("BiddingRankAll-RankLyt")
  self.lytRankLytRankList = self:child("BiddingRankAll-RankLyt-RankList")
  self.btnRankLytNextPage = self:child("BiddingRankAll-RankLyt-NextPage")
  self.btnRankLytBeforePage = self:child("BiddingRankAll-RankLyt-BeforePage")
  self.imgRankLytPageNumBg = self:child("BiddingRankAll-RankLyt-PageNumBg")
  self.txtRankLytPageNum = self:child("BiddingRankAll-RankLyt-PageNum")
  self.editRankLytPageInput = self:child("BiddingRankAll-RankLyt-PageInput")
  self.lytTitleFinder = self:child("BiddingRankAll-Title-Finder")
  self.imgTitleFinderBg = self:child("BiddingRankAll-Title-Finder-Bg")
  self.btnTitleFinderFind = self:child("BiddingRankAll-Title-Finder-Find")
  self.editTitleFinderEdit = self:child("BiddingRankAll-Title-Finder-Edit")
  self.gridView = UIMgr:new_widget("grid_view")
  self.gridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gridView:InitConfig(0, 20, 1)
  self.gridView:SetvScorllMoveAble(false)
  self.gridView:SethScorllMoveAble(false)
  self.gridView:SetAutoColumnCount(false)
  self.lytRankLytRankList:AddChildWindow(self.gridView)
  self.initPlaceHolder = true
  self.editTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
  self.editTitleFinderEdit:SetProperty("", "")
end

function WidgetBiddingRankAll:initEvent()
  self:subscribe(self.btnTitleFinderFind, UIEvent.EventButtonClick, function()
  end)
  self:subscribe(self.btnRankLytNextPage, UIEvent.EventButtonClick, function()
    self:setPage(self.currPage + 1)
  end)
  self:subscribe(self.btnRankLytBeforePage, UIEvent.EventButtonClick, function()
    self:setPage(self.currPage - 1)
  end)
  self:unsubscribe(self.editTitleFinderEdit, UIEvent.EventEditTextInput)
  self:subscribe(self.editTitleFinderEdit, UIEvent.EventEditTextInput, function(window, trigger)
    if trigger ~= 0 then
      return
    end
    local text = self.editTitleFinderEdit:GetPropertyString("Text", "")
    if text ~= "" then
      local targetId = tonumber(text)
      targetId = targetId or 0
      Me:sendPacket({
        pid = "findBiddingRankPlayer",
        blockId = self.blockId,
        findId = targetId
      })
    else
      self.initPlaceHolder = true
      self.editTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
      self:setPage(self.currPage)
    end
  end)
  self:subscribe(self.editTitleFinderEdit, UIEvent.EventWindowTouchDown, function()
    if self.initPlaceHolder then
      self.initPlaceHolder = false
      self.editTitleFinderEdit:SetProperty("Text", "")
    end
  end)
  self:subscribe(self.editRankLytPageInput, UIEvent.EventEditTextInput, function(window, trigger)
    if trigger ~= 0 then
      return
    end
    local text = self.editRankLytPageInput:GetPropertyString("Text", "")
    if text ~= "" then
      local page = tonumber(text)
      if page and 0 < page and page <= self.maxPage then
        self:setPage(page)
      else
        self.editRankLytPageInput:SetProperty("Text", self.currPage)
      end
    end
  end)
end

function WidgetBiddingRankAll:initData()
  self.blockId = ""
  self.currPage = 1
  self.maxPage = 1
  self.initPlaceHolder = true
  self.dataInfoList = {}
end

function WidgetBiddingRankAll:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_LOADED_RANK_LIST, function(blockId, page, data)
    if self.blockId == blockId then
      self.maxNum = BiddingRankManager:getRankMaxNum(blockId)
      local pageNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
      self.maxPage = math.ceil(self.maxNum * 1.0 / pageNum)
      self.currPage = math.min(self.currPage, self.maxPage)
      if self.currPage == page then
        self.rankData = data
        self:updateRankList()
      end
      self:updatePageNum()
    end
  end)
end

function WidgetBiddingRankAll:setPage(page)
  page = math.max(page, 1)
  page = math.min(page, self.maxPage)
  self.currPage = page
  self.editRankLytPageInput:SetProperty("Text", self.currPage)
  self:updateView()
end

function WidgetBiddingRankAll:updateView()
  BiddingRankManager:loadRankList(self.blockId, self.currPage)
end

function WidgetBiddingRankAll:updateRankList()
  local dataList = BiddingRankManager:getRankList(self.blockId, self.currPage) or {}
  for i, data in ipairs(dataList) do
    if not self.dataInfoList[i] then
      local node = UIMgr:new_widget("biddingRankInfo")
      self.gridView:AddItem(node)
      self.dataInfoList[i] = node:get()
    end
    local info = self.dataInfoList[i]
    info:updateData(self.blockId, self.currPage, data)
  end
  for i = 1, Define.BIDDING_RANK_PAGE_SHOW_NUM do
    if not dataList[i] and self.dataInfoList[i] then
      local info = self.dataInfoList[i]
      self.gridView:RemoveItem(info:root())
      self.dataInfoList[i] = nil
    end
  end
end

function WidgetBiddingRankAll:updatePageNum()
  self.txtRankLytPageNum:SetText(self.currPage .. "/" .. self.maxPage)
end

function WidgetBiddingRankAll:initInfoView(blockId)
  for i = 1, Define.BIDDING_RANK_PAGE_SHOW_NUM do
    if self.dataInfoList[i] then
      local info = self.dataInfoList[i]
      self.gridView:RemoveItem(info:root())
      self.dataInfoList[i] = nil
    end
  end
  self.blockId = blockId
  self.maxNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  local pageNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  self.maxPage = math.ceil(self.maxNum * 1.0 / pageNum)
  self.currPage = 1
  self.editRankLytPageInput:SetProperty("Text", self.currPage)
  self:updatePageNum()
  self.initPlaceHolder = true
  self.editTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
  if not self.initSubEvent then
    self:subscribeEvent()
    self.initSubEvent = true
  end
  BiddingRankManager:loadRankList(self.blockId, self.currPage)
end

function WidgetBiddingRankAll:onClose()
  self:onDestroy()
end

function WidgetBiddingRankAll:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
    self.initSubEvent = false
  end
end

return WidgetBiddingRankAll
