local WinDramaHistory = M
local UIAnimationManager = T(UILib, "UIAnimationManager")

function WinDramaHistory:init()
  WinBase.init(self, "DramaHistory.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaHistory:initUI()
  self.ani = nil
  self.lytPanel = self:child("DramaHistory-Panel")
  self.lytListPanel = self:child("DramaHistory-ListPanel")
  self.btnClose = self:child("DramaHistory-CloseButton")
  self:child("DramaHistory-TitleText"):SetText(Lang:toText("g2052.gui.drama.history"))
  self:initAdapter()
end

function WinDramaHistory:initAdapter()
  local params = {
    xDis = 0,
    yDis = 16,
    xCellNum = 1,
    widgetWidth = 642,
    widgetHeight = 132,
    widgetJson = "DramaHistoryItem.json",
    widgetName = "dramaHistoryItem",
    gvParent = self.lytListPanel
  }
  self.historyListView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  self.historyAdapter = self.historyListView:getAdapter()
  local historyGridView = self.historyListView:getGridView()
  historyGridView:SetMoveAble(true)
  historyGridView:SetvScorllMoveAble(true)
end

function WinDramaHistory:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaHistory")
  end)
end

function WinDramaHistory:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_DRAMA_HISTORY_UPDATE, function(data)
    self:updateHistoryListView(data)
  end)
end

function WinDramaHistory:updateHistoryListView(data)
  self.historyAdapter:setData(data)
end

function WinDramaHistory:initView()
  self:getHistoryData()
end

function WinDramaHistory:getHistoryData()
  Me:requestHistoryDrama()
end

function WinDramaHistory:playMoveAni()
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
  self.ani = UIAnimationManager:play(self.lytPanel, "dramaHistory")
end

function WinDramaHistory:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinDramaHistory:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
  if self.ani then
    UIAnimationManager:stop(self.ani)
  end
end

return WinDramaHistory
