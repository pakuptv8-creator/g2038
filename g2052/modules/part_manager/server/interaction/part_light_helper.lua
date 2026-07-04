local PartLightHelper = T(Lib, "PartLightHelper")
local LuaTimer = T(Lib, "LuaTimer")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local EmergencyHelper = T(Lib, "EmergencyHelper")

function PartLightHelper:init()
  self.lightPartList = {}
end

function PartLightHelper:updateLightFireState(player, part, params)
  local partId = part:getInstanceID()
  local fireEffectNames = Lib.splitString(params[1], "#")
  local effectCount = #fireEffectNames
  local effectIndex = 1
  local effectInfo = self.lightPartList[partId]
  if effectInfo then
    effectIndex = effectInfo.effectIndex + 1
    if effectCount < effectIndex then
      self:removeOnePartLight(partId)
      return
    else
      self:removeOnePartLight(partId)
    end
  end
  local fireEffectName = fireEffectNames[effectIndex]
  local scale = tonumber(params[2]) == 0 and 1 or tonumber(params[2])
  local igniteIdx = tonumber(params[3]) or -1
  local triggerAssociatedName = params[4]
  local triggerDelayTime = tonumber(params[5]) or 0
  local fireSoundArr = Lib.splitString(params[6] or "", "#")
  local fireSoundConf = Lib.splitString(fireSoundArr[effectIndex] or "", ",")
  local yaw = part:getLocalRotation().y
  if fireEffectName == "g2052_kaolu_fire1.effect" or fireEffectName == "g2052_kaolu_fire2.effect" then
    local houseModel = part:findFirstAncestor("house")
    if houseModel then
      local houseId = houseModel:getInstanceID()
      local locationList = HouseManager:getLocationList() or {}
      local targetHouseInfo
      for _, houseInfo in pairs(locationList) do
        if houseInfo.houseId and houseInfo.houseId == houseId then
          targetHouseInfo = houseInfo
          break
        end
      end
      if targetHouseInfo and targetHouseInfo.initPosInfo and targetHouseInfo.initPosInfo.yaw then
        yaw = yaw - targetHouseInfo.initPosInfo.yaw
      end
    end
  end
  local firePos = part:getPosition()
  local partName = part:getProperty("name")
  local lightInfo = {
    effectName = fireEffectName,
    firePos = firePos,
    scale = scale,
    yaw = yaw,
    effectIndex = effectIndex,
    showMapName = World.cfg.defaultMap or "map001",
    lastMapName = World.cfg.defaultMap or "map001",
    action = "play"
  }
  WorldServer.BroadcastPacket({
    pid = "partLightOnFireState",
    effectName = lightInfo.effectName,
    firePos = lightInfo.firePos,
    scale = lightInfo.scale,
    yaw = lightInfo.yaw,
    action = "play",
    soundName = fireSoundConf[1],
    soundVolume = tonumber(fireSoundConf[2])
  })
  self.lightPartList[partId] = lightInfo
  if effectCount == 1 or 1 < effectCount and 1 < effectIndex then
    part.fireState = "onFire"
  end
  local houseModel = EmergencyHelper:getKindlingHouse(partId)
  houseModel = houseModel or part:findFirstAncestor("house")
  if houseModel then
    if igniteIdx ~= -1 and effectIndex ~= igniteIdx then
      return
    end
    if triggerAssociatedName ~= "" then
      local function triggerEventCall()
        if not part or not part:isValid() then
          return
        end
        local partId = part:getInstanceID()
        local effectInfo = self.lightPartList[partId]
        if not effectInfo then
          return
        elseif igniteIdx ~= -1 and effectInfo.effectIndex ~= igniteIdx then
          return
        end
        local nodes = {}
        local parent = part:getParent()
        Lib.getInstanceAllChild(parent or part, nodes, Define.ABILITY.AABB, triggerAssociatedName)
        for _, part in pairs(nodes) do
          if part and part:isValid() and player:isValid() then
            Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, player, true)
          end
        end
      end
      
      if 0 < triggerDelayTime then
        LuaTimer:scheduleTimer(function()
          triggerEventCall()
        end, triggerDelayTime * 1000, 1)
      else
        triggerEventCall()
      end
    else
      LuaTimer:scheduleTimer(function()
        if not part or not part:isValid() then
          return
        end
        if not houseModel:isValid() then
          return
        end
        if not self.lightPartList[partId] then
          return
        end
        local locationData
        local instanceId = houseModel:getInstanceID()
        local locationList = HouseManager:getLocationList()
        for _, v in pairs(locationList) do
          if v.houseId == instanceId then
            locationData = v
            break
          end
        end
        if locationData then
          local EmergencyHelper = T(Lib, "EmergencyHelper")
          EmergencyHelper:lightOnFireInHouse(partId, Define.EMERGENCY_TYPE.FireDisaster, locationData.id, player)
        end
      end, World.cfg.fireTriggerTime * 1000, 1)
    end
  end
end

function PartLightHelper:removeOnePartLight(partId)
  local effectInfo = self.lightPartList[partId]
  if not effectInfo then
    return
  end
  WorldServer.BroadcastPacket({
    pid = "partLightOnFireState",
    effectName = effectInfo.effectName,
    firePos = effectInfo.firePos,
    action = "del"
  })
  self.lightPartList[partId] = nil
  local part = Instance.getByInstanceId(partId)
  if part then
    part.fireState = nil
  end
end

function PartLightHelper:updateAllClientEffect(mapName, player)
  local dataList = {}
  for partID, effectInfo in pairs(self.lightPartList) do
    local temp = Lib.copy(effectInfo)
    if mapName ~= temp.showMapName then
      temp.action = "del"
      self.lightPartList[partID].lastMapName = mapName
      table.insert(dataList, temp)
    elseif mapName ~= temp.lastMapName then
      temp.action = "play"
      self.lightPartList[partID].lastMapName = mapName
      table.insert(dataList, temp)
    end
  end
  local packet = {
    pid = "SCPushPartLightState",
    dataList = dataList
  }
  player:sendPacket(packet)
end

function PartLightHelper:loginSyncLightState(player)
  local dataList = {}
  for partID, effectInfo in pairs(self.lightPartList) do
    table.insert(dataList, effectInfo)
  end
  local packet = {
    pid = "SCPushPartLightState",
    dataList = dataList
  }
  player:sendPacket(packet)
end

function PartLightHelper:getLightInfoByPartId(partId)
  return self.lightPartList[partId]
end

function PartLightHelper:removePartInteractState(part)
  local partID = part:getInstanceID()
  self:removeOnePartLight(partID)
end
