local BrightnessScaleHelper = T(Lib, "brightnessScaleHelper")
local HouseConfig = T(Config, "HouseConfig")
local Player = _ENV.Player

function Player:onApplyHouse(params)
  local targetId = params.targetId
  if not HouseManager:verifyCreateCd(self.platformUserId) then
    return
  end
  if params.newTargetId and params.newTargetId ~= params.targetId then
    local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
    if info then
      HouseManager:onDismantleHouseByLocationId(id)
    end
    HouseManager:breakAwayFromLocation(self.platformUserId)
    targetId = params.newTargetId
  end
  if params.cfgName and not HouseManager:verifyHouseVip(self, targetId, params.cfgName, true) then
    return
  end
  local canOccupy = HouseManager:occupyLocation(self, targetId)
  if not canOccupy then
    return
  end
  return self:onOperationHouse(params)
end

local function anewApplyHouse(self, v, oldTargetId, oldId, id)
  local params = {
    cfgName = v.cfgName,
    targetId = id
  }
  if oldTargetId then
    params = {
      cfgName = v.cfgName,
      targetId = oldTargetId,
      newTargetId = id
    }
  end
  if oldId then
    self:sendPacket({
      pid = "againApplyHouse",
      params = params
    })
  else
    self:onApplyHouse(params)
  end
end

function Player:requestOpenHouseUI(params)
  local info, oldId = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info then
    return
  end
  local canOccupy, targetInfo, needPrivilege = HouseManager:occupyLocation(self, params.id, true)
  if not canOccupy then
    return
  end
  self:sendPacket({
    pid = "openHouseUI",
    landName = targetInfo.landName,
    targetId = params.id,
    oldTargetId = oldId
  })
end

function Player:onOpenHouseUI(type, target, params)
  if not target and not target:isValid() then
    return
  end
  local id = target:getInstanceID()
  local parent = target:getParent()
  if parent and parent:isValid() then
    id = parent:getInstanceID()
  end
  local canOccupy, targetInfo, needPrivilege = HouseManager:occupyLocation(self, id, true)
  local oldTargetId
  if not canOccupy then
    if needPrivilege then
      Plugins.CallTargetPluginFunc("business_model", "openBuyPrivilegeDialog", self, needPrivilege)
    end
    return
  end
  local info, oldId = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info then
    oldTargetId = oldId
  end
  if targetInfo.id ~= oldId then
    local houses = HouseConfig:getAllHouseByLandName(targetInfo.landName)
    for _, v in pairs(houses) do
      if v.default then
        anewApplyHouse(self, v, oldTargetId, oldId, id)
        return
      end
    end
  end
  self:sendPacket({
    pid = "openHouseUI",
    landName = targetInfo.landName,
    targetId = id,
    oldTargetId = oldTargetId
  })
end

function Player:onOperationHouse(params)
  local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info then
    if info.houseId then
      if params.isSwitch then
        if not HouseManager:verifyHouseVip(self, id, params.cfgName, true) then
          return
        end
        local is_Ad_free = 0
        if not HouseManager:verifyHouseVip(self, id, params.cfgName) then
          is_Ad_free = 1
        end
        HouseManager:switchHouseModel(id, params.cfgName, false, is_Ad_free)
        return true
      end
      if params.isDismantle then
        HouseManager:onDismantleHouseByLocationId(id)
      end
    else
      if not params or params.isDismantle then
        return
      end
      if not HouseManager:verifyHouseVip(self, id, params.cfgName, true) then
        return
      end
      local is_Ad_free = 0
      if not HouseManager:verifyHouseVip(self, id, params.cfgName) then
        is_Ad_free = 1
      end
      HouseManager:createHouse(self, id, params.cfgName, is_Ad_free)
    end
    return true
  end
  return
end

function Player:informCloseHouseUi()
  local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info and info.houseId then
    return
  end
  HouseManager:breakAwayFromLocation(self.platformUserId)
end

function Player:onHouseAreaMonitoring(type, target, params)
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    HouseManager:setVisitPlayers(self, target, true)
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    HouseManager:setVisitPlayers(self, target, false)
  end
  self:onAreaMonitoring(type, target, params)
end

