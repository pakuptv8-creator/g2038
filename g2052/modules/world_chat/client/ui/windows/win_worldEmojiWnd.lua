local WinWorldEmojiWnd = M
local EmojiConfig = T(Config, "EmojiConfig")

function WinWorldEmojiWnd:init()
  WinBase.init(self, "WorldEmojiWnd.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinWorldEmojiWnd:initUI()
  self.lytPanelBg = self:child("WorldEmojiWnd-panelBg")
  self.lytContent = self:child("WorldEmojiWnd-content")
  self:initAdapter()
end

function WinWorldEmojiWnd:initAdapter()
  local params = {
    xDis = 10,
    yDis = 15,
    xCellNum = 5,
    widgetWidth = 110,
    widgetHeight = 110,
    widgetJson = "WorldEmojiItem.json",
    widgetName = "worldEmojiItem",
    gvParent = self.lytContent,
    dataList = {}
  }
  self.worldEmojiView = Plugins.CallTargetPluginFunc("engine_overwrite", "initAdapterView", params)
  local gridView = self.worldEmojiView:getGridView()
  gridView:SetMoveAble(true)
  gridView:SetvScorllMoveAble(true)
  gridView:SetAutoColumnCount(false)
  self.worldEmojiAdapter = self.worldEmojiView:getAdapter()
  self.worldEmojiAdapter:setData(EmojiConfig:getItems())
end

function WinWorldEmojiWnd:initEvent()
end

function WinWorldEmojiWnd:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_WORLD_ICON_SHOW, function(isShow)
    if not isShow then
      self:onHide()
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_WORLD_CHAT_SEND_EMOJI, function()
    self:onHide()
  end)
end

function WinWorldEmojiWnd:initView()
  self.worldEmojiView:getGridView():ResetPos()
  self.worldEmojiAdapter:notifyDataChange()
end

function WinWorldEmojiWnd:onHide()
  UI:closeWnd("worldEmojiWnd")
end

function WinWorldEmojiWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("worldEmojiWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinWorldEmojiWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinWorldEmojiWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinWorldEmojiWnd
