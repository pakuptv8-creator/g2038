local CW = World.CurWorld
local setting = require("common.setting")
local PropsConfig = T(Config, "PropsConfig")
local PartCfg = setting:mod("part")
local Player = _ENV.Player
local InteractEventConfig = T(Config, "InteractEventConfig")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local PartManagerShow = T(Lib, "PartManagerShow")
local EmergencyHelper = T(Lib, "EmergencyHelper")
local engine_version = EngineVersionSetting:getEngineVersion()

function Player:onFurnitureInteract(type, part, params, isBreak)
  if not part or not part:isValid() then
    return false
  end
  local InteractionHelper = T(Lib, "InteractionHelper")
  local oldPartId = self:getInteractionPartID()
  if oldPartId ~= "" and oldPartId == part:getInstanceID() then
    InteractionHelper:stopFurnitureAction(self)
  elseif oldPartId ~= "" then
    self:doStopPlayerFurniture()
    local sitIdx = PartManagerHelper:getPartFurnitureSitIdx(part)
    if sitIdx and 0 < sitIdx then
      return InteractionHelper:doFurnitureAction(part, self, sitIdx)
    else
      return false
    end
  else
    local sitIdx = PartManagerHelper:getPartFurnitureSitIdx(part)
    if sitIdx and 0 < sitIdx then
      return InteractionHelper:doFurnitureAction(part, self, sitIdx)
    else
      return false
    end
  end
  return true
end

function Player:onSwingInteract(type, part, params)
  if not part or not part:isValid() then
    return
  end
  if self.isNowSwing then
    return
  end
  local sitIdx = PartManagerHelper:getPartFurnitureSitIdx(part, self, params)
  if sitIdx and 0 < sitIdx then
    local InteractionHelper = T(Lib, "InteractionHelper")
    local result = InteractionHelper:doFurnitureAction(part, self, sitIdx)
    if not result then
      return
    end
    self.isNowSwing = true
    local interactiveId = self:getInteractPlayerHorseID()
    if 0 < interactiveId then
      self:onlyClearPlayerHorse()
    end
    local oldGravity = tonumber(self:getEntityProp("gravity"))
    self:setProp("gravity", 0)
    self:setOnSwingState(1)
    local initSwingPos = part:getPosition()
    local initRotation = part:getRotation()
    self.oldSwingPos = Lib.copy(initSwingPos)
    self.oldRotation = Lib.copy(initRotation)
    self.curSwingPart = part
    WorldServer.BroadcastPacket({
      pid = "playerDoSwing",
      objID = self.objID,
      partID = part:getInstanceID(),
      oldGravity = oldGravity
    })
  end
end

function Player:stopSwing()
  if self:getOnSwingState() == 1 then
    if self.curSwingPart and self.curSwingPart:isValid() then
      self.curSwingPart:setUseCollide(true)
      self.curSwingPart:setRotation(self.oldRotation)
      self.curSwingPart:setPosition(self.oldSwingPos)
    end
    self:resetInitGravity()
    self:setOnSwingState(0)
    self.isNowSwing = false
    WorldServer.BroadcastPacket({
      pid = "playerStopSwing",
      objID = self.objID
    })
  end
end

function Player:onSlideLadderInteract(type, part, params)
  if self:getOnSlideState() == 1 then
    return
  end
  if not params[1] or params[1] == "" then
    return
  end
  local ladderPartId = Lib.splitString(params[4] or "", ":")
  local ladderPart = Instance.getByInstanceId(ladderPartId[2])
  if not ladderPart or not ladderPart:isValid() then
    return
  end
  local pos = Lib.splitString(params[2] or "", "#", true)
  local param = {
    name = "",
    cfgName = params[1],
    map = self.map,
    pos = ladderPart:getPosition() + Lib.v3(pos[1], pos[2] + 0.5, pos[3]),
    ry = -ladderPart:getRotation().y + pos[4]
  }
  self.playerMirror = EntityServer.Create({
    name = "",
    cfgName = World.cfg.playerCfg,
    pos = self:getPosition(),
    map = self.map,
    rp = self:getRotationPitch(),
    ry = self:getRotationYaw(),
    rr = self:getRotationRoll()
  })
  if self.playerMirror and self.playerMirror:isValid() then
    local actorName
    if self:data("main").sex == 2 then
      actorName = self:cfg().actorGirlName or "girl.actor"
    else
      actorName = self:cfg().actorName or "boy.actor"
    end
    self.playerMirror:changeActor(actorName, true)
  end
  local target = EntityServer.Create(param)
  local ridePosIndex = 1
  if target and target:isValid() then
    local interactiveId = self:getInteractPlayerHorseID()
    if 0 < interactiveId then
      self:onlyClearPlayerHorse()
    end
    self.startSlideLadderTime = os.time()
    self:setOnSlideState(1)
    self.playerMirror:rideOn(target, nil, ridePosIndex)
    self.curTotalSlideTime = tonumber(params[3])
    self:hideEntity()
    World.Timer(5, function()
      WorldServer.BroadcastPacket({
        pid = "onStartSlideLadderInteract",
        pos = part:getPosition(),
        time = tonumber(params[3]),
        objID = self.objID,
        triggerPartId = part:getInstanceID(),
        ladderPartId = ladderPartId[2],
        mirrorID = self.playerMirror.objID,
        targetID = target.objID
      })
    end)
    self:data("main").slideLadderEntity = target
    self:data("main").slideLadder = part
  end
