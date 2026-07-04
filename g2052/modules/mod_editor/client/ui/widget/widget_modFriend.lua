local widget_base = require("ui.widget.widget_base")
local WidgetModFriend = Lib.derive(widget_base)
local ModAsyncProxy = T(Lib, "ModAsyncProxy")
local ModReportProxy = T(Lib, "ModReportProxy")

function WidgetModFriend:init()
  widget_base.init(self, "ModFriend.json")
  self._allEvent = {}
  self:initUI()
  self.reportName = World.cfg.modUIInfo.modUINameMappings.MainFriend
  self:initEvent()
  self.reqFriendKey = "WidgetModFriend_FriendMod"
  ModAsyncProxy:regDelegateRequest(self.reqFriendKey, AsyncProcess.GetFriendsMods, Event.EVENT_MOD_UPDATE_FRIEND_MAP_LIST)
end

function WidgetModFriend:initUI()
  self.lytMapPanel = self:child("ModFriend-MapPanel")
  self.lytMapList = self:child("ModFriend-MapList")
  self.imgEmpty = self:child("ModFriend-Empty-Image")
  self.txtEmpty = self:child("ModFriend-Empty-Label")
  self.txtEmpty:SetText(Lang:toText("g2052.guid.mod_empty_friend"))
  self.imgEmpty:SetVisible(false)
  self:initAdapter()
end

function WidgetModFriend:initAdapter()
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
  self:initFriendMapData()
end

function WidgetModFriend:initEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_MOD_UPDATE_FRIEND_MAP_LIST, function(data)
    self:updateMapInfoShow(data)
  end)
  self:subscribe(self.mapGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.mapGridView:GetScrollOffset()
    local minOffset = self.mapGridView:GetMinScrollOffset()
    if offset < minOffset then
      if self.friendPageData.pageNo < self.friendPageData.totalPage - 1 and 1 < os.time() - self.isRequestingData then
        self.isRequestingData = os.time()
        self:requestFriendMapList()
      end
    elseif 0 < offset then
    end
  end)
end

function WidgetModFriend:initFriendMapData()
  self.friendPageData = {
    pageNo = -1,
    totalPage = 0,
    mapListData = {}
  }
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
end

function WidgetModFriend:reload(needInitData)
  ModReportProxy:openUIReport(self.reportName)
  if needInitData then
    self:initFriendMapData()
    self:requestFriendMapList()
  end
end

function WidgetModFriend:requestFriendMapList(pageNo)
  local pageNo = pageNo or self.friendPageData.pageNo + 1
  local pageSize = Define.ModFriendsPageSize
  ModAsyncProxy:request(self.reqFriendKey, pageNo, pageSize)
end

function WidgetModFriend:updateMapInfoShow(data)
  self.friendPageData.pageNo = data.pageNo
  self.friendPageData.totalPage = data.totalPage
  self.friendPageData.totalSize = data.totalSize
  for _, val in pairs(data.data) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainFriend)
    table.insert(self.friendPageData.mapListData, val)
    table.insert(self.mapAdapter.data, val)
  end
  self.mapAdapter:notifyDataChange()
  self:mapListEmptyTest()
end

function WidgetModFriend:mapListEmptyTest()
  local isEmpty = Lib.table_is_empty(self.friendPageData.mapListData)
  self.imgEmpty:SetVisible(isEmpty)
end

function WidgetModFriend:onClose()
  ModReportProxy:closeUIReport(self.reportName)
end

function WidgetModFriend:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  ModAsyncProxy:unRegDelegateRequest(self.reqFollowKey)
end

return WidgetModFriend
