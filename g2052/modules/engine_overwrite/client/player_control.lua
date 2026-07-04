local debugport = require("common.debugport")
local lastKeyState = L("lastKeyState", {})
local bm = Blockman.Instance()
local appState = L("appState", {})
local slideTick = L("slideTick", 0)
local nextLine = L("nextLine", nil)
local slideJumpFlag = L("slideJumpFlag", false)
local nextRollTime = L("nextRollTime", 0)
local rollBeginTime = L("rollBeginTime", 0)
local rollEndTime = L("rollEndTime", 0)
local isRolling = L("isRolling", false)
local slideTimes = L("slideTimes", 0)
local nextTurnTick = L("nextTurnTick", 0)
local lastDist = L("lastDist", 0)
local lastTouch = L("lastTouch", false)
local useJumpProgress = World.cfg.jumpControlConfig and World.cfg.jumpControlConfig.useJumpProgress

local function checkNewState(key, new)
  if lastKeyState[key] == new then
    return false
  end
  lastKeyState[key] = new
  return true
end

local function isKeyNewDown(key)
  local state = bm:isKeyPressing(key)
  return checkNewState(key, state) and state
end

local function isKeyUpDown(key)
  local state = bm:isKeyPressing(key)
  if lastKeyState[key] == state then
    return 0
  end
  lastKeyState[key] = state
  return state and 1 or 2
end

local function axisValue(forward, back)
  local value = 0.0
  if bm:isKeyPressing(forward) then
    value = value + 1
  end
  if bm:isKeyPressing(back) then
    value = value - 1
  end
  return value
end

local nextJumpTime = 0
local jumpBeginTime = 0
local jumpEndTime = 0
local onGround = true

local function checkJump(control, player)
  local playerCfg = player:cfg()
  local worldCfg = World.cfg
  local nowTime = World.Now()
  if onGround ~= player.onGround then
    onGround = player.onGround
    if onGround then
      nextJumpTime = nowTime + (playerCfg.jumpInterval or 2)
      if worldCfg.jumpProgressIcon or useJumpProgress then
        Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
      end
      player.twiceJump = nil
      player.takeoff = false
      jumpBeginTime = 0
    end
  end
  if 0 < bm:getVerticalSlide() then
    bm:setVerticalSlide(0)
    slideJumpFlag = true
  end
  if PlayerControl.checkJump() or slideJumpFlag then
    local canJump = player.onGround or player:isSwimming()
    local id = player.rideOnId
    local pet
    if 0 < id and not player:isCameraMode() then
      pet = player.world:getEntity(id)
      canJump = pet.onGround or pet:isSwimming()
    end
    if canJump then
      jumpBeginTime = nowTime
      jumpEndTime = nowTime + (playerCfg.maxPressJumpTime or 0)
      if worldCfg.jumpProgressIcon or useJumpProgress then
        Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {
          jumpStart = true,
          jumpBeginTime = jumpBeginTime,
          jumpEndTime = jumpEndTime
        })
      end
    end
    if worldCfg.enableTwiceJump and 0 == jumpEndTime and not player.twiceJump then
      player.twiceJump = true
      if playerCfg.twiceJumpSkill and nowTime - jumpBeginTime >= (playerCfg.twiceJumpTouchTime or 0) then
        Skill.Cast(playerCfg.twiceJumpSkill)
      end
    end
    if nowTime > jumpEndTime or nowTime < nextJumpTime then
      if slideJumpFlag then
        slideJumpFlag = false
      end
      return
    end
    local isSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_MODE")
    if canJump and not isSkateMode then
      control:jump()
    end
  else
    if worldCfg.jumpProgressIcon or useJumpProgress then
      Lib.emitEvent(Event.EVENT_UPDATE_JUMP_PROGRESS, {jumpStop = true})
    end
    jumpEndTime = 0
  end
end

function PlayerControl.forceJump()
  local control = bm:control()
  control:jump()
end