end

function Player:doStartSlideLadder()
  if self:getOnSlideState() == 0 then
    return
  end
  self.curSlideTime = 0
  self.slideTimer = World.Timer(1, function()
    if not self or not self:isValid() then
      return false
    end
    self.curSlideTime = self.curSlideTime + 1
    if self.curSlideTime >= (self.curTotalSlideTime or 30) then
      self:stopSlideLadderInteract()
      return false
    end
    return true
  end)
end

function Player:stopSlideLadderInteract()
  if self:getOnSlideState() == 0 then
    return
  end
  if not self:tryClearRide() then
    return
  end
  self:setOnSlideState(0)
  if self:data("main").slideLadder and self:data("main").slideLadder:isValid() then
    self:data("main").slideLadder:setUseCollide(true)
    self:data("main").slideLadder = nil
  end
  if self:data("main").slideLadderEntity and self:data("main").slideLadderEntity:isValid() then
    WorldServer.BroadcastPacket({
      pid = "onStopSlideLadderInteract",
      objID = self.objID,
      targetID = self:data("main").slideLadderEntity.objID
    })
  end
  if self.playerMirror and self.playerMirror:isValid() then
    self.playerMirror:destroy()
    self.playerMirror = nil
  end
  if self.slideTimer then
    self.slideTimer()
    self.slideTimer = nil
  end
  local startTime = self.startSlideLadderTime or 0
  local defaultData = {
    event_name = "slide_ladder",
    event_time = os.time() - startTime
  }
  Plugins.CallTargetPluginFunc("report", "report", "event_ride_end", defaultData, self)
end

function Player:onFinishSlideLadderInteract(pos)
  if self:data("main").slideLadderEntity and self:data("main").slideLadderEntity:isValid() then
    self:data("main").slideLadderEntity:destroy()
    self:data("main").slideLadderEntity = nil
  end
end

function Player:onExplodeBarrier(type, target, params, itemCfg)
  if itemCfg and itemCfg.propParams.throwType and tonumber(itemCfg.propParams.throwType) == 1 and (not target or not target:isValid()) then
    return
  end
  Lib.logDebug("explode action")
  local handBagsInfo = self:getHandbagsInfo()
  for _, v in pairs(handBagsInfo) do
    if v.inUse then
    end
  end
  local propParams = itemCfg.propParams
  local pTarget = propParams.throwType and tonumber(propParams.throwType) == 1 and target or nil
  local pos = propParams.throwType and tonumber(propParams.throwType) == 1 and params.pos or nil
  local bombPart = self:addItemPartToWorld(itemCfg.throwCfgName or "myplugin/bomb", pTarget, pos)
  if bombPart then
    if propParams.throwType and tonumber(propParams.throwType) == 2 then
      local partPos = self:getFrontPos(0.3, true, false) + {
        x = 0,
        y = 1.5,
        z = 0.2
      }
      bombPart:setPosition(partPos)
      self:throwBomb(bombPart)
    end
    local posT = Lib.v3(0, 0, 0)
    if target and target:isValid() then
      posT = target:getPosition()
    end
    if not bombPart or not bombPart:isValid() then
      return
    end
    local bombPos = propParams.throwType and tonumber(propParams.throwType) == 1 and (params.pos or posT) or bombPart:getPosition()
    local fromUserId = self.platformUserId
    local mapName = self.map.name
    World.Timer(propParams.readyTime and tonumber(propParams.readyTime) or 40, function()
      if not bombPart or not bombPart:isValid() then
        return
      end
      bombPos = propParams.throwType and tonumber(propParams.throwType) == 1 and (params.pos or posT) or bombPart:getPosition()
      local packet = {
        pid = "bombReady",
        pos = bombPos,
        effect = propParams.effect,
        sound = propParams.sound,
        fromUserId = fromUserId,
        mapName = mapName,
        effectTime = propParams.effectTime and tonumber(propParams.effectTime) or 600
      }
      WorldServer.BroadcastPacket(packet)
      World.Timer(propParams.vanishTime and tonumber(propParams.vanishTime) or 15, function()
        if bombPart and bombPart:isValid() then
          bombPos = propParams.throwType and tonumber(propParams.throwType) == 1 and (params.pos or posT) or bombPart:getPosition()
          PartManagerHelper:clearBarrier(self, bombPart:getInstanceID(), bombPos, target)
        end
      end)
    end)
  end
end

local function getTargetPos(position, yawOffset, from)
  local fromYaw = from:getRotationYaw() - yawOffset
  local yaw = (360 - fromYaw + 90) % 360
  local pos = Lib.tov3(Lib.copy(position))
  local new_off_x, new_off_y = pos.x, pos.z
  local arc1 = math.atan(new_off_y, -new_off_x)
  local deg1 = math.deg(arc1)
  local deg2 = yaw - (360 - deg1 + 90) % 360
  local arc2 = math.rad(deg2)
  local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
  local offx = len * math.cos(arc2)
  local offy = len * math.sin(arc2)
  pos.x = -offx
  pos.z = offy
  local targrtpos = from:getPosition() + pos
  return targrtpos
