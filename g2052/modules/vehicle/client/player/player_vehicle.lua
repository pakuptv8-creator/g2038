local CarConfig = T(Config, "CarConfig")
local RedDotConfig = T(Config, "RedDotConfig")
local cjson = require("cjson")
local primaryCarCreateCd = World.cfg.primaryCarCreateCd or 1
Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(riderObjId, rideOnId)
  if riderObjId == Me.objID then
    local target = World.CurWorld:getEntity(rideOnId)
    if target and target:cfg().showCarControl == true then
      UI:openWnd("carOperation")
    end
  end
end)
local Player = _ENV.Player

function Player:loadNewVehicleRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewVehicleRecord-" .. userId .. ".json"
  local file = io.open(path, "r")
  if not file then
    self.newVehicleRecord = {}
    return
  end
  file:close()
  self.newVehicleRecord = Lib.read_json_file(path) or {}
  for id, _ in pairs(self.newVehicleRecord) do
    CarConfig:updateIsNewStatusById(tonumber(id))
  end
end

function Player:saveNewVehicleRecord()
  local userId = self.platformUserId
  local path = Root.Instance():getWriteablePath() .. "g2052NewVehicleRecord-" .. userId .. ".json"
  local file, errmsg = io.open(path, "w")
  if not file then
    print("\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129saveNewVehicleRecord  error \239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129\239\188\129")
    print(errmsg)
    return false
  end
  local ok, content = pcall(cjson.encode, self.newVehicleRecord)
  assert(ok, path)
  file:write(Lib.jsonToFormat(content))
  file:close()
end

function Player:updateVehicleRedDotStatus()
  local allCfg = CarConfig:getAllCfgs()
  for _, v in pairs(allCfg) do
    if v.isNew == 1 then
      Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewVehicle, 1)
      return
    end
  end
  Plugins.CallPluginFunc("resetRedDotState", RedDotConfig.RD_KEY.HasNewVehicle, 0)
end

function Player:selectCarLogic(data)
  self:updateCarUseCD()
  local isCancel = false
  local useCar = Me:getInUseCar()
  if useCar and useCar.id == data.id then
    isCancel = true
  end
  if not isCancel and Me.rideOnId > 0 then
    local target = World.CurWorld:getEntity(Me.rideOnId)
    if target and target:cfg().isShip then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
      return
    end
  end
  local isAdvanced = CarConfig:isAdvancedCar(data.id)
  if isAdvanced and Me:isInFloatState() and not isCancel then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
    return
  end
  local oldPartId = Me:getInteractionPartID()
  if oldPartId ~= "" and not isCancel then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
    return
  end
  if Me:getInteractCarEnterID() ~= "" and not isCancel then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
    return
  end
  if Me:getInIndoor() and next(Me:getPlayerCurArea()) ~= nil and not isCancel and isAdvanced then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
    return
  end
  if self._nextCreateTime and os.time() < self._nextCreateTime and not isCancel then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText({
      "g2052.gui.house.create.cd",
      self._nextCreateTime - os.time()
    }))
    return
  end
  if useCar then
    local isSkateEntity = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_ENTITY", useCar.id)
    if isSkateEntity then
      local canLeaveSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_CAN_LEAVE_SKATE_MODE")
      if not canLeaveSkateMode then
        return
      end
    end
  end
  local curSkateEntity = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_ENTITY", data.id)
  if curSkateEntity then
    if Me:isInFloatState() and not isCancel then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
      return
    end
    if not isCancel and not Me.onGround then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", Lang:toText("g2052.gui.car.forbid.use"))
      return
    end
  end
  local params = {
    id = data.id
  }
  Me:sendPacket({
    pid = "OnOperationCar",
    params = params
  }, function(ret)
    if not ret then
      print("--OnOperationCar no choice item--")
    end
  end)
  if not isCancel then
    if isAdvanced then
      self._CDType = Define.VEHICLE_TYPE.Advanced
    else
      self._nextCreateTime = os.time() + primaryCarCreateCd
      self._CDType = Define.VEHICLE_TYPE.Primary
    end
  end
end

function Player:updateCarUseCD()
  local now = os.time()
  local nextCreateTime = self._nextCreateTime
  if not nextCreateTime then
    Lib.emitEvent(Event.EVENT_CAR_CREATE_CD_UPDATE, "")
    return
  end
  if now < nextCreateTime then
    if self.countDownCreateTimer then
      self.countDownCreateTimer()
      self.countDownCreateTimer = nil
    end
    
    local function showLeftTime()
      local now = os.time()
      local leftTime = nextCreateTime - now
      local textTime = ""
      if 0 < leftTime then
        textTime = Lang:toText({
          "g2052.gui.house.create.cd",
          leftTime
        })
      end
      Lib.emitEvent(Event.EVENT_CAR_CREATE_CD_UPDATE, textTime)
      return leftTime
    end
    
    showLeftTime()
    self.countDownCreateTimer = Me:timer(5, function()
      local leftTime = showLeftTime()
      if 0 < leftTime then
        return true
      end
      self.countDownCreateTimer = nil
      self._nextCreateTime = nil
      self._CDType = nil
    end)
  else
    Lib.emitEvent(Event.EVENT_CAR_CREATE_CD_UPDATE, "")
    self.countDownCreateTimer = nil
    self._nextCreateTime = nil
    self._CDType = nil
  end
end

function Player:checkIsInWatchCD(watchType)
  if Me.lastWatchAdTime then
    local remainTime = 10 - (os.time() - Me.lastWatchAdTime)
    if 0 < remainTime then
      local tips = Lang:toText({
        "g2052.advertisement.use.car.cd.tips",
        remainTime
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", tips)
      return true
    end
  end
  Me.lastWatchAdTime = os.time()
  return false
end

function Player:requestWatchAd(watchType, params)
  if self:checkIsInWatchCD(watchType) then
    return false
  end
  local adsId = Define.AdvertisingAdsId.Car
  if watchType == Define.AdvertisingType.Car then
    adsId = Define.AdvertisingAdsId.Car
  elseif watchType == Define.AdvertisingType.Dress then
    adsId = Define.AdvertisingAdsId.Dress
  elseif watchType == Define.AdvertisingType.Pet then
    adsId = Define.AdvertisingAdsId.Pet
  elseif watchType == Define.AdvertisingType.House then
    adsId = Define.AdvertisingAdsId.House
  elseif watchType == Define.AdvertisingType.AdvertisementDraw then
    adsId = Define.AdvertisingAdsId.AdvertisementDraw
  elseif watchType == Define.AdvertisingType.AdvertisementLockSlot then
    adsId = Define.AdvertisingAdsId.AdvertisementLockSlot
  elseif watchType == Define.AdvertisingType.AdvertisementScene then
    adsId = Define.AdvertisingAdsId.AdvertisementScene
  else
    return false
  end
  local defaultData = {ad_id = adsId}
  Plugins.CallTargetPluginFunc("report", "report", "g2052_vehicle_mAd_click", defaultData, Me)
  CGame.instance:getShellInterface():onWatchAd(watchType, params or "", adsId)
  return true
end
