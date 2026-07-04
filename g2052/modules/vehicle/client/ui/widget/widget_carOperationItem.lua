local CONTROL_OPTION_MAX = 10
local POINTER_ROTATE_MIN = -130
local POINTER_ROTATE_MAX = 130
local math_floor = math.floor
local CUSTOM_FUNC_OWNER = {
  Define.OPERATION_TYPE.DOUBLE_FLASH,
  Define.OPERATION_TYPE.LOCK,
  Define.OPERATION_TYPE.HONK,
  Define.OPERATION_TYPE.HELP
}
local CUSTOM_FUNC_USER = {
  Define.OPERATION_TYPE.DOUBLE_FLASH,
  Define.OPERATION_TYPE.HONK,
  Define.OPERATION_TYPE.HELP
}
local ICON_OPERATION = {
  [Define.OPERATION_TYPE.PAINT] = "set:g2052_function.json image:icon_0_painting",
  [Define.OPERATION_TYPE.MUSIC] = "set:g2052_function.json image:icon_0_music",
  [Define.OPERATION_TYPE.HEADLIGHT] = "set:g2052_function.json image:icon_0_headlights",
  [Define.OPERATION_TYPE.DOUBLE_FLASH] = "set:g2052_function.json image:icon_0_double_flash",
  [Define.OPERATION_TYPE.LOCK] = "set:g2052_function.json image:icon_0_locked",
  [Define.OPERATION_TYPE.HONK] = "set:g2052_function.json image:icon_0_horn",
  [Define.OPERATION_TYPE.HELP] = "set:g2052_function.json image:icon_0_jump",
  [Define.OPERATION_TYPE.ALARM] = "set:g2052_function.json image:icon_0_police_lights",
  [Define.OPERATION_TYPE.FIRST_AID] = "set:g2052_function.json image:icon_0_police_lights",
  [Define.OPERATION_TYPE.SQUIRT_WATER] = "set:g2052_function.json image:icon_0_firefighting02",
  [Define.OPERATION_TYPE.SHIFT_GEARS] = "set:g2052_function.json image:icon_0_turntable",
  [Define.OPERATION_TYPE.ARM_TURN] = "set:g2052_function.json image:icon_0_firefighting01",
  [Define.OPERATION_TYPE.STOP_SIGN] = "set:g2052_function.json image:icon_0_shop"
}
local BTN_BG_RES = {
  headlight = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  lock = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  music = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  doubleFlash = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  alarm = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  firstAid = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  squirtWater = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  armTurn = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  },
  stopSign = {
    "set:g2052_function.json image:img_9_box_bg03",
    "set:g2052_function.json image:img_9_box_bg03"
  }
}
local CarConfig = T(Config, "CarConfig")

local function getVehicleWheels(vehicleInst)
  local wheels = {}
  local count = vehicleInst:getChildrenCount()
  for i = 0, count - 1 do
    local n = vehicleInst:getChildAt(i)
    if n:getName() == "chelun_front" or n:getName() == "chelun_rear" then
      table.insert(wheels, n)
    end
  end
  return wheels
end

local widget_base = require("ui.widget.widget_base")
local WidgetCarOperationItem = Lib.derive(widget_base)

function WidgetCarOperationItem:init(params)
  widget_base.init(self, "CarOperationItem.json")
  self._allEvent = {}
  self.lastSpeed = 0
  self.lastMoveDir = Lib.v3(0, 0, 0)
  self.isSlowDown = false
  self._isPlayingMoveSound = false
  self._speedChangeStatus = 0
  self._checkSpeedTab = {}
  self._car = params.car
  self._vehicleStatus = params.vehicleStatus or {}
  self._wheels = getVehicleWheels(self._car)
  self._controller = params.controller
  self.cancelDestroySignal = params.controller:connect("on_destroy", function(instance)
    if instance == self._controller and GUIManager:Instance() then
      if self.speedTimer then
        self.speedTimer()
        self.speedTimer = nil
      end
      Lib.emitEvent(Event.EVENT_REMOVE_OPERATION_PANEL, "car")
    end
  end)
  self._isOwner = params.isOwner
  self.rx = 0
  self.ry = 0
  self:initUI()
  self:initView()
  self:initEvent()
  self:beginTick()
end

function WidgetCarOperationItem:initUI()
  self.lytSpeedShow = self:child("CarOperationItem-SpeedShow")
  self.imgSpeedCircle = self:child("CarOperationItem-SpeedCircle")
  self.imgSpeedKe = self:child("CarOperationItem-SpeedKe")
  self.txtSpeedNum = self:child("CarOperationItem-SpeedNum")
  self.imgSpeedPointer = self:child("CarOperationItem-SpeedPointer")
  for i = 1, CONTROL_OPTION_MAX do
    self["btnOperation" .. i] = self:child("CarOperationItem-OperationBtn" .. i)
    self["imgOperation" .. i] = self:child("CarOperationItem-icon" .. i)
    self["imgSelectIcon" .. i] = self:child("CarOperationItem-selectIcon" .. i)
    self["imgSelectIcon" .. i]:SetVisible(false)
  end
