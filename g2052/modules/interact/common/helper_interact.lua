local Interact = T(World, "Interact")
local InteractCounter = T(World, "InteractCounter")
local InteractEventConfig = T(Config, "InteractEventConfig")
local ConditionCheckUtils = T(Lib, "ConditionCheckUtils")
local PartInteractHelper = T(Lib, "PartInteractHelper")
local WeatherMgr = T(Lib, "WeatherMgr")
local GameTimes = T(Lib, "GameTimes")
local InteractSoundHelper = T(Lib, "InteractSoundHelper")
local dayFollowsNightTimes = World.cfg.dayFollowsNightTimes or {morning = 4, night = 19}
local partInteractPopInfo = World.cfg.partInteractPopInfo or {}

local function getOffsetPos(entity, offset)
  local offsetPos = entity:getFrontPos(offset, true, true)
  return offsetPos
end

function Entity:setDistanceDynamicInfo(from)
  if not (self and self:isValid()) or not self:cfg().nearProps then
    return
  end
  if not from then
    if World.isClient then
      from = Me
    else
      Lib.logError("no from, distance error", debug.traceback())
    end
  end
  local nearProps = self:cfg().nearProps
  local centerOffset = self:cfg().nearPropsCenterOffset or {}
  if not self:data("main").distanceInfo then
    self:data("main").distanceInfo = {
      timer = nil,
      radiusSth = {}
    }
  end
  local distanceInfo = self:data("main").distanceInfo
  if distanceInfo.timer then
    distanceInfo.timer()
  end
  distanceInfo.timer = nearProps and next(nearProps) and self:lightTimer("npc_say_hi_and_effect_timer", 10, function()
    local posSelf = self:getPosition()
    for radius, val in pairs(nearProps) do
      radius = tonumber(radius)
      local distance
      if centerOffset[tostring(radius)] then
        distance = Lib.getPosDistance(getOffsetPos(self, tonumber(centerOffset[radius])), Me:getPosition())
      else
        distance = Lib.getPosDistance(posSelf, Me:getPosition())
      end
      if radius >= distance and not distanceInfo.radiusSth[radius] then
        Interact.tryInteract(self, val, from)
        distanceInfo.radiusSth[radius] = true
      elseif radius < distance and distanceInfo.radiusSth[radius] then
        Interact.tryInteract(self, val, from, {disable = true})
        distanceInfo.radiusSth[radius] = false
      end
    end
    return true
  end)
end

local function getPartInteractPopCount(self)
  local count = 0
  for i, v in pairs(self.curPartInteractPop) do
    count = count + 1
  end
  return count
end

function Entity:checkPartIsCanShowInteractPop(part)
  local partId = part:getInstanceID()
  local existInteract = InteractEventConfig:verifyInteractType(part.name, Define.PART_INTERACT_TYPE.POP_CLICKED)
  if not existInteract then
    return false
  end
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  return PartManagerHelper:IsCanShowInteractPopForMe(partId)
end

function Entity:checkPartIsCanClickInteractPop(part)
  local partId = part:getInstanceID()
  local existInteract = InteractEventConfig:verifyClickInteractTip(part.name, Define.PART_INTERACT_TYPE.CLICKED)
  if not existInteract then
    return false
  end
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  return PartManagerHelper:IsCanShowInteractPopForMe(partId)
end

function Entity:removePartInteractPop(partId)
  if not self.curPartInteractPop[partId] then
    return
  end
  local removeFun = self.curPartInteractPop[partId].removeFun
  if removeFun then
    removeFun()
  end
  if self.curPartInteractPop[partId].isTv then
    self:sendPacket({
      pid = "CloseTelevision"
    })
  end
  self.curPartInteractPop[partId] = nil
end

local function checkForDisplacement(id, oldPos)
  local part = Instance.getByInstanceId(id)
  if part and part:isValid() then
    local pos = part:getPosition()
    if pos ~= oldPos then
      return true
    end
  end
  return false
end

