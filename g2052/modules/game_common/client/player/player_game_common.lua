local SoundConfig = T(Config, "SoundConfig")
local MonitorConfig = T(Config, "MonitorConfig")
local WeatherConfig = T(Config, "WeatherConfig")
local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
local Player = _ENV.Player
local bm = Blockman.Instance()
local ti = TouchManager:Instance()
local emptyPos = {
  x = 0,
  y = 0,
  z = 0
}

function Player:simulationClickOnScene()
  local touch = ti:getTouch(ti:getActiveTouch())
  if not touch then
    return
  end
  local hit = bm:getRayTraceResult(touch:getTouchPoint(), -1, true, false, false, {})
  local packet = {}
  if hit.type == "ENTITY" then
    packet.targetID = hit.objID
    packet.targetPos = hit.hitPos
  elseif hit.type == "PART" then
    local part = hit.part
    if not part then
      hit.worldPos = hit.hitPos
      packet.partID = hit.partId
    else
      packet.partID = part:getInstanceID()
    end
    if not packet.partID then
      return
    end
  end
  PlayerControl.processClick(hit, packet)
end

local oldCameraDistance = 15.0
local fakeFirstViewForceEnabled = false

function Player:ForceEnableFakeFirstView(enabled)
  if fakeFirstViewForceEnabled == enabled then
    return
  end
  local curDistance = Blockman.instance:viewerRenderDistance()
  if enabled then
    oldCameraDistance = curDistance
  end
  fakeFirstViewForceEnabled = enabled
  local add = enabled and -curDistance or oldCameraDistance - curDistance
  Blockman.instance:addCameraDistance(add)
end

local WINDOW_WIDTH = math.max(GUISystem.instance:GetRootWindow():GetPixelSize().x, GUISystem.instance:GetRootWindow():GetPixelSize().y)
Lib.subscribeEvent(Event.EVENT_TOUCH_SCREEN_ZOOM, function(delta)
  if fakeFirstViewForceEnabled then
    return
  end
  local sensitive = World.cfg.cameraZoomSensitive or 80 / WINDOW_WIDTH
  Blockman.instance:addCameraDistance(-delta * sensitive)
end)

function Player:startCameraSmoothMovement(curPos, targetPos, time)
  local cam = self:getSecondCamera()
  local mainCamera = CameraManager.Instance():findCamera("mainCamera")
  if not mainCamera then
    return
  end
  if self.cameraSmoothMoveTimer then
    self.cameraSmoothMoveTimer()
    self.cameraSmoothMoveTimer = nil
    mainCamera:setActive()
  end
  curPos = Lib.tov3(curPos or emptyPos)
  targetPos = Lib.tov3(targetPos or emptyPos)
  if curPos == targetPos then
    mainCamera:setActive()
    return
  end
  cam:setPosition(curPos)
  cam:setDirection(mainCamera:getDirection())
  cam:setUp(mainCamera:getUp())
  cam:setFov(mainCamera:getFov())
  cam:setWidth(mainCamera:getWidth())
  cam:setHeight(mainCamera:getHeight())
  cam:setNearClip(mainCamera:getNearClip())
  cam:setFarClip(mainCamera:getFarClip())
  cam:setActive()
  local offsetPos = (targetPos - curPos) / time
  local count = 0
  self.cameraSmoothMoveTimer = self:timer(1, function()
    count = count + 1
    local surplus = time - count
    local newPos = curPos + offsetPos * count
    cam:setPosition(newPos)
    if newPos == targetPos or surplus <= 0 then
      mainCamera:setActive()
      self.cameraSmoothMoveTimer = nil
      return
    end
    return true
  end)
end

function Player:getSecondCamera()
  local cam = CameraManager.Instance():createCamera("second")
  return cam
end

function Player:playSoundByKey(key, time)
  Lib.logDebug(key)
  local sid = 0
  local soundInfo
  if key then
    soundInfo = SoundConfig:getSound(key)
    sid = Me:playSound(soundInfo)
  end
  if time then
    World.Timer(time, function()
      Me:stopSound(sid)
    end)
  end
  return sid, soundInfo
end

function Player:play3dSoundByKey(key, pos, time)
  Lib.logDebug(key)
  local sid = 0
  if key then
    local soundInfo = SoundConfig:getSound(key)
    local sound = soundInfo.sound
    sound = "asset" .. sound
    sid = TdAudioEngine.Instance():play3dSound(sound, pos, soundInfo.loop, 1, 1.0, 100.0)
    if soundInfo.volume then
      TdAudioEngine.Instance():setSoundsVolume(sid, soundInfo.volume)
    end
    TdAudioEngine.Instance():set3DRollOffMode(sid, Sound3DRollOffType.LINEAR)
    local soundDistance = World.cfg.soundDistance or {1, 5}
    TdAudioEngine.Instance():set3DMinMaxDistance(sid, soundDistance[1], soundDistance[2])
  end
  if time then
    World.Timer(time, function()
      Me:stopSound(sid)
    end)
  end
  return sid
end

function Player:playWeatherBgm()
  if not self:getPlaySpecialBgm() then
    local lastWeather = Me:data("main").weather
    if lastWeather then
      local cfg = WeatherConfig:getCfgByIdAndMapName(lastWeather, self.map.name)
      if not cfg then
        return
      end
      self:switchBgmSoundByKey(cfg.bgm)
    end
  end
end

function Player:switchBgmSoundByKey(key)
  Lib.logDebug(key)
  if key then
    local soundInfo = SoundConfig:getSound(key)
    local bgm = {
      bgmSound = soundInfo.sound,
      bgmVolume = soundInfo.volume
    }
    self:playGameBgm(bgm)
  end
end

function Player:openMonitorView(type, target, params)
  local monitorId = tonumber(params[1])
  if not monitorId then
    return
  end
  local conf = MonitorConfig:getCfgById(monitorId)
  if not conf then
    return
  end
  local parent = target:getParent()
  if not parent or not parent:isValid() then
    return
  end
  local group = {}
  for _, v in ipairs(conf) do
    local nodes = {}
    local partName = v.partName
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, partName)
    if 0 < #nodes then
      for _, node in ipairs(nodes) do
        group[#group + 1] = node
      end
    end
  end
  if #group < 1 then
    return
  end
  local cameraData = {}
  for _, v in ipairs(group) do
    local cameraPos = v:getPosition()
    local rotation = v:getRotation()
    local dir = Lib.correctMoveDistance(rotation, Lib.v3(0, 0, -1))
    cameraData[#cameraData + 1] = {cameraPos = cameraPos, dir = dir}
  end
  UI:openWnd("cameraSwitch", cameraData, 1, false)
end

function Player:checkIsMobileEditor()
  return Lib.isG2052ModEditor()
end

function Player:uiMutualExclusion(uiName)
  for _, name in pairs(Define.MainBtnUi) do
    if name ~= uiName and UI:isOpen(name) then
      UI:closeWnd(name)
    end
  end
end

local uiByMode = {
  Normal = {
    biddingPreview = function(wnd)
      UI:closeWnd("biddingPreview")
    end,
    biddingAuditPreview = function(wnd)
      UI:closeWnd("biddingAuditPreview")
    end,
    gameMain = function(wnd)
      if wnd then
        wnd:updateRightBtnList({})
        wnd:setBtnHouseScanVisible(true)
        wnd:updateModBtnShow(World.cfg.showModBtnOnGameMain)
        wnd:updateMaskPanelShow(false)
      end
    end,
    houseAndCarOperation = function(wnd)
      if wnd then
        wnd:updateHouseOperationShow(true)
      end
    end
  },
  Preview = {
    biddingPreview = function(wnd)
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
      UI:openWnd("biddingPreview")
    end,
    gameMain = function(wnd)
      if wnd then
        wnd:updateRightBtnList({
          [Define.BTN_SORT.BABY] = false,
          [Define.BTN_SORT.HOUSE] = false
        })
        wnd:setBtnHouseScanVisible(false)
        wnd:updateModBtnShow(false)
        wnd:updateMaskPanelShow(false)
      end
    end,
    houseAndCarOperation = function(wnd)
      if wnd then
        wnd:updateHouseOperationShow(false)
      end
    end
  },
  WaitChange = {
    gameMain = function(wnd)
      if wnd then
        wnd:updateRightBtnList({
          [Define.BTN_SORT.BABY] = false,
          [Define.BTN_SORT.HOUSE] = false
        })
        wnd:setBtnHouseScanVisible(false)
        wnd:updateModBtnShow(false)
        wnd:updateMaskPanelShow(true)
      end
    end,
    houseAndCarOperation = function(wnd)
      if wnd then
        wnd:updateHouseOperationShow(false)
      end
    end
  },
  PreviewAudit = {
    biddingAuditPreview = function(wnd)
      Plugins.CallTargetPluginFunc("new_video", "updateNewVideoShow", false)
      UI:openWnd("biddingAuditPreview")
      UI:getWnd("biddingAuditPreview"):requestAuditData()
    end,
    gameMain = function(wnd)
      if wnd then
        wnd:updateRightBtnList({
          [Define.BTN_SORT.BABY] = false,
          [Define.BTN_SORT.HOUSE] = false
        })
        wnd:setBtnHouseScanVisible(false)
        wnd:updateModBtnShow(false)
      end
    end,
    houseAndCarOperation = function(wnd)
      if wnd then
        wnd:updateHouseOperationShow(false)
      end
    end
  },
  MobileEditor = {
    gameMain = function(wnd)
      if wnd then
        wnd:updateRightBtnList({
          [Define.BTN_SORT.BABY] = false,
          [Define.BTN_SORT.HOUSE] = false
        })
        wnd:setBtnHouseScanVisible(false)
        wnd:updateModBtnShow(false)
        wnd:updateMaskPanelShow(false)
      end
    end,
    houseAndCarOperation = function(wnd)
      if wnd then
        wnd:updateHouseOperationShow(false)
      end
    end
  }
}

function Player:changePlayModel(model, modelData)
  self.modelData = modelData
  self.model = model
  Lib.logDebug("1111111111111111111111111", model, Me.modelData)
  local showUIList = uiByMode[model]
  for uiName, func in pairs(showUIList) do
    Lib.logDebug("uiName", uiName)
    local wnd = UI:getWnd(uiName, true)
    func(wnd)
  end
end

function Player:alternatingDayAndNight(isNight)
  self.isNight = isNight
  BrightnessScaleHelper:changeAllPlayerBrightnessScale()
end

local function getRotateTrack(angle, axis, base, initRotation, time)
  local pos = base * -1
  local q1 = Quaternion.fromEulerAngle(initRotation.x, initRotation.y, initRotation.z)
  local curPos = q1 * pos
  local track = {}
  for i = 1, time do
    local newRotation = initRotation + axis * (angle / time) * i
    local q2 = Quaternion.fromEulerAngle(newRotation.x, newRotation.y, newRotation.z)
    local newPos = q2 * pos
    track[i] = {
      newRotation = newRotation,
      offsetPos = newPos - curPos
    }
  end
  return track
end

local function getRotateTrackInternal(angle, axis, base, initRotation, time)
  local raised = math.abs(initRotation.x) > 0.01 or 0.01 < math.abs(initRotation.y)
  local pos = base * -1
  local q1 = Quaternion.fromEulerAngle(initRotation.x, initRotation.y, initRotation.z)
  local curPos = q1 * pos
  local track = {}
  for i = 1, time do
    local newRotation = 0
    if raised then
      newRotation = initRotation - axis * (angle / time) * i
    else
      newRotation = initRotation + axis * (angle / time) * i
    end
    local q2 = Quaternion.fromEulerAngle(newRotation.x, newRotation.y, newRotation.z)
    local newPos = q2 * pos
    table.insert(track, {
      newRotation = newRotation,
      offsetPos = newPos - curPos
    })
  end
  return track
end

local function partRestoreRotate(target, restoreCB)
  if not target.operationRotateInfo then
    return
  end
  local initPos = target.operationRotateInfo.initPos
  local track = target.operationRotateInfo.track
  local time = target.operationRotateInfo.time
  local rotation = target.operationRotateInfo.rotation
  local count = time + 1
  if target.initCollision then
    target:setProperty("useCollide", "false")
  end
  target.partRestoreTimer = World.Timer(1, function()
    if not target or not target:isValid() then
      return
    end
    count = count - 1
    if track[count] then
      target:setLocalRotation(track[count].newRotation)
      target:setLocalPosition(initPos + track[count].offsetPos)
    end
    if count <= 1 then
      target:setLocalRotation(rotation)
      target:setLocalPosition(initPos)
      target.partRestoreTimer = nil
      target.operationRotateInfo = nil
      restoreCB()
      return
    end
    return true
  end)
end

local function partRestoreRotateInternal(target, restoreCB)
  if not target.operationRotateInfo then
    return
  end
  local initPos = target.operationRotateInfo.initPos
  local track = target.operationRotateInfo.track
  local time = target.operationRotateInfo.time
  local rotation = target.operationRotateInfo.rotation
  local count = 0
  if target.initCollision then
    target:setProperty("useCollide", "false")
  end
  target.partRestoreTimer = World.Timer(1, function()
    if not target or not target:isValid() then
      return
    end
    count = count + 1
    if track[count] then
      target:setLocalRotation(track[count].newRotation)
      target:setLocalPosition(initPos + track[count].offsetPos)
    end
    if count >= time then
      target:setLocalRotation(Lib.v3(0, 0, 0))
      target.partRestoreTimer = nil
      target.operationRotateInfo = nil
      restoreCB()
      return
    end
    return true
  end)
end

local function partRotate(target, finishCB)
  if not target.operationRotateInfo then
    return
  end
  local initPos = target.operationRotateInfo.initPos
  local track = target.operationRotateInfo.track
  local time = target.operationRotateInfo.time
  local count = 0
  if target.initCollision then
    target:setProperty("useCollide", "false")
  end
  target.partRotateTimer = World.Timer(1, function()
    if not target or not target:isValid() then
      return
    end
    count = count + 1
    if track[count] then
      target:setLocalRotation(track[count].newRotation)
      target:setLocalPosition(initPos + track[count].offsetPos)
    end
    if count == time then
      target.partRotateTimer = nil
      finishCB()
      return
    end
    return true
  end)
end

function Player:operationPartLocalRotate(type, target, params)
  if target.partRotateTimer or target.partRestoreTimer or target.restoreRotateTimer then
    return false
  end
  if params then
    if not target.initCollision and params[8] ~= "crash" then
      target.initCollision = target:getProperty("useCollide")
    end
    local rotateCall = Lib.splitString(params[7], "#")
    if params[4] == "" and target.operationRotateInfo then
      local time = target.operationRotateInfo.time
      partRestoreRotate(target, function()
        if rotateCall[1] and self[rotateCall[1]] then
          self[rotateCall[1]](self, "close", target, rotateCall)
        end
        if target and target:isValid() and target.initCollision then
          target:setProperty("useCollide", target.initCollision)
        end
      end)
      if target.restoreRotateTimer then
        target.restoreRotateTimer()
        target.restoreRotateTimer = nil
      end
      return true
    end
    local initPos = target:getLocalPosition()
    local rotation = target:getLocalRotation()
    local angle = tonumber(params[1]) or 0
    local axis = Lib.createV3ByString(params[2])
    local base = Lib.createV3ByString(params[3])
    local time = tonumber(params[6]) or 1
    local track = getRotateTrack(angle, axis, base, rotation, time)
    if not target.initialInfo then
      target.initialInfo = {pos = initPos, rotation = rotation}
    end
    target.operationRotateInfo = {
      initPos = initPos,
      rotation = rotation,
      track = track,
      time = time
    }
    partRotate(target, function()
      if rotateCall[1] and self[rotateCall[1]] then
        self[rotateCall[1]](self, "open", target, rotateCall)
      end
      if target and target:isValid() and target.initCollision then
        target:setProperty("useCollide", target.initCollision)
      end
    end)
    local restoreTime = tonumber(params[5])
    if restoreTime then
      target.restoreRotateTimer = World.Timer(restoreTime + time, function()
        partRestoreRotate(target, function()
          if rotateCall[1] and self[rotateCall[1]] then
            self[rotateCall[1]](self, "close", target, rotateCall)
          end
          if target and target:isValid() and target.initCollision then
            target:setProperty("useCollide", target.initCollision)
          end
        end)
        target.restoreRotateTimer = nil
      end)
    end
  end
  return true
end

function Player:operationPartLocalRotateInternal(_, target, angle, axis, base, time)
  if target.partRotateTimer or target.partRestoreTimer then
    return false
  end
  local initPos = target:getLocalPosition()
  local rotation = target:getLocalRotation()
  local raised = math.abs(rotation.x) > 0.01 or 0.01 < math.abs(rotation.y)
  local track = getRotateTrackInternal(angle, axis, base, rotation, time)
  target.operationRotateInfo = {
    initPos = initPos,
    rotation = rotation,
    track = track,
    time = time
  }
  if not target.initCollision then
    target.initCollision = target:getProperty("useCollide")
  end
  local fn = raised and partRestoreRotateInternal or partRotate
  fn(target, function()
    if target and target:isValid() and target.initCollision then
      target:setProperty("useCollide", target.initCollision)
    end
  end)
  return true
end

function Player:checkPlayerIsVipByUserId(userId)
  return Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", userId, Define.PRIVILEGE_TYPE.VIP)
end

function Player:closeRightFunctionWnd()
  local data = {
    "role",
    "professionWnd",
    "partner",
    "g2052Bag",
    "dance",
    "car",
    "house",
    "giftWnd"
  }
  for _, uiName in pairs(data) do
    if UI:isOpen(uiName) then
      UI:closeWnd(uiName)
    end
  end
end

function Player:sendShortChatById(shortData)
  if not self.shortChatTimeList then
    self.shortChatTimeList = {}
  end
  if self.shortChatCDing then
    local remainTime = World.cfg.shortChatCD - (os.time() - self.shortChatCDing)
    if 0 < remainTime then
      local text = Lang:toText({
        "g2052.gui.short.chat.tips",
        remainTime
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
      return
    end
  end
  self.shortChatCDing = nil
  if #self.shortChatTimeList >= World.cfg.shortChatMaxNum then
    local passTime = os.time() - self.shortChatTimeList[1]
    if passTime < 60 then
      self.shortChatTimeList = {}
      self.shortChatCDing = os.time()
      local text = Lang:toText({
        "g2052.gui.short.chat.tips",
        World.cfg.shortChatCD
      })
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
      return
    else
      self.shortChatTimeList = {}
    end
  end
  local packet = {
    pid = "CSSendShortChatMsg",
    id = shortData.id,
    msg = Lang:toText(shortData.shortDesc)
  }
  Me:sendPacket(packet)
  table.insert(self.shortChatTimeList, os.time())
end