function PlayerControl.checkClickChangeBlock(pos)
  local cfg = Me.map:getBlock(pos)
  if not (cfg and cfg.canClick) or not cfg.clickChangeBlock then
    return false
  end
  local toBlockCfg = Block.GetNameCfg(cfg.clickChangeBlock)
  if toBlockCfg then
    if Blockman.instance.singleGame then
      Me.map:setBlockConfigId(pos, toBlockCfg.id)
    else
      local packet = {
        pid = "ClickChangeBlock",
        pos = pos
      }
      Me:sendPacket(packet)
    end
    return true
  else
    print("Error cfg in block " .. cfg.fullName .. ", clickChangeBlock: " .. cfg.clickChangeBlock)
  end
  return false
end

local function checkRoll(player)
  local tryRoll = false
  if bm:getVerticalSlide() < 0 then
    bm:setVerticalSlide(0)
    tryRoll = true
  end
  local nowTime = World.Now()
  if nowTime < nextRollTime then
    return
  end
  if isRolling and nowTime > rollEndTime then
    isRolling = false
    return
  end
  if tryRoll and not isRolling then
    isRolling = true
    local playerCfg = player:cfg()
    local worldCfg = World.cfg
    rollBeginTime = nowTime
    rollEndTime = nowTime + worldCfg.maxRollTime or 0
    nextRollTime = nowTime + worldCfg.rollInterval or 0
    Skill.Cast(playerCfg.rollSkill)
  end
end

local speSinVal = {
  0,
  1,
  0,
  -1
}
local speCosVal = {
  1,
  0,
  -1,
  0
}

local function setNearRunLine(player, left, baseZ, baseX)
  local sinYaw = speSinVal[math.modf(-player:getRotationYaw() % 360 / 90) + 1]
  local cosYaw = speCosVal[math.modf(-player:getRotationYaw() % 360 / 90) + 1]
  local tarZ = baseZ - left * sinYaw
  local tarX = baseX + left * cosYaw
  nextLine = {
    A = sinYaw,
    B = -cosYaw,
    C = tarX * cosYaw - tarZ * sinYaw
  }
  slideTick = World.CurWorld:getTickCount()
end

local function setRunLineAfterTurn(player, tarZ, tarX)
  local sinYaw = speSinVal[math.modf(-player:getRotationYaw() % 360 / 90) + 1]
  local cosYaw = speCosVal[math.modf(-player:getRotationYaw() % 360 / 90) + 1]
  nextLine = {
    A = sinYaw,
    B = -cosYaw,
    C = tarX * cosYaw - tarZ * sinYaw
  }
end

local lastMoveStatus = {
  forward = 0,
  left = 0,
  isMoving = false
}

local function checkMovingChange(control, player, forward, left)
  local playerCfg = player:cfg()
  local movingChangeStatusSkill = playerCfg.movingChangeStatusSkill
  if movingChangeStatusSkill and (lastMoveStatus.forward == 0 and lastMoveStatus.left == 0 and (forward ~= 0 or left ~= 0) or (lastMoveStatus.forward ~= 0 or lastMoveStatus.left ~= 0) and forward == 0 and left == 0) then
    Skill.Cast(movingChangeStatusSkill)
    lastMoveStatus.forward = forward
    lastMoveStatus.left = left
  end
  local movingChangeSkill = playerCfg.movingChangeSkill
  if movingChangeSkill and lastMoveStatus.isMoving ~= player.isMoving then
    Skill.Cast(movingChangeSkill)
    lastMoveStatus.isMoving = player.isMoving
  end
end

local lockVisionCfg = World.cfg.lockVision