local function verifyPartInteractDistance(self, MePos)
  local curPos = self:getPosition()
  local range = partInteractPopInfo.tipRange or 5
  local offset = Lib.v3(range, range, range)
  local minPos = curPos - offset
  local maxPos = curPos + offset
  local map = self.map
  local parts = map:getTouchParts(minPos, maxPos)
  local maxPartClickInteractTip = partInteractPopInfo.maxClickTipCount or 6
  local canClickList = {}
  if self.curPartClickInteractionTip then
    local PartManagerHelper = T(Lib, "PartManagerHelper")
    for id, v in pairs(self.curPartClickInteractionTip) do
      if range < (Lib.v3(MePos.x, MePos.y, MePos.z) - v.pos):len() then
        self:closePartClickInteractionTip(id)
      elseif not PartManagerHelper:IsCanShowInteractPopForMe(v.partID) then
        self:closePartClickInteractionTip(id)
      elseif checkForDisplacement(id, v.partPos) then
        self:closePartClickInteractionTip(id)
      end
    end
  else
    self.curPartClickInteractionTip = {}
  end
  for i, part in pairs(parts or {}) do
    if self:checkPartIsCanClickInteractPop(part) then
      local temp = {
        partID = part:getInstanceID(),
        distance = (Lib.v3(MePos.x, MePos.y, MePos.z) - part:getPosition()):len()
      }
      table.insert(canClickList, temp)
    end
  end
  table.sort(canClickList, function(a, b)
    return a.distance < b.distance
  end)
  local canShowClickTip = {}
  for i = 1, #canClickList do
    local partID = canClickList[i].partID
    if i <= maxPartClickInteractTip then
      canShowClickTip[partID] = true
      if not self.curPartClickInteractionTip[partID] then
        Me:showPartClickInteractionTip(partID)
      end
    end
  end
  for partID, v in pairs(self.curPartClickInteractionTip) do
    if not canShowClickTip[partID] then
      self:closePartClickInteractionTip(partID)
    end
  end
end

function Entity:startScanningSurroundingParts(immediately)
  if not self.surroundingCd then
    self.surroundingCd = 20
  end
  self.surroundingCd = self.surroundingCd - 1
  if self.surroundingCd > 0 and not immediately then
    return
  end
  self.surroundingCd = 20
  local curPos = self:getPosition()
  local range = partInteractPopInfo.range or 5
  local offset = Lib.v3(range, range, range)
  local minPos = curPos - offset
  local maxPos = curPos + offset
  local map = self.map
  if not map or not map.getTouchParts then
    return
  end
  local parts = map:getTouchParts(minPos, maxPos)
  local MePos = self:getPosition()
  if self.curPartInteractPop then
    local PartManagerHelper = T(Lib, "PartManagerHelper")
    for id, v in pairs(self.curPartInteractPop) do
      local newRange = v.isTv and 20 or range
      if newRange < (Lib.v3(MePos.x, MePos.y, MePos.z) - v.pos):len() then
        self:removePartInteractPop(id)
      elseif not PartManagerHelper:IsCanShowInteractPopForMe(v.partID) then
        self:removePartInteractPop(id)
      end
    end
  else
    self.curPartInteractPop = {}
  end
  local maxPartInteractPop = partInteractPopInfo.maxCount or 3
  local canShowList = {}
  for i, part in pairs(parts or {}) do
    if self:checkPartIsCanShowInteractPop(part) then
      local temp = {
        partID = part:getInstanceID(),
        distance = (Lib.v3(MePos.x, MePos.y, MePos.z) - part:getPosition()):len()
      }
      table.insert(canShowList, temp)
    end
  end
  table.sort(canShowList, function(a, b)
    return a.distance < b.distance
  end)
  local canShowPartID = {}
  for i = 1, #canShowList do
    local partID = canShowList[i].partID
    if i <= maxPartInteractPop then
      canShowPartID[partID] = true
      if not self.curPartInteractPop[partID] then
        Me:showPartInteractionUI(partID)
      end
    end
  end
  for partID, v in pairs(self.curPartInteractPop) do
    if not canShowPartID[partID] and not self.curPartInteractPop[partID].isTv then
      self:removePartInteractPop(partID)
    end
  end
  verifyPartInteractDistance(self, MePos)
  self:checkPlayerIsIndoors()
  self:checkDiurnalChange()
end

