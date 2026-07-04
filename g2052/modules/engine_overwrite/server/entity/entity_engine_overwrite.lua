local EntityServer = _ENV.EntityServer
local WeatherCtrl = T(Lib, "WeatherCtrl")
local InteractionHelper = T(Lib, "InteractionHelper")
local borderVertex = {
  Lib.v2(-222, -292),
  Lib.v2(-222, 180),
  Lib.v2(220, 180),
  Lib.v2(364, 35),
  Lib.v2(364, -292)
}

local function pointInRegion(point, vertexTab)
  local crossCount = 0
  local len = #vertexTab
  for i = 1, len do
    local p1 = vertexTab[i]
    local p2 = vertexTab[i + 1]
    p2 = p2 or vertexTab[i + 1 - len]
    local isContinue = false
    if p1.y == p2.y then
      isContinue = true
    end
    if point.y < math.min(p1.y, p2.y) then
      isContinue = true
    end
    if point.y >= math.max(p1.y, p2.y) then
      isContinue = true
    end
    if isContinue == false then
      local x = (point.y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y) + p1.x
      if x > point.x then
        crossCount = crossCount + 1
      end
    end
  end
  if crossCount % 2 == 1 then
    return true
  else
    return false
  end
end

function EntityServer:rideOn(target, ctrl, targetIndex)
  if target and target.curHp and target.curHp <= 0 then
    target = nil
  end
  if not self:isValid() then
    return
  end
  if target and target:isValid() then
    local interactPlayerHorseID = self:getInteractPlayerHorseID()
    if 0 < interactPlayerHorseID then
      self:onlyClearPlayerHorse()
    end
  end
  if 0 < self.rideOnId then
    local old = self.world:getEntity(self.rideOnId)
    if old == target then
      return
    end
    if old and old:isValid() then
      local rps = old:cfg().ridePos or {}
      if not rps[self.rideOnIdx + 1] then
        print("Invalid config of ridePos, entity:" .. old:cfg().fullName .. ", index:" .. self.rideOnIdx + 1)
        return
      end
      if rps[self.rideOnIdx + 1].ctrl then
        old:setPlayerControl(old)
      end
      if rps[self.rideOnIdx + 1].buff then
        self:removeTypeBuff("fullName", rps[self.rideOnIdx + 1].buff)
      end
      old:data("passengers")[self.rideOnIdx + 1] = nil
      Trigger.CheckTriggers(old:cfg(), "ENTITY_RIDE_OFF", {
        obj1 = old,
        obj2 = self,
        ctrl = rps[self.rideOnIdx + 1].ctrl
      })
      self:sendPacketToTracking({
        pid = "EntityRideOff",
        objID = self.objID,
        rideOffId = old.objID
      }, true)
      if self:isControl() then
        self:rideOff(old.objID)
      end
    end
    self:setRideOn(0, 0)
  elseif not target then
    return
  end
  if target and target:isValid() then
    local rps = target:cfg().ridePos or {}
    local passengers = target:data("passengers")
    local idx, ctrlIdx
    for i, tb in ipairs(rps) do
      if rps[i].ctrl then
        ctrlIdx = i
      end
      if not passengers[i] and (ctrl == nil or tb.ctrl == ctrl) and (targetIndex == nil or i == targetIndex) and idx == nil then
        idx = i
      end
    end
    if idx then
      passengers[idx] = self.objID
      self:setRideOn(target.objID, idx - 1)
      if rps[idx].ctrl then
        target:setPlayerControl(self)
      end
      if rps[idx].buff then
        self:addBuff(rps[idx].buff)
      end
      Trigger.CheckTriggers(target:cfg(), "ENTITY_RIDE_ON", {
        obj1 = target,
        obj2 = self,
        ctrl = rps[idx].ctrl
      })
      if not target.isPlayer then
        if 0 < target.rideOnId then
          local ctrlEntity = self.world:getEntity(target.rideOnId)
          if ctrlEntity.isPlayer then
            Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", ctrlEntity, Define.HEART_WARM_TASK_TYPE.CAR_OTHERS)
          end
        elseif 1 < #passengers and passengers[ctrlIdx] then
          local ctrlEntity = self.world:getEntity(passengers[ctrlIdx])
          if ctrlEntity and ctrlEntity.isPlayer then
            Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", ctrlEntity, Define.HEART_WARM_TASK_TYPE.CAR_OTHERS)
          end
        end
      end
    else
      return
    end
  end
  local packet = {
    pid = "EntityRideOn",
    objID = self.objID,
    rideOnId = self.rideOnId,
    rideOnIdx = self.rideOnIdx
  }
  self:sendPacketToTracking(packet, true)
  self:incCtrlVer()
  self:syncSkillMap()
end

local oldSetMapPos = EntityServer.setMapPos

function EntityServer:setMapPos(map, pos, yaw, pitch, canRide, cameraParam)
  if not self or not self:isValid() then
    return
  end
  if self:getInteractPlayerHorseID() > 0 then
    canRide = true
  end
  if self.stopPartInteraction then
    self:stopPartInteraction()
  end
  if self.stopSwing then
    self:stopSwing()
  end
  if self.stopSlideLadderInteract then
    self:stopSlideLadderInteract()
  end
  if self.SetForceSwim then
    self:SetForceSwim(false)
  end
  local isDelay = false
  if self.rideOnInstanceId then
    isDelay = true
  end
  if self.leaveFixedPointVehicle then
    self:leaveFixedPointVehicle(true)
  end
  InteractionHelper:tryClearCatchRobberRide(self)
  
  local function execute()
    local oldMapName = self.map and self.map.name or ""
    oldSetMapPos(self, map, pos, yaw, pitch, canRide, cameraParam)
    local newMapName = self.map.name
    if self.isPlayer and oldMapName ~= newMapName then
      WeatherCtrl:sendWeatherInfo(self)
      if newMapName == "map001" then
        HouseManager:syncLocationInfo(self.platformUserId)
      end
    end
  end
  
  if isDelay then
    World.Timer(1, function()
      if not self or not self:isValid() then
        return
      end
      execute()
    end)
  else
    execute()
  end
end
