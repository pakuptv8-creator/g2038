local widget_base = require("ui.widget.widget_base")
local WidgetModSelectBottom = Lib.derive(widget_base)

function WidgetModSelectBottom:init()
  widget_base.init(self, "ModSelectBottom.json")
  self._allEvent = {}
  self:initUI()
end

function WidgetModSelectBottom:initUI()
  self.lytMapPanel = self:child("ModSelectBottom-MapPanel")
  self.lytMapList = self:child("ModSelectBottom-MapList")
  self:initAdapter()
  self:initEvent()
end

function WidgetModSelectBottom:initAdapter()
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

function WidgetModSelectBottom:initEvent()
  self:subscribe(self.mapGridView, UIEvent.EventScrollMoveChange, function()
    local offset = self.mapGridView:GetScrollOffset()
    local minOffset = self.mapGridView:GetMinScrollOffset()
    if offset < minOffset then
      if os.time() - self.isRequestingData > 1 then
        self.isRequestingData = os.time()
        local pageNo = self.pageNo or 0
        Lib.emitEvent(Event.EVENT_MOD_NOTIFY_CHANGE_RECOMMEND_MAP, pageNo + 1)
      end
    elseif 0 < offset then
      Lib.emitEvent(Event.EVENT_MOD_UPDATE_SELECT_BOTTOM_STATE, 1)
    end
  end)
end

function WidgetModSelectBottom:updateItemByData(data)
  self.pageNo = data.pageNo or 0
  data = data.data
  for key, val in pairs(data or {}) do
    Lib.attachModItemInfo(val, World.cfg.modUIInfo.modItemFromPathMappings.MainRecommend)
    self.mapAdapter:addItem(val)
  end
  self.mapAdapter:notifyDataChange()
end

function WidgetModSelectBottom:resetRecommendData()
  self.mapAdapter:clearItems()
  self.mapGridView:ResetPos()
end

function WidgetModSelectBottom:resetPos()
  self.mapGridView:ResetPos()
end

function WidgetModSelectBottom:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WidgetModSelectBottom