local function CheckSlideScreen(player)
  if not lockVisionCfg or not lockVisionCfg.open then
    bm:setVerticalSlide(0)
    bm:setHorizonSlide(0)
    return
  end
  if not player:getValue("canSlide") then
    bm:setVerticalSlide(0)
    bm:setHorizonSlide(0)
    return
  end
  local verticalSlide = bm:getVerticalSlide()
  local horizonSlide = bm:getHorizonSlide()
  if 0 < slideTimes then
    if TouchManager.Instance():getSceneTouch1() then
      verticalSlide = 0
      horizonSlide = 0
      lastTouch = true
    elseif lastTouch then
      verticalSlide = 0
      horizonSlide = 0
      lastTouch = false
    else
      slideTimes = 0
    end
  end
  if player.isFlying then
    verticalSlide = 0
  end
  if verticalSlide ~= 0 and math.abs(verticalSlide) < (lockVisionCfg.touchDist or 20) then
    verticalSlide = 0
  end
  if horizonSlide ~= 0 and math.abs(horizonSlide) < (lockVisionCfg.touchDist or 20) then
    horizonSlide = 0
  end
  if 0 < math.abs(verticalSlide) or 0 < math.abs(horizonSlide) then
    slideTimes = slideTimes + 1
  end
  if math.abs(verticalSlide) > math.abs(horizonSlide) then
    horizonSlide = 0
  else
    verticalSlide = 0
  end
  bm:setVerticalSlide(verticalSlide)
  bm:setHorizonSlide(horizonSlide)
end

local function doHorizonSlide(player, left, forward)
  local horizonSlide = bm:getHorizonSlide()
  local slideDir = -Lib.sgn(horizonSlide)
  local changeLine = slideDir ~= 0
  local nowPos = player:getPosition()
  if changeLine then
    if World.CurWorld:getTickCount() - slideTick < (lockVisionCfg.senseTick or 5) then
      changeLine = false
    end
    bm:setHorizonSlide(0)
  end
  if not nowPos then
    return 0, 0
  end
  local _, regionTurnDir = player.map:getRegionValue(nowPos, "slideTurnDir")
  if slideDir ~= 0 and regionTurnDir then
    if World.Now() > nextTurnTick and regionTurnDir == slideDir then
      player:addYawOrPitch(-slideDir * 90, 0)
      nextTurnTick = World.Now() + 11
      setRunLineAfterTurn(player, math.floor(nowPos.z) + 0.5, math.floor(nowPos.x) + 0.5)
    end
  elseif nextLine ~= nil then
    local distance = nowPos.z * nextLine.A + nowPos.x * nextLine.B + nextLine.C
    lastDist = distance
    if math.abs(distance) < 0.1 or Lib.sgn(distance) * Lib.sgn(lastDist) < -1 then
      if nextLine.A ~= 0 then
        nowPos.z = (nextLine.A * nowPos.z - nextLine.B * nowPos.x - nextLine.C) / (2 * nextLine.A)
      end
      if nextLine.B ~= 0 then
        nowPos.x = (-nextLine.A * nowPos.z + nextLine.B * nowPos.x - nextLine.C) / (2 * nextLine.B)
      end
      local motion = player.motion
      motion.x = 0
      motion.z = 0
      player.motion = motion
      player:setPosition(nowPos)
      nextLine = nil
      left = 0
      forward = 0
    elseif changeLine then
      left = Lib.sgn(slideDir) * lockVisionCfg.slideWidth
      local zOnNextLine = -nextLine.C * nextLine.A
      local xOnNextLine = -nextLine.C * nextLine.B
      setNearRunLine(player, left, zOnNextLine, xOnNextLine)
    else
      left = Lib.sgn(distance) * lockVisionCfg.slideWidth
      forward = lockVisionCfg.slideWidth * math.tan(math.rad(90 - lockVisionCfg.slideAngle))
    end
  elseif slideDir ~= 0 then
    left = Lib.sgn(slideDir) * lockVisionCfg.slideWidth
    setNearRunLine(player, left, nowPos.z, nowPos.x)
  elseif lockVisionCfg and lockVisionCfg.open then
    left = 0
  end
  return left, forward
end

local inSprint