end

function Player:throwBomb(part)
  if part then
    part:setProperty("density", part.properties.density or 0.5)
    local targetPos = getTargetPos({
      x = 0,
      y = 7,
      z = 5
    }, 0, self)
    local velocityDir = targetPos - part:getPosition()
    local torque = Lib.v3(0, 0, 0)
    part:applyForce(10.0 * velocityDir:normalize(), torque)
  end
end

function Player:addItemPartToWorld(cfgName, target, clickPos, ignoreCheckNearby, ignorePlayerYaw)
  local partCfg = PartCfg:get(cfgName)
  if not partCfg then
    Lib.logError("--error-partCfg-:", cfgName)
    return
  end
  if clickPos then
    local allEntity = self.map:getNearbyEntities(clickPos, 1)
    if not Lib.table_is_empty(allEntity) and not ignoreCheckNearby then
      return
    end
  end
  local manager = CW:getSceneManager()
  local scene = manager:getOrCreateScene(self.map.obj)
  local inst = Instance.newInstance(partCfg, self.map)
  if not inst then
    return
  end
  if not ignorePlayerYaw then
    local yaw = self:getRotationYaw()
    local preRotation = inst:getRotation()
    preRotation.y = preRotation.y - yaw
    inst:setRotation(preRotation)
  end
  inst:setParent(scene:getRoot())
  local pos_target
  if target and target:isValid() then
    pos_target = target:getPosition()
  end
  if pos_target then
    local pos = inst:getPosition()
    if clickPos then
      pos = clickPos - pos
    else
      pos = pos_target - pos
    end
    if inst.properties and inst.properties.offsetPosy and inst.properties.offsetPosy > 0 then
      pos.y = pos.y + inst.properties.offsetPosy
    end
    inst:setPosition(pos)
  end
  return inst
end

function Player:onPlaceToWorld(type, target, params)
  if not target or not target:isValid() then
    return
  end
  local itemId
  local handBagsInfo = self:getHandbagsInfo()
  for _, v in pairs(handBagsInfo) do
    if v.inUse then
      itemId = v.itemId
      break
    end
  end
  if not itemId then
    return
  end
  if not self:checkItemIdTimeCanPlace(itemId) then
    return
  end
  if itemId == Define.PROP_ITEM_ID.Lighter then
    self:onPlaceSmallFirePoint(target, params.pos)
    return
  end
  local isCanPlace, placePartName = PropsConfig:canPlaceToWorld(itemId)
  if not isCanPlace or placePartName == "" then
    return
  end
  if not PartManagerHelper:checkOnePartCanPlace(self.platformUserId, itemId) then
    return
  end
  local isSuc = PartManagerHelper:addOnePlacePart(self.platformUserId, itemId)
  if not isSuc then
    return
  end
  local part = self:addItemPartToWorld(placePartName, target, params.pos)
  if part then
    PartManagerHelper:inputOnePlacePartData(self.platformUserId, itemId, part)
  else
    PartManagerHelper:outputOnePlacePartInvalidData(self.platformUserId, itemId)
  end
end

function Player:onPlaceSmallFirePoint(target, placePos)
  local map = self.map
  local range = 2
  if placePos == nil then
    placePos = target:getPosition()
  end
  local minPos = {
    x = placePos.x - range,
    y = placePos.y - range,
    z = placePos.z - range
  }
  local maxPos = {
    x = placePos.x + range,
    y = placePos.y + range,
    z = placePos.z + range
  }
  if not map then
    return
  end
  local hasFirePointList = {}
  local parts = map:getTouchParts(minPos, maxPos)
  if parts then
    for _, part in pairs(parts) do
      if part:isValid() and part.properties.name == "small_fire_point" then
        table.insert(hasFirePointList, part)
      end
    end
  end
  if 0 < #hasFirePointList then
    local locationId, ownerId = HouseManager:checkPlayerIsOtherVisit(self)
    if locationId then
      for _, fire_point_part in pairs(hasFirePointList) do
        EmergencyHelper:addKindlingList(locationId, ownerId, fire_point_part:getInstanceID(), false)
        Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.TOUCH_BEGIN, fire_point_part, self, true)
      end
    end
    return
  else
    local itemId = Define.PROP_ITEM_ID.Lighter
    local isCanPlace, placePartName = PropsConfig:canPlaceToWorld(itemId)
    if not isCanPlace or placePartName == "" then
      return
    end
    if not PartManagerHelper:checkOnePartCanPlace(self.platformUserId, itemId) then
      return
    end
    local isSuc = PartManagerHelper:addOnePlacePart(self.platformUserId, itemId)
    if not isSuc then
      return
    end
    local part = self:addItemPartToWorld(placePartName, target, placePos)
    if part then
      PartManagerHelper:inputOnePlacePartData(self.platformUserId, itemId, part)
      local locationId, ownerId = HouseManager:checkPlayerIsOtherVisit(self)
      if locationId then
        EmergencyHelper:addKindlingList(locationId, ownerId, part:getInstanceID(), true)
      end
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, self, true)
    else
      PartManagerHelper:outputOnePlacePartInvalidData(self.platformUserId, itemId)
    end
  end
