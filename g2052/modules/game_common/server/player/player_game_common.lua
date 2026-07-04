local LuaTimer = T(Lib, "LuaTimer")
local EmergencyHelper = T(Lib, "EmergencyHelper")
local InteractEventConfig = T(Config, "InteractEventConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PartManagerShow = T(Lib, "PartManagerShow")
local PartInteractHelper = T(Lib, "PartInteractHelper")
local PartFurnitureHelper = T(Lib, "PartFurnitureHelper")
local DyeingStatusMgr = T(Lib, "DyeingStatusMgr")
local CarConfig = T(Config, "CarConfig")
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local ChatShortLangConfig = T(Config, "ChatShortLangConfig")
local Player = _ENV.Player

function Player:onEnterPortal(type, target, params)
  if params and params[1] ~= "" then
    local info = Lib.splitString(params[1], "#") or {}
    local mapName = info[1]
    if not mapName then
      return
    end
    local pos = {
      x = tonumber(info[2] or 0),
      y = tonumber(info[3] or 0),
      z = tonumber(info[4] or 0)
    }
    local ry = tonumber(info[5] or 0)
    self:setMapPos(mapName, pos, ry, nil, true)
  end
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
      target:setRotation(track[count].newRotation)
      target:setPosition(initPos + track[count].offsetPos)
    end
    if count <= 1 then
      target:setRotation(rotation)
      target:setPosition(initPos)
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
      target:setRotation(track[count].newRotation)
      target:setPosition(initPos + track[count].offsetPos)
    end
    if count == time then
      target.partRotateTimer = nil
      target.resultInfo = nil
      finishCB()
      return
    end
    return true
  end)
  target.resultInfo = {
    pos = initPos + track[#track].offsetPos,
    rotation = track[#track].newRotation
  }
end

local function acceleratedChangeRotateState(target, info)
  local pos = info.pos
  local rotation = info.rotation
  if pos and rotation then
    target:setRotation(rotation)
    target:setPosition(pos)
  end
end

local function disposeRegionTypeTrigger(type, target)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN or type == Define.PART_INTERACT_TYPE.TOUCH_END then
    local info = {}
    if target.partRotateTimer then
      info = target.resultInfo
      target.partRotateTimer()
      target.partRotateTimer = nil
    elseif target.partRestoreTimer then
      info = target.initialInfo
      target.partRestoreTimer()
      target.partRestoreTimer = nil
    end
    if target.restoreRotateTimer then
      target.restoreRotateTimer()
      target.restoreRotateTimer = nil
    end
    acceleratedChangeRotateState(target, info)
    return true
  end
  return false
end

function Player:checkOperationPartLocalRotate(typ, target, params)
  if tonumber(target.networkOwner) ~= self:getRaknetID() then
    return
  end
  self:sendPacket({
    pid = "operationPartLocalRotate",
    type = typ,
    targetInsId = target:getInstanceID(),
    params = params
  })
end

function Player:showShopCarNameEditor(typ, target, params)
  if tonumber(target.networkOwner) ~= self:getRaknetID() then
    return
  end
  self:sendPacket({
    pid = "showShopCarNameEditor",
    type = typ,
    targetInsId = target:getInstanceID(),
    params = params
  })
end

function Player:operationPartRotate(type, target, params)
  if target.isNeedPlayerPool and target.initialInfo then
    local pos = target:getPosition()
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN and pos ~= target.initialInfo.pos or type == Define.PART_INTERACT_TYPE.TOUCH_END and pos == target.initialInfo.pos then
      return
    end
  end
  if (target.partRotateTimer or target.partRestoreTimer or target.restoreRotateTimer) and not disposeRegionTypeTrigger(type, target) then
    return
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
      return
    end
    local initPos = target:getPosition()
    local rotation = target:getRotation()
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
end

local function partSmoothMovement(target, isRestore)
  if not target.operationMoveInfo then
    return
  end
  local distance = target.operationMoveInfo.distance
  local time = target.operationMoveInfo.time
  local scene = target:getScene()
  if not scene then
    return
  end
  local nodes = target.operationMoveInfo.nodes
  local offset = distance / time
  if isRestore then
    offset = offset * -1
  end
  local count = 0
  target.partSmoothMovementTimer = World.Timer(1, function()
    for _, v in pairs(nodes or {}) do
      if not v or not v:isValid() then
        return
      end
    end
    count = count + 1
    scene.move(nodes, offset, true)
    if count == time then
      target.partSmoothMovementTimer = nil
      if isRestore then
        target.operationMoveInfo = nil
      end
      return
    end
    return true
  end)
  target.initState = isRestore
end

local function acceleratedChangeMoveState(target, info, isNew)
  for id, v in pairs(info or {}) do
    local part = Instance.getByInstanceId(id)
    if part and part:isValid() then
      if isNew then
        part:setPosition(v.newPos)
      else
        part:setPosition(v.pos)
      end
    end
  end
  target.operationMoveInfo = nil
end

local function moveDisposeRegionTypeTrigger(type, target)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN or type == Define.PART_INTERACT_TYPE.TOUCH_END then
    local info = target.moveInitialInfo
    local isNew = target.initState
    if target.partSmoothMovementTimer then
      target.partSmoothMovementTimer()
      target.partSmoothMovementTimer = nil
    end
    if target.restoreMoveTimer then
      target.restoreMoveTimer()
      target.restoreMoveTimer = nil
    end
    if info then
      acceleratedChangeMoveState(target, info, isNew)
    end
    return true
  end
  return false
end

function Player:operationPartMove(type, target, params)
  if (target.partSmoothMovementTimer or target.restoreMoveTimer) and not moveDisposeRegionTypeTrigger(type, target) then
    return
  end
  if params then
    local nodes = {target}
    local scene = target:getScene()
    local parent
    if params[4] ~= "" then
      nodes = {}
      parent = target:getParent()
      Lib.getInstanceAllChild(parent or target, nodes, Define.ABILITY.AABB, nil, true)
    end
    if params[2] == "" and target.operationMoveInfo then
      partSmoothMovement(target, true)
      if target.restoreMoveTimer then
        target.restoreMoveTimer()
        target.restoreMoveTimer = nil
      end
      return
    end
    local rotation = target:getRotation()
    local distance = Lib.createV3ByString(params[1])
    distance = Lib.correctMoveDistance(rotation, distance)
    local time = tonumber(params[5]) or 1
    target.operationMoveInfo = {
      distance = distance,
      time = time,
      nodes = nodes
    }
    if not target.moveInitialInfo then
      target.moveInitialInfo = {}
      for _, v in pairs(nodes) do
        local id = v:getInstanceID()
        if id then
          target.moveInitialInfo[id] = {
            pos = v:getPosition(),
            newPos = v:getPosition() + distance
          }
        end
      end
    end
    partSmoothMovement(target)
    local restoreTime = tonumber(params[3])
    if restoreTime then
      target.restoreMoveTimer = World.Timer(restoreTime + time, function()
        if target.operationMoveInfo then
          partSmoothMovement(target, true)
        end
        target.restoreMoveTimer = nil
      end)
    end
  end
end

local function dealingWithOfflinePlayers(players)
  for id, _ in pairs(players) do
    local player = Game.GetPlayerByUserId(id)
    if not player or not player:isValid() then
      players[id] = nil
    end
  end
end

function Player:multiplayerTriggerManagement(type, target)
  if not target.interactionPlayerUserIds then
    target.interactionPlayerUserIds = {}
  end
  dealingWithOfflinePlayers(target.interactionPlayerUserIds)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    target.interactionPlayerUserIds[self.platformUserId] = true
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END and target.interactionPlayerUserIds then
    target.interactionPlayerUserIds[self.platformUserId] = nil
  end
  if target.interactionPlayerUserIds then
    local playerCount = 0
    for i, v in pairs(target.interactionPlayerUserIds or {}) do
      playerCount = playerCount + 1
    end
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
      local canOpen = 0 < playerCount and not target.hasTriggered
      return canOpen
    elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
      local canClose = playerCount == 0 and target.hasTriggered
      return canClose
    end
  end
  return true
end

local function isNeedPlayerPool(target)
  local prop = InteractEventConfig:getCfgById(target.name)
  local needPlayerPool = false
  if prop then
    local triggersData = prop.triggersData or {}
    local monitorSTouch = false
    local monitorETouch = false
    for i, v in pairs(triggersData) do
      if v == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
        monitorSTouch = true
      elseif v == Define.PART_INTERACT_TYPE.TOUCH_END then
        monitorETouch = true
      end
    end
    if monitorSTouch and monitorETouch then
      needPlayerPool = true
    end
  end
  return needPlayerPool
end

local function changeSwitchMash(target, initMash, triggerMash, hasTriggered)
  if initMash ~= "" and not hasTriggered then
    target:setProperty("mesh", initMash)
  elseif triggerMash ~= "" and hasTriggered then
    target:setProperty("mesh", triggerMash)
  end
end

function Player:checkMultiplayerTrigger(type, target)
  if isNeedPlayerPool(target) and not self:multiplayerTriggerManagement(type, target) then
    return false
  end
  return true
end

local function changeSwitchState(type, target)
  if target.hasTriggered then
    target.hasTriggered = false
  else
    target.hasTriggered = true
  end
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    target.hasTriggered = true
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    target.hasTriggered = false
  end
end

function Player:onTriggerAssociated(type, target, params, isBreak)
  if params then
    if params[1] ~= "" then
      changeSwitchState(type, target)
      local PartManagerHelper = T(Lib, "PartManagerHelper")
      local targets = Lib.splitString(params[1], "#") or {}
      local parent = target
      local tier = tonumber(params[8]) or 1
      for i = 1, tier do
        if parent and parent:isValid() and parent.getParent then
          local node = parent:getParent()
          if node then
            parent = node
          else
            break
          end
        end
      end
      local nodes = {}
      if not target.targetList then
        for _, name in pairs(targets) do
          Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, name)
        end
        PartManagerShow:updateParentChildList(parent, nodes)
        target.targetList = nodes
      else
        nodes = target.targetList
      end
      local partId = target:getInstanceID()
      local childList = {}
      local allNode = {}
      table.insert(allNode, partId)
      for _, part in pairs(nodes) do
        if part and part:isValid() then
          table.insert(childList, part:getInstanceID())
          table.insert(allNode, part:getInstanceID())
        end
      end
      if params[7] and tonumber(params[7]) == 1 then
        PartManagerHelper:updatePartEntityInfo(target, 1, self.objID, isBreak)
      end
      PartManagerHelper:updateGroupPartState(partId, childList)
      local openTrigger = tonumber(params[2]) and tonumber(params[2]) or Define.PART_INTERACT_TYPE.CLICKED
      local closeTrigger = tonumber(params[3]) and tonumber(params[3]) or Define.PART_INTERACT_TYPE.CLICKED
      local isNeedPlayerPool = isNeedPlayerPool(target)
      for _, part in pairs(nodes) do
        if part and part:isValid() then
          local type = target.hasTriggered and openTrigger or closeTrigger
          part.isNeedPlayerPool = isNeedPlayerPool
          Plugins.CallTargetPluginFunc("interact", "tryPartInteract", type, part, self, true, isBreak)
        end
      end
    end
    changeSwitchMash(target, params[4], params[5], target.hasTriggered)
    if params[6] ~= "" and self[params[6]] then
      self[params[6]](self, target)
    end
  end
end

function Player:onLightOnFire(type, target, params)
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  PartManagerHelper:updateFireLightOnPart(type, self, target, params)
end

function Player:operatePartInteractLock(type, target, params)
  local canOperate = true
  local nodes = {}
  local kind = {}
  local targetId = target:getInstanceID()
  if params[1] ~= "" then
    local targets = Lib.splitString(params[1], "#") or {}
    local parent = target:getParent()
    if not target.targetList then
      for _, name in pairs(targets) do
        Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, name)
      end
      target.targetList = nodes
    else
      nodes = target.targetList
    end
    if not target.kindList then
      Lib.getInstanceAllChild(parent, kind, Define.ABILITY.AABB, target.name)
      target.kindList = kind
    else
      kind = target.kindList
    end
    if params[2] == "house" then
      canOperate = HouseManager:verifyingOperationRights(self.platformUserId, target, "inLock")
    end
  else
    table.insert(nodes, target)
  end
  if canOperate then
    for _, part in pairs(nodes) do
      self:addPartInteractLock(type, part, params)
    end
    target.hasTriggered = not target.hasTriggered
  end
  for _, v in pairs(kind) do
    if v:getInstanceID() ~= targetId then
      v.hasTriggered = target.hasTriggered
    end
    changeSwitchMash(v, params[3], params[4], target.hasTriggered)
  end