local function checkSprintEvent(movingStyle, isMoving, forward, left)
  if not World.cfg.enableSprintEvent then
    return
  end
  local bmGameSettings = bm.gameSettings
  local fov = bmGameSettings:getFovSetting()
  if not inSprint and isMoving and movingStyle == 2 then
    Lib.emitEvent(Event.BEGIN_SPRINT, forward, left)
    inSprint = true
  elseif inSprint and (not isMoving or movingStyle ~= 2) then
    Lib.emitEvent(Event.END_SPRINT, forward, left)
    inSprint = nil
  end
end

function PlayerControl.checkSprint()
  return Me.moveState == "sprint"
end

function PlayerControl.checkWalk()
  return Me.moveState == "walk"
end

function PlayerControl.checkSneak()
  return bm:isKeyPressing("key.sneak")
end

function PlayerControl.checkJump()
  if Me:isInFloatState() then
    return false
  end
  return bm:isKeyPressing("key.jump")
end

local inertanceEnabled = false
local inertanceDuration = 10
local inertanceEndTime = 0
local inertanceForward = 0
local inertanceLeft = 0

function PlayerControl.enableInertance(enable, duration)
  inertanceEnabled = enable
  inertanceDuration = duration or 10
end

function PlayerControl.updateInertance(forward, left)
  if not inertanceEnabled then
    return
  end
  local now = World.Now()
  inertanceEndTime = now + inertanceDuration
  inertanceForward = forward
  inertanceLeft = left
end

function PlayerControl.checkInertance()
  return inertanceEnabled and World.Now() < inertanceEndTime and (inertanceForward ~= 0 or inertanceLeft ~= 0)
end

local sceneManager = World.CurWorld:getSceneManager()
local SkateControl = T(Lib, "SkateControl")
local FlightVehicleControl = T(Lib, "FlightVehicleControl")
local worldCfgViewBobbing = World.cfg.viewBobbing