function Entity:checkPlayerIsIndoors()
  local mainCamera = CameraManager.Instance():findCamera("mainCamera")
  if not mainCamera then
    return
  end
  local chestPos = Lib.copy(mainCamera:getPosition())
  local pos = self:getPosition()
  if chestPos.y < pos.y + 0.5 then
    chestPos.y = pos.y + 0.5
  end
  local chestResult = self.map:getPhysicsWorld():raycast(chestPos, Lib.v3(0, 1, 0), 20, -1) or {}
  local inIndoor = self:getInIndoor()
  if inIndoor ~= (chestResult.targetType ~= 0) then
    if not Lib.isG2052ModOrEditor() then
      WeatherMgr:playerEnterIndoor(chestResult.targetType ~= 0)
    end
    self:setInIndoor(chestResult.targetType ~= 0)
  end
end

function Entity:checkDiurnalChange()
  local curTime = GameTimes:GetTime()
  local isNight = curTime.hour >= dayFollowsNightTimes.night or curTime.hour <= dayFollowsNightTimes.morning
  if isNight ~= self.isNight then
    self:alternatingDayAndNight(isNight)
  end
end

function Interact.exec(prop, target, from, params)
  if prop.sync == "client" and World.isClient or prop.sync == "server" and World.isGameServer or prop.sync == "both" then
    if Interact[prop.func] and Interact[prop.func](target, prop.params, from, not params.disable, params) and prop.executionCallback then
      Interact.tryInteract(target, prop.executionCallback, from, params)
    end
  elseif params.noSync then
    if (prop.sync == "all" or prop.sync == "dungeon" and World.isClient) and Interact[prop.func] and Interact[prop.func](target, prop.params, from, not params.disable, params) and prop.executionCallback then
      Interact.tryInteract(target, prop.executionCallback, from, params)
    end
    return
  elseif prop.sync == "all" then
    if World.isClient then
      Me:sendPacket({
        pid = "interactBroadcast",
        targetID = target and target.objID,
        prop = prop,
        disable = params.disable
      })
    else
      WorldServer.BroadcastPacket({
        pid = "interact",
        targetID = target and target.objID,
        fromID = from.objID,
        prop = prop,
        disable = params.disable
      })
    end
  elseif prop.sync == "dungeon" then
    if World.isClient then
      Me:sendPacket({
        pid = "interactDungeonBroadcast",
        targetID = target and target.objID,
        fromID = from.objID,
        prop = prop,
        disable = params.disable
      })
    else
      local map
      if target and target:isValid() then
        map = target.map
      elseif from and from:isValid() then
        map = from.map
      end
      if map then
        local packet = {
          pid = "interact",
          targetID = target and target.luaObjID,
          fromID = from.objID,
          prop = prop,
          disable = params.disable
        }
        Plugins.CallTargetPluginFunc("dungeon", "dungeonBroadcastPacketByMap", map, packet)
      else
        print("dungeon no map !!!!!!!!!!!!!!!!!!!!!!!!!!!")
      end
    end
  else
    if not (from and from:isValid()) or not from.isPlayer then
      return
    end
    from:sendPacket({
      pid = "interact",
      targetID = target and target:isValid() and target.objID,
      fromID = from.objID,
      prop = prop,
      disable = params.disable,
      params = params
    })
  end
end

function Interact.getKey(prop, target, from)
  local key = prop.counterLimit.type .. "_" .. prop.counterLimit.key
  if prop.counterLimit.type == "self" then
    local id = target.id or target.objID or 0
    key = id .. "_" .. key
  elseif prop.counterLimit.type == "dungeon" then
    if not from:getDungeonId() then
      Lib.logError("tower data", from:getTowerData())
      return
    end
    key = from:getDungeonId() .. "_" .. key
  end
  return key
end

function Interact.incrCounter(key)
  if not InteractCounter[key] then
    InteractCounter[key] = 0
  end
  InteractCounter[key] = InteractCounter[key] + 1
  return InteractCounter[key]
end

function Interact.getCounter(key)
  if not InteractCounter[key] then
    InteractCounter[key] = 0
  end
  return InteractCounter[key]
end

function Interact.deleteCounter(keyType, id)
  local isNumber = type(id) == "number"
  for key, v in pairs(InteractCounter) do
    local t = Lib.split(key, "_")
    if isNumber then
      t[1] = tonumber(t[1])
    end
    if t[1] == id and keyType == t[2] then
      InteractCounter[key] = nil
    end
  end