end

function Player:addPartInteractLock(type, target, params)
  target.isInteractLock = not target.isInteractLock
  if target.isInteractLock then
    local rotateInfo = target.initialInfo
    local moveInfo = target.moveInitialInfo
    if target.partRotateTimer then
      target.partRotateTimer()
      target.partRotateTimer = nil
      target.resultInfo = nil
    end
    if target.partRestoreTimer then
      target.partRestoreTimer()
      target.partRestoreTimer = nil
    end
    if target.restoreRotateTimer then
      target.restoreRotateTimer()
      target.restoreRotateTimer = nil
    end
    if target.partSmoothMovementTimer then
      target.partSmoothMovementTimer()
      target.partSmoothMovementTimer = nil
    end
    if target.restoreMoveTimer then
      target.restoreMoveTimer()
      target.restoreMoveTimer = nil
    end
    if rotateInfo then
      acceleratedChangeRotateState(target, rotateInfo)
    end
    if moveInfo then
      acceleratedChangeMoveState(target, moveInfo)
    end
    target.hasTriggered = nil
    target.operationRotateInfo = nil
  end
end

function Player:deltaEntityProp(key, value, isNeedRecover)
  if isNeedRecover then
    self:recoverEntityProp(key)
  end
  self:deltaEntityProp(key, value)
  self:sendPacket({
    pid = "deltaEntityProp",
    key = key,
    value = value,
    isNeedRecover = isNeedRecover
  })
