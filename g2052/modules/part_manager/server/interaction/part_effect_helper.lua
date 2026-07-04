local PartEffectHelper = T(Lib, "PartEffectHelper")
local LuaTimer = T(Lib, "LuaTimer")

function PartEffectHelper:init()
  self.effectPartList = {}
end

function PartEffectHelper:addOnePartEffect(part, params)
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  local pos = part:getPosition()
  local effectName = params[1]
  local posOffset = Lib.v3(0, 0, 0)
  if params[2] ~= "" then
    posOffset = Lib.createV3ByString(params[2])
  end
  local scale = tonumber(params[3]) == 0 and 1 or tonumber(params[3])
  local time = tonumber(params[5])
  if effectName and effectName ~= "" then
    local finalPos = Lib.v3(pos.x + posOffset.x, pos.y + posOffset.y, pos.z + posOffset.z)
    local effectInfo = {
      effectName = effectName,
      pos = finalPos,
      scale = scale,
      yaw = tonumber(params[4]) or 0,
      action = "play",
      showMapName = World.cfg.defaultMap or "map001",
      lastMapName = World.cfg.defaultMap or "map001"
    }
    WorldServer.BroadcastPacket({
      pid = "SCUpdateEffectOnPart",
      action = effectInfo.action,
      effectName = effectInfo.effectName,
      pos = effectInfo.pos,
      scale = effectInfo.scale,
      yaw = effectInfo.yaw
    })
    self.effectPartList[partId] = effectInfo
    part.effectShowState = "show"
    if time then
      part.effectHoldKey = LuaTimer:scheduleTimer(function()
        self:removeOnePartEffect(partId)
        if part.isInteracting then
          part.isInteracting = false
        end
      end, time, 1)
    end
  end
end

function PartEffectHelper:removeOnePartEffect(partId)
  local effectInfo = self.effectPartList[partId]
  if not effectInfo then
    return
  end
  WorldServer.BroadcastPacket({
    pid = "SCUpdateEffectOnPart",
    action = "del",
    effectName = effectInfo.effectName,
    pos = effectInfo.pos
  })
  self.effectPartList[partId] = nil
  local part = Instance.getByInstanceId(partId)
  if not part or not part:isValid() then
    return
  end
  part.effectShowState = nil
end

function PartEffectHelper:updatePartEffectState(part, params, isBreak)
  if not part or not part:isValid() then
    return
  end
  local partId = part:getInstanceID()
  if self.effectPartList[partId] then
    if params[7] == "reset" and tonumber(params[5]) then
      if part.effectHoldKey then
        part.effectHoldKey()
        part.effectHoldKey = nil
      end
      part.effectHoldKey = World.Timer(tonumber(params[5]), function()
        self:removeOnePartEffect(partId)
        if part.isInteracting then
          part.isInteracting = false
        end
      end)
    else
      self:removeOnePartEffect(partId)
    end
  elseif not isBreak then
    if tonumber(params[8]) and tonumber(params[8]) > 0 then
      if part.effectAddTimer then
        part.effectAddTimer()
        part.effectAddTimer = nil
      end
      part.effectAddTimer = World.Timer(tonumber(params[8]), function()
        self:addOnePartEffect(part, params)
      end)
    else
      self:addOnePartEffect(part, params)
    end
  end
end

function PartEffectHelper:updateAllClientEffect(mapName, player)
  local dataList = {}
  for partID, effectInfo in pairs(self.effectPartList) do
    local temp = Lib.copy(effectInfo)
    if mapName ~= temp.showMapName then
      temp.action = "del"
      self.effectPartList[partID].lastMapName = mapName
      table.insert(dataList, temp)
    elseif mapName ~= temp.lastMapName then
      temp.action = "play"
      self.effectPartList[partID].lastMapName = mapName
      table.insert(dataList, temp)
    end
  end
  local packet = {
    pid = "SCPushPartEffectState",
    dataList = dataList
  }
  player:sendPacket(packet)
end

function PartEffectHelper:loginSyncPartEffectState(player)
  local dataList = {}
  for partID, effectInfo in pairs(self.effectPartList) do
    table.insert(dataList, effectInfo)
  end
  local packet = {
    pid = "SCPushPartEffectState",
    dataList = dataList
  }
  player:sendPacket(packet)
end

function PartEffectHelper:getEffectInfoByPartId(partId)
  return self.effectPartList[partId]
end

function PartEffectHelper:removePartInteractState(part)
  local partID = part:getInstanceID()
  self:removeOnePartEffect(partID)
end

local RegionEffectsConfig = T(Config, "RegionEffectsConfig")

function PartEffectHelper:loginInitPartRegionEffect(mapName, player)
  if mapName ~= "map001" then
    return
  end
  local effectConfigs = RegionEffectsConfig:getAllConfigs()
  local posGroup = {}
  for id, v in pairs(effectConfigs) do
    local partId = v.partID
    local posOffset = v.pos
    local part = Instance.getByInstanceId(partId)
    if partId ~= "" and part and part:isValid() then
      local pos = part:getPosition()
      posGroup[id] = Lib.v3(pos.x + posOffset.x, pos.y + posOffset.y, pos.z + posOffset.z)
    else
      posGroup[id] = Lib.v3(posOffset.x, posOffset.y, posOffset.z)
    end
  end
  local packet = {
    pid = "initPartRegionEffect",
    pos = posGroup
  }
  player:sendPacket(packet)
end
