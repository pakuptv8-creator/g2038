local rand = math.random
local LuaTimer = T(Lib, "LuaTimer")
local EmergencyConfig = T(Config, "EmergencyConfig")
local triggerTimes = {}
local allEmergencyData = EmergencyConfig:getAllCfg()
local EmergencyHelper = T(Lib, "EmergencyHelper")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function EmergencyHelper:init()
  self.effectStatus = {}
  self.kindlingList = {}
  Lib.subscribeEvent(Event.EVENT_UPDATE_HOUSE_INFO, function(allHouseInfo)
  end)
end

function EmergencyHelper:clearKindlingList(locationId)
  if self.kindlingList[locationId] then
    self.kindlingList[locationId] = nil
  end
end

function EmergencyHelper:addKindlingList(locationId, ownerId, partId, needRemove)
  if not self.kindlingList[locationId] then
    self.kindlingList[locationId] = {}
  end
  self.kindlingList[locationId][partId] = {
    locationId = locationId,
    ownerId = ownerId,
    partId = partId,
    needRemove = needRemove
  }
end

function EmergencyHelper:destroyKindlingPart(part)
  local partId = part:getInstanceID()
  for locationId, val in pairs(self.kindlingList) do
    for _, info in pairs(val) do
      if info.partId == partId then
        self.kindlingList[locationId][partId] = nil
      end
    end
  end
  self:removeEffectWithPart(part)
end

function EmergencyHelper:removeHouseKindling(locationId)
  if not locationId then
    return
  end
  for locationId, val in pairs(self.kindlingList) do
    for _, info in pairs(val) do
      if info.needRemove then
        local part = Instance.getByInstanceId(info.partId)
        if part and part:isValid() then
          PartManagerHelper:doDestroyPart(part)
        end
      end
    end
  end
end

function EmergencyHelper:getKindlingHouse(partId)
  local locationList = HouseManager:getLocationList()
  for locationId, val in pairs(self.kindlingList) do
    for _, info in pairs(val) do
      if info.partId == partId then
        local locationInfo = locationList[locationId]
        if locationInfo then
          local house = Instance.getByInstanceId(locationInfo.houseId)
          if house and house:isValid() then
            return house
          end
        end
      end
    end
  end
  return false
end

function EmergencyHelper:getEmergencyLocation()
  local temp = {}
  local list = HouseManager:getLocationList()
  local fireHouses = {}
  for _, v in pairs(self.effectStatus) do
    fireHouses[v.id] = true
  end
  for partId, v in pairs(list) do
    if v.ownerId and not fireHouses[partId] then
      temp[#temp + 1] = v
    end
  end
  if 0 < #temp then
    local targetIdx = rand(1, #temp)
    return temp[targetIdx]
  end
end

function EmergencyHelper:lightOnFireInHouse(partId, emergencyType, locationId, player)
  if self.effectStatus[partId] then
    return
  end
  local part = Instance.getByInstanceId(partId)
  local firePos = {}
  table.insert(firePos, part:getPosition())
  self.effectStatus[partId] = {
    partId = partId,
    emergencyType = emergencyType,
    id = locationId
  }
  WorldServer.BroadcastPacket({
    pid = "emergencyAppear",
    emergencyType = emergencyType,
    id = locationId,
    firePos = firePos
  })
  local kindlingInfo = self.kindlingList[locationId]
  if kindlingInfo and kindlingInfo[partId] and kindlingInfo[partId].ownerId ~= player.platformUserId then
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", player, Define.HEART_WARM_TASK_TYPE.FIRE_HOUSE)
  end
end

function EmergencyHelper:getEffectStatus()
  return self.effectStatus
end

function EmergencyHelper:clearEffectStatus(partId)
  if self.effectStatus[partId] then
    self.effectStatus[partId] = nil
  end
end

function EmergencyHelper:removeEmergencyEffect(locationId)
  if not locationId then
    return
  end
  for partId, v in pairs(self.effectStatus) do
    if v.id == locationId then
      self:clearEffectStatus(partId)
    end
  end
  WorldServer.BroadcastPacket({
    pid = "emergencyDisappear",
    id = locationId
  })
end

function EmergencyHelper:removeEffectWithPart(part)
  local partId = part:getInstanceID()
  local fireEffectInfo = self.effectStatus[partId]
  if fireEffectInfo then
    WorldServer.BroadcastPacket({
      pid = "delEmergencyEffect",
      type = Define.EMERGENCY_TYPE.FireDisaster,
      key = fireEffectInfo.id,
      posList = {
        part:getPosition()
      }
    })
    self:clearEffectStatus(partId)
  end
end

function EmergencyHelper:syncDataS2C(mapName, player)
  if mapName ~= "map001" then
    return
  end
  World.Timer(1, function()
    local effectStatus = EmergencyHelper:getEffectStatus()
    if next(effectStatus) ~= nil then
      local temp = {}
      for partId, v in pairs(effectStatus) do
        if not temp[v.id] then
          temp[v.id] = {}
        end
        if not temp[v.id][v.emergencyType] then
          temp[v.id][v.emergencyType] = {}
        end
        local part = Instance.getByInstanceId(partId)
        if part and part:isValid() then
          table.insert(temp[v.id][v.emergencyType], part:getPosition())
        end
      end
      for houseId, v in pairs(temp) do
        for emergencyType, pos in pairs(v) do
          player:sendPacket({
            pid = "emergencyAppear",
            emergencyType = emergencyType,
            id = houseId,
            firePos = pos
          })
        end
      end
    end
  end)
end

EmergencyHelper:init()
return EmergencyHelper
