SceneUIPartManager = {}
local PartSceneNameConfig = T(Config, "PartSceneNameConfig")

function SceneUIPartManager:init()
  self.partUITipsCfg = PartSceneNameConfig:getAllCfgs()
  self.partUITipsInfo = {}
  self.partUIContentInfo = {}
end

function SceneUIPartManager:loadingPartTipsUIInfo(part, map)
  if not self.partUITipsCfg[part.name] then
    return
  end
  if not self.partUITipsInfo[map.name] then
    self.partUITipsInfo[map.name] = {}
  end
  local instanceId = part:getInstanceID()
  if not self.partUITipsInfo[map.name][instanceId] then
    self.partUITipsInfo[map.name][instanceId] = {
      rotation = part:getRotation(),
      pos = part:getPosition(),
      partName = part.name,
      partId = instanceId,
      mapName = map.name
    }
  end
end

function SceneUIPartManager:pushClientPartUIMapInfo(mapName, player)
  if not self.partUITipsInfo[mapName] then
    return
  end
  local packet = {
    pid = "SCPartUIMapInfo",
    mapName = mapName,
    partUIData = self.partUITipsInfo[mapName]
  }
  player:sendPacket(packet)
end

function SceneUIPartManager:loadingPartContentUIInfo(part, map, params)
  if not self.partUIContentInfo[map.name] then
    self.partUIContentInfo[map.name] = {}
  end
  local instanceId = part:getInstanceID()
  if not self.partUIContentInfo[map.name][instanceId] then
    self.partUIContentInfo[map.name][instanceId] = {
      rotation = part:getRotation(),
      pos = part:getPosition(),
      partName = part.name,
      partId = instanceId,
      mapName = map.name,
      contentTxt = params[5] or "",
      contentColor = Lib.getTextColor(params[6] or "000000"),
      signName = "",
      signColor = Lib.getTextColor("000000")
    }
    if params[7] and params[7] ~= "" then
      self.partUIContentInfo[map.name][instanceId].bgColor = Lib.getTextColor(params[7])
    end
  end
end

function SceneUIPartManager:pushClientPartContentMapInfo(mapName, player)
  if not self.partUIContentInfo[mapName] then
    return
  end
  local packet = {
    pid = "SCPartContentMapInfo",
    mapName = mapName,
    partUIData = self.partUIContentInfo[mapName]
  }
  player:sendPacket(packet)
end

function SceneUIPartManager:doChangePartContent(packet, player)
  local mapName = packet.mapName
  local partId = packet.partId
  if not self.partUIContentInfo[mapName] then
    return
  end
  if not self.partUIContentInfo[mapName][partId] then
    return
  end
  if packet.contentTxt then
    self.partUIContentInfo[mapName][partId].contentTxt = World.CurWorld:filterWord(packet.contentTxt)
  end
  if packet.contentColor then
    self.partUIContentInfo[mapName][partId].contentColor = packet.contentColor
  end
  if packet.signName then
    self.partUIContentInfo[mapName][partId].signName = packet.signName
  end
  if packet.signColor then
    self.partUIContentInfo[mapName][partId].signColor = packet.signColor
  end
  if packet.bgColor then
    self.partUIContentInfo[mapName][partId].bgColor = packet.bgColor
  end
  local packet = {
    pid = "SCUpdatePartContentShow",
    mapName = mapName,
    partID = partId,
    partUIInfo = self.partUIContentInfo[mapName][partId]
  }
  player:sendPacketToTracking(packet, true)
end

SceneUIPartManager:init()