end

function Player:onTouchLadder(type, part, params)
  part.usingLadderPlayers = part.usingLadderPlayers or {}
  local begin = type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN
  if begin then
    part.usingLadderPlayers[self.platformUserId] = true
    local angle = tonumber(params[1]) or 0
    local speed = tonumber(params[2]) or 0.05
    self:SetForceClimb(begin, speed, angle)
  else
    part.usingLadderPlayers[self.platformUserId] = nil
    if self.forceClimbMode then
      self:sendPacket({
        pid = "onTouchLadderEnd"
      })
    end
    self:SetForceClimb(false, 0, 0)
  end
end

function Player:onHouseTouchLadder(type, part, params)
  part.usingLadderPlayers = part.usingLadderPlayers or {}
  local begin = type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN
  if begin then
    part.usingLadderPlayers[self.platformUserId] = true
    local initYaw = Lib.changeCfgStringCoord(part.properties.rotation).y
    local speed = tonumber(params[2]) or 0.05
    local angle = -1 * (part:getRotation().y - initYaw) + -1 * initYaw
    self:SetForceClimb(begin, speed, angle)
  else
    part.usingLadderPlayers[self.platformUserId] = nil
    if self.forceClimbMode then
      self:sendPacket({
        pid = "onTouchLadderEnd"
      })
    end
    self:SetForceClimb(false, 0, 0)
  end
end

function Player:onKickOutOfRoom(type, part, params)
  if not part.entityIn then
    part.entityIn = {}
    local partName = params[1]
    local newPos = Lib.createV3ByString(params[2])
    local parent = part:getParent()
    local nodes = {}
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, partName)
    if 0 < #nodes then
      do
        local checkPart = nodes[1]
        part.kickOutTimer = World.Timer(1, function()
          if checkPart.operationRotateInfo then
            return true
          end
          if next(part.entityIn) ~= nil then
            for _, entity in pairs(part.entityIn) do
              if entity and entity:isValid() then
                local pos = entity:getPosition()
                entity:setMapPos("map001", {
                  x = pos.x + newPos.x,
                  y = pos.y + newPos.y,
                  z = pos.z + newPos.z
                })
              end
            end
          end
          part.entityIn = {}
          part.kickOutTimer = nil
        end)
      end
    end
  end
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    part.entityIn[self.platformUserId] = self
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    part.entityIn[self.platformUserId] = nil
  end
end

function Player:onChangeProfession(type, part, params)
  if not part or not part:isValid() then
    return
  end
  local oldProfessionId = self:getProfessionId()
  if oldProfessionId == tonumber(params[1]) then
    Plugins.CallTargetPluginFunc("profession", "updatePlayerProfession", self, 0, true)
  else
    Plugins.CallTargetPluginFunc("profession", "updatePlayerProfession", self, params[1], true)
  end
end

function Player:playEffectOnPart(type, target, params, isBreak)
  PartManagerHelper:updateEffectOnPart(type, target, params, isBreak)
end

function Player:playLimitEffectOnPart(type, target, params)
  if params[7] and params[7] ~= "" then
    local inUseProp = self:getInUseProp()
    if inUseProp then
      local itemId = tonumber(params[7])
      if inUseProp.itemId ~= itemId then
        return
      end
    end
  end
  PartManagerHelper:playLimitEffectOnPart(type, target, params)
end

function Player:onUpdatePartShow(type, part, params)
  if not part or not part:isValid() then
    return
  end
  if params[1] and params[1] ~= "" then
    local parent = part:getParent()
    if not parent or not parent:isValid() then
      return
    end
    local partArr = Lib.splitString(params[1], "#")
    for _, partName in pairs(partArr) do
      PartManagerShow:updatePartShowByParent(partName, parent)
    end
  else
    PartManagerShow:updatePartShowState(part)
  end
end

function Player:onUpdateChildEffect(type, part, params, isBreak)
  if not part or not part:isValid() then
    return
  end
  local delayTime = tonumber(params[2]) or 0
  if params[1] and params[1] ~= "" then
    local function callbackFunc()
      local partArr = Lib.splitString(params[1], "#")
      
      for _, partName in pairs(partArr) do
        local count = part:getChildrenCount()
        for i = 0, count - 1 do
          local childPart = part:getChildAt(i)
          if childPart and childPart:isValid() and childPart.className == "EffectPart" and childPart.properties and childPart.properties.name and partName == childPart.properties.name then
            local visible = childPart:getProperty("visible")
            if visible == "true" then
              childPart:setProperty("visible", "false")
            else
              childPart:setProperty("visible", "true")
            end
          end
        end
      end
    end
    
    if part.callBackTimer then
      part.callBackTimer()
      return
    end
    if isBreak then
      callbackFunc()
    elseif 0 < delayTime then
      part.callBackTimer = World.Timer(delayTime, function()
        callbackFunc()
        part.callBackTimer = nil
        return false
      end)
    else
      callbackFunc()
    end
  end
end

function Player:onChangePartMesh(type, part, params)
  if not part or not part:isValid() then
    return
  end
  if params[1] and params[1] ~= "" then
    local partArr = Lib.splitString(params[1], "#")
    if not part.curMeshIndex then
      part.curMeshIndex = 1
    end
    part:setProperty("mesh", partArr[part.curMeshIndex])
    part.curMeshIndex = part.curMeshIndex + 1
    if part.curMeshIndex > #partArr then
      part.curMeshIndex = 1
    end
  end