end

function WidgetCarOperationItem:initEvent()
  for i = 1, CONTROL_OPTION_MAX do
    self:subscribe(self["btnOperation" .. i], UIEvent.EventButtonClick, function()
      local op = self.controlOptions[i]
      if op then
        if op == "help" then
          if self._controller.className ~= "VehicleControlClient" then
            return
          end
          local now = os.time()
          if self.lastJumpTime and now - self.lastJumpTime < 5 then
            return
          end
          local curPos = self._car:getPosition()
          local curRotation = self._car:getRotation()
          self._controller:setPosition(curPos + Lib.v3(0, 4, 0))
          self._controller:setRotation(Lib.v3(0, curRotation.y, 0))
          self._car:setLineVelocity(Lib.v3(0, 0, 0))
          self.lastJumpTime = os.time()
        elseif op == "music" then
          UI:openWnd("carBgmWnd", self._car, self._vehicleStatus or {})
        elseif op == "paint" then
          self:onClickPaint()
        elseif op == "armTurn" then
          self:onClickArmTurn()
        elseif op == "shiftGears" then
          self:onClickShiftGears()
        elseif op == "stopSign" then
          self:onClickStopSign()
        else
          Me:sendPacket({
            pid = "sendCarCommand",
            tid = self._cfg.id,
            act = op,
            instanceID = self._car:getInstanceID()
          })
        end
        if op == "squirtWater" then
          Plugins.CallTargetPluginFunc("report", "report", "car_water", nil, Me)
        end
      end
    end)
  end
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_STATUS_CHANGE, function(params)
    local act = params.act
    local status = params.status
    self:updateBtnStatus(act, status)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_CAR_BGM_UPDATE, function(bgm)
    if not self._vehicleStatus[Define.OPERATION_TYPE.MUSIC] then
      self._vehicleStatus[Define.OPERATION_TYPE.MUSIC] = {isActive = false}
    end
    if bgm then
      self._vehicleStatus[Define.OPERATION_TYPE.MUSIC].isActive = true
      self._vehicleStatus[Define.OPERATION_TYPE.MUSIC].bgm = bgm
    else
      self._vehicleStatus[Define.OPERATION_TYPE.MUSIC].isActive = false
      self._vehicleStatus[Define.OPERATION_TYPE.MUSIC].bgm = nil
    end
  end)
end

function WidgetCarOperationItem:onClickArmTurn()
  local part = self._car:findFirstChild("shengjiangti")
  if not part then
    return
  end
  if not Me:operationPartLocalRotateInternal(nil, part, -60, Lib.v3(1, 0, 0), Lib.v3(0, 0, -3.6), 10) then
    return
  end
  Me:sendPacket({
    pid = "sendCarCommand",
    act = "armTurn",
    instanceID = self._car:getInstanceID()
  })
  Plugins.CallTargetPluginFunc("report", "report", "car_shengjiangti", nil, Me)
end

function WidgetCarOperationItem:onClickStopSign()
  local part = self._car:findFirstChild("stopboard")
  if not part then
    return
  end
  if not Me:operationPartLocalRotateInternal(nil, part, -90, Lib.v3(0, 1, 0), Lib.v3(0, 0, 0.5), 10) then
    return
  end
  Me:sendPacket({
    pid = "sendCarCommand",
    act = "stopSign",
    instanceID = self._car:getInstanceID()
  })
  Plugins.CallTargetPluginFunc("report", "report", "car_stop", nil, Me)
end

function WidgetCarOperationItem:onClickShiftGears()
  if not self:checkVip() then
    return
  end
  local wndName = "gearShift"
  if UI:isOpen(wndName) then
    UI:closeWnd(wndName)
    return
  end
  UI:openWnd(wndName, self._car)
end

function WidgetCarOperationItem:checkVip()
  return true
end

function WidgetCarOperationItem:onClickPaint()
  if not self:checkVip() then
    return
  end
  local wndName = "ColorSelect"
  if UI:isOpen(wndName) then
    UI:closeWnd(wndName)
    return
  end
  UI:openWnd(wndName, {
    panelStatus = Me.carColorPanelStatus,
    title = Lang:toText("g2052.gui.vehicle.part.color"),
    leaveCb = function()
      UI:closeWnd(wndName)
    end,
    confirmCb = function(color, panelStatus)
      if color then
        Me.carColorPanelStatus = panelStatus
        Me:sendPacket({
          pid = "reqPaintVehicle",
          color = {
            color.r,
            color.g,
            color.b,
            1
          }
        })
        Plugins.CallTargetPluginFunc("report", "report", "car_colorchange", nil, Me)
      end
    end
  })