end

function Player:stopInteractiveSound()
  local sid = self:getValue("curInteractiveSound")
  if sid ~= "" then
    self:setCurInteractiveSound("")
  end
end

function Player:onDressUp(type, target, params)
  local dressIds
  local dressId = tonumber(params[1])
  if dressId then
    dressIds = {dressId}
  else
    local randomParts = Lib.splitString(params[2], "#", true)
    local items = AppearanceConfig:randomItemsByIndexes(randomParts)
    dressIds = items
  end
  for _, dressId in ipairs(dressIds) do
    local dressConf = AppearanceConfig:getCfgById(dressId)
    if dressConf then
      local skinData = dressConf.parts
      for partName, _ in pairs(skinData) do
        DyeingStatusMgr:delStatus(self, partName)
      end
      local conflictParts = dressConf.conflictParts or {}
      local shapeInfo = self:getShapeInfo()
      local changeSkinData, shapeInfoRemove = self:parseNewSkinData(Lib.copyTable1(skinData))
      self:changeSkin(changeSkinData)
      for i, v in pairs(skinData) do
        shapeInfo[i] = v
      end
      if shapeInfoRemove then
        for master, _ in pairs(shapeInfoRemove) do
          shapeInfo[master] = nil
        end
      end
      if next(conflictParts) ~= nil then
        for _, master in pairs(conflictParts) do
          shapeInfo[master] = nil
        end
      end
      self:setValue(Define.APPEARANCE_VAR_KEY.ShapeInfo, shapeInfo)
    end
  end
