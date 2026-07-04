local WinCarBgmWnd = M
local CarBgmConfig = T(Config, "CarBgmConfig")

function WinCarBgmWnd:init()
  WinBase.init(self, "CarBgmWnd.json")
  self:initData()
  self:initUI()
  self:initEvent()
end

function WinCarBgmWnd:initData()
  self._allEvent = {}
  self.carBgmData = CarBgmConfig:getBgmList() or {}
end

function WinCarBgmWnd:initUI()
  self.imgMainWnd = self:child("CarBgmWnd-mainWnd")
  self.imgTitleBg = self:child("CarBgmWnd-titleBg")
  self.txtTitleText = self:child("CarBgmWnd-titleText")
  self.btnClose = self:child("CarBgmWnd-close")
  self.lytList = self:child("CarBgmWnd-list")
  self.lytLine = self:child("CarBgmWnd-line")
  self.btnPlay = self:child("CarBgmWnd-play")
  self.btnStop = self:child("CarBgmWnd-stop")
  self.btnLeft = self:child("CarBgmWnd-left")
  self.btnRight = self:child("CarBgmWnd-right")
  self.txtTitleText:SetText(Lang:toText("gui.house.bgm.title"))
  self:initCarBgmList()
end

function WinCarBgmWnd:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    UI:closeWnd(self)
  end)
  self:subscribe(self.btnPlay, UIEvent.EventButtonClick, function()
    if self.selectedBgmKey then
      self:playMusic()
    end
  end)
  self:subscribe(self.btnStop, UIEvent.EventButtonClick, function()
    Me:sendPacket({
      pid = "stopCarBgm",
      instanceID = self._vehicle:getInstanceID()
    })
    self._musicStatus.isActive = false
    self._musicStatus.bgm = nil
    self:updateBtnStatus()
    Lib.emitEvent(Event.EVENT_CAR_BGM_UPDATE)
  end)
  self:subscribe(self.btnLeft, UIEvent.EventButtonClick, function()
    self:onSwitchBgm()
  end)
  self:subscribe(self.btnRight, UIEvent.EventButtonClick, function()
    self:onSwitchBgm(true)
  end)
end

function WinCarBgmWnd:subscribeEvent()
end

function WinCarBgmWnd:initCarBgmList()
  self.carBgmView = GridViewHelper.new({
    name = "carBgmView",
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
    widgetJson = "CarBgmCell.json",
    widgetName = "carBgmCell",
    gvParent = self.lytList,
    cellSelectedCb = function(data, dx, dy, index)
      self.selectedBgmKey = data.soundKey
      self.curIndex = index
      if self.selectedBgmKey then
        self:playMusic()
      end
    end
  })
end

function WinCarBgmWnd:playMusic()
  if not self._vehicle or not self._vehicle:isValid() then
    return
  end
  self._musicStatus.isActive = true
  self._musicStatus.bgm = self.selectedBgmKey
  if not Me.carMusic or Me.carMusic.key ~= self.selectedBgmKey then
    Me:sendPacket({
      pid = "playCarBgm",
      key = self.selectedBgmKey,
      instanceID = self._vehicle:getInstanceID()
    })
  end
  Lib.emitEvent(Event.EVENT_CAR_BGM_UPDATE, self.selectedBgmKey)
  self:updateBtnStatus()
end

function WinCarBgmWnd:updateCarBgmShow()
  local index = -1
  if self._musicStatus and self._musicStatus.isActive then
    local idx
    for i, v in ipairs(self.carBgmData) do
      if v.soundKey == self._musicStatus.bgm then
        idx = i
        break
      end
    end
    if idx then
      index = idx
    end
  end
  self.carBgmView:setData(self.carBgmData, index, nil, false)
end

function WinCarBgmWnd:onSwitchBgm(add)
  local index = 1
  local maxCount = Lib.getTableSize(self.carBgmData)
  if self.curIndex then
    if add then
      index = maxCount < self.curIndex + 1 and 1 or self.curIndex + 1
    else
      index = 1 > self.curIndex - 1 and maxCount or self.curIndex - 1
    end
  end
  self.carBgmView:setData(self.carBgmData, index, nil, false)
end

function WinCarBgmWnd:updateBtnStatus()
  local canPlay = true
  if self._musicStatus.bgm and self.selectedBgmKey and self.selectedBgmKey == self._musicStatus.bgm then
    canPlay = false
  end
  self.btnStop:SetVisible(not canPlay)
  self.btnPlay:SetVisible(canPlay)
end

function WinCarBgmWnd:initView()
  self:updateCarBgmShow()
  self:updateBtnStatus()
end

function WinCarBgmWnd:onOpen(vehicle, vehicleStatus)
  self.selectedBgmKey = nil
  self._vehicle = vehicle
  self._musicStatus = Lib.copyTable1(vehicleStatus.music or {})
  self:initView()
  self:subscribeEvent()
  self._vehicle:connect("on_destroy", function(instance)
    if instance == self._vehicle and GUIManager:Instance() then
      UI:closeWnd(self)
    end
  end)
end

function WinCarBgmWnd:onClose()
  if self._allEvent then
    for _, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return WinCarBgmWnd
