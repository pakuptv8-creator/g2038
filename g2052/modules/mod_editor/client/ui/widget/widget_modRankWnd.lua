local widget_base = require("ui.widget.widget_base")
local WidgetModRankWnd = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")
local CurRankTabIndex = Define.ModRankType.Week

function WidgetModRankWnd:init()
  widget_base.init(self, "ModRankWnd.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainRank
  self.reqRankKey = "ModRank_Rank"
  ModAsyncProxy:regDelegateRequest(self.reqRankKey, AsyncProcess.GetModRank, Event.EVENT_MOD_RANK_UPDATE_DATA)
  self:initEvent()
end

function WidgetModRankWnd:initUI()
  self.lytRankPanel = self:child("ModRankWnd-RankPanel")
  self.lytTopTabPanel = self:child("ModRankWnd-TopTabPanel")
  self.lytRankList = self:child("ModRankWnd-RankList")
  self.gridViewTab = UIMgr:new_widget("grid_view")
  self.gridViewTab:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gridViewTab:InitConfig(0, 0, 3)
  self.lytTopTabPanel:AddChildWindow(self.gridViewTab)
  self.gridViewTab:SetAutoColumnCount(false)
  self.gridViewTab:SetMoveAble(false)
  self.rankPageData = {}
  self.tabViewList = {}
  self.rankGridView = {}
  self.rankAdapter = {}
  self.rankListView = {}
  for i = 1, 3 do
    self.tabViewList[i] = UIMgr:new_widget("modRankTabItem")
    self.gridViewTab:AddItem(self.tabViewList[i])
    self.tabViewList[i]:invoke("initTabIndex", i)
    local params = {
      xDis = 0,
      yDis = 5,
      xCellNum = 1,
      widgetWidth = 900,
      widgetHeight = 133,
      widgetJson = "ModRankItem.json",
      widgetName = "modRankItem",
      gvParent = self.lytRankList,
      dataList = {}
    }
    self.rankListView[i] = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
    self.rankGridView[i] = self.rankListView[i]:getGridView()
    self.rankGridView[i]:SetMoveAble(true)
    self.rankGridView[i]:SetvScorllMoveAble(true)
    self.rankGridView[i]:SetAutoColumnCount(false)
    self.rankAdapter[i] = self.rankListView[i]:getAdapter()
    self.rankGridView[i]:SetVisible(false)
    self:initRankTabData(i)
  end
  self.isRequestingData = 0
end

function WidgetModRankWnd:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RANK_TAB_SELECT, function(tabIndex)
    if tabIndex == CurRankTabIndex then
      return
    end
    CurRankTabIndex = tabIndex
    self:updateRankTabView()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_RANK_UPDATE_DATA, function(data)
    self:updateRankInfoShow(data)
  end)
  for i = 1, 3 do
    self:subscribe(self.rankGridView[i], UIEvent.EventScrollMoveChange, function()
      local offset = self.rankGridView[i]:GetScrollOffset()
      local minOffset = self.rankGridView[i]:GetMinScrollOffset()
      if offset < minOffset then
        if self.rankPageData[i].pageNo < self.rankPageData[i].totalPage - 1 and 1 < os.time() - self.isRequestingData then
          self.isRequestingData = os.time()
          self:requestRankMapList(i)
        end
      elseif 0 < offset then
      end
    end)
  end
end

function WidgetModRankWnd:requestRankMapList(typ, pageNo)
  local pageNo = pageNo or self.rankPageData[typ].pageNo + 1
  local pageSize = Define.ModRankOnceNum
  self.reqRankTyp = typ
  ModAsyncProxy:request(self.reqRankKey, typ, pageNo, pageSize)
end

function WidgetModRankWnd:initRankTabData(tabIndex)
  self.rankPageData[tabIndex] = {
    pageNo = -1,
    totalPage = 0,
    rankData = {}
  }
  self.rankAdapter[tabIndex]:clearItems()
  self.rankGridView[tabIndex]:ResetPos()
end

function WidgetModRankWnd:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  if needInitData then
    for i = 1, 3 do
      self:initRankTabData(i)
    end
    self:updateRankTabView()
  end
end

function WidgetModRankWnd:updateRankTabView()
  for i = 1, 3 do
    self.tabViewList[i]:invoke("updateSelectState", i == CurRankTabIndex)
    self.rankGridView[i]:SetVisible(i == CurRankTabIndex)
  end
  if self.rankPageData[CurRankTabIndex].pageNo < 0 then
    self:requestRankMapList(CurRankTabIndex)
  end
end

function WidgetModRankWnd:updateRankInfoShow(data)
  if not data then
    return
  end
  local rankType = self.reqRankTyp
  self.rankPageData[rankType].pageNo = data.pageNo
  self.rankPageData[rankType].totalPage = data.totalPage
  for _, val in pairs(data.data) do
    table.insert(self.rankPageData[rankType].rankData, val)
    table.insert(self.rankAdapter[rankType].data, val)
  end
  self.rankAdapter[rankType]:notifyDataChange()
end

function WidgetModRankWnd:onClose()
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModRankWnd:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqRankKey)
end

return WidgetModRankWnd
