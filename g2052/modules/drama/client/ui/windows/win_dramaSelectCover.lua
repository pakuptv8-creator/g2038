local WinDramaSelectCover = M
local DramaCoverConfig = T(Config, "DramaCoverConfig")

function WinDramaSelectCover:init()
  WinBase.init(self, "DramaSelectCover.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinDramaSelectCover:initUI()
  self.lytPanel = self:child("DramaSelectCover-Panel")
  self.btnButtonClose = self:child("DramaSelectCover-ButtonClose")
  self.lytListPanel = self:child("DramaSelectCover-ListPanel")
  self.btnButtonNO = self:child("DramaSelectCover-ButtonNO")
  self.btnButtonYes = self:child("DramaSelectCover-ButtonYes")
  self:child("DramaSelectCover-TextTitle"):SetText(Lang:toText("g2052.gui.drama.cover"))
  self:child("DramaSelectCover-TextNo"):SetText(Lang:toText("g2052.gui.cancel"))
  self:child("DramaSelectCover-TextYes"):SetText(Lang:toText("g2052.gui.confirm"))
  self:initAdapter()
end

function WinDramaSelectCover:initAdapter()
  local params = {
    xDis = 5,
    yDis = 8,
    xCellNum = 1,
    widgetWidth = 436,
    widgetHeight = 132,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = true,
    vScorllMoveAble = true,
    widgetJson = "DramaSelectCoverItem.json",
    widgetName = "dramaSelectCoverItem",
    gvParent = self.lytListPanel,
    dataList = {},
    cellSelectedCb = function(data, dx, dy, index)
      self:selectCover(data)
    end
  }
  self.coverListView = GridViewHelper.new(params)
  self.coverListView:setData(DramaCoverConfig:getAllCfgs(), 1)
end

function WinDramaSelectCover:selectCover(data)
  self.selectedCoverId = data.id
end

function WinDramaSelectCover:initEvent()
  self:subscribe(self.btnButtonClose, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaSelectCover")
  end)
  self:subscribe(self.btnButtonNO, UIEvent.EventButtonClick, function()
    UI:closeWnd("dramaSelectCover")
  end)
  self:subscribe(self.btnButtonYes, UIEvent.EventButtonClick, function()
    if self.selectedCoverId then
      Lib.emitEvent(Event.EVENT_DRAMA_SELECT_COVER, self.selectedCoverId)
    end
    UI:closeWnd("dramaSelectCover")
  end)
end

function WinDramaSelectCover:subscribeEvent()
end

function WinDramaSelectCover:initView()
end

function WinDramaSelectCover:onHide()
  UI:closeWnd("dramaSelectCover")
end

function WinDramaSelectCover:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("dramaSelectCover")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinDramaSelectCover:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinDramaSelectCover:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
    self._allEvent = {}
  end
end

return WinDramaSelectCover