end

function WidgetCarOperationItem:updateBtnStatus(act, status)
  for i, v in ipairs(self.controlOptions) do
    if act == v and BTN_BG_RES[act] then
      self["imgSelectIcon" .. i]:SetVisible(status)
    end
  end
end

function WidgetCarOperationItem:sortOptions()
  table.sort(self.controlOptions, function(a, b)
    local orderA = Define.OPERATION_ORDER[a]
    local orderB = Define.OPERATION_ORDER[b]
    return orderA < orderB
  end)
end

function WidgetCarOperationItem:initView()
  self.controlOptions = Lib.copyTable1(CUSTOM_FUNC_USER)
  if self._isOwner then
    self.controlOptions = Lib.copyTable1(CUSTOM_FUNC_OWNER)
  end
  local carName = self._car:getName()
  local cfg = CarConfig:getCfgByName("myplugin/" .. carName)
  if cfg then
    for i = 1, 10 do
      local tb = cfg["custom_func" .. i]
      if tb and next(tb) then
        table.insert(self.controlOptions, tb[1])
      end
    end
    self._cfg = cfg
  end
  self:sortOptions()
  for i = 1, CONTROL_OPTION_MAX do
    local command = self.controlOptions[i] or ""
    self["btnOperation" .. i]:SetVisible(command ~= "")
    if ICON_OPERATION[command] then
      self["imgOperation" .. i]:SetImage(ICON_OPERATION[command])
    end
    self["imgSelectIcon" .. i]:SetVisible(false)
  end
  self.txtSpeedNum:SetText("0KM/H")
  self.imgSpeedPointer:SetRotate(POINTER_ROTATE_MIN)
  if next(self._vehicleStatus) ~= nil then
    for act, status in pairs(self._vehicleStatus) do
      self:updateBtnStatus(act, status.isActive)
    end
  end
end

function WidgetCarOperationItem:updatePointerRotation(curSpeed, speedMax)
  if not curSpeed or not speedMax then
    return
  end
  if speedMax <= curSpeed then
    self.imgSpeedPointer:SetRotate(POINTER_ROTATE_MAX)
  elseif curSpeed == 0 then
    self.imgSpeedPointer:SetRotate(POINTER_ROTATE_MIN)
  else
    local percent = curSpeed / speedMax
    local rotation_add = math_floor((POINTER_ROTATE_MAX - POINTER_ROTATE_MIN) * percent)
    self.imgSpeedPointer:SetRotate(POINTER_ROTATE_MIN + rotation_add)
  end
  local buff = Me:getTypeBuff("fullName", "myplugin/car_speed_up_buff") or Me:getTypeBuff("fullName", "myplugin/car_speed_down_buff") or Me:getTypeBuff("fullName", "myplugin/car_move_buff")
  if buff then
    local volume = curSpeed / 35.0
    TdAudioEngine.Instance():setSoundsVolume(buff.soundId, volume)
  end
end

