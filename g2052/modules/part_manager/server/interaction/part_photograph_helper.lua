local PartPhotographHelper = T(Lib, "PartPhotographHelper")
local LuaTimer = T(Lib, "LuaTimer")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function PartPhotographHelper:init()
  self.areaInfoList = {}
  self.pictureList = {}
  self:startAreaTimer()
end

function PartPhotographHelper:startAreaTimer()
  World.Timer(20, function()
    local curTime = os.time()
    local photographPlayerList = {}
    local needPho = false
    for partID, areaInfo in pairs(self.areaInfoList) do
      for userId, time in pairs(areaInfo.playerList) do
        if curTime - time == World.cfg.photographSetting.stayTime then
          if not photographPlayerList[partID] then
            photographPlayerList[partID] = {}
          end
          table.insert(photographPlayerList[partID], userId)
          self.areaInfoList[partID].playerList[userId] = nil
          needPho = true
        end
      end
    end
    if needPho then
      self:updatePhotographList(photographPlayerList)
    end
    return true
  end)
end

function PartPhotographHelper:updatePhotographAreaState(player, type, part, params)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  if not self.areaInfoList[partID] then
    self.areaInfoList[partID] = {
      params = params,
      playerList = {}
    }
  end
  if not self.pictureList[partID] then
    self.pictureList[partID] = {}
  end
  local userId = player.platformUserId
  if type == Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    local nonePicture = true
    for _, pictureInfo in pairs(self.pictureList[partID]) do
      if pictureInfo.userId == userId then
        nonePicture = false
      end
    end
    if nonePicture and not self.areaInfoList[partID].playerList[userId] then
      self.areaInfoList[partID].playerList[userId] = os.time()
    end
  elseif type == Define.PART_INTERACT_TYPE.TOUCH_END then
    self.areaInfoList[partID].playerList[userId] = nil
  end
end

function PartPhotographHelper:updatePhotographList(photographPlayerList)
  for partID, playerList in pairs(photographPlayerList) do
    if not self.pictureList[partID] then
      self.pictureList[partID] = {}
    end
    local count = #playerList
    if 0 < count then
      for _, userId in pairs(playerList) do
        local player = Game.GetPlayerByUserId(userId)
        local pictureInfo = {
          userId = userId,
          nameContent = player:getNameContent(),
          nameColor = player:getNameColor(),
          sex = player:data("main").sex or 2,
          actorScale = World.cfg.photographSetting.actorScale,
          skinData = player:data("skin")
        }
        table.insert(self.pictureList[partID], pictureInfo)
      end
      local existNum = #self.pictureList[partID]
      if existNum > World.cfg.photographSetting.maxShowNum then
        for i = 1, existNum - World.cfg.photographSetting.maxShowNum do
          table.remove(self.pictureList[partID], 1)
        end
      end
      self:clientUpdatePicture(partID)
      self:playPhotographEffect(partID)
    end
  end
end

function PartPhotographHelper:clientUpdatePicture(partID, player)
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  local qiangPartName = self.areaInfoList[partID].params[6]
  local parent = part:getParent()
  if parent and parent:isValid() then
    local nodes = {}
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, qiangPartName)
    for _, cPart in pairs(nodes) do
      if cPart and cPart:isValid() then
        local pos = cPart:getPosition()
        local posOffset = Lib.createV3ByString(self.areaInfoList[partID].params[2])
        local finalPos = Lib.v3(pos.x + posOffset.x, pos.y + posOffset.y, pos.z + posOffset.z)
        local packet = {
          pid = "UpdatePolicePictureShow",
          playerList = self.pictureList[partID],
          position = finalPos,
          rotate = Lib.createV3ByString(self.areaInfoList[partID].params[3]),
          width = tonumber(self.areaInfoList[partID].params[1]),
          viewDistance = tonumber(self.areaInfoList[partID].params[4]),
          partID = partID
        }
        if player then
          player:sendPacket(packet)
        else
          WorldServer.BroadcastPacket(packet)
        end
        return
      end
    end
  end
end

function PartPhotographHelper:playPhotographEffect(partID)
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  local effectPartName = self.areaInfoList[partID].params[5]
  local parent = part:getParent()
  if parent and parent:isValid() then
    local nodes = {}
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, effectPartName)
    local InteractEventConfig = T(Config, "InteractEventConfig")
    for _, cPart in pairs(nodes) do
      if cPart and cPart:isValid() then
        local newProp = InteractEventConfig:getCfgById(cPart.name)
        if newProp and newProp.func and newProp.func == "playEffectOnPart" then
          PartManagerHelper:updateEffectOnPart(1, cPart, newProp.params)
        end
      end
    end
  end
end

function PartPhotographHelper:removePartInteractState(part)
  if not part or not part:isValid() then
    return
  end
  local partID = part:getInstanceID()
  self.areaInfoList[partID] = nil
end

function PartPhotographHelper:loginSyncPictureState(player)
  for partID, playerList in pairs(self.pictureList) do
    if 0 < #playerList then
      self:clientUpdatePicture(partID, player)
    end
  end
end
