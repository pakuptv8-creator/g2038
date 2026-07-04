local handles = T(Player, "PackageHandlers")
local InteractionHelper = T(Lib, "InteractionHelper")

function handles:InteractWithEntity(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity or not entity:isValid() then
    return
  end
  local cfgKey, cfgIndex, btnType, btnIndex = packet.cfgKey, packet.cfgIndex, packet.btnType, packet.btnIndex
  local cfg = entity:cfg()[cfgKey]
  if cfgIndex then
    cfg = cfg[cfgIndex]
  end
  if not (cfg and cfg[btnType]) or not cfg[btnType][btnIndex] then
    return
  end
  local btnCfg = cfg[btnType][btnIndex]
  if btnCfg.event and entity[btnCfg.event] and type(entity[btnCfg.event]) == "function" then
    entity[btnCfg.event](entity, self, btnCfg)
  else
    Plugins.CallTargetPluginFunc("interact", "diy", {
      btnCfg.event
    }, entity, self, btnCfg)
  end
end

function handles:CancelInteractiveAction(packet)
  if self:canReleaseRobber() then
    self:releaseRobber()
    return
  end
  if self:isCatchAsRobber() then
    return false
  end
  local interactPlayerHorseID = self:getInteractPlayerHorseID()
  local interactPlayerUpID = self:getInteractPlayerUpID()
  if 0 < interactPlayerUpID and 0 < interactPlayerHorseID then
    local upEntity = World.CurWorld:getEntity(interactPlayerUpID)
    if upEntity and upEntity:isValid() then
      upEntity:onlyClearPlayerHorse()
    end
    self:onlyClearPlayerHorse()
  elseif 0 < interactPlayerHorseID then
    self:onlyClearPlayerHorse()
  elseif 0 < interactPlayerUpID then
    local upEntity = World.CurWorld:getEntity(interactPlayerUpID)
    if upEntity and upEntity:isValid() then
      upEntity:onlyClearPlayerHorse()
    end
  end
end

function handles:PlayerDanceBroadcast(packet)
  local defaultData = {
    action_id = packet.actionId
  }
  Plugins.CallTargetPluginFunc("report", "report", "action_play", defaultData, self)
  InteractionHelper:doDanceAction(self, packet.actionId, true, false, true)
  if not self.playerDoDanceCount then
    self.playerDoDanceCount = 0
  end
  self.playerDoDanceCount = self.playerDoDanceCount + 1
end

function handles:PlayerStopDanceBroadcast(packet)
  InteractionHelper:doDanceAction(self, nil, false, packet.isOnlyStop, true)
end

function handles:RequestPlayerInteractive(packet)
  InteractionHelper:requestInteractiveAction(self, packet.targetID, packet.interactiveID)
end

function handles:ResponsePlayerInteractive(packet)
  if packet.isAgree then
    InteractionHelper:agreeInteractiveAction(packet.fromId, self, packet.interactiveID)
  else
    local fromEntity = World.CurWorld:getEntity(packet.fromId)
    if fromEntity and fromEntity:isValid() then
      Plugins.CallTargetPluginFunc("interaction_ui", "HideOneInteractTips", fromEntity)
    end
  end
end

function handles:ClickPartInteractionPop(packet)
  if packet.targetID then
    local part = Instance.getByInstanceId(packet.targetID)
    if part and part:isValid() then
      Trigger.CheckTriggers(part._cfg, "PART_POP_CLICKED", {part1 = part, from = self})
    end
  end
end

function handles:tryCatchRobber(packet)
  InteractionHelper:tryCatchRobber(self, packet.targetId)
end

function handles:ClientRequestStopFurniture(packet)
  local oldPartId = self:getInteractionPartID()
  if oldPartId ~= "" then
    self:doStopPlayerFurniture()
  end
end

function handles:ClientDoJumpTrigger(packet)
  self:clientDoJumpEvent()
end

function handles:OperatePalette(packet)
  local data = packet.data
  local targetObjID = packet.targetObjID
  local type = packet.type
  local target = World.CurWorld:getEntity(targetObjID)
  if not target then
    return
  end
  if type == "Save" then
    target:setPaletteData(data)
  elseif type == "Close" and targetObjID == self.rideOnId then
    self:clearRide()
  end
end