end

function Player:operationTelevision(type, target, params)
  if target.className ~= "Part" then
    return
  end
  local screen = Lib.getOneDecalTypeChildren(target)
  if not screen or not screen:isValid() then
    return
  end
  target.screenId = screen:getInstanceID()
  screen.channels = Lib.splitString(params[1], "#") or {}
  local btnNames = Lib.splitString(params[2], "#") or {}
  if target.screenId then
    if target.inTheOpen then
      target.inTheOpen = false
      self:exitWatchTelevision(target.screenId)
    else
      self:openWatchTelevision(target.screenId, true)
      target.inTheOpen = true
    end
    PartInteractHelper.showTVButton(target, btnNames, target.inTheOpen)
  end
end

function Player:operatingInTaiwan(type, target, params)
  if params[1] == "" then
    return
  end
  local parent = target:getParent()
  local nodes = {}
  if parent and parent:isValid() then
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, nil, true)
  end
  local vtPart
  for _, v in pairs(nodes) do
    if v.inTheOpen then
      vtPart = v
      break
    end
  end
  if vtPart and vtPart.screenId then
    self:switchTelevisionChannels(vtPart.screenId, params[1] == "1", params[1] == "3")
  end
end

function Player:onWatchTelevision(type, target, params)
  if target.className ~= "Part" then
    return
  end
  local screen = Lib.getOneDecalTypeChildren(target)
  if not screen or not screen:isValid() then
    return
  end
  local id = screen:getInstanceID()
  screen.channels = Lib.splitString(params[1], "#") or {}
  if id then
    self:openWatchTelevision(id)
    self:updateCurWatchTelevision(id)
  end
end

function Player:onTogglesDecalContent(type, target, params)
  if target.className ~= "Part" then
    return
  end
  local screen = Lib.getOneDecalTypeChildren(target)
  if not screen or not screen:isValid() then
    return
  end
  local channels = Lib.splitString(params[1], "#") or {}
  if not target.curDecalIndex then
    target.curDecalIndex = tonumber(params[2]) or 0
  else
    target.curDecalIndex = target.curDecalIndex + 1
    if target.curDecalIndex > 0 and not channels[target.curDecalIndex] then
      target.curDecalIndex = 1
    end
  end
  local texture = channels[target.curDecalIndex] or ""
  screen:setTexture(texture)