function WidgetCarOperationItem:beginTick()
  Me:sendPacket({
    pid = "vehicleStop",
    tid = self._cfg.id,
    instanceID = self._car:getInstanceID()
  })
  if self._controller then
    local speedMax = self._controller.speedMax
    self.speedTimer = World.Timer(2, function()
      if not (self._controller and self._controller:isValid()) or not self._controller.getCurSpeed then
        return
      end
      local speed = math.abs(math_floor(self._controller:getCurSpeed() + 0.5))
      local curSpeed = math_floor(self._controller:getCurSpeed() + 0.5)
      local speedChangeStatus
      if speed ~= self.lastSpeed then
        if speed > self.lastSpeed then
          speedChangeStatus = 1
          self._checkSpeedTab = {}
          self._checkSpeedTab[1] = 1
        else
          speedChangeStatus = -1
          self._checkSpeedTab = {}
          self._checkSpeedTab[1] = -1
        end
        self.lastSpeed = speed
        self.txtSpeedNum:SetText(speed .. "KM/H")
      elseif next(self._checkSpeedTab) ~= nil then
        self._checkSpeedTab[#self._checkSpeedTab + 1] = 0
        local len = #self._checkSpeedTab
        if 5 <= len then
          speedChangeStatus = 0
          self._checkSpeedTab = {}
        else
          local sum = 0
          for _, v in ipairs(self._checkSpeedTab) do
            sum = sum + v
          end
          if 0 < sum then
            speedChangeStatus = 1
          else
            speedChangeStatus = 0
          end
        end
      elseif speed == 0 or speed == speedMax then
        speedChangeStatus = 0
        self._checkSpeedTab = {}
      else
        speedChangeStatus = 0
      end
      local speedNeed = 0
      if self._cfg then
        speedNeed = self._cfg.playRunSoundSpeed
      end
      if speed > speedNeed and speedChangeStatus ~= self._speedChangeStatus then
        if speedChangeStatus == 1 then
          Me:sendPacket({
            pid = "vehicleSpeedUp",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
        elseif speedChangeStatus == -1 then
          Me:sendPacket({
            pid = "vehicleSpeedDown",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
        else
          Me:sendPacket({
            pid = "vehicleSpeedUpOrDownCancel",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
        end
        self._speedChangeStatus = speedChangeStatus
      end
      local moveDir = self._car:getMountEntityTryMoveDir()
      if self.lastMoveDir.x == 0 and self.lastMoveDir.z == 0 and (moveDir.x ~= 0 or moveDir.z ~= 0) then
        self.isSlowDown = false
        Me:sendPacket({
          pid = "vehicleStop",
          tid = self._cfg.id,
          instanceID = self._car:getInstanceID()
        })
      elseif (self.lastMoveDir.x ~= 0 or self.lastMoveDir.z ~= 0) and moveDir.x == 0 and moveDir.z == 0 then
        if speed == 0 then
          Me:sendPacket({
            pid = "vehicleStop",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
          self._isPlayingMoveSound = false
        else
          self.isSlowDown = true
        end
      elseif self.isSlowDown and speed == 0 then
        Me:sendPacket({
          pid = "vehicleStop",
          tid = self._cfg.id,
          instanceID = self._car:getInstanceID()
        })
        self.isSlowDown = false
        self._isPlayingMoveSound = false
      end
      if speed > speedNeed then
        if not self._isPlayingMoveSound then
          Me:sendPacket({
            pid = "vehicleMove",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
          self._isPlayingMoveSound = true
        end
      elseif self._isPlayingMoveSound then
        if 0 < speed then
          Me:sendPacket({
            pid = "vehicleStop",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
        else
          Me:sendPacket({
            pid = "vehicleMoveCancel",
            tid = self._cfg.id,
            instanceID = self._car:getInstanceID()
          })
        end
        self._isPlayingMoveSound = false
      end
      self.lastMoveDir = moveDir
      self:executeWheelTurn(curSpeed, moveDir)
      self:updatePointerRotation(speed, speedMax)
      return true
    end)
  end
end

function WidgetCarOperationItem:executeWheelTurn(curSpeed, moveDir)
  local enableMove = self._controller:getProperty("enableMove")
  if not enableMove or enableMove == "false" then
    return
  end
  if #self._wheels > 0 then
    for _, wheelInst in ipairs(self._wheels) do
      if wheelInst:isValid() then
        if curSpeed == 0 and moveDir.x == 0 and moveDir.z == 0 then
          wheelInst:setLocalRotation(Lib.v3(self.rx, 0, 0))
          self.ry = 0
        else
          local leftMove = 0
          if moveDir.x ~= 0 then
            if 0 < moveDir.x then
              leftMove = World.cfg.vehicleWheelTurnSpeed
            else
              leftMove = -World.cfg.vehicleWheelTurnSpeed
            end
          elseif self.ry ~= 0 then
            if 0 < self.ry then
              leftMove = -World.cfg.vehicleWheelTurnSpeed
            else
              leftMove = World.cfg.vehicleWheelTurnSpeed
            end
          end
          local forwardMove = curSpeed == 0 and 0 or curSpeed * 0.5
          local ry = self.ry + leftMove
          local maxAngle = World.cfg.vehicleWheelTurnAngle
          if ry > maxAngle then
            ry = maxAngle
          end
          if ry < -maxAngle then
            ry = -maxAngle
          end
          local rx = self.rx + forwardMove
          if 360 < rx then
            rx = rx - 360
          end
          if rx < -360 then
            rx = rx + 360
          end
          if wheelInst:getName() == "chelun_front" then
            wheelInst:setLocalRotation(Lib.v3(rx, ry, 0))
          else
            wheelInst:setLocalRotation(Lib.v3(rx, 0, 0))
          end
          self.rx = rx
          self.ry = ry
        end
      end
    end
  end
end

function WidgetCarOperationItem:onDestroy()
  if self.cancelDestroySignal then
    self.cancelDestroySignal()
  end
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.speedTimer then
    self.speedTimer()
    self.speedTimer = nil
  end
end

return WidgetCarOperationItem
