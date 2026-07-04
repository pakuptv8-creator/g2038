local widget_base = require("ui.widget.widget_base")
local WidgetBiddingRankMy = Lib.derive(widget_base)
local BiddingRankManager = T(Lib, "BiddingRankManager")

function WidgetBiddingRankMy:init()
  widget_base.init(self, "BiddingRankMy.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetBiddingRankMy:initUI()
  self.lytMyLyt = self:child("BiddingRankMy-MyLyt")
  self.lytMyList = self:child("BiddingRankMy-MyList")
  self.txtNoneMine = self:child("BiddingRankMy-NoneMine")
  self.txtNoneMine:SetText(Lang:toText("g2052.gui.bidding_rank.none_submit"))
  self.txtNoneMine:SetVisible(false)
  self:initAdapter()
end

function WidgetBiddingRankMy:initAdapter()
  local params = {
    xDis = 32,
    yDis = 41,
    xCellNum = 2,
    widgetWidth = 418,
    widgetHeight = 256,
    widgetJson = "BiddingFourItem.json",
    widgetName = "biddingFourItem",
    gvParent = self.lytMyList,
    dataList = {}
  }
  self.landListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.landListView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(false)
  self.landAdapter = self.landListView:getAdapter()
  self.landGridView = self.landListView:getGridView()
end

function WidgetBiddingRankMy:initEvent()
end

function WidgetBiddingRankMy:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.UPDATE_BIDDING_MY_INFO, function(blockId, data)
    if self.blockId == blockId then
      self:updateLandInfoShow(data)
    end
  end)
end

function WidgetBiddingRankMy:initInfoView(blockId)
  self.blockId = blockId
  if not self.initSubEvent then
    self:subscribeEvent()
    self.initSubEvent = true
  end
  Me:sendPacket({
    pid = "getMyBiddingRankPlayer",
    blockId = self.blockId
  })
end

function WidgetBiddingRankMy:updateLandInfoShow(data)
  self.landAdapter:clearItems()
  self.landGridView:ResetPos()
  local showData = {}
  if data then
    showData = Lib.copyTable1(data)
  end
  for key, val in pairs(showData) do
    showData[key].blockId = self.blockId
    showData[key].curTabType = Define.BiddingRankTab.Mine
  end
  self.landAdapter:setData(showData)
  self.txtNoneMine:SetVisible(#data <= 0)
end

function WidgetBiddingRankMy:onClose()
  self:onDestroy()
end

function WidgetBiddingRankMy:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
    self.initSubEvent = false
  end
end

return WidgetBiddingRankMy
