local PartOccupationManager = T(Lib, "PartOccupationManager")
local PartManagerShow = T(Lib, "PartManagerShow")

function PartOccupationManager:init()
  self.occupationList = {}
end

function PartOccupationManager:startOccupationTimer()
  if self.occupyTimer then
    return
  end
  self.occupyTimer = World.Timer(20, function()
    local isHasTimer = false
    local curTime = os.time()
    for partId, val in pairs(self.occupationList) do
      if val.totalTime > 0 then
        local passTime = curTime - val.startTime
        local remainTime = val.totalTime - passTime
        if remainTime <= 0 then
          self:cleanOccupationInteract(partId)
        else
          isHasTimer = true
        end
      end
    end
    if isHasTimer then
      return true
    else
      self:stopOccupationTimer()
      return false
    end
  end)
end

function PartOccupationManager:stopOccupationTimer()
  if self.occupyTimer then
    self.occupyTimer()
    self.occupyTimer = nil
  end
end

function PartOccupationManager:updateOccupationState(player, part, params)
  if not part or not part:isValid() then
    return
  end
  if not player or not player:isValid() then
    return
  end
  local partID = part:getInstanceID()
  if self.occupationList[partID] then
    if self.occupationList[partID].userId ~= player.platformUserId then
      self:pushClientOccupationResult(player, params[2], 1)
      return
    end
    self:onTriggerOtherInteract(player, part)
  else
    for partId, val in pairs(self.occupationList) do
      if val.userId == player.platformUserId then
        self:pushClientOccupationResult(player, params[2], 2)
        return
      end
    end
    self.occupationList[partID] = {
      userId = player.platformUserId,
      params = params,
      startTime = os.time(),
      totalTime = tonumber(params[1] or -1),
      playerName = player.name
    }
    self:updateOccupationOwnName(partID, player.name)
    self:onTriggerOtherInteract(player, part)
    if self.occupationList[partID].totalTime > 0 then
      self:startOccupationTimer()
    end
  end
end

function PartOccupationManager:onTriggerOtherInteract(player, part)
  local partID = part:getInstanceID()
  local params = self.occupationList[partID].params
  local targets = Lib.splitString(params[3], "#") or {}
  local parent = part:getParent()
  local nodes = {}
  if not part.targetList then
    for _, name in pairs(targets) do
      Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, name)
    end
    PartManagerShow:updateParentChildList(parent, nodes)
    part.targetList = nodes
  else
    nodes = part.targetList
  end
  for _, target in pairs(nodes) do
    if target and target:isValid() then
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, target, player, true)
    end
  end
end

function PartOccupationManager:pushClientOccupationResult(player, goodsName, resultType)
  local packet = {
    pid = "SCPushOccupationResult",
    goodsName = goodsName or "",
    resultType = resultType
  }
  if player and player:isValid() then
    player:sendPacket(packet)
  end
end

function PartOccupationManager:updateOccupationOwnName(partID, ownName)
  if not self.occupationList[partID] then
    return
  end
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  local params = self.occupationList[partID].params
  local parent = part:getParent()
  local nodes = {}
  local nameText = params[4]
  local nameInfo = Lib.splitString(params[5], "#") or {}
  if nameText and nameText ~= "" then
    Lib.getInstanceAllChild(parent, nodes, Define.ABILITY.AABB, nameText or "")
    for _, target in pairs(nodes) do
      if target and target:isValid() then
        if not target.surfaceInfo then
          target.surfaceInfo = Instance.Create("TextDecal")
          target.surfaceInfo:setProperty("decalSurface", tostring(nameInfo[1]))
          target.surfaceInfo:setParent(target)
        end
        target.surfaceInfo:setText(ownName)
        target.surfaceInfo:setFont(nameInfo[2] or "HT16")
        target.surfaceInfo:setSize({
          x = tonumber(nameInfo[3]),
          y = tonumber(nameInfo[4])
        })
        local color = Lib.getTextColor(nameInfo[5])
        target.surfaceInfo:setTextColor(color)
        local horz = tonumber(nameInfo[6]) or 1
        if horz == 0 then
          target.surfaceInfo:setHorzFormatting("LeftAligned")
        elseif horz == 1 then
          target.surfaceInfo:setHorzFormatting("CentreAligned")
        else
          target.surfaceInfo:setHorzFormatting("RightAligned")
        end
        local vert = tonumber(nameInfo[7]) or 1
        if vert == 0 then
          target.surfaceInfo:setVertFormatting("TopAligned")
        elseif vert == 1 then
          target.surfaceInfo:setVertFormatting("CentreAligned")
        else
          target.surfaceInfo:setVertFormatting("BottomAligned")
        end
      end
    end
  end
end

function PartOccupationManager:cleanOccupationInteract(partID)
  if not self.occupationList[partID] then
    return
  end
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  local player = Game.GetPlayerByUserId(self.occupationList[partID].userId)
  if player and player:isValid() then
    local nodes = part.targetList or {}
    for _, target in pairs(nodes) do
      if target and target:isValid() and target.isInteracting then
        Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, target, player, true)
      end
    end
  end
  self:updateOccupationOwnName(partID, "")
  self.occupationList[partID] = nil
end

function PartOccupationManager:removeOccupationInfo(userId)
  for partId, val in pairs(self.occupationList) do
    if val.userId == userId then
      self:cleanOccupationInteract(partId)
      return
    end
  end
end
