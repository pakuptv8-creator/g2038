local widget_base = require("ui.widget.widget_base")
local WidgetModTopicSmall = Lib.derive(widget_base)

function WidgetModTopicSmall:init()
  widget_base.init(self, "ModTopicSmall.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetModTopicSmall:initUI()
  self.lytMapPanel = self:child("ModTopicSmall-MapPanel")
  self.lytTitlePanel = self:child("ModTopicSmall-TitlePanel")
  self.txtTitleText = self:child("ModTopicSmall-TitleText")
  self.lytMapList = self:child("ModTopicSmall-MapList")
  self.imgTitleIcon = self:child("ModAuthorMapItem-TitleIcon")
  self:initAdapter()
end

function WidgetModTopicSmall:initAdapter()
  local params = {
    xDis = 48,
    yDis = 40,
    xCellNum = 4,
    widgetWidth = 195,
    widgetHeight = 271,
    widgetJson = "ModMapItem.json",
    widgetName = "modMapItem",
    gvParent = self.lytMapList,
    dataList = {}
  }
  self.mapListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.mapListView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(false)
  self.mapAdapter = self.mapListView:getAdapter()
  self.mapGridView = self.mapListView:getGridView()
  self.isRequestingData = 0
  self:initTopicDetailData()
end

function WidgetModTopicSmall:initEvent()
  self:subscribe(self.lytTitlePanel, UIEvent.EventWindowClick, function()
    Lib.emitEvent(Event.EVENT_MOD_TOPIC_WND_UPDATE, false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_TOPIC_DETAIL, function(data)
    self:updateMapInfoShow(data)
  end)
  self:subscribe(self.mapGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.mapGridView:GetScrollOffset()
    local minOffset = self.mapGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self.topicPageData.pageNo < self.topicPageData.totalPage - 1 and 1 < os.time() - self.isRequestingData then
        self.isRequestingData = os.time()
        Lib.emitEvent(Event.EVENT_MOD_NOTIFY_CHANGE_TOPIC_DETAIL_MAP, self.topicPageData.topicId, self.topicPageData.pageNo + 1)
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModTopicSmall:initTopicDetailData(topicId, title)
  self.topicPageData = {
    pageNo = -1,
    totalPage = 0,
    topicId = topicId,
    mapListData = {},
    title = title
  }
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
  self.lytTitlePanel:SetVisible(false)
end

function WidgetModTopicSmall:updateMapInfoShow(data)
  self.topicPageData.pageNo = data.pageNo
  self.topicPageData.totalPage = data.totalPage
  self.topicPageData.totalSize = data.totalSize
  for _, val in pairs(data.data) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainTopic)
    table.insert(self.topicPageData.mapListData, val)
    table.insert(self.mapAdapter.data, val)
  end
  self.mapAdapter:notifyDataChange()
  self.lytTitlePanel:SetVisible(true)
  local titleContent = self.topicPageData.title
  self.txtTitleText:SetText(titleContent)
  local strW = self.txtTitleText:GetFont():GetStringWidth(titleContent)
  self.lytTitlePanel:SetWidth({0, strW})
end

function WidgetModTopicSmall:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModTopicSmall
