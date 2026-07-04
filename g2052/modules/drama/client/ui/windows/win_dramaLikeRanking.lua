local WinDramaLikeRanking = M
local UIAnimationManager = T(UILib, "UIAnimationManager")

function WinDramaLikeRanking:init()
  WinBase.init(self, "DramaLikeRanking.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaLikeRanking:initUI()
  self.ani = nil
  self.btnClose = self:child("DramaLikeRanking-Close")
  self.lytPanel = self:child("DramaLikeRanking-Panel")
  self.lytList = self:child("DramaLikeRanking-ListPanel")
  self.lytSelfRank = self:child("DramaLikeRanking-SelfPanel")
  self:child("DramaLikeRanking-TitleText"):SetText(Lang:toText("g2052.gui.drama.like.ranking"))
  self:initAdapter()
end

function WinDramaLikeRanking:initAdapter()
  self.curPageNo = nil
  self.totalPageNum = 1
  self.isRequestingData = false
  self.lastRequestTime = 0
  local params = {
    xDis = 0,
    yDis = 8,
    xCellNum = 1,
    widgetWidth = 391,
    widgetHeight = 97,
    widgetJson = "DramaLikeRankingItem.json",
    widgetName = "dramaLikeRankingItem",
    gvParent = self.lytList
  }
  self.rankingListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.rankingGridView = self.rankingListView:getGridView()
  self.rankingGridView:SetMoveAble(true)
  self.rankingGridView:SetvScorllMoveAble(true)
  self.rankingGridView:SetAutoColumnCount(false)
  self.rankingAdapter = self.rankingListView:getAdapter()
  self.myLikeRankingItem = UIMgr:new_widget("dramaLikeRankingItem")
  if self.myLikeRankingItem then
    self.lytSelfRank:AddChildWindow(self.myLikeRankingItem)
    self.myLikeRankingItem:invoke("setSelfMode")
  end
end

function WinDramaLikeRanking:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaLikeRanking")
  end)
  self:subscribe(self.rankingGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.rankingGridView:GetScrollOffset()
    local minOffset = self.rankingGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self:isInRequestCD() then
        return
      end
      self:getRankingData(self.curPageNo + 1)
    elseif 0 < offset then
      if self:isInRequestCD() then
        return
      end
      self:getRankingData(self.curPageNo - 1)
    end
  end)
end

function WinDramaLikeRanking:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_LIKE_RANKING_UPDATE, function(data)
    self:updateLikeRankingListView(data)
    self.isRequestingData = false
    self.lastRequestTime = os.time()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_UPDATE_LIKES_NUM, function(data)
    if data.userId == Me.platformUserId then
      self:updateSelfLikeNumShow(data)
    end
  end)
end

function WinDramaLikeRanking:isInRequestCD()
  if self.isRequestingData or os.time() - self.lastRequestTime < 1 then
    return true
  else
    return false
  end
end

function WinDramaLikeRanking:updateLikeRankingListView(data)
  self.rankingAdapter:clearItems()
  self.rankingGridView:ResetPos()
  self.curPageNo = data.currentPage
  self.totalPageNum = data.maxPages
  self.rankingAdapter:setData(data.items)
end

function WinDramaLikeRanking:initView()
  self:getRankingData(1)
  Me:requestLikesNumByUserID(Me.platformUserId)
end

function WinDramaLikeRanking:playMoveAni()
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
  self.ani = UIAnimationManager:play(self.lytPanel, "dramaRanking")
end

function WinDramaLikeRanking:getRankingData(pageNo)
  if pageNo < 1 then
    return
  end
  if pageNo > self.totalPageNum then
    return
  end
  if pageNo == self.curPageNo then
    return
  end
  self.isRequestingData = true
  Me:requestLikeRankingList(pageNo)
end

function WinDramaLikeRanking:updateSelfLikeNumShow(data)
  if self.myLikeRankingItem then
    self.myLikeRankingItem:invoke("selfDataChanged", data)
  end
end

function WinDramaLikeRanking:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinDramaLikeRanking:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
end

return WinDramaLikeRanking