function Player:onAreaMonitoring(type, target, params)
  if params[1] == "1" then
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
      local info = {
        name = target.name,
        time = os.time()
      }
      self:setPlayerCurArea(info)
      Plugins.CallTargetPluginFunc("report", "report", "enter_area", {
        job_id = self:getProfessionId()
      }, self)
      if not self.isFirstEnterArea then
        Plugins.CallTargetPluginFunc("report", "report", "first_area", nil, self)
        self.isFirstEnterArea = true
      end
      if target.name == "area_police_station1" then
        local professionId = self:getProfessionId()
        if professionId == Define.CareerType.Police and self:checkIsCarryOtherPlayer() then
          Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.POLICE_LOCK)
        end
      end
    elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
      local CurArea = self:getPlayerCurArea()
      if not Lib.table_is_empty(CurArea) then
        Plugins.CallTargetPluginFunc("report", "report", "leave_area", nil, self)
        self:setPlayerCurArea({})
      end
    end
  end
  if params[2] ~= "" then
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
      self:setPlaySpecialBgm(true)
      self:sendPacket({
        pid = "updateAreaBgm",
        key = params[2]
      })
    elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
      self:setPlaySpecialBgm(false)
      self:sendPacket({
        pid = "updateAreaBgm",
        key = "weather"
      })
    end
  end
  if tonumber(params[3]) then
    local brightnessScale
    if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
      brightnessScale = tonumber(params[3]) or 2
    elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
      brightnessScale = self._cfg.brightnessScale or 2
    end
    BrightnessScaleHelper:updateBrightnessScale(self.objID, brightnessScale)
  end
end

function Player:updateOneselfDoorState(target)
  HouseManager:updateDoorState(self.platformUserId, target)
end

function Player:removeFromMonitorUsingRecord()
  local curRecord = self:getMonitorUsingRecord()
  local size = Lib.getTableSize(curRecord)
  local has = curRecord[self.platformUserId] ~= nil
  if not has then
    return
  end
  size = size - 1
  self:removeMonitorUsingRecord(self.platformUserId)
  if size <= 0 then
    self.map:updateAllEntitiesViewDistance(-1)
  end
end

function Player:reconfirmApplyHouse(params)
  if params then
    self:onApplyHouse(params)
  end
end

function Player:onUpdateHouseGhost(type, target, params, isBreak)
  if not (target and target:isValid()) or not params then
    return
  end
  local ghostType = tonumber(params[1])
  local ghostAppearPoint = params[2]
  local ghostAppearInterval = tonumber(params[3])
  local ghostShowTime = tonumber(params[4])
  local ghostDetectorAreaName = params[5]
  if not (ghostType and ghostAppearPoint and ghostAppearInterval and ghostShowTime) or not ghostDetectorAreaName then
    print("!!!!!!!!!!!!!!! Player:onUpdateHouseGhost error ,params:", self.platformUserId, Lib.v2s(params))
    return
  end
  self:clearHouseGhostTimer(ghostType)
  if not isBreak then
    self.houseEventGhostPointIndex = 0
    local nodes = {}
    Lib.getInstanceAllChild(target:getParent(), nodes, Define.ABILITY.AABB, ghostAppearPoint)
    local nodesNum = #nodes
    if nodesNum < 1 then
      print("!!!!!!!!!!!!!!! Player:onUpdateHouseGhost error ,no ghostAppearPoint :", ghostAppearPoint, self.platformUserId)
      return
    end
    if not self.houseEventGhostTimer then
      self.houseEventGhostTimer = {}
    end
    self.houseEventGhostTimer[ghostType] = World.Timer(ghostAppearInterval * 20, function()
      local part = nodes[self.houseEventGhostPointIndex + 1]
      if not part or not part:isValid() then
        print("!!!!!!!!!!!!!!! Player:onUpdateHouseGhost,part not valid:", self.houseEventGhostPointIndex, self.platformUserId)
        self:clearHouseGhostTimer()
        return
      end
      part.isGhostAppear = true
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, self, true)
      self.houseEventGhostPointIndex = (self.houseEventGhostPointIndex + 1) % nodesNum
      local ghostDetectorAreaList = {}
      Lib.getInstanceAllChild(part:getParent(), ghostDetectorAreaList, Define.ABILITY.AABB, ghostDetectorAreaName)
      local ghostDetectorArea = ghostDetectorAreaList[1]
      HouseManager:notifyPlayerInGhostDetectorArea(ghostDetectorArea, false)
      World.Timer(ghostShowTime * 20, function()
        if part then
          part.isGhostAppear = nil
          HouseManager:notifyPlayerInGhostDetectorArea(ghostDetectorArea, true)
        end
      end)
      return true
    end)
  end
