local widget_base = require("ui.widget.widget_base")
local WidgetModMy = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModMy:init()
  widget_base.init(self, "ModMy.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainMy
  self.reqMyKey = "ModMy_MyMap"
  ModAsyncProxy:regDelegateRequest(self.reqMyKey, AsyncProcess.GetMyModGameList, Event.EVENT_MOD_UPDATE_MY_MAP_LIST)
  self:initEvent()
end

function WidgetModMy:initUI()
  self.lytMapPanel = self:child("ModMy-MapPanel")
  self.lytMapList = self:child("ModMy-MapList")
  self.imgEmpty = self:child("ModMy-Empty-Image")
  self.txtEmpty = self:child("ModMy-Empty-Label")
  self.txtEmpty:SetText(Lang:toText("g2052.guid.mod_empty_my"))
  self.imgEmpty:SetVisible(false)
  self:initAdapter()
end

function WidgetModMy:initAdapter()
  local params = {
    xDis = 48,
    yDis = 26,
    xCellNum = 4,
    widgetWidth = 195,
    widgetHeight = 239,
    widgetJson = "ModAuthorMapItem.json",
    widgetName = "modMyMapItem",
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
  self:initMyMapData()
end

function WidgetModMy:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_MY_MAP_LIST, function(data)
    self:updateMapInfoShow(data)
  end)
  self:subscribe(self.mapGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.mapGridView:GetScrollOffset()
    local minOffset = self.mapGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self.myPageData.pageNo < self.myPageData.totalPage - 1 and 1 < os.time() - self.isRequestingData then
        self.isRequestingData = os.time()
        self:requestMyMapList()
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModMy:requestMyMapList(pageNo)
  local pageNo = pageNo or self.myPageData.pageNo + 1
  local pageSize = Define.ModMapOnceNum
  ModAsyncProxy:request(self.reqMyKey, pageNo, pageSize)
end

function WidgetModMy:initMyMapData()
  self.myPageData = {
    pageNo = -1,
    totalPage = 0,
    mapListData = {}
  }
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
end

function WidgetModMy:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  if needInitData then
    self:initMyMapData()
    self:requestMyMapList()
  end
end

function WidgetModMy:onClose()
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModMy:updateMapInfoShow(data)
  self.myPageData.pageNo = data.pageNo
  self.myPageData.totalPage = data.totalPage
  self.myPageData.totalSize = data.totalSize
  for _, val in pairs(data.data) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainMy)
    table.insert(self.myPageData.mapListData, val)
    table.insert(self.mapAdapter.data, val)
  end
  self.mapAdapter:notifyDataChange()
  self:mapListEmptyTest()
end

function WidgetModMy:mapListEmptyTest()
  local isEmpty = Lib.table_is_empty(self.myPageData.mapListData)
  self.imgEmpty:SetVisible(isEmpty)
end

function WidgetModMy:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqMyKey)
end

return WidgetModMy
