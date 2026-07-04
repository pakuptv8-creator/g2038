local Player = _ENV.Player
local LuaTimer = T(Lib, "LuaTimer")

function Player:checkChatPlayerInfoIsOpen()
  return false
end

function Player:sendNormalChatBuriedPoint(chatTabType, msg, time, emoji)
  Me:addOneChatCount()
end

function Player:sendPrivateChatBuriedPoint(userId, msg, emoji)
  Me:addOneChatCount()
end

function Player:cameraModeClose()
  if not self:isCameraMode() then
    return
  end
  Me:setFlyMode(false)
  if not self.showFunc then
    return
  end
  self.showFunc()
  self.showFuncId = nil
  Lib.emitEvent(Event.EVENT_SWITCH_INTERACTION_WND, true)
  self:setCameraMode(false)
  self:updateMainPlayerRideOn()
  Me:refreshBoundBoxWithShapeScale()
  if UI:isOpen("takePhotos") then
    UI:closeWnd("takePhotos")
  end
end

function Player:onInInteractionRangesChanged(objID, isCheckIn)
  local ranges = Me:data("inInteractionRanges")
  local target = World.CurWorld:getEntity(objID)
  if isCheckIn then
    if target and target:isValid() then
      target.isShowInteractionUi = true
      ranges[objID] = true
      Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_CHECKIN, objID, true)
    end
  else
    if target and target:isValid() then
      target.isShowInteractionUi = false
    end
    ranges[objID] = nil
    Lib.emitEvent(Event.EVENT_OBJECT_INTERACTION_CHECKIN, objID, false)
  end
  self:checkSortInteraction()
end

local Cinemachine = T(Lib, "LuaCinemachine")
local isPetCameraIn = false
local cameraMoving = false
local oldCinemachine = ""

function Player:petCameraIn(objID, duration)
  do return end
  if cameraMoving or isPetCameraIn or self.isFirstPersonViewMode then
    return
  end
  local pet = World.CurWorld:getObject(objID)
  if not pet then
    return
  end
  local mainCamera = CameraManager.Instance():getMainCamera()
  local playerPos = Me:getPosition()
  local cameraPos = mainCamera:getPosition()
  local focusPos = Lib.v3(playerPos.x, Me:prop("eyeHeight"), playerPos.z)
  if Cinemachine:isValid() then
    oldCinemachine = Cinemachine:getLiveCameraName()
  end
  Cinemachine:enable(true)
  Cinemachine:createCamera("InteractPlayerCam", {
    follow = Me,
    lookAt = Me,
    body = {
      type = "HardLockToTarget",
      offset = cameraPos - playerPos,
      localspace = false
    },
    aim = {
      type = "HardLookAt",
      offset = {
        0,
        focusPos.y,
        0
      }
    }
  })
  Cinemachine:blendTo("InteractPlayerCam", 0)
  local desiredDegree = World.cfg.petCameraAngle
  local desiredDistance = World.cfg.petCameraDistance
  local mainCameraDir = cameraPos - focusPos
  local y = math.tan(math.rad(desiredDegree)) * (Lib.v3(cameraPos.x, focusPos.y, cameraPos.z) - focusPos):len()
  local pos = Lib.v3(cameraPos.x, focusPos.y + y, cameraPos.z)
  local petDir = (pos - focusPos):normalize()
  local petCameraPos = pet:getPosition() + petDir * desiredDistance
  Cinemachine:createCamera("InteractPetCam", {
    follow = pet,
    lookAt = pet,
    body = {
      type = "HardLockToPosition",
      position = petCameraPos
    },
    aim = {
      type = "HardLookAt",
      offset = {
        0,
        World.cfg.petCameraFocusOffsetY,
        0
      }
    }
  })
  cameraMoving = true
  Me.disableControl = true
  UI:HideAllWindowsExcept({})
  Cinemachine:blendTo("InteractPetCam", duration)
  LuaTimer:scheduleTimer(function()
    cameraMoving = false
    Me.disableControl = false
    UI:HideAllWindowsExcept({interactionContainer = true, interactionClickWnd = true})
  end, duration * 1000 + 10, 1)
  isPetCameraIn = true
  if self.petCameraTimer then
    LuaTimer:cancel(self.petCameraTimer)
  end
  self.lastWatchPetPos = Me:getPosition()
  self.petCameraTimer = LuaTimer:schedule(function()
    if isPetCameraIn and (self.lastWatchPetPos - Me:getPosition()):lenSqr() > 0.1 then
      Me:petCameraOut(0.5)
    end
  end, 0, 300)
end

function Player:petCameraOut(duration)
  do return end
  if cameraMoving or not isPetCameraIn then
    return
  end
  isPetCameraIn = false
  cameraMoving = true
  Me.disableControl = true
  UI:HideAllWindowsExcept({})
  
  local function callback()
    if cameraMoving then
      if oldCinemachine == "" then
        Cinemachine:enable(false)
      else
        Cinemachine:blendTo(oldCinemachine, 0)
      end
      cameraMoving = false
      Me.disableControl = false
    end
  end
  
  Cinemachine:blendTo("InteractPlayerCam", duration, callback)
  LuaTimer:scheduleTimer(function()
    callback()
    UI:RestoreAllWindows()
  end, duration * 1000 + 100, 1)
  if self.petCameraTimer then
    LuaTimer:cancel(self.petCameraTimer)
    self.petCameraTimer = nil
  end
end

Lib.subscribeEvent(Event.EVENT_SCENE_TOUCH_BEGIN, function()
  if not Me.disableControl and isPetCameraIn then
    Me:petCameraOut(0.5)
  end
end)
Lib.subscribeEvent(Event.EVENT_FAKE_FPV_CHANGED, function(isFirstPersonViewMode)
  Me.isFirstPersonViewMode = isFirstPersonViewMode
end)