end

function Player:stopPartInteraction()
  local partId = self:getInteractionPartID()
  local part = Instance.getByInstanceId(partId)
  if part and part:isValid() then
    PartManagerHelper:removePartInteractState(part)
  end
end

function Player:OnSecretBlackboard(type, part, params)
  if not part or not part:isValid() then
    return
  end
  if part.isFinishCollection then
    return
  end
  local cfg = InteractEventConfig:getCfgById(part.name)
  if not (cfg and cfg.precondition) or not cfg.precondition.paramArr then
    return
  end
  local inUseProp = self:getInUseProp()
  if inUseProp then
    if part.curShowPart and part.curShowPart[inUseProp.itemId] == 1 then
      return
    end
    local tbPartList = Lib.split(params[1], "#")
    for i = 1, #tbPartList do
      local itemId = tonumber(cfg.precondition.paramArr[i])
      if inUseProp.itemId == itemId then
        PartManagerShow:onShowPopPool(tonumber(tbPartList[i]))
        if not part.curShowPart then
          part.curShowPart = {}
        end
        part.curShowPart[itemId] = 1
        self:removeInUseHandItem()
      end
    end
  end
  if part.curShowPart then
    local result = true
    for itemId, value in pairs(part.curShowPart) do
      if value ~= 1 then
        result = false
      end
    end
    part.isFinishCollection = result
  end
  if part.isFinishCollection then
    if params[2] and params[2] ~= "" then
      local transformPartId = Lib.split(params[2], ":")
      PartManagerShow:onShowPopPool(tonumber(transformPartId[2]))
    end
    self:sendPacket({
      pid = "transformState",
      isStart = 1
    })
    World.Timer(20, function()
      if params[4] and params[4] ~= "" then
        local info = Lib.splitString(params[4], "#") or {}
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
        self:sendPacket({
          pid = "transformState",
          isStart = 0
        })
      end
    end)
    World.Timer(tonumber(params[3]) or 1, function()
      if not part or not part:isValid() then
        return false
      end
      PartManagerShow:initSecretBlackboardPart(part)
    end)
  end
end

function Player:onPrinterInteract(type, part, params)
  if part and part:isValid() then
    PartManagerHelper:updatePrinterState(self, type, part, params, "onPrinterInteract")
  end
end

function Player:onPrintPaperInteract(type, part, params)
  if part and part:isValid() then
    PartManagerHelper:updatePrinterState(self, type, part, params, "onPrintPaperInteract")
  end
end

function Player:switchPartName(type, target, params)
  if params[1] ~= "" then
    local parent = target:getParent()
    local names = Lib.splitString(params[1], "#") or {}
    local nodes = {}
    local newName = {}
    for i, name in pairs(names) do
      nodes[name] = {}
      local index = i + 1
      if index > #names then
        index = 1
      end
      newName[name] = names[index]
      Lib.getInstanceAllChild(parent, nodes[name], Define.ABILITY.AABB, name)
    end
    for name, v in pairs(nodes) do
      for _, part in pairs(v or {}) do
        if newName[name] then
          if part.isInteracting then
            if part.interactPlayerList then
              local playerList = Lib.copyTable1(part.interactPlayerList)
              for id, val in pairs(playerList) do
                if val then
                  local player = World.CurWorld:getEntity(id)
                  if player and player:isValid() then
                    Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, player, true, true)
                  end
                end
              end
              part:setProperty("name", newName[name])
              local newProp = InteractEventConfig:getCfgById(newName[name])
              if newProp and newProp.func and newProp.func == "onFurnitureInteract" then
                PartManagerHelper:updatePartParamsInfo(part, newProp.params)
              end
              for id, val in pairs(playerList) do
                if val then
                  local player = World.CurWorld:getEntity(id)
                  if player and player:isValid() then
                    Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, player, true, false)
                  end
                end
              end
            else
              part:setProperty("name", newName[name])
            end
          else
            part:setProperty("name", newName[name])
          end
        end
      end
    end
  end
end

function Player:switchFurnitureName(type, target, params)
  if params[1] ~= "" then
    local parent = target:getParent()
    local names = Lib.splitString(params[1], "#") or {}
    local nodes = {}
    local newName = {}
    for i, name in pairs(names) do
      nodes[name] = {}
      local index = i + 1
      if index > #names then
        index = 1
      end
      newName[name] = names[index]
      Lib.getInstanceAllChild(parent, nodes[name], Define.ABILITY.AABB, name)
    end
    for name, v in pairs(nodes) do
      for _, part in pairs(v or {}) do
        if newName[name] then
          if part.isInteracting then
            if part.interactPlayerList then
              local playerList = Lib.copyTable1(part.interactPlayerList)
              local newProp = InteractEventConfig:getCfgById(newName[name])
              local content = Lib.splitString(newProp.params[1], "#")
              local InteractionHelper = T(Lib, "InteractionHelper")
              for id, val in pairs(playerList) do
                if val then
                  local player = World.CurWorld:getEntity(id)
                  if player and player:isValid() then
                    PartManagerHelper:updatePartParamsInfo(part, newProp.params)
                    InteractionHelper:updateFurnitureActionState(player.objID, content[1], part:getInstanceID(), true)
                  end
                end
              end
              part:setProperty("name", newName[name])
            else
              part:setProperty("name", newName[name])
            end
          else
            part:setProperty("name", newName[name])
          end
        end
      end
    end
  end