end

function Player:exitWatchTelevision(id)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() then
    local img = ""
    if screen.defaultImg then
      img = screen.defaultImg
    end
    screen:setTexture(img)
  end
end

function Player:openWatchTelevision(id, isRandom)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() and screen.className == "Decal" and screen.channels then
    if not screen.defaultImg then
      screen.defaultImg = screen:getProperty("decalTexture")
    end
    local decalTexture
    local channels = screen.channels
    if isRandom then
      math.randomseed(os.time())
      local index = math.random(1, #channels)
      decalTexture = channels[index]
      screen.curChannel = 1
    elseif screen.curChannel then
      decalTexture = channels[screen.curChannel]
    else
      decalTexture = channels[1]
      screen.curChannel = 1
    end
    screen:setTexture(decalTexture or "")
  end
end

function Player:switchTelevisionChannels(id, add, isRandom)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() and screen.channels then
    local channels = screen.channels
    local curChannel
    if isRandom then
      math.randomseed(os.time())
      curChannel = math.random(1, #screen.curChannel)
    elseif screen.curChannel then
      if add then
        curChannel = screen.curChannel + 1
      else
        curChannel = screen.curChannel - 1
      end
      if not channels[curChannel] then
        if curChannel > #channels then
          curChannel = 1
        elseif curChannel < 1 then
          curChannel = #channels
        end
      end
    else
      curChannel = 1
    end
    local tImg = channels[curChannel] or ""
    screen.curChannel = curChannel
    screen:setTexture(tImg)
  end
end

function Player:triggerPasswordInput(type, target, params)
  Lib.logDebug("triggerPasswordInput------------------")
  local password = tostring(params[1])
  if not password or password == "" then
    return
  end
  local triggerPartName = params[2]
  if not triggerPartName then
    return
  end
  local parent = target:getParent()
  local nodes = {}
  Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, triggerPartName)
  if next(nodes) == nil then
    return
  end
  if nodes[1] then
    local part = nodes[1]
    if not part.operationMoveInfo and not part.operationRotateInfo then
      local partID = part:getInstanceID()
      self:sendPacket({
        pid = "openPasswordInput",
        password = password,
        partID = partID
      })
    end
  end
end

function Player:changePartColor(type, target, params)
  if params[1] ~= "" then
    if target.oldColor then
      target:setProperty("materialColor", target.oldColor)
      target.oldColor = nil
    else
      target.oldColor = target:getProperty("customColor")
      local color = Lib.splitString(params[1], ",")
      if #color == 4 then
        target:setProperty("materialColor", "r:" .. color[1] / 255 .. " g:" .. color[2] / 255 .. " b:" .. color[3] / 255 .. " a:" .. color[4] .. "")
      end
    end
  end
  if params[2] ~= "" then
    if target.oldAlpha then
      target:setProperty("materialAlpha", target.oldAlpha)
      target.oldAlpha = nil
    else
      target.oldAlpha = target:getProperty("materialAlpha")
      target:setProperty("materialAlpha", params[2])
    end
  end
  if params[3] == "1" or params[3] == 1 then
    local bloom = target:getProperty("bloom")
    if bloom == "true" then
      target:setProperty("bloom", "false")
    else
      target:setProperty("bloom", "true")
    end
  end
end

function Player:rideFixedPointVehicle(type, target, params)
  if self.rideOnId > 0 or self:getInteractionPartID() ~= "" or self.rideOnInstanceId or self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
    return
  end
  if self.fixedPointVehicleDepartureTime and os.time() - self.fixedPointVehicleDepartureTime < 2 then
    return
  end
  self.fixedPointVehicleDepartureTime = nil
  if not target.initRotation then
    target.initRotation = target:getRotation()
  end
  local inUseVehicle
  if not target.mount then
    target.mount = Instance.Create("MountPoint")
    target.mount:setName("mp_driver")
    target.mount:setParent(target)
    local rotation = target:getRotation() + Lib.createV3ByString(params[2])
    target.mount.rotation = rotation
    target.mount.pos = Lib.createV3ByString(params[1])
    target.mount.attachInstanceId = target:getInstanceID()
    inUseVehicle = false
  elseif target.mount.mountId == 0 then
    inUseVehicle = false
  else
    inUseVehicle = true
  end
  if not inUseVehicle then
    target.mount:attach(self)
    target:setNetworkOwner(self:getRaknetID())
    self.rideFixedPointVehicleId = target:getInstanceID()
    self:sendPacket({
      pid = "onRideFixedPointVehicle",
      instanceId = self.rideFixedPointVehicleId
    })
  end
end

function Player:leaveFixedPointVehicle(isTransfer)
  if self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
    local PartManagerHelper = T(Lib, "PartManagerHelper")
    local parentId = PartManagerHelper:isBelongPartGroup(self.rideFixedPointVehicleId)
    if parentId and parentId ~= "" then
      local parentPart = Instance.getByInstanceId(parentId)
      if parentPart and parentPart:isValid() then
        Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, parentPart, self, true, true)
      end
    end
    local ins = Instance.getByInstanceId(self.rideFixedPointVehicleId)
    if ins and ins:isValid() then
      ins.mount.mountId = 0
      self:sendPacket({
        pid = "LeaveRideFixedPointVehicle"
      })
      if ins.initRotation then
        ins:setRotation(ins.initRotation)
      end
      if not isTransfer then
        local pos = self:getPosition()
        pos.y = pos.y + 2
        self:setMapPos(self.map, pos)
      end
      self.fixedPointVehicleDepartureTime = os.time()
    end
    self.rideFixedPointVehicleId = ""
  end