function PlayerControl.UpdateControl(frame_time)
  local player = Player.CurPlayer
  local control = bm:control()
  if player.disableControl then
    control:setMove(0, 0)
    return
  end
  FrontSight.checkHit(player)
  local movingStyle = 0
  if PlayerControl.checkSneak() then
    movingStyle = 1
  elseif PlayerControl.checkSprint() then
    movingStyle = 2
  elseif PlayerControl.checkWalk() then
    movingStyle = 3
  end
  if World.cfg.bobbingCameraEffect == false then
    bm.gameSettings.bobbingCameraEffect = false
  end
  if player and player.movingStyle ~= movingStyle then
    player:setValue("movingStyle", movingStyle)
    bm.gameSettings.viewBobbing = worldCfgViewBobbing or false
  end
  if isKeyNewDown("key.f5") then
    bm:switchPersonView()
    PlayerControl.UpdatePersonView()
  end
  if isKeyNewDown("key.f1") and World.gameCfg.gm then
    Lib.emitEvent(Event.EVENT_SHOW_GMBOARD)
  end
  if isKeyNewDown("key.f11") and World.gameCfg.debug then
    if movingStyle == 0 then
      Game.RunTelnet(1, debugport.port)
    else
      Game.RunTelnet(2, debugport.serverPort)
    end
  end
  if (isKeyNewDown("key.exit") or isKeyNewDown("key.android.back")) and (not UI.guideMask or not next(UI.guideMask)) then
    Lib.emitEvent(Event.EVENT_BACK_KEY_DOWN)
  end
  if isKeyNewDown("key.chat") then
    Lib.emitEvent(Event.EVENT_CHAT_KEY_DOWN)
  end
  if isKeyNewDown("key.pack") and not World.cfg.disableKeyPack then
    Lib.emitEvent(Event.EVENT_MAIN_ROLE, true)
  end
  if isKeyNewDown("key.mouse_state") then
    Lib.emitEvent(Event.EVENT_CHANGE_MOUSE_STATE)
  end
  local poleForward = bm.gameSettings.poleForward
  local poleStrafe = bm.gameSettings.poleStrafe
  local forward = axisValue("key.forward", "key.back") + poleForward
  if bm:isKeyPressing("key.top.left") or bm:isKeyPressing("key.top.right") then
    forward = forward + 1
  end
  if bm:isKeyPressing("key.bottom.left") or bm:isKeyPressing("key.bottom.right") then
    forward = forward - 1
  end
  if player and player:getValue("isKeepAhead") then
    forward = 1
  end
  local left = 0.0
  if not World.cfg.moveOneAxisOnly or not (0 < math.abs(forward)) then
    left = axisValue("key.left", "key.right") + poleStrafe + axisValue("key.top.left", "key.top.right") + axisValue("key.bottom.left", "key.bottom.right")
  end
  if not player then
    if forward ~= 0 or left ~= 0 then
      local sinYaw = math.sin(math.rad(bm:getViewerYaw()))
      local cosYaw = math.cos(math.rad(bm:getViewerYaw()))
      local MOVE_SPEED = 0.2
      local pos = Lib.tov3(bm:getViewerPos())
      pos.x = pos.x + (left * cosYaw - forward * sinYaw) * MOVE_SPEED
      pos.z = pos.z + (left * sinYaw + forward * cosYaw) * MOVE_SPEED
      bm:setViewerPos(pos, bm:getViewerYaw(), bm:getViewerPitch(), 1)
    end
    return
  end
  CheckSlideScreen(player, left, forward)
  left, forward = doHorizonSlide(player, left, forward)
  checkRoll(player)
  forward = isRolling and 1 or forward
  local isSkateMode = Plugins.CallTargetPluginFunc("skate", "IS_SKATE_MODE")
  local control = bm:control()
  if World.CurWorld.isEditor then
    PlayerControl.do_move()
  elseif player.cameraEditModeCtrl then
    PlayerControl.do_edit_move()
  else
    local controlEntity = control.entity
    local cfg = controlEntity:cfg()
    if Me.sitDisableControl then
      control:setMove(0, 0)
    elseif cfg.isAircraft and controlEntity.onGround then
      control:setMove(0, 0)
    elseif isSkateMode then
      local vAxisValue = axisValue("key.forward", "key.back")
      local hAxisValue = axisValue("key.left", "key.right")
      SkateControl:setControl(poleForward, poleStrafe, vAxisValue, hAxisValue)
      local jumpKeyOpt = isKeyUpDown("key.jump")
      if jumpKeyOpt == 1 then
        Lib.emitEvent(Event.SET_JUMP_CHARGE, true)
      elseif jumpKeyOpt == 2 then
        Lib.emitEvent(Event.SET_JUMP_CHARGE, false)
      end
    elseif Me.inFlightVehicleControl then
      local vAxisValue = axisValue("key.forward", "key.back")
      local hAxisValue = axisValue("key.left", "key.right")
      FlightVehicleControl:setControl(poleForward, poleStrafe, vAxisValue, hAxisValue)
    else
      control:setMove(forward, left)
      if forward ~= 0 or left ~= 0 then
        PlayerControl.updateInertance(forward, left)
      end
    end
  end
  if PlayerControl.checkInertance() then
    control:setMove(inertanceForward, inertanceLeft)
  end
  control:setBraking(bm:isKeyPressing("key.brake"))
  if not player:isSwimming() and (forward ~= 0 or left ~= 0) and 0 < player.curHp and 0 < player.rideOnId and 0 < player.rideOnId or player.onGround and player.isMoving then
    FrontSight.Diffuse(nil, 2)
  end
  PlayerControl.checkJump_impl(control, player)
  checkSprintEvent(movingStyle, player.isMoving, forward, left)
  if isKeyNewDown("key.jump") and not Me:isInFloatState() then
    local name = player:data("skill").jumpSkill
    if name then
      player:setForceClimbMode(false, 0, 0)
      Skill.Cast(name)
      Me:sendPacket({
        pid = "ClientDoJumpTrigger"
      })
    end
  end
  local act = bm:getUserAction().action
  if not checkNewState("act", act) and act ~= "CLICK" and act ~= "TOUCH_BEGIN" then
    return
  end
  local hit = bm:getHitInfo()
  local packet = {}
  if hit.type == "ENTITY" then
    local entity = hit.entity
    packet.targetID = entity.objID
    packet.targetPos = entity:getPosition()
  elseif hit.type == "PART" then
    local part = hit.part
    if part and part:isValid() then
      packet.partID = part:getInstanceID()
    end
  elseif hit.type == "BLOCK" then
    packet.blockPos = hit.blockPos
    packet.sideNormal = hit.sideNormal
    if packet.sideNormal then
      packet.isUp = packet.sideNormal.y == 0.0 and hit.worldPos.y - hit.blockPos.y > 0.5 or packet.sideNormal.y == -1.0
    end
  end
  if act == "CLICK" then
    PlayerControl.processClick(hit, packet)
  elseif act == "TOUCH_BEGIN" then
    packet.touchAtScene = true
    Skill.TouchBegin(packet)
  elseif act == "TOUCH_END" then
    Skill.TouchEnd(packet)
  end
