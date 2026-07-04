local widget_base = require("ui.widget.widget_base")
local WidgetModFollow = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModFollow:init()
  widget_base.init(self, "ModFollow.json")
  self._allEvent = {}
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainFollow
  self:initUI()
  self:initEvent()
  self.reqFollowKey = "WidgetModFollow_FollowMod"
  ModAsyncProxy:regDelegateRequest(self.reqFollowKey, AsyncProcess.GetModFollowPlayerMapList, Event.EVENT_MOD_UPDATE_FOLLOW_MAP_LIST)
end

function WidgetModFollow:initUI()
  self.lytMapPanel = self:child("ModFollow-MapPanel")
  self.lytMapList = self:child("ModFollow-MapList")
  self.imgEmpty = self:child("ModFollow-Empty-Image")
  self.txtEmpty = self:child("ModFollow-Empty-Label")
  self.txtEmpty:SetText(Lang:toText("g2052.guid.mod_empty_follow"))
  self.imgEmpty:SetVisible(false)
  self:initAdapter()
end

function WidgetModFollow:initAdapter()
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
end

function WidgetModFollow:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FOLLOW_MAP_LIST, function(data)
    self:updateMapInfoShow(data)
  end)
  self:subscribe(self.mapGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.mapGridView:GetScrollOffset()
    local minOffset = self.mapGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self.followPageData.pageNo < self.followPageData.totalPage - 1 and 1 < os.time() - self.isRequestingData then
        self.isRequestingData = os.time()
        self:requestFollowMaps()
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModFollow:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  self.followPageData = {
    pageNo = -1,
    totalPage = 0,
    mapListData = {}
  }
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
  self:requestFollowMaps()
end

function WidgetModFollow:requestFollowMaps(pageNo)
  local pageNo = pageNo or self.followPageData.pageNo + 1
  local pageSize = Define.ModMapOnceNum
  ModAsyncProxy:request(self.reqFollowKey, pageNo, pageSize)
end

function WidgetModFollow:updateMapInfoShow(data)
  self.followPageData.pageNo = data.pageNo
  self.followPageData.totalPage = data.totalPage
  self.followPageData.pageSize = data.pageSize
  self.followPageData.totalSize = data.totalSize
  for _, val in pairs(data.data) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainFollow)
    table.insert(self.followPageData.mapListData, val)
    table.insert(self.mapAdapter.data, val)
  end
  self.mapAdapter:notifyDataChange()
  self:mapListEmptyTest()
end

function WidgetModFollow:mapListEmptyTest()
  local isEmpty = Lib.table_is_empty(self.followPageData.mapListData)
  self.imgEmpty:SetVisible(isEmpty)
end

function WidgetModFollow:onClose()
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModFollow:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqFollowKey)
end

return WidgetModFollow