end

function Player:refreshGuiZiImage(partType, target, info)
  local partCfgName = info[2]
  local triggerName = info[3]
  local triggerPart = {}
  if triggerName and triggerName ~= "" then
    local parent = target:getParent()
    Lib.getInstanceAllChild(parent, triggerPart, Define.ABILITY.AABB, triggerName)
  end
  local isSelect = "true"
  if partType == "open" then
    if not target.imagePart then
      local imagePart = self:addItemPartToWorld(partCfgName)
      if imagePart then
        target.imagePart = imagePart
      end
    end
    isSelect = "false"
  elseif partType == "close" and target.imagePart then
    local part = target.imagePart
    part:destroy()
    target.imagePart = nil
  end
  for _, v in pairs(triggerPart) do
    v:setProperty("selectable", isSelect)
  end
end

function Player:onPolicePhotograph(type, part, params)
  if part and part:isValid() then
    PartManagerHelper:updatePhotographAreaState(self, type, part, params)
  end
end

function Player:onPlayerPhotograph(type, part, params)
  if part and part:isValid() then
    PartManagerHelper:updatePlayerPhotographInfo(self, part, params)
  end
end

function Player:onCascadeState(type, part, params)
  if not part or not part:isValid() then
    return
  end
  local parent = part
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
  local fromList = Lib.splitString(params[1], "#") or {}
  local fromNodes = {}
  if not part.fromNodes then
    for _, name in pairs(fromList) do
      Lib.getInstanceAllChild(parent, fromNodes, Define.ABILITY.AABB, name)
    end
    PartManagerShow:updateParentChildList(parent, fromNodes)
    part.fromNodes = fromNodes
  else
    fromNodes = part.fromNodes
  end
  local allFromPartId = {}
  for _, partNode in pairs(fromNodes) do
    if partNode and partNode:isValid() then
      table.insert(allFromPartId, partNode:getInstanceID())
    end
  end
  local newState = PartManagerHelper:getPartListInteractState(allFromPartId)
  if part.switchState == newState then
    return
  else
    part.switchState = newState
    local targetList = Lib.splitString(params[2], "#") or {}
    local targetNodes = {}
    if not part.targetNodes then
      for _, name in pairs(targetList) do
        Lib.getInstanceAllChild(parent, targetNodes, Define.ABILITY.AABB, name)
      end
      PartManagerShow:updateParentChildList(parent, fromNodes)
      part.targetNodes = targetNodes
    else
      targetNodes = part.targetNodes
    end
    for _, partNode in pairs(targetNodes) do
      if partNode and partNode:isValid() then
        Plugins.CallTargetPluginFunc("interact", "tryPartInteract", type, partNode, self, true)
      end
    end
  end
end

function Player:onVehicleToOnePart(type, part, params, isBreak)
  if part and part:isValid() then
    local oldPartId = self:getInteractionPartID()
    if oldPartId ~= "" then
      self:doStopPlayerFurniture()
    end
    if self:getInteractPlayerHorseID() > 0 then
      self:onlyClearPlayerHorse()
    end
    if 0 < self.rideOnId then
      return
    end
    local rideOnInstanceId = self.rideOnInstanceId
    if rideOnInstanceId then
      local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
      if vehicleInst and vehicleInst:isValid() then
        return false
      end
    end
    if isBreak then
      self:setInteractCarEnterID("")
      if part.carId then
        local carPart = Instance.getByInstanceId(part.carId)
        if carPart and carPart:isValid() then
          carPart.mount.mountId = 0
        end
        self:sendPacket({
          pid = "pushInteractBedActionData",
          isAdd = false,
          partID = part:getInstanceID(),
          objID = self.objID
        })
        local offInfo = Lib.splitString(params[3], "#")
        local pos = carPart:getPosition() + Lib.v3(tonumber(offInfo[1]) or 0, tonumber(offInfo[2]) or 0, tonumber(offInfo[3]) or 0)
        self:setMapPos(self.map, pos)
      end
      return
    end
    if self:getInteractCarEnterID() ~= "" then
      return
    end
    if params[1] and params[1] ~= "" then
      local triggerPart = {}
      local parent = part:getParent()
      Lib.getInstanceAllChild(parent, triggerPart, Define.ABILITY.AABB, params[1])
      local carPart = triggerPart[1]
      local actionInfo = Lib.splitString(params[2], "#")
      if carPart and carPart:isValid() then
        part.carId = carPart:getInstanceID()
        if not carPart.mount then
          carPart.mount = Instance.Create("MountPoint")
          carPart.mount:setName("mp_driver")
          carPart.mount:setParent(carPart)
          carPart.mount.rotation = Lib.v3(tonumber(actionInfo[5]), tonumber(actionInfo[6]), tonumber(actionInfo[7]))
          carPart.mount.pos = Lib.v3(tonumber(actionInfo[2]), tonumber(actionInfo[3]), tonumber(actionInfo[4]))
          carPart.mount.attachInstanceId = carPart:getInstanceID()
        end
        local pYaw = -tonumber(actionInfo[6])
        local newPos = self:getNewWithShapeScale(Lib.v3(tonumber(actionInfo[2]), tonumber(actionInfo[3]), tonumber(actionInfo[4])), pYaw)
        carPart.mount.pos = newPos
        carPart.mount:attach(self)
        self:setInteractCarEnterID(part:getInstanceID())
        self:sendPacket({
          pid = "pushInteractBedActionData",
          actionName = actionInfo[1] or "idle",
          partID = part:getInstanceID(),
          isAdd = true,
          objID = self.objID
        })
      end
      
      function part.jumpBackFunc()
        local parentId = PartManagerHelper:isBelongPartGroup(part:getInstanceID())
        if parentId and parentId ~= "" then
          local parentPart = Instance.getByInstanceId(parentId)
          if parentPart and parentPart:isValid() then
            Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, parentPart, self, true, true)
          end
        end
      end
    end
  end
