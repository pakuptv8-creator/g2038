local HalloweenPartHelper = T(Lib, "HalloweenPartHelper")
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function HalloweenPartHelper:init()
  self.halloweenPartUIInfo = {}
  self.curMapObj = nil
  self.halloweenEntity = {}
  self:initEvent()
end

function HalloweenPartHelper:initEvent()
  Lib.subscribeEvent(Event.EVENT_HALLOWEEN_OPEN_STATE_UPDATE, function()
    if not HalloweenHelperCommon:isHalloweenDay() then
      self:removeHalloweenPart()
    end
  end)
end

function HalloweenPartHelper:loadingHalloweenPartInfo(part, map, params)
  if not self.halloweenPartUIInfo[map.name] then
    self.halloweenPartUIInfo[map.name] = {}
  end
  if not self.halloweenEntity[map.name] then
    self.halloweenEntity[map.name] = {}
  end
  local instanceId = part:getInstanceID()
  if not self.halloweenPartUIInfo[map.name][instanceId] then
    self.halloweenPartUIInfo[map.name][instanceId] = {
      rotation = part:getRotation(),
      pos = part:getPosition(),
      partName = part.name,
      partId = instanceId,
      mapName = map.name,
      awardId = tonumber(params[2]) or 0
    }
  end
  if not self.halloweenEntity[map.name][instanceId] then
    local newPos = part:getPosition()
    newPos.y = newPos.y - 2
    self.halloweenEntity[map.name][instanceId] = EntityServer.Create({
      name = "",
      map = map,
      cfgName = "myplugin/player_none",
      pos = newPos,
      ry = 180,
      rp = 0
    })
  end
end

function HalloweenPartHelper:pushClientHalloweenUIInfo(mapName, player, resetTime)
  self.curMapObj = player.map.obj
  if not HalloweenHelperCommon:isHalloweenDay() then
    self:removeHalloweenPart()
    return
  end
  if not self.halloweenPartUIInfo[mapName] then
    return
  end
  for mapName, partList in pairs(self.halloweenPartUIInfo) do
    for partId, _ in pairs(partList) do
      if not self.halloweenEntity[mapName][partId] then
        return
      end
      self.halloweenPartUIInfo[mapName][partId].objID = self.halloweenEntity[mapName][partId].objID
    end
  end
  local packet = {
    pid = "SCHalloweenPartUIInfo",
    mapName = mapName,
    partUIData = self.halloweenPartUIInfo[mapName],
    serverTime = os.time(),
    resetTime = resetTime
  }
  player:sendPacket(packet)
end

function HalloweenPartHelper:removeHalloweenPart()
  local needRemoveUI = false
  for mapName, partList in pairs(self.halloweenPartUIInfo) do
    for partId, _ in pairs(partList) do
      local part = Instance.getByInstanceId(partId)
      needRemoveUI = true
      if part and part:isValid() then
        local parent = part:getParent()
        if parent and parent:isValid() then
          PartManagerHelper:doDestroyPart(parent)
        else
          PartManagerHelper:doDestroyPart(part)
        end
      end
    end
  end
  for mapName, partList in pairs(self.halloweenEntity) do
    for partId, _ in pairs(partList) do
      self.halloweenEntity[mapName][partId]:destroy()
      self.halloweenEntity[mapName][partId] = nil
    end
  end
  if self.curMapObj then
    local manager = World.CurWorld:getSceneManager()
    local scene = manager:getOrCreateScene(self.curMapObj)
    local nodes = {}
    Lib.getInstanceAllChild(scene:getRoot(), nodes, Define.ABILITY.AABB, World.cfg.halloweenSetting.signPartName)
    for _, hidePart in pairs(nodes) do
      if hidePart and hidePart:isValid() then
        PartManagerHelper:doDestroyPart(hidePart)
      end
    end
  end
  if needRemoveUI then
    local packet = {
      pid = "SCRemoveAllHalloweenUI"
    }
    WorldServer.BroadcastPacket(packet)
  end
  self.halloweenPartUIInfo = {}
  self.halloweenEntity = {}
end

HalloweenPartHelper:init()