end

local buffPlayerTab = {}
local buffCheckTimer

function Player:addBuffOnPlayer(type, target, params)
  local buffFullName = params[1]
  if not buffFullName then
    return
  end
  local duration = tonumber(params[2])
  local checkPartCondition = Lib.splitString(params[3], "#")
  local canTrigger = true
  if next(checkPartCondition) ~= nil then
    local checkPartName = checkPartCondition[1]
    local key = tostring(checkPartCondition[2])
    local value = checkPartCondition[3]
    local nodes = {}
    local parent = target:getParent()
    Lib.getInstanceAllChild(parent or target, nodes, Define.ABILITY.AABB, checkPartName)
    if nodes[1] then
      local part = nodes[1]
      if key and value and part[key] ~= value then
        canTrigger = false
      end
    end
  end
  if canTrigger and params[4] and params[4] ~= "" then
    local parent = target:getParent()
    local nameList = Lib.splitString(params[4], "#")
    canTrigger = false
    for _, name in pairs(nameList) do
      local nodes = {}
      Lib.getInstanceAllChild(parent or target, nodes, Define.ABILITY.AABB, name)
      if nodes[1].isInteracting then
        canTrigger = true
      end
    end
  end
  if not canTrigger then
    if buffPlayerTab[self.platformUserId] and type == Define.PART_INTERACT_TYPE.TOUCH_END then
      buffPlayerTab[self.platformUserId] = nil
      if next(buffPlayerTab) == nil and buffCheckTimer then
        buffCheckTimer()
        buffCheckTimer = nil
      end
    end
    return
  end
  target:connect("on_destroy", function(instance)
    if instance == target then
      buffPlayerTab = {}
    end
  end)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    self:addBuff(buffFullName, duration)
    buffPlayerTab[self.platformUserId] = 1
    if not buffCheckTimer then
      buffCheckTimer = World.Timer(10, function()
        if next(buffPlayerTab) ~= nil then
          local badIds = {}
          for userId, _ in pairs(buffPlayerTab) do
            local player = Game.GetPlayerByUserId(userId)
            if player and player:isValid() then
              if not player:getTypeBuff("fullName", buffFullName) then
                player:addBuff(buffFullName, duration)
              end
            else
              badIds[#badIds + 1] = userId
            end
          end
          for _, id in ipairs(badIds) do
            buffPlayerTab[id] = nil
          end
          return true
        elseif buffCheckTimer then
          buffCheckTimer()
          buffCheckTimer = nil
        end
      end)
    end
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    buffPlayerTab[self.platformUserId] = nil
    if next(buffPlayerTab) == nil and buffCheckTimer then
      buffCheckTimer()
      buffCheckTimer = nil
    end
  end
end

function Player:triggerColorSelect(type, target, params, isBreak)
  if isBreak == true then
    self:sendPacket({
      pid = "closeColorSelect"
    })
    return
  end
  Lib.logDebug("triggerColorSelect------------------")
  local partName = tostring(params[1])
  local effectName = tostring(params[2])
  local effectPlayTime = tonumber(params[3])
  if not partName or partName == "" then
    return
  end
  if not target then
    return
  end
  local partID = target:getInstanceID()
  self:sendPacket({
    pid = "openColorSelect",
    partName = partName,
    effectInfo = {
      effectName = effectName,
      effectPlayTime = effectPlayTime,
      parentPartID = partID
    }
  })
end

local function getOilGun(inst)
  local count = inst:getChildrenCount()
  for i = 0, count - 1 do
    local n = inst:getChildAt(i)
    if n:getName() == "oilGun" then
      return n
    end
  end
end

function Player:addOilGunToVehicle(vehicleInst, OilMachineInst)
  if not vehicleInst or not OilMachineInst then
    return
  end
  local gunPartCfgName = "myplugin/youqiang"
  local partCfg = PartCfg:get(gunPartCfgName)
  if not partCfg then
    Lib.logError("--error-partCfg-:", gunPartCfgName)
    return
  end
  local gunInst = Instance.newInstance(partCfg, self.map)
  if not gunInst then
    return
  end
  local name = vehicleInst:getProperty("name")
  local cfg = CarConfig:getCfgByName("myplugin/" .. name) or {}
  local posOffset = Lib.v3(cfg.oilGunLocalPos[1] or 1.55, cfg.oilGunLocalPos[2] or 0, cfg.oilGunLocalPos[3] or -1.2)
  gunInst:setLocalPosition(posOffset)
  gunInst:setName("oilGun")
  gunInst:setParent(vehicleInst)
  local pos_gun = gunInst:getPosition()
  local pos_oilMachine = OilMachineInst:getPosition()
  local dis = Lib.getPosDistance(pos_gun, pos_oilMachine)
  local RodConstraint = Instance.Create("RopeConstraint")
  RodConstraint:setProperty("slavePartID", tostring(gunInst:getInstanceID()))
  RodConstraint:setProperty("masterLocalPos", "x:0.1 y:0 z:0")
  RodConstraint:setProperty("length", tostring(dis + 0.7))
  RodConstraint:setProperty("radius", "0.05")
  RodConstraint:setProperty("color", {
    0,
    0,
    0,
    1
  })
  RodConstraint:setProperty("visible", "true")
  RodConstraint:setParent(OilMachineInst)
  RodConstraint:calcAndUpdateParams()
  return gunInst, RodConstraint
end

function Player:refuelTheVehicle(type, target, params)
  if not self.rideOnInstanceId then
    return
  end
  local vehicle = Instance.getByInstanceId(self.rideOnInstanceId)
  if not vehicle or not vehicle:isValid() then
    return
  end
  local oilGun = getOilGun(vehicle)
  if oilGun then
    return
  end
  local VehicleManager = T(Lib, "VehicleManager")
  local driver = VehicleManager:getVehicleDriver(vehicle)
  if not driver or not driver:isValid() then
    return
  end
  if not driver.isPlayer then
    return
  end
  if driver.platformUserId ~= self.platformUserId then
    return
  end
  if not target or target.isUsing then
    return
  end
  target.isUsing = true
  local instanceId = target:getInstanceID()
  self:setInUseOilGunID(instanceId)
  local waitTime = tonumber(params[1]) or 40
  local hidePartName = "gas_station_oil_tank_002"
  local parent = target:getParent()
  local nodes = {}
  Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, hidePartName)
  for _, hidePart in pairs(nodes) do
    PartManagerShow:updatePartShowState(hidePart)
  end
  local gunPart, RodConstraint = self:addOilGunToVehicle(vehicle, target)
  
  local function restore()
    for _, hidePart in pairs(nodes) do
      PartManagerShow:updatePartShowState(hidePart)
    end
    if RodConstraint and RodConstraint:isValid() then
      RodConstraint:destroy()
    end
    if gunPart and gunPart:isValid() then
      gunPart:destroy()
    end
  end
  
  target.restoreFunc = restore
  World.Timer(1, function()
    self:sendPacket({
      pid = "beginRefuelVehicle",
      duration = waitTime,
      gunInstanceID = gunPart and gunPart:getInstanceID(),
      boxInstanceID = target:getInstanceID(),
      vehicleInstanceID = vehicle:getInstanceID()
    })
  end)