end

function Player:clearHouseGhostTimer(ghostType)
  if not self.houseEventGhostTimer then
    return
  end
  if not ghostType then
    for k, v in pairs(self.houseEventGhostTimer) do
      v()
      self.houseEventGhostTimer[k] = nil
      print("------------------------- Player:clearHouseGhostTimer    all", k, self.platformUserId)
    end
  elseif self.houseEventGhostTimer[ghostType] then
    self.houseEventGhostTimer[ghostType]()
    self.houseEventGhostTimer[ghostType] = nil
    print("------------------------- Player:clearHouseGhostTimer", self.platformUserId, ghostType)
  end
end

function Player:onEarthquake(type, target, params, isBreak)
  if not (target and target:isValid()) or not params then
    return
  end
  local shakeScale = tonumber(params[1]) or 0.2
  local shakeOnceDuration = math.max(0.01, tonumber(params[2]) or 0.5)
  local shakeTimeMin = tonumber(params[3]) or 2
  local shakeTimeMax = tonumber(params[4]) or 4
  local shakeWaitTimeMin = tonumber(params[5]) or 3
  local shakeWaitTimeMax = tonumber(params[6]) or 6
  local shakeEffectPoint = params[7]
  local shakeStamp = 0
  self:clearHouseEarthquakeTimer()
  if not isBreak then
    local nodes = {}
    Lib.getInstanceAllChild(target:getParent(), nodes, Define.ABILITY.AABB, shakeEffectPoint)
    local curShakeTime, curWaitTime = self:nextShakeRandomTime(shakeTimeMin, shakeTimeMax, shakeWaitTimeMin, shakeWaitTimeMax)
    self.houseEarthquakeTimer = World.Timer(10, function()
      if os.time() - shakeStamp >= curShakeTime + curWaitTime then
        local shakeCount = math.max(1, math.floor(curShakeTime / shakeOnceDuration))
        local playerInHouse = self:getPlayerInMyHouse()
        for _, player in pairs(playerInHouse) do
          if player:isValid() then
            player:sendPacket({
              pid = "onEarthquakeS2C",
              scale = shakeScale,
              duration = shakeOnceDuration,
              count = shakeCount
            })
          end
        end
        for _, part in pairs(nodes) do
          if not part:isValid() then
            print("!!!!!!!!!!!!!!! Player:onEarthquake,part not valid:", self.platformUserId)
            self:clearHouseEarthquakeTimer()
            return
          end
          Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, self, true)
        end
        shakeStamp = os.time()
        curShakeTime, curWaitTime = self:nextShakeRandomTime(shakeTimeMin, shakeTimeMax, shakeWaitTimeMin, shakeWaitTimeMax)
      end
      return true
    end)
  end
end

function Player:nextShakeRandomTime(shakeTimeMin, shakeTimeMax, shakeWaitTimeMin, shakeWaitTimeMax)
  local curShakeTime = math.random(shakeTimeMin, shakeTimeMax)
  local curWaitTime = math.random(shakeWaitTimeMin, shakeWaitTimeMax)
  return curShakeTime, curWaitTime
end

function Player:clearHouseEarthquakeTimer()
  print("------------------------- Player:clearHouseEarthquakeTimer", self.houseEarthquakeTimer, self.platformUserId)
  if self.houseEarthquakeTimer then
    self.houseEarthquakeTimer()
    self.houseEarthquakeTimer = nil
  end
end

function Player:getPlayerInMyHouse()
  local info, id = HouseManager:inquireLocationInfoByPlatformUserId(self.platformUserId)
  if info and info.houseId and HouseManager.visitPlayers then
    return HouseManager.visitPlayers[id] or {}
  else
    return {}
  end
end