end

function Interact.checkLimit(prop, target, from, disable)
  if prop.counterLimit then
    local key = Interact.getKey(prop, target, from)
    if not key then
      return false
    end
    local count = Interact.getCounter(key)
    Interact.incrCounter(key)
    if prop.counterLimit.counterMax and count > prop.counterLimit.counterMax then
      Lib.logDebug("counter too many, ignore ", key, count, prop.counterLimit.counterMax, prop)
      if prop.invalidCallback then
        Interact.tryInteract(target, prop.invalidCallback, from, disable)
      end
      return true
    end
    if prop.counterLimit.counterMin and count < prop.counterLimit.counterMin then
      Lib.logDebug("counter too less, ignore", key, count, prop.counterLimit.counterMin, prop)
      if prop.invalidCallback then
        Interact.tryInteract(target, prop.invalidCallback, from, disable)
      end
      return true
    end
  end
  return false
end

function Interact.tryOneInteractTarget(target, prop, from, params)
  local canInteract = true
  if not Lib.canMeetTheCondition(target, from, prop.conditions) then
    canInteract = false
  end
  if canInteract and Interact.checkLimit(prop, target, from, params.disable) then
    canInteract = false
  end
  if canInteract then
    local prop = Lib.copy(prop)
    if prop.delay and prop.delay > 0 then
      World.Timer(prop.delay, function()
        Interact.exec(prop, target, from, params)
      end)
    else
      Interact.exec(prop, target, from, params)
    end
  elseif prop.invalidCallback then
    Interact.tryInteract(target, prop.invalidCallback, from, params)
  end
end

function Interact.tryInteract(target, props, from, params)
  params = params or {}
  for index, prop in ipairs(props or {}) do
    if type(prop) ~= "table" then
      prop = InteractEventConfig:getCfgById(prop)
      prop.params.useCsv = true
    end
    if prop.entityTargets and next(prop.entityTargets) then
      local entityList
      if World.isClient then
        entityList = World.CurWorld:getAllEntity()
      else
        local map = target and target.map
        map = map or from and from.map
        entityList = map.objects
      end
      if not entityList then
        Interact.tryOneInteractTarget(target, prop, from, params)
        return
      end
      for _, obj in pairs(entityList) do
        if prop.entityTargets[obj:cfg().fullName or ""] then
          Interact.tryOneInteractTarget(obj, prop, from, params)
        end
      end
    else
      Interact.tryOneInteractTarget(target, prop, from, params)
    end
  end
end

local function isSameRelation(list1, list2)
  if #list1 == #list2 then
    table.sort(list1)
    table.sort(list2, function(a, b)
      return a.name < b.name
    end)
    for key1, name1 in pairs(list1) do
      if not list2[key1] or name1 ~= list2[key1].name then
        return false
      end
    end
    return true
  else
    return false
  end
end