end

local function setNewEffect(node, effect)
  if effect and effect ~= "" then
    node:setVisible(true)
    node:setEffect(effect)
    local pos = node:getPosition()
    if pos ~= node.initPos then
      pos = node.initPos
    else
      pos = node.initPos + Lib.v3(0, -0.001, 0)
    end
    node:setPosition(pos)
  else
    node:setVisible(false)
  end
end

function Player:operationEffectTelevision(type, target, params)
  if target.className ~= "Part" then
    return
  end
  local screen = Lib.getInitEffectPart(target)
  if not screen or not screen:isValid() then
    return
  end
  target.screenId = screen:getInstanceID()
  screen.channels = Lib.splitString(params[1], "#") or {}
  if not screen.initPos then
    screen.initPos = screen:getPosition()
  end
  local btnNames = Lib.splitString(params[2], "#") or {}
  if target.screenId then
    if target.inTheOpen then
      target.inTheOpen = false
      self:exitEffectWatchTelevision(target.screenId)
    else
      self:openEffectWatchTelevision(target.screenId, true)
      target.inTheOpen = true
    end
    PartInteractHelper.showTVButton(target, btnNames, target.inTheOpen)
  end
end

function Player:exitEffectWatchTelevision(id)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() then
    local img = ""
    if screen.defaultImg then
      img = screen.defaultImg
    end
    screen:setVisible(false)
  end
