local widget_base = require("ui.widget.widget_base")
local WidgetModTopic = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModTopic:init()
  widget_base.init(self, "ModTopic.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainTopic
  self.reqTopicKey = "ModTopic_Topic"
  self.reqTopicMapKey = "ModTopic_TopicMap"
  ModAsyncProxy:regDelegateRequest(self.reqTopicKey, AsyncProcess.GetTopicMods, Event.EVENT_MOD_UPDATE_TOPIC_LIST)
  ModAsyncProxy:regDelegateRequest(self.reqTopicMapKey, AsyncProcess.GetTopicDetailsMods, Event.EVENT_MOD_UPDATE_TOPIC_DETAIL)
  self:initEvent()
end

function WidgetModTopic:initUI()
  self.lytTopicPanel = self:child("ModTopic-TopicPanel")
  self.lytTopicList = self:child("ModTopic-TopicList")
  self.smallTopicWnd = UIMgr:new_widget("modTopicSmall")
  self.smallTopicWnd:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lytTopicList:AddChildWindow(self.smallTopicWnd)
  self:initAdapter()
  self:updateSmallWndShow(false)
end

function WidgetModTopic:initAdapter()
  local params = {
    xDis = 0,
    yDis = 20,
    xCellNum = 1,
    widgetWidth = 930,
    widgetHeight = 320,
    widgetJson = "ModTopicItem.json",
    widgetName = "modTopicItem",
    gvParent = self.lytTopicList,
    dataList = {}
  }
  self.topicListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.topicGridView = self.topicListView:getGridView()
  self.topicGridView:SetMoveAble(true)
  self.topicGridView:SetvScorllMoveAble(true)
  self.topicGridView:SetAutoColumnCount(false)
  self.topicAdapter = self.topicListView:getAdapter()
  self.isRequestingData = 0
  self:initTopicListData()
end

function WidgetModTopic:requestTopicList(pageNo)
  local pageNo = pageNo or self.topicPageData.pageNo + 1
  local pageSize = Define.ModMainTopicPageSize
  ModAsyncProxy:request(self.reqTopicKey, pageNo, pageSize)
end

function WidgetModTopic:requestTopicMapList(id, pageNo)
  if not id or not pageNo then
    return
  end
  local pageSize = Define.ModDetailTopicPageSize
  ModAsyncProxy:request(self.reqTopicMapKey, id, pageNo, pageSize)
end

function WidgetModTopic:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_TOPIC_WND_UPDATE, function(isShow, value)
    self:updateSmallWndShow(isShow, value)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_TOPIC_LIST, function(data)
    self:updateTopicInfoShow(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_NOTIFY_CHANGE_TOPIC_DETAIL_MAP, function(id, pageNo)
    self:requestTopicMapList(id, pageNo)
  end)
  self:subscribe(self.topicGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.topicGridView:GetScrollOffset()
    local minOffset = self.topicGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self.topicPageData.pageNo < self.topicPageData.totalPage - 1 and 1 < os.time() - self.isRequestingData then
        self.isRequestingData = os.time()
        self:requestTopicList()
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModTopic:updateSmallWndShow(isShow, value)
  self.smallTopicWnd:SetVisible(isShow)
  self.topicGridView:SetVisible(not isShow)
  if isShow then
    self.smallTopicWnd:invoke("initTopicDetailData", value.id, value.title)
    self:requestTopicMapList(value.id, 0)
  end
end

function WidgetModTopic:initTopicListData()
  self.topicPageData = {
    pageNo = -1,
    totalPage = 0,
    topicData = {}
  }
  self.topicAdapter:clearItems()
  self.topicGridView:ResetPos()
end

function WidgetModTopic:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  if needInitData then
    self:initTopicListData()
    self:requestTopicList()
  end
end

function WidgetModTopic:updateTopicInfoShow(data)
  self.topicPageData.pageNo = data.pageNo
  self.topicPageData.totalPage = data.totalPage
  self.topicPageData.totalSize = data.totalSize
  data = data.data
  self.topicPageData.topicData = data
  self.topicAdapter:setData(data or {})
end

function WidgetModTopic:onClose()
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModTopic:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqTopicKey)
  ModAsyncProxy:unRegDelegateRequest(self.reqTopicMapKey)
end

return WidgetModTopic
