local widget_base = require("ui.widget.widget_base")
local WidgetModSearch = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")
local StatusDefine = {Popular = 1, Result = 2}
local Status = 1

function WidgetModSearch:init()
  widget_base.init(self, "ModSearch.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.ModSearch
  self.reqSearchKey = "ModSearch_Search"
  self.reqHotKey = "ModSearch_Hot"
  ModAsyncProxy:regDelegateRequest(self.reqSearchKey, AsyncProcess.GetSearchModGameList, Event.EVENT_MOD_RESPONSE_MAP_SEARCH)
  ModAsyncProxy:regDelegateRequest(self.reqHotKey, AsyncProcess.GetModSearchHot, Event.EVENT_MOD_RESPONSE_MAP_SEARCH_HOT)
  self:initEvent()
end

function WidgetModSearch:initUI()
  self.lytMapPanel = self:child("ModSearch-MapPanel")
  self.lytMapList = self:child("ModSearch-MapList")
  self.lytPopular = self:child("ModSearch-Popular")
  self.txtPopular = self:child("ModSearch-Popular-Title")
  self.txtPopular:SetText(Lang:toText("g2052.gui.mod_search.hot"))
  self.lytResult = self:child("ModSearch-Result")
  self.subUiList = {}
  self.subUiList[StatusDefine.Popular] = self.lytPopular
  self.subUiList[StatusDefine.Result] = self.lytResult
  for _, w in pairs(self.subUiList) do
    w:SetVisible(false)
  end
  self.gvResult = GridViewHelper.new({
    name = "gvResult",
    xCellNum = 4,
    yDis = 40,
    xDis = 48,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    moveAble = true,
    vScorllMoveAble = true,
    widgetWidth = 195,
    widgetHeight = 271,
    widgetJson = "ModMapItem.json",
    widgetName = "modMapItem",
    gvParent = self.lytResult,
    cellSelectedCb = function(data, dx, dy, index)
    end
  })
  self.gvResultWidget = self.gvResult:getGridView()
end

function WidgetModSearch:getSearchList()
  if not self.pageNo or not self.keyWord then
    return
  end
  self:requestModSearchMap()
end

function WidgetModSearch:requestModSearchMap(pageNo)
  local pageNo = pageNo or self.pageNo + 1
  local pageSize = Define.ModSearchItemOnceNum
  local keyWord = self.keyWord
  ModAsyncProxy:request(self.reqSearchKey, keyWord, pageNo, pageSize)
end

function WidgetModSearch:onResponseSearch(data)
  self.pageNo = data.pageNo
  local all = data.data or {}
  if Lib.table_is_empty(all) then
    return
  end
  for _, v in pairs(all) do
    Lib.attachModItemInfo(v, World.cfg.modUIInfo.modItemFromPathMappings.ModSearch)
    table.insert(self.searchItemData, v)
  end
  self.gvResult:setData(self.searchItemData, -1, nil, true)
end

function WidgetModSearch:requestSearchHot()
  ModAsyncProxy:request(self.reqHotKey)
end

function WidgetModSearch:onResponseSearchHot(data)
  self.popularData = {}
  for _, str in pairs(data) do
    table.insert(self.popularData, {topic = str})
    local standardWidth = self.lytPopular:GetWidth()[2]
    local startX = 0
    local startY = 0
    local travel = {
      pos = {x = startX, y = startY},
      startX = startX,
      spaceX = 42,
      spaceY = 22,
      standardWidth = standardWidth,
      cb = function()
        self:hotSearch(str)
      end
    }
    self.popularItems = {}
    for _, info in pairs(self.popularData) do
      local top = #self.popularItems + 1
      local widget = UIMgr:new_widget("modSearchPopularItem")
      self.lytPopular:AddChildWindow(widget)
      travel.str = info.topic
      widget:invoke("reload", travel)
      self.popularItems[top] = widget
    end
  end
end

function WidgetModSearch:search()
  if not self.keyWord or self.keyWord == "" then
    return
  end
  self.pageNo = -1
  self.searchItemData = {}
  self.gvResult:setData(self.searchItemData, -1, nil, true)
  self:getSearchList()
  self.gvResultWidget:ResetPos()
end

function WidgetModSearch:nextSearchList()
  self:getSearchList()
end

function WidgetModSearch:initEvent()
  self:subscribe(self.gvResultWidget, UIEvent.EventScrollMoveChange, function()
    local offset = self.gvResultWidget:GetScrollOffset()
    local minOffset = self.gvResultWidget:GetMinScrollOffset()
    if offset < minOffset then
      self:nextSearchList()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_SEARCH, function(data)
    self:onResponseSearch(data)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RESPONSE_MAP_SEARCH_HOT, function(data)
    self:onResponseSearchHot(data)
  end)
end

function WidgetModSearch:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqSearchKey)
  ModAsyncProxy:unRegDelegateRequest(self.reqHotKey)
end

function WidgetModSearch:reload(str)
  ModReportProxy:openUIReport(self.reportName)
  local index = str == "" and StatusDefine.Popular or StatusDefine.Result
  self.keyWord = str
  self:update(index)
end

local updFuncSet = {
  [StatusDefine.Popular] = function(self)
    if self.popularData then
      return
    end
    self:requestSearchHot()
  end,
  [StatusDefine.Result] = function(self)
    self:search()
  end
}

function WidgetModSearch:hotSearch(str)
  if str == "" then
    return
  end
  self.keyWord = str
  self:update(StatusDefine.Result)
end

function WidgetModSearch:update(index)
  for _, v in pairs(StatusDefine) do
    self.subUiList[v]:SetVisible(false)
  end
  Status = index
  self.subUiList[index]:SetVisible(true)
  updFuncSet[Status](self)
end

function WidgetModSearch:onClose()
  ModReportProxy:closeUIReport(self.reportName)
  Status = StatusDefine.Popular
  self.resultData = nil
end

return WidgetModSearch