end

function Player:openEffectWatchTelevision(id, isRandom)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() and screen.className == "EffectPart" and screen.channels then
    if not screen.defaultImg then
      screen.defaultImg = screen:getProperty("effectFilePath")
    end
    local decalTexture
    local channels = screen.channels
    if isRandom then
      math.randomseed(os.time())
      local index = math.random(1, #channels)
      decalTexture = channels[index]
      screen.curChannel = 1
    elseif screen.curChannel then
      decalTexture = channels[screen.curChannel]
    else
      decalTexture = channels[1]
      screen.curChannel = 1
    end
    setNewEffect(screen, decalTexture)
  end
end

function Player:operatingInEffectTaiwan(type, target, params)
  if params[1] == "" then
    return
  end
  local parent = target:getParent()
  local nodes = {}
  if parent and parent:isValid() then
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, nil, true)
  end
  local vtPart
  for _, v in pairs(nodes) do
    if v.inTheOpen then
      vtPart = v
      break
    end
  end
  if vtPart and vtPart.screenId then
    self:switchEffectTelevisionChannels(vtPart.screenId, params[1] == "1", params[1] == "3")
  end
end

function Player:switchEffectTelevisionChannels(id, add, isRandom)
  local screen = Instance.getByInstanceId(id)
  if screen and screen:isValid() and screen.channels then
    local channels = screen.channels
    local curChannel
    if isRandom then
      math.randomseed(os.time())
      curChannel = math.random(1, #screen.curChannel)
    elseif screen.curChannel then
      if add then
        curChannel = screen.curChannel + 1
      else
        curChannel = screen.curChannel - 1
      end
      if not channels[curChannel] then
        if curChannel > #channels then
          curChannel = 1
        elseif curChannel < 1 then
          curChannel = #channels
        end
      end
    else
      curChannel = 1
    end
    local tImg = channels[curChannel] or ""
    screen.curChannel = curChannel
    setNewEffect(screen, tImg)
  end
end

function Player:onControlHouseLight(type, target, params)
  local function getHouseNode(node)
    if not node or not node:isValid() then
      return
    end
    if node.name == "house" then
      return node
    end
    local parent = node:getParent()
    return getHouseNode(parent)
  end
  
  local houseNode = getHouseNode(target)
  if houseNode and houseNode:isValid() then
    local id = houseNode:getInstanceID()
    local value = tonumber(params[1]) or 0
    HouseManager:controlLight(self, id, tostring(value))
  end
end

function Player:doShortChatDanceAction(id)
  local actionName = ChatShortLangConfig:getOneShortActionById(id)
  local DanceConfig = T(Config, "DanceConfig")
  local actionId = DanceConfig:getCfgByActonName(actionName)
  if actionId and 0 < actionId then
    local InteractionHelper = T(Lib, "InteractionHelper")
    InteractionHelper:doDanceAction(self, actionId, true)
  end
end

function Player:onPartSendShortMsg(type, target, params)
  if not params[1] or params[1] == "" then
    return
  end
  local shortId = tonumber(params[1])
  local shortCfg = ChatShortLangConfig:getCfgById(shortId)
  if shortCfg then
    if params[3] and params[3] == "1" then
      self:doShortChatDanceAction(shortId)
    end
    local packet2 = {
      pid = "SCPartSendShortMsg",
      fromname = self.name,
      shortId = shortId,
      needHead = params[2] and params[2] == "1",
      needChat = params[4] and params[4] == "1",
      args = table.pack(self.objID, nil, Define.Page.COMMON, self.platformUserId),
      textVipColor = self:getTextVipColor()
    }
    self:sendChatMsg(packet2, true)
  end
end

function Player:playOneOnceAction(actionName, priority)
  local packet = {
    pid = "SCPlayOnceAction",
    actionName = actionName,
    priority = priority or 0,
    fromID = self.objID
  }
  self:sendPacketToTracking(packet, true)
end