end

function Player:onEditPartContentShow(type, part, params)
  self:sendPacket({
    pid = "SCOpenPartContentEditWnd",
    partID = part:getInstanceID(),
    mapName = self.map.name,
    partParams = params
  })
end

function Player:onCancelHandSomeItem(type, part, params)
  local inUseProp = self:getInUseProp()
  if not inUseProp then
    return
  end
  if inUseProp.itemId == 0 then
    return
  end
  local needRemove = false
  if params[1] ~= "" then
    local itemList = Lib.splitString(params[1], "#", true)
    for _, id in pairs(itemList) do
      if inUseProp.itemId == id then
        needRemove = true
      end
    end
  else
    needRemove = true
  end
  if needRemove then
    self:removeInUseHandItem()
  end
end

function Player:onCreateMovePart(type, part, params, isBreak)
  if part and part:isValid() then
    local oldPartId = self:getInteractionPartID()
    if oldPartId ~= "" then
      self:doStopPlayerFurniture()
    end
    if self:getInteractPlayerHorseID() > 0 then
      self:onlyClearPlayerHorse()
    end
    if 0 < self.rideOnId then
      return
    end
    local rideOnInstanceId = self.rideOnInstanceId
    if rideOnInstanceId then
      local vehicleInst = Instance.getByInstanceId(rideOnInstanceId)
      if vehicleInst and vehicleInst:isValid() then
        return false
      end
    end
    if self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
      return
    end
    if self:getInteractCarEnterID() ~= "" then
      return
    end
    if params[1] and params[1] ~= "" then
      local carPart = self:addItemPartToWorld(params[1])
      World.Timer(3, function()
        if not self or not self:isValid() then
          PartManagerHelper:doDestroyPart(carPart)
          return
        end
        if self:getInteractCarEnterID() ~= "" then
          return
        end
        local offsetPos = Lib.splitString(params[2], "#", true)
        local myPos = self:getPosition()
        local partPos = part:getPosition()
        local pPos = Lib.v3(partPos.x, myPos.y, partPos.z)
        local bornPos
        if params[7] and params[7] ~= "" then
          local tDir = (myPos - pPos):normalize() * (tonumber(params[7]) or 0)
          bornPos = pPos + tDir
          bornPos.y = partPos.y + (offsetPos[2] or 0)
        else
          bornPos = partPos + Lib.v3(offsetPos[1] or 0, offsetPos[2] or 0, offsetPos[3] or 0)
        end
        local endDir = pPos - bornPos
        local tan = math.atan(endDir.z, endDir.x)
        local pYaw = math.deg(tan) - 90
        local newPos = self:getNewWithShapeScale(bornPos, pYaw)
        carPart:setPosition(newPos)
        carPart:setRotation(Lib.v3(0, -pYaw, 0))
        local actionInfo = Lib.splitString(params[3], "#")
        if carPart and carPart:isValid() then
          if not carPart.mount then
            carPart.mount = Instance.Create("MountPoint")
            carPart.mount:setName("mp_driver")
            carPart.mount:setParent(carPart)
            carPart.mount.rotation = Lib.v3(tonumber(actionInfo[5]), tonumber(actionInfo[6]), tonumber(actionInfo[7]))
            carPart.mount.pos = Lib.v3(tonumber(actionInfo[2]), tonumber(actionInfo[3]), tonumber(actionInfo[4]))
            carPart.mount.attachInstanceId = carPart:getInstanceID()
          end
          carPart.mount:attach(self)
          self:setInteractCarEnterID(carPart:getInstanceID())
          self:sendPacket({
            pid = "pushInteractBedActionData",
            actionName = actionInfo[1] or "idle",
            partID = carPart:getInstanceID(),
            isAdd = true,
            objID = self.objID
          })
          
          function carPart.jumpBackFunc()
            if not carPart or not carPart:isValid() then
              return
            end
            if carPart.mount.mountId == 0 then
              return
            end
            carPart.mount.mountId = 0
            self:sendPacket({
              pid = "pushInteractBedActionData",
              isAdd = false,
              partID = carPart:getInstanceID(),
              objID = self.objID
            })
            self:setInteractCarEnterID("")
            carPart.isInteracting = false
            if params[6] and params[6] ~= "" then
              local offInfo = Lib.splitString(params[6], "#")
              local pos = carPart:getPosition() + Lib.v3(tonumber(offInfo[1]) or 0, tonumber(offInfo[2]) or 0, tonumber(offInfo[3]) or 0)
              self:setMapPos(self.map, pos)
            end
          end
          
          local function callbackFunc()
            carPart.jumpBackFunc()
            PartManagerHelper:doDestroyPart(carPart)
          end
          
          local moveInfo = Lib.splitString(params[4], "#", true)
          local moveDir = Lib.v3(moveInfo[1], moveInfo[2], moveInfo[3])
          local moveTime = tonumber(params[5]) or 1
          PartManagerHelper:doPartMoveOperation(carPart, moveDir, moveTime, callbackFunc)
        end
        return false
      end)
    end
  end