end

function PlayerControl.processClick(hit, packet)
  if not hit then
    return
  end
  Lib.emitEvent(Event.EVENT_CLICK_SCREEN, Blockman.Instance():getMousePos())
  if UI:isOpen("playerInteractPop") then
    UI:getWnd("playerInteractPop"):onShow(false)
  end
  if hit.type == "PART" and packet.partID then
    local PartManagerHelper = T(Lib, "PartManagerHelper")
    if not PartManagerHelper:IsCanShowInteractPopForMe(packet.partID) then
      return
    end
    if Me:isCameraMode() then
      return false
    end
  end
  packet.targetPos = hit.worldPos
  Skill.ClickCast(packet)
  if hit.type == "BLOCK" then
    PlayerControl.checkClickChangeBlock(packet.blockPos)
  elseif hit.type == "ENTITY" then
    Me:processClickEntity(hit, packet)
  elseif hit.type == "PART" and packet.partID then
    local part = Instance.getByInstanceId(packet.partID)
    if part and part:isValid() then
      Trigger.CheckTriggers(part._cfg, "PART_CLICKED", {
        part1 = part,
        from = Me
      })
    end
  end
end

function PlayerControl.checkJump_impl(control, player)
  checkJump(control, player)
end

function PlayerControl.UpdatePersonView()
  local view = bm:getCurrPersonView()
  local entity = bm:viewEntity()
  if view == 0 and entity and entity:cfg().canFirstView == false then
    bm:switchPersonView()
  end
end

function PlayerControl.do_edit_move()
  local player = Player.CurPlayer
  if not player then
    return
  end
  local nextPos
  local poleForwar = bm.gameSettings.poleForward
  local poleStrafe = bm.gameSettings.poleStrafe
  local forward = axisValue("key.forward", "key.back") + poleForwar
  if bm:isKeyPressing("key.top.left") or bm:isKeyPressing("key.top.right") then
    forward = forward + 1
  end
  local left = axisValue("key.left", "key.right") + axisValue("key.top.left", "key.top.right") + poleStrafe
  local up = axisValue("key.jump", "key.sneak")
  nextPos = player:getPosition()
  if forward == 0.0 and left == 0.0 and up == 0.0 then
    player.isMoving = false
    return
  end
  local MOVE_SPEED = player.camaraModeSpd or 0.2
  local rotationYaw = math.rad(player:getRotationYaw())
  local f1 = math.sin(rotationYaw)
  local f2 = math.cos(rotationYaw)
  nextPos.x = nextPos.x + (left * f2 - forward * f1) * MOVE_SPEED
  nextPos.z = nextPos.z + (forward * f2 + left * f1) * MOVE_SPEED
  nextPos.y = nextPos.y + up * MOVE_SPEED
  player:setMove(0, nextPos, player:getRotationYaw(), player:getRotationPitch(), 1, 0)
  player.isMoving = true
