local WinBiddingAuditRankList = M
local BiddingRankManager = T(Lib, "BiddingRankManager")

function WinBiddingAuditRankList:init()
  WinBase.init(self, "BiddingAuditRankList.json")
  self._allEvent = {}
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinBiddingAuditRankList:initData()
  self.blockId = ""
  self.currPage = 1
  self.maxPage = 1
  self.currAuditStatus = Define.AUDIT_STATUS.ALL
  self.isShowRadio = false
  self.initPlaceHolder = true
  self.dataInfoList = {}
end

function WinBiddingAuditRankList:initUI()
  self.lytTitle = self:child("BiddingRankList-Title")
  self.imgTitleBg = self:child("BiddingRankList-Title-Bg")
  self.btnTitleClose = self:child("BiddingRankList-Title-Close")
  self.imgTitleCloseBg = self:child("BiddingRankList-Title-CloseBg")
  self.imgTitleCloseImg = self:child("BiddingRankList-Title-CloseImg")
  self.lytTitleFinder = self:child("BiddingRankList-Title-Finder")
  self.imgTitleFinderBg = self:child("BiddingRankList-Title-Finder-Bg")
  self.btnTitleFinderFind = self:child("BiddingRankList-Title-Finder-Find")
  self.biddingRankListTitleFinderEdit = self:child("BiddingRankList-Title-Finder-Edit")
  self.lytRankLyt = self:child("BiddingRankList-RankLyt")
  self.lytRankLytRankList = self:child("BiddingRankList-RankLyt-RankList")
  self.btnRankLytNextPage = self:child("BiddingRankList-RankLyt-NextPage")
  self.btnRankLytBeforePage = self:child("BiddingRankList-RankLyt-BeforePage")
  self.txtRankLytPageNum = self:child("BiddingRankList-RankLyt-PageNum")
  self.pageInputEdit = self:child("BiddingRankList-RankLyt-PageInput")
  self.auditStatusLyt = self:child("BiddingRankList-Title-Audit-Status")
  self.auditStatusSelect = self:child("BiddingRankList-Audit-Select")
  self.auditStatusSelect:SetText(Lang:toText(Define.AUDIT_STATUS_TIPS[self.currAuditStatus]))
  self.gridView = UIMgr:new_widget("grid_view")
  self.gridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gridView:InitConfig(0, 20, 1)
  self.gridView:SetvScorllMoveAble(false)
  self.gridView:SethScorllMoveAble(false)
  self.lytRankLytRankList:AddChildWindow(self.gridView)
  self.initPlaceHolder = true
  self.biddingRankListTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
  self.biddingRankListTitleFinderEdit:SetProperty("", "")
  self.txtTitleName = self:child("BiddingRankList-Title-TitleName")
  self.txtTitleName:SetText(Lang:toText("g2052.gui.bidding_audit.title"))
end

function WinBiddingAuditRankList:initEvent()
  self:subscribe(self.btnTitleClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnTitleFinderFind, UIEvent.EventButtonClick, function()
  end)
  self:subscribe(self.btnRankLytNextPage, UIEvent.EventButtonClick, function()
    self:setPage(self.currPage + 1)
  end)
  self:subscribe(self.btnRankLytBeforePage, UIEvent.EventButtonClick, function()
    self:setPage(self.currPage - 1)
  end)
  self:unsubscribe(self.biddingRankListTitleFinderEdit, UIEvent.EventEditTextInput)
  self:subscribe(self.biddingRankListTitleFinderEdit, UIEvent.EventEditTextInput, function(window, trigger)
    if trigger ~= 0 then
      return
    end
    local text = self.biddingRankListTitleFinderEdit:GetPropertyString("Text", "")
    if text ~= "" then
      local targetId = tonumber(text)
      targetId = targetId or 0
      Me:sendPacket({
        pid = "requestAuditRankList",
        blockId = self.blockId,
        currPage = 1,
        pageSize = Define.BIDDING_RANK_PAGE_SHOW_NUM,
        status = self.currAuditStatus,
        findId = targetId
      })
    else
      self.initPlaceHolder = true
      self.biddingRankListTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
      self:setPage(self.currPage)
    end
  end)
  self:subscribe(self.biddingRankListTitleFinderEdit, UIEvent.EventWindowTouchDown, function()
    if self.initPlaceHolder then
      self.initPlaceHolder = false
      self.biddingRankListTitleFinderEdit:SetProperty("Text", "")
    end
  end)
  self:subscribe(self.pageInputEdit, UIEvent.EventEditTextInput, function(window, trigger)
    if trigger ~= 0 then
      return
    end
    local text = self.pageInputEdit:GetPropertyString("Text", "")
    if text ~= "" then
      local page = tonumber(text)
      if page and 0 < page and page <= self.maxPage then
        self:setPage(page)
      else
        self.pageInputEdit:SetProperty("Text", self.currPage)
      end
    end
  end)
  self:subscribe(self.auditStatusSelect, UIEvent.EventButtonClick, function()
    if not self.isShowRadio then
      self:showAuditStatusRadio()
    else
      self:hideAuditStatusRadio()
    end
  end)
end

