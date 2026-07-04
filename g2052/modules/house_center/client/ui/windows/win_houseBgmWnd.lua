local WinHouseBgmWnd = M
local HouseBgmConfig = T(Config, "HouseBgmConfig")

function WinHouseBgmWnd:init()
  WinBase.init(self, "HouseBgmWnd.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinHouseBgmWnd:initData()
  self._allEvent = {}
  self.houseBgmData = HouseBgmConfig:getAllCfgs() or {}
  self.houseInfo = {}
end

function WinHouseBgmWnd:initUI()
  self.imgMainWnd = self:child("HouseBgmWnd-mainWnd")
  self.imgTitleBg = self:child("HouseBgmWnd-titleBg")
  self.txtTitleText = self:child("HouseBgmWnd-titleText")
  self.btnClose = self:child("HouseBgmWnd-close")
  self.lytList = self:child("HouseBgmWnd-list")
  self.lytLine = self:child("HouseBgmWnd-line")
  self.btnPlay = self:child("HouseBgmWnd-play")
  self.btnStop = self:child("HouseBgmWnd-stop")
  self.btnLeft = self:child("HouseBgmWnd-left")
  self.btnRight = self:child("HouseBgmWnd-right")
  self.txtTitleText:SetText(Lang:toText("gui.house.bgm.title"))
  self:initHouseBgmList()
end

function WinHouseBgmWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnPlay, UIEvent.EventButtonClick, function()
    if self.selectedBgmKey then
      Me:sendPacket({
        pid = "PlayHouseBgm",
        key = self.selectedBgmKey
      })
    end
  end)
  self:subscribe(self.btnStop, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "StopHouseBgm"
    })
  end)
  self:subscribe(self.btnLeft, UIEvent.EventButtonClick, function()
    self:onSwitchBgm()
  end)
  self:subscribe(self.btnRight, UIEvent.EventButtonClick, function()
    self:onSwitchBgm(true)
  end)
end

function WinHouseBgmWnd:subscribeEvent()
end

function WinHouseBgmWnd:initHouseBgmList()
  self.houseBgmView = GridViewHelper.new({
    name = "houseBgmView",
    xCellNum = 1,
    xDis = 5,
    moveAble = true,
    vScorllMoveAble = true,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    autoColumnCount = false,
    widgetWidth = 246,
    widgetHeight = 44,
    widgetJson = "HouseBgmCell.json",
    widgetName = "houseBgmCell",
    gvParent = self.lytList,
    cellSelectedCb = function(data, dx, dy, index)
      self.selectedBgmKey = data.soundKey
      self.curIndex = index
      if self.selectedBgmKey then
        Me:sendPacket({
          pid = "PlayHouseBgm",
          key = self.selectedBgmKey
        })
      end
      self:updateHouseBgmInfo()
    end
  })
end

function WinHouseBgmWnd:updateHouseBgmList()
  local index = -1
  if self.houseInfo.bgm then
    index = HouseBgmConfig:getIdByKey(self.houseInfo.bgm) or -1
  end
  self.houseBgmView:setData(self.houseBgmData, index, nil, false)
end

function WinHouseBgmWnd:onSwitchBgm(add)
  local index = 1
  local maxCount = 0
  for i, v in pairs(self.houseBgmData) do
    maxCount = maxCount + 1
  end
  if self.curIndex then
    if add then
      index = maxCount < self.curIndex + 1 and 1 or self.curIndex + 1
    else
      index = 1 > self.curIndex - 1 and maxCount or self.curIndex - 1
    end
  end
  self.houseBgmView:setData(self.houseBgmData, index, nil, false)
end

function WinHouseBgmWnd:updateHouseInfo(data)
  self.houseInfo = data
  self:updateHouseBgmInfo()
  Lib.emitEvent(Event.EVENT_UPDATE_OWN_HOUSE_BGM, self.houseInfo.bgm)
end

function WinHouseBgmWnd:updateHouseBgmInfo()
  local canPlay = true
  if self.houseInfo.bgm and self.selectedBgmKey and self.selectedBgmKey == self.houseInfo.bgm then
    canPlay = false
  end
  self.btnStop:SetVisible(not canPlay)
  self.btnPlay:SetVisible(canPlay)
end

function WinHouseBgmWnd:initView()
  self:updateHouseBgmList()
end

function WinHouseBgmWnd:onHide()
  UI:closeWnd("houseBgmWnd")
end

function WinHouseBgmWnd:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("houseBgmWnd")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinHouseBgmWnd:onOpen()
  self:initView()
  self:subscribeEvent()
end

function WinHouseBgmWnd:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinHouseBgmWnd
