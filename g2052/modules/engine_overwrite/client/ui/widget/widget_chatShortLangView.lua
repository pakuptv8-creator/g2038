local widget_base = require("ui.widget.widget_base")
local WidgetChatShortLangView = Lib.derive(widget_base)
local ChatShortLangConfig = T(Config, "ChatShortLangConfig")

function WidgetChatShortLangView:init()
  widget_base.init(self, "ChatShortLangView.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WidgetChatShortLangView:initUI()
  self.lytItemPanel = self:child("ChatShortLangView-ItemPanel")
  self.lytDotPanel = self:child("ChatShortLangView-DotPanel")
  self.itemGridView = UIMgr:new_widget("grid_view")
  self.lytItemPanel:AddChildWindow(self.itemGridView)
  self.itemGridView:SetMoveAble(true)
  self.itemGridView:SethScorllMoveAble(true)
  self.itemGridView:SetvScorllMoveAble(false)
  self.itemGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.itemGridView:SetAutoColumnCount(false)
  self.itemCells = {}
  self.itemCache = {}
  self.dotGridView = UIMgr:new_widget("grid_view")
  self.lytDotPanel:AddChildWindow(self.dotGridView)
  self.dotGridView:SethScorllMoveAble(false)
  self.dotGridView:SetvScorllMoveAble(false)
  self.dotGridView:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.dotGridView:InitConfig(0, 0, 1)
  self.dotCells = {}
  self.allShortCfg = ChatShortLangConfig:getAllCfgByTriggerType(1)
  self.onePageWidth = 333
  local totalNum = #self.allShortCfg
  self.totalPageCount = math.ceil(totalNum / 3)
  self.showPageCount = 2
  self.curStartPageNo = 1
  self.curShowPageNo = 1
  self.curShowIndex = 1
  self:initDotViewShow()
  self:initItemViewShow()
end

function WidgetChatShortLangView:initHorizontalListView()
end

function WidgetChatShortLangView:initDotViewShow()
  self.dotGridView:InitConfig(18, 0, self.totalPageCount)
  for index = 1, self.totalPageCount do
    local cell = UIMgr:new_widget("chatShortLangDot")
    cell:invoke("updateSelectState", false)
    self.dotGridView:AddItem(cell)
    self.dotCells[index] = cell
  end
end

function WidgetChatShortLangView:initEvent()
  self:subscribe(self.itemGridView, UIEvent.EventWindowTouchDown, function()
    UI:getWnd("chatMini"):resetAutoHideTime()
    self.touchStartOffset = self.itemGridView:GetScrollOffset()
    self:startAutoRefreshTimer()
  end)
  self:subscribe(self.itemGridView, UIEvent.EventScrollMoveChange, function()
    UI:getWnd("chatMini"):resetAutoHideTime()
    self.touchMoveTime = self.touchPassTime
  end)
end

function WidgetChatShortLangView:initItemViewShow()
  if self.totalPageCount > 2 then
    self.showPageCount = 2
    self.curShowPageNo = 1
    self.curStartPageNo = 1
    self.curShowIndex = 1
    self:updateItemViewShow()
  else
    self.showPageCount = self.totalPageCount
    self.curShowPageNo = 1
    self.curStartPageNo = 1
    self.curShowIndex = 1
    self:updateItemViewShow()
  end
end

function WidgetChatShortLangView:updateItemViewShow()
  self.itemGridView:InitConfig(0, 0, self.showPageCount)
  for index = 1, 3 do
    if index <= self.showPageCount then
      local preKey = (self.curStartPageNo - 1) * 3
      local itemData = {
        [1] = self.allShortCfg[preKey + (index - 1) * 3 + 1],
        [2] = self.allShortCfg[preKey + (index - 1) * 3 + 2],
        [3] = self.allShortCfg[preKey + (index - 1) * 3 + 3]
      }
      if self.itemCells[index] then
        self.itemCells[index]:invoke("initShortItemData", itemData)
      else
        local cell
        if 0 < #self.itemCache then
          cell = table.remove(self.itemCache)
        else
          cell = UIMgr:new_widget("chatShortLangItem")
        end
        cell:invoke("initShortItemData", itemData)
        self.itemGridView:AddItem(cell)
        self.itemCells[index] = cell
      end
    elseif self.itemCells[index] then
      self.itemGridView:RemoveItem(self.itemCells[index], false)
      table.insert(self.itemCache, self.itemCells[index])
      self.itemCells[index] = nil
    end
  end
  self.itemGridView:SetMoveAble(true)
  self.itemGridView:SetScrollOffset(-self.onePageWidth * (self.curShowIndex - 1))
  for index = 1, self.totalPageCount do
    self.dotCells[index]:invoke("updateSelectState", self.curShowPageNo == index)
  end
end

function WidgetChatShortLangView:updatePageShow()
  self:stopAutoRefreshTimer()
  if self.totalPageCount > 2 then
    if self.curShowIndex == self.showPageCount then
      self.curShowPageNo = self.curStartPageNo + self.curShowIndex - 1
      if self.curShowPageNo == self.totalPageCount then
        self.showPageCount = 2
        self.curShowIndex = 2
        self.curStartPageNo = self.totalPageCount - 1
      else
        self.showPageCount = 3
        self.curShowIndex = 2
        self.curStartPageNo = self.curShowPageNo - 1
      end
    elseif self.curShowIndex == 1 then
      self.curShowPageNo = self.curStartPageNo
      if self.curShowPageNo == 1 then
        self.showPageCount = 2
        self.curShowIndex = 1
        self.curStartPageNo = 1
      else
        self.showPageCount = 3
        self.curShowIndex = 2
        self.curStartPageNo = self.curShowPageNo - 1
      end
    else
      self.curShowPageNo = self.curStartPageNo + self.curShowIndex - 1
      if self.curShowPageNo == self.totalPageCount then
        self.showPageCount = 2
        self.curShowIndex = 2
        self.curStartPageNo = self.totalPageCount - 1
      elseif self.curShowPageNo == 1 then
        self.showPageCount = 2
        self.curShowIndex = 1
        self.curStartPageNo = 1
      else
        self.showPageCount = 3
        self.curShowIndex = 2
        self.curStartPageNo = self.curShowPageNo - 1
      end
    end
    self:updateItemViewShow()
  else
    self.itemGridView:SetMoveAble(true)
    self.itemGridView:SetScrollOffset(-self.onePageWidth * (self.curShowIndex - 1))
    self.showPageCount = 2
    self.curShowPageNo = self.curShowIndex
    self.curStartPageNo = 1
    for index = 1, self.totalPageCount do
      self.dotCells[index]:invoke("updateSelectState", self.curShowPageNo == index)
    end
  end
end

function WidgetChatShortLangView:startAutoRefreshTimer()
  self:stopAutoRefreshTimer()
  if self.showPageCount <= 1 then
    return
  end
  local waitTime = 5
  local moveTime = 4.0
  self.refreshPassTime = 0
  self.touchPassTime = 0
  self.touchMoveTime = 0
  self.targetEndOffset = nil
  self.targetMidOffset = nil
  self.autoRefreshTimer = World.Timer(1, function()
    self.touchPassTime = self.touchPassTime + 1
    self.refreshPassTime = self.refreshPassTime + 1
    if self.targetEndOffset and self.targetMidOffset then
      local result = self.targetMidOffset + (self.targetEndOffset - self.targetMidOffset) * self.refreshPassTime / moveTime
      if self.targetEndOffset < self.targetMidOffset then
        if result < self.targetEndOffset then
          result = self.targetEndOffset
        end
      elseif self.targetEndOffset > self.targetMidOffset then
        if result > self.targetEndOffset then
          result = self.targetEndOffset
        end
      else
        result = self.targetEndOffset
      end
      self.itemGridView:SetScrollOffset(math.floor(result))
      if self.refreshPassTime >= moveTime then
        self:updatePageShow()
      end
    elseif self.touchPassTime - self.touchMoveTime > waitTime then
      self:checkNextMoveOffset()
    end
    return true
  end)
end

function WidgetChatShortLangView:checkNextMoveOffset()
  self.targetMidOffset = self.itemGridView:GetScrollOffset()
  if self.targetMidOffset < self.touchStartOffset then
    if self.curShowIndex >= self.showPageCount then
      self:updatePageShow()
      return
    end
    self.curShowIndex = self.curShowIndex + 1
  elseif self.targetMidOffset > self.touchStartOffset then
    if self.curShowIndex <= 1 then
      self:updatePageShow()
      return
    end
    self.curShowIndex = self.curShowIndex - 1
  else
    self:updatePageShow()
    return
  end
  self.targetEndOffset = -self.onePageWidth * (self.curShowIndex - 1)
  self.itemGridView:SetMoveAble(false)
  self.refreshPassTime = 0
  self.curShowPageNo = self.curStartPageNo + self.curShowIndex - 1
  for index = 1, self.totalPageCount do
    self.dotCells[index]:invoke("updateSelectState", self.curShowPageNo == index)
  end
end

function WidgetChatShortLangView:stopAutoRefreshTimer()
  if self.autoRefreshTimer then
    self.autoRefreshTimer()
    self.autoRefreshTimer = nil
  end
end

function WidgetChatShortLangView:onDestroy()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:stopAutoRefreshTimer()
end

return WidgetChatShortLangView