function Interact.tryPartInteract(type, target, from, forceTrigger, isBreak)
  if not target or not target:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  local partName = target:getProperty("name")
  if not partName then
    return
  end
  local prop = InteractEventConfig:getCfgById(partName)
  if not prop then
    return
  end
  if not from[prop.func] then
    return
  end
  if not (prop.sync ~= "client" or World.isClient) or prop.sync == "server" and World.isClient then
    return
  end
  local tartPartId = target:getInstanceID()
  if not forceTrigger and type == Define.PART_INTERACT_TYPE.CLICKED and not prop.canClicked then
    return
  end
  if isBreak == nil then
    if target.isInteracting then
      isBreak = true
    end
  elseif not target.isInteracting then
    isBreak = nil
  end
  if not ConditionCheckUtils.checkEventCanInteract(type, from, target, prop, forceTrigger, isBreak) then
    return
  end
  if World.isClient and prop.sync == "client" then
    if from[prop.func] then
      from[prop.func](from, type, target, prop.params, isBreak)
    end
    if prop.triggerSound and not isBreak then
      InteractSoundHelper:playSound({
        instanceId = tartPartId,
        triggerType = "triggerSound",
        isToOthers = true
      })
    end
    if prop.breakSound and (isBreak or target.isInteracting) then
      InteractSoundHelper:playSound({
        instanceId = tartPartId,
        triggerType = "breakSound",
        isToOthers = true
      })
    end
  elseif not World.isClient and prop.sync == "server" then
    if prop.triggerSound then
      if isBreak then
        InteractSoundHelper:stopSound({
          instanceId = tartPartId,
          triggerType = "triggerSound",
          isFollow = true
        })
      else
        InteractSoundHelper:playSound({
          instanceId = tartPartId,
          triggerType = "triggerSound",
          isFollow = true
        })
      end
    end
    if prop.breakSound and (isBreak or target.isInteracting) then
      InteractSoundHelper:playSound({
        instanceId = tartPartId,
        triggerType = "breakSound",
        isFollow = true
      })
    end
    if from[prop.func] then
      local defaultData = {
        event_name = target.name,
        job_id = from:getProfessionId()
      }
      from[prop.func](from, type, target, prop.params, isBreak)
      if prop.eventReport == 1 then
        Plugins.CallTargetPluginFunc("report", "report", "event_call", defaultData, from)
      end
    end
  end
  if isBreak then
    target.isInteracting = false
  else
    target.isInteracting = not target.isInteracting
  end
  if target.isInteracting then
    target.lastTriggerInteractTime = os.time()
  end
  if target.isInteracting and prop.nextInteract then
    target.interactEventCDTime = math.ceil(prop.nextInteract[3] / 20)
    if target.nextInteractTimer then
      target.nextInteractTimer()
      target.nextInteractTimer = nil
    end
    target.nextInteractTimer = World.Timer(prop.nextInteract[1], function()
      if target and target:isValid() then
        local triggerPart = {}
        if prop.nextInteract[2] and prop.nextInteract[2] ~= "" then
          local parent = target:getParent()
          Lib.getInstanceAllChild(parent, triggerPart, Define.ABILITY.AABB, prop.nextInteract[2], true)
        end
        for _, v in pairs(triggerPart or {}) do
          if v and v:isValid() then
            Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, v, from, true, false)
          end
        end
        target.nextInteractTimer = nil
      end
    end)
  end
  if prop.bindRelation then
    local childPart = {}
    local parent = target:getParent()
    for _, name in pairs(prop.bindRelation) do
      Lib.getInstanceAllChild(parent, childPart, Define.ABILITY.AABB, name)
    end
    if 0 < #childPart then
      local partList = {}
      for _, v in pairs(childPart or {}) do
        if v and v:isValid() then
          table.insert(partList, v:getInstanceID())
        end
      end
      table.insert(partList, target:getInstanceID())
      Plugins.CallTargetPluginFunc("part_manager", "updateBindPlayerPartList", partList, from.objID, target.isInteracting)
    end
  end
  if prop.controlCascade then
    local childPart = {}
    local parent = target:getParent()
    local PartManagerShow = T(Lib, "PartManagerShow")
    for _, name in pairs(prop.controlCascade) do
      local isCascade = InteractEventConfig:isCascadeRelation(name, target.name)
      if isCascade then
        Lib.getInstanceAllChild(parent, childPart, Define.ABILITY.AABB, name)
        PartManagerShow:updateParentChildList(parent, childPart)
      end
    end
    if 0 < #childPart then
      for _, v in pairs(childPart or {}) do
        if v and v:isValid() then
          Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, v, from)
        end
      end
    end
  end
  Plugins.CallTargetPluginFunc("part_manager", "updatePartInteractPlayer", target, from.objID, target.isInteracting)
  Plugins.CallTargetPluginFunc("interaction_ui", "updatePlayerInteractPart", from, tartPartId, target.isInteracting)
end

function Interact.partWithPartInteract(type, fromPart, targetPart)
  if not (fromPart and fromPart:isValid()) or not fromPart.properties then
    return
  end
  local fromPartName = fromPart.properties.name
  if not fromPartName then
    return
  end
  local prop = InteractEventConfig:getCfgById(fromPartName)
  if not prop then
    return
  end
  if World.isClient and prop.sync == "client" then
  elseif not World.isClient and prop.sync == "server" then
    if fromPart.isInteractLock then
      Lib.logDebug("---isInteractLock---")
      return
    end
    if PartInteractHelper[prop.func] then
      PartInteractHelper[prop.func](type, fromPart, targetPart, prop.params)
    end
  end
end

return Interact