end

function Player:onWithPartDirMove(type, part, params, isBreak)
  if part and part:isValid() then
    local oldPartId = self:getInteractionPartID()
    if oldPartId ~= "" then
      self:doStopPlayerFurniture()
    end
    if self:getInteractPlayerHorseID() > 0 then
      self:onlyClearPlayerHorse()
    end
    if 0 < self.rideOnId then
      return
    end
    if self.rideOnInstanceId then
      return
    end
    if self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
      return
    end
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
      if self:getInteractCarEnterID() ~= "" then
        return
      end
      if params[1] and params[1] ~= "" then
        local carPart = self:addItemPartToWorld(params[1])
        World.Timer(3, function()
          if not self or not self:isValid() then
            PartManagerHelper:doDestroyPart(carPart)
            return
          end
          if self:getInteractCarEnterID() ~= "" or self.rideOnId > 0 or self.rideOnInstanceId or self.rideFixedPointVehicleId and self.rideFixedPointVehicleId ~= "" then
            PartManagerHelper:doDestroyPart(carPart)
            return
          end
          local myPos = self:getPosition()
          local offsetPos = Lib.splitString(params[2], "#", true)
          local bornPos = myPos + Lib.v3(offsetPos[1] or 0, offsetPos[2] or 0, offsetPos[3] or 0)
          carPart:setPosition(bornPos)
          local actionInfo = Lib.splitString(params[3], "#")
          if carPart and carPart:isValid() then
            if not carPart.mount then
              carPart.mount = Instance.Create("MountPoint")
              carPart.mount:setName("mp_driver")
              carPart.mount:setParent(carPart)
              carPart.mount.rotation = Lib.v3(tonumber(actionInfo[5]), tonumber(actionInfo[6]), tonumber(actionInfo[7]))
              carPart.mount.pos = Lib.v3(tonumber(actionInfo[2]), tonumber(actionInfo[3]), tonumber(actionInfo[4]))
              carPart.mount.attachInstanceId = carPart:getInstanceID()
            end
            carPart.mount:attach(self)
            self:setInteractCarEnterID(carPart:getInstanceID())
            self:sendPacket({
              pid = "pushInteractBedActionData",
              actionName = actionInfo[1] or "idle",
              partID = carPart:getInstanceID(),
              isAdd = true,
              objID = self.objID
            })
            local moveDir = part:getWorldQuaternion() * Lib.v3(0, 0, 1):normalize()
            local moveSpeed = tonumber(params[4]) or 0.5
            local scene = carPart:getScene()
            if self.carPartMoveTimer then
              self.carPartMoveTimer()
              self.carPartMoveTimer = nil
            end
            local landPosY = 1.7
            self.carPartMoveTimer = World.Timer(1, function()
              if not self or not self:isValid() then
                PartManagerHelper:doDestroyPart(carPart)
                return
              end
              local offset = moveDir * moveSpeed
              local playerPos = self:getPosition() + offset
              if playerPos.y >= landPosY then
                scene.move({carPart}, offset, true)
              else
                offset.y = 0
                scene.move({carPart}, offset, true)
              end
              return true
            end)
          end
          return false
        end)
      end
    elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
      self:stopPartDirMove()
    end
  end
end

function Player:stopPartDirMove()
  if not self or not self:isValid() then
    return
  end
  local carEnterID = self:getInteractCarEnterID()
  if carEnterID == "" then
    return
  end
  local carPart = Instance.getByInstanceId(carEnterID)
  if not carPart or not carPart:isValid() then
    return
  end
  if self.carPartMoveTimer then
    self.carPartMoveTimer()
    self.carPartMoveTimer = nil
  end
  carPart.mount.mountId = 0
  self:sendPacket({
    pid = "pushInteractBedActionData",
    isAdd = false,
    partID = carPart:getInstanceID(),
    objID = self.objID
  })
  self:setInteractCarEnterID("")
  carPart.isInteracting = false
  PartManagerHelper:doDestroyPart(carPart)
  local playerPos = self:getPosition()
  local landPosY = 1.7
  if landPosY > playerPos.y then
    local pos = self:getPosition()
    pos.y = landPosY
    self:setMapPos(self.map, pos)
  end
end

function Player:onOccupationPart(type, part, params, isBreak)
  PartManagerHelper:updateOccupationState(type, self, part, params)
end