end

function PlayerControl.do_move()
  local player = Player.CurPlayer
  if not player then
    Lib.logDebug("do moveeeeeeeeeeeeeeeeeeeeeeeeeeee error no player")
    return
  end
  Lib.logDebug("do moveeeeeeeeeeeeeeeeeeeeeeeeeeee start", player.objID, player.platformUserId)
  local nextPos
  local poleForwar = bm.gameSettings.poleForward
  local poleStrafe = bm.gameSettings.poleStrafe
  local forward = axisValue("key.forward", "key.back") + poleForwar
  if bm:isKeyPressing("key.top.left") or bm:isKeyPressing("key.top.right") then
    forward = forward + 1
  end
  local left = axisValue("key.left", "key.right") + axisValue("key.top.left", "key.top.right") + poleStrafe
  local up = axisValue("key.rise", "key.descend")
  nextPos = player:getPosition()
  if forward == 0.0 and left == 0.0 and up == 0.0 then
    player.isMoving = false
    Lib.logDebug("do moveeeeeeeeeeeeeeeeeeeeeeeeeeee end no moving")
    return
  end
  local rotationYaw = math.rad(player:getRotationYaw())
  local rotationPitch = math.rad(player:getRotationPitch())
  local f1 = math.sin(rotationYaw)
  local f2 = math.cos(rotationYaw)
  local f3 = math.sin(rotationPitch)
  local MOVE_SPEED = 0.2
  nextPos.x = nextPos.x + (left * f2 - forward * f1) * MOVE_SPEED
  nextPos.z = nextPos.z + (forward * f2 + left * f1) * MOVE_SPEED
  if up ~= 0.0 then
    nextPos.y = nextPos.y + (up - forward * f3) * MOVE_SPEED
  end
  player:setMove(0, nextPos, player:getRotationYaw(), player:getRotationPitch(), 1, 0)
  player.isMoving = true
  Lib.logDebug("do moveeeeeeeeeeeeeeeeeeeeeeeeeeee end success")
end

function PlayerControl.OnRebirth()
  nextLine = nil
end

function PlayerControl.OnTouchBlock(player, pos)
  if lockVisionCfg.collideBack then
    local cosYaw = speCosVal[math.modf(-player:getRotationYaw() % 360 / 90) + 1]
    local dx = cosYaw
    local pPos = player:getPosition()
    if math.floor(pPos.x) + dx == pos.x or math.floor(pPos.x) - dx == pos.x then
      setNearRunLine(player, 0, math.floor(pPos.z) + 0.5, math.floor(pPos.x) + 0.5)
    end
  end
end

local pauseWhenOpenCfg = World.cfg.pauseWhenOpen

function PlayerControl.CheckUIOpenPauseGame(name, state)
  if pauseWhenOpenCfg and pauseWhenOpenCfg[name] and World.CurWorld:isGamePause() == not state then
    local newMainUI = UI:getWnd("newmainuinavigation", true)
    if newMainUI and newMainUI.pause and newMainUI.pause.show then
      Lib.emitEvent(Event.EVENT_PAUSE_BY_CLIENT)
    end
  end
end

function PlayerControl.UpdateControlInfo(target)
  local control = bm:control()
  local player = Player.CurPlayer
  if target and not player:isCameraMode() then
    local pos = target:cfg().ridePos[player.rideOnIdx + 1]
    control:attach(target)
    control.enable = pos.ctrl
    bm:setViewEntity(pos.view and target or player)
  else
    control:attach(player)
    control.enable = true
    bm:setViewEntity(player)
  end
end

function EntityClientMainPlayer:isForbidRotate()
  return true
end

RETURN()
