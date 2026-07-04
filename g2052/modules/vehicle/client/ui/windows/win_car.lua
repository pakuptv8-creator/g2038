local CarConfig = T(Config, "CarConfig")
local WinCar = M
local advancedCarCreateCd = World.cfg.advancedCarCreateCd or 10

function WinCar:init()
  WinBase.init(self, "Car.json")
  self._allEvent = {}
  self:initUI()
  self:initEvent()
end

function WinCar:initUI()
  self.lytMask = self:child("Car-mask")
  self.imgInterface = self:child("Car-Interface")
  self.imgTitleBg = self:child("Car-titleBg")
  self.txtTitle = self:child("Car-CarTitle")
  self.lytInterfaceDataList = self:child("Car-Interface-Data-List")
  self.btnClose = self:child("Car-Close")
  self.lytLeftTab = self:child("Car-leftTab")
  self.imgOperation = self:child("Car-operationCar")
  self.txtOperationTxt = self:child("Car-operationTxt")
  self.lytClearHandView = self:child("Car-Clear-HandCar-View")
  self.imgClearHandBg = self:child("Car-Clear-HandCar-Bg")
  self.btnClearHandBtn = self:child("Car-Clear-HandCar-Btn")
  self.txtCountDown = self:child("Car-CountDown")
  self.txtCountDown:SetText("")
  self.txtAdTips = self:child("Car-AdTips")
  self.txtAdTips:SetText(Lang:toText("g2052.advertisement.use.car.tips"))
  self.txtTitle:SetText(Lang:toText("g2052.gui.car.title"))
  self.txtOperationTxt:SetText(Lang:toText("g2052.gui.confirm"))
  self:initCarList()
end

function WinCar:initCarList()
  self.carGridView = GridViewHelper.new({
    name = "carGridView",
    xCellNum = 3,
    yDis = 6,
    xDis = 8,
    area = {
      {0, 0},
      {0, 0},
      {1, 0},
      {1, 0}
    },
    moveAble = true,
    vScorllMoveAble = true,
    autoColumnCount = false,
    widgetWidth = 90,
    widgetHeight = 90,
    widgetJson = "CarItem.json",
    widgetName = "carItem",
    gvParent = self.lytInterfaceDataList,
    cellSelectedCb = function(data, dx, dy, index)
      Me:selectCarLogic(data)
    end
  })
end

function WinCar:initEvent()
  self:subscribe(self.btnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
  self:subscribe(self.btnClearHandBtn, UIEvent.EventButtonClick, function()
    local inUseCar = Me:getInUseCar()
    if inUseCar then
      local isSkateEntity = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_ENTITY", inUseCar.id)
      if isSkateEntity then
        local canLeaveSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_CAN_LEAVE_SKATE_MODE")
        if not canLeaveSkateMode then
          return
        end
      end
      local params = {
        id = inUseCar.id
      }
      Me:sendPacket({
        pid = "OnOperationCar",
        params = params
      }, function(ret)
        if not ret then
          print("--OnOperationCar2 no choice item--")
        end
      end)
    end
  end)
  self:subscribe(self.lytMask, UIEvent.EventWindowTouchDown, function()
    Me:simulationClickOnScene()
    self:onHide()
  end)
end

function WinCar:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_IN_USE_CAR, function(inUseCarInfo, objID)
    if objID ~= Me.objID then
      return
    end
    self:updateCarData()
    Me:updateCarUseCD()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_CREATED, function()
    Me._nextCreateTime = os.time() + advancedCarCreateCd
    Me:updateCarUseCD()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_WATCH_AD_UPDATE, function()
    self:updateCarData()
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_CREATE_CD_UPDATE, function(txt)
    if txt then
      self.txtCountDown:SetText(txt)
    end
  end)
end

function WinCar:updateCarData()
  self.carData = Me:getAllVehicle()
  local inUseCar = Me:getInUseCar()
  for _, info in pairs(self.carData) do
    info.isHave = false
    if inUseCar and inUseCar.id == info.id then
      info.isHave = true
    end
  end
  self.carGridView:setData(self.carData, -1, nil, true)
end

function WinCar:initView()
  self:updateCarData()
end

function WinCar:onHide()
  UI:closeWnd("car")
  Plugins.CallTargetPluginFunc("advertisement_module", "openAdvertisementMain", true)
end

function WinCar:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("car")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function WinCar:hasScanAllNewCar()
  local newCars = CarConfig:getNewCars()
  if #newCars == 0 then
    return
  end
  if Me.newVehicleRecord == nil then
    return
  end
  for _, v in ipairs(newCars) do
    CarConfig:updateIsNewStatusById(v.id)
    Me.newVehicleRecord[tostring(v.id)] = 1
  end
  Me:updateVehicleRedDotStatus()
  Me:saveNewVehicleRecord()
end

function WinCar:onOpen()
  Me:uiMutualExclusion("car")
  self:initView()
  self:subscribeEvent()
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, false)
  Me:updateCarUseCD()
end

function WinCar:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  Lib.emitEvent(Event.EVENT_UPDATE_MAIN_RIGHT_SHOW, true)
  self:hasScanAllNewCar()
end

return WinCar
