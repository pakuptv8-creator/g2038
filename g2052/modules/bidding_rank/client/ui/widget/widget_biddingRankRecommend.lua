local widget_base = require("ui.widget.widget_base")
local WidgetBiddingRankRecommend = Lib.derive(widget_base)
local BiddingRankManager = T(Lib, "BiddingRankManager")

function WidgetBiddingRankRecommend:init()
  widget_base.init(self, "BiddingRankRecommend.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingRankRecommend:initUI()
  self.lytRecommendLyt = self:child("BiddingRankRecommend-RecommendLyt")
  self.lytRecommendList = self:child("BiddingRankRecommend-RecommendList")
  self.btnRecommendRefresh = self:child("BiddingRankRecommend-RecommendRefresh")
  self:initAdapter()
end

function WidgetBiddingRankRecommend:initAdapter()
  local params = {
    xDis = 32,
    yDis = 41,
    xCellNum = 2,
    widgetWidth = 418,
    widgetHeight = 256,
    widgetJson = "BiddingFourItem.json",
    widgetName = "biddingFourItem",
    gvParent = self.lytRecommendList,
    dataList = {}
  }
  self.landListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.landListView:getGridView()
  gridView:SetMoveAble(false)
  gridView:SetvScorllMoveAble(false)
  gridView:SetAutoColumnCount(false)
  self.landAdapter = self.landListView:getAdapter()
  self.landGridView = self.landListView:getGridView()
end

function WidgetBiddingRankRecommend:initEvent()
  self:subscribe(self.btnRecommendRefresh, UIEvent.EventButtonClick, function()
    BiddingRankManager:getRecommendLandList(self.blockId)
  end)
end

function WidgetBiddingRankRecommend:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_BIDDING_RECOMMEND_INFO, function(blockId, data)
    if self.blockId == blockId then
      self:updateLandInfoShow(data)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_BIDDING_RECOMMEND_UP, function(blockId, mapId, data)
    if self.blockId == blockId then
      for key, val in pairs(self.landAdapter.data) do
        if val.mapId == mapId then
          self.landAdapter.data[key].userLikeType = data.userLikeType
          self.landAdapter.data[key].likeNumber = data.likeNumber
        end
      end
      self.landAdapter:notifyDataChange()
    end
  end)
end

function WidgetBiddingRankRecommend:initInfoView(blockId)
  self.blockId = blockId
  if not self.initSubEvent then
    self:subscribeEvent()
    self.initSubEvent = true
  end
  BiddingRankManager:getRecommendLandList(self.blockId)
end

function WidgetBiddingRankRecommend:updateLandInfoShow(data)
  self.landAdapter:clearItems()
  self.landGridView:ResetPos()
  local showData = {}
  if data then
    showData = Lib.copyTable1(data)
  end
  for key, val in pairs(showData) do
    showData[key].blockId = self.blockId
    showData[key].curTabType = Define.BiddingRankTab.Recommend
  end
  self.landAdapter:setData(showData)
end

function WidgetBiddingRankRecommend:onClose()
  self:onDestroy()
end

function WidgetBiddingRankRecommend:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
    self.initSubEvent = false
  end
end

return WidgetBiddingRankRecommend