function WinBiddingAuditRankList:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_LOADED_AUDIT_RANK_LIST, function(blockId, page, data)
    if self.blockId == blockId then
      self.maxNum = data.totalSize
      local pageNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
      self.maxPage = math.ceil(self.maxNum * 1.0 / pageNum)
      self.currPage = math.max(math.min(self.currPage, self.maxPage), 1)
      if self.currPage == page then
        self.rankData = data.data
        self:updateRankList()
      end
      self:updatePageNum()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.BIDDING_AUDIT_SUCCESS, function()
    self:updateView()
  end)
end

function WinBiddingAuditRankList:initView()
  self:updateView()
end

function WinBiddingAuditRankList:setPage(page)
  page = math.max(math.min(page, self.maxPage), 1)
  self.currPage = page
  self.pageInputEdit:SetProperty("Text", self.currPage)
  self:updateView()
end

function WinBiddingAuditRankList:initRankList()
  Me:sendPacket({
    pid = "requestAuditRankList",
    blockId = self.blockId,
    currPage = 1,
    pageSize = Define.BIDDING_RANK_PAGE_SHOW_NUM
  })
end

function WinBiddingAuditRankList:updateView()
  Me:sendPacket({
    pid = "requestAuditRankList",
    blockId = self.blockId,
    currPage = self.currPage,
    pageSize = Define.BIDDING_RANK_PAGE_SHOW_NUM,
    status = self.currAuditStatus
  })
end

function WinBiddingAuditRankList:updateRankList(rankData)
  local dataList = rankData or self.rankData
  for i, data in ipairs(dataList) do
    if not self.dataInfoList[i] then
      local node = UIMgr:new_widget("biddingAuditRankInfo")
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
  self.auditStatusSelect:SetText(Lang:toText(Define.AUDIT_STATUS_TIPS[self.currAuditStatus]))
end

function WinBiddingAuditRankList:updatePageNum()
  self.txtRankLytPageNum:SetText(self.currPage .. "/" .. self.maxPage)
end

function WinBiddingAuditRankList:showAuditStatusRadio()
  self.isShowRadio = true
  if self.auditRadioListLyt then
    self.auditRadioListLyt:SetVisible(true)
  else
    local cell = GUIWindowManager.instance:CreateGUIWindow1("Layout", "auditRadioListLyt")
    self.auditStatusLyt:AddChildWindow(cell)
    local num = 0
    for _, status in pairs(Define.AUDIT_STATUS) do
      local btn = GUIWindowManager.instance:CreateGUIWindow1("Button", "Cell")
      btn:SetNormalImage("set:g2052_function.json image:img_0_colour03")
      btn:SetPushedImage("set:g2052_function.json image:img_0_colour03")
      btn:SetText(Lang:toText(Define.AUDIT_STATUS_TIPS[status]))
      btn:SetProperty("StretchType", "NineGrid")
      btn:SetProperty("StretchOffset", "16 16 16 16")
      btn:SetArea({0, 0}, {
        0,
        40 * num
      }, {0, 100}, {0, 40})
      self:subscribe(btn, UIEvent.EventButtonClick, function()
        self:selectAuditStatus(status)
        self:hideAuditStatusRadio()
      end)
      cell:AddChildWindow(btn)
      num = num + 1
    end
    cell:SetArea({0, 0}, {0, 40}, {0, 100}, {
      0,
      40 * num
    })
    cell:SetBackgroundColor({
      0.4666666666666667,
      0.28627450980392155,
      0.4235294117647059,
      1
    })
    self.auditRadioListLyt = cell
  end
end

function WinBiddingAuditRankList:hideAuditStatusRadio()
  self.isShowRadio = false
  if self.auditRadioListLyt then
    self.auditRadioListLyt:SetVisible(false)
  end
end

function WinBiddingAuditRankList:selectAuditStatus(status)
  self.currAuditStatus = status
  self:updateView()
end

function WinBiddingAuditRankList:reShow()
  self:show()
  local parent = self:root():GetParent()
  parent:RemoveChildWindow1(self:root())
  parent:AddChildWindow(self:root())
end

function WinBiddingAuditRankList:onHide()
  self:hide()
end

function WinBiddingAuditRankList:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("biddingAuditRankList")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinBiddingAuditRankList:onOpen(blockId)
  self.blockId = blockId
  self.maxNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  local pageNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  self.maxPage = math.ceil(self.maxNum * 1.0 / pageNum)
  self.currPage = 1
  self.pageInputEdit:SetProperty("Text", self.currPage)
  self.initPlaceHolder = true
  self.biddingRankListTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
  self:subscribeEvent()
  self:initRankList()
  self:show()
end

function WinBiddingAuditRankList:setBlockId(blockId)
  if blockId == self.blockId then
    return
  end
  self.blockId = blockId
  self.maxNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  local pageNum = Define.BIDDING_RANK_PAGE_SHOW_NUM
  self.maxPage = math.ceil(self.maxNum * 1.0 / pageNum)
  self.currPage = 1
  self.pageInputEdit:SetProperty("Text", self.currPage)
  self.initPlaceHolder = true
  self.biddingRankListTitleFinderEdit:SetProperty("Text", Lang:toText("g2052.gui.bidding_rank.finder_placeHolder"))
  self:initRankList()
end

function WinBiddingAuditRankList:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinBiddingAuditRankList
