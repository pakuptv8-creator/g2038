require("server.interaction.part_furniture_helper")
require("server.interaction.part_single_helper")
require("server.interaction.part_effect_helper")
require("server.interaction.part_light_helper")
require("server.interaction.part_printer_helper")
require("server.interaction.part_photograph_helper")
require("server.interaction.player_photograph_helper")
require("server.interaction.player_occupation_helper")
require("server.part_float_area_manager")
local PartManagerHelper = T(Lib, "PartManagerHelper")
local InteractEventConfig = T(Config, "InteractEventConfig")
local PropsConfig = T(Config, "PropsConfig")
local LuaTimer = T(Lib, "LuaTimer")
local PropsAttrConfig = T(Config, "PropsAttrConfig")
local GameTimes = T(Lib, "GameTimes")
local MessageNoticeManager = T(Lib, "MessageNoticeManager")
local MessageConfig = T(Config, "MessageConfig")
local EmergencyHelper = T(Lib, "EmergencyHelper")

function PartManagerHelper:init()
  self.partTypeClass = {}
  for _, className in pairs(Define.PART_TYPE_CLASS) do
    self.partTypeClass[className] = T(Lib, className)
    self.partTypeClass[className]:init()
  end
  self.groupPartList = {}
  self.biddingPartList = {}
  self.bindPlayerList = {}
  self.partTimeTriggerList = {}
  self.partPlaceItems = {}
  World.Timer(20, function()
    self:updatePartPlaceList()
    self:updateTimeTriggerState()
    return true
  end)
end

function PartManagerHelper:addTimeTriggerList(part)
  local partId = part:getInstanceID()
  if not self.partTimeTriggerList[partId] then
    self.partTimeTriggerList[partId] = {
      part = part,
      partId = partId,
      isOpening = false
    }
  end
end

function PartManagerHelper:updateTimeTriggerState()
  for partId, partInfo in pairs(self.partTimeTriggerList) do
    if partInfo.part and partInfo.part:isValid() then
      local partName = partInfo.part.name
      local interactInfo = InteractEventConfig:getCfgById(partName) or {}
      local curTime = GameTimes:GetTime()
      local isTrigger = false
      if partInfo.isOpening then
        for _, val in pairs(interactInfo.closeTimeList) do
          if tonumber(curTime.hour) == val[1] and tonumber(curTime.min) == val[2] then
            isTrigger = true
          end
        end
      else
        for _, val in pairs(interactInfo.startTimeList) do
          if tonumber(curTime.hour) == val[1] and tonumber(curTime.min) == val[2] then
            isTrigger = true
          end
        end
      end
      if isTrigger then
        for _, player in pairs(Game.GetAllPlayers()) do
          if player and player:isValid() then
            if player[interactInfo.func] then
              player[interactInfo.func](player, Define.PART_INTERACT_TYPE.GAME_TIME, partInfo.part, interactInfo.params, self.partTimeTriggerList[partId].isOpening)
              self.partTimeTriggerList[partId].isOpening = not self.partTimeTriggerList[partId].isOpening
            end
            break
          end
        end
      end
    else
      self.partTimeTriggerList[partId] = nil
    end
  end
end

function PartManagerHelper:updateAllClientEffect(mapName, player)
  self.partTypeClass.PartEffectHelper:updateAllClientEffect(mapName, player)
  self.partTypeClass.PartLightHelper:updateAllClientEffect(mapName, player)
end

function PartManagerHelper:updateBiddingPartLand(partId, mapName, signKey)
  self.biddingPartList[partId] = {mapName = mapName, signKey = signKey}
  self:pushClientBiddingPart()
end

function PartManagerHelper:pushClientBiddingPart(player)
  local packet = {
    pid = "SCPushClientBiddingPart",
    params = self.biddingPartList
  }
  if player and player:isValid() then
    player:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

function PartManagerHelper:updateGroupPartState(partId, childList)
  if self.groupPartList[partId] then
    self.groupPartList[partId] = nil
  else
    self.groupPartList[partId] = childList
  end
end

function PartManagerHelper:isOnGroupPartState(partId)
  return self.groupPartList[partId]
end

function PartManagerHelper:getPartListInteractState(childList)
  for _, childId in pairs(childList) do
    local part = Instance.getByInstanceId(childId)
    if part and part:isValid() and part.isInteracting then
      return true
    end
  end
  return false
end

function PartManagerHelper:isBelongPartGroup(partId)
  for parentId, childList in pairs(self.groupPartList) do
    for _, childId in pairs(childList) do
      if partId == childId then
        return parentId
      end
    end
  end
  return false
end

function PartManagerHelper:updatePartPlaceList()
  local placePartSetting = World.cfg.placePartSetting
  for userId, placeItems in pairs(self.partPlaceItems) do
    for itemId, placeData in pairs(placeItems) do
      for i = #placeData.partList, 1, -1 do
        if os.time() - placeData.partList[i].bornTime > placePartSetting.lifeTime then
          self:removePlacePartByIndex(userId, itemId, i)
        end
      end
    end
  end
end

function PartManagerHelper:checkOnePartCanPlace(userId, itemId)
  if not self.partPlaceItems[userId] then
    self.partPlaceItems[userId] = {}
  end
  if not self.partPlaceItems[userId][itemId] then
    self.partPlaceItems[userId][itemId] = {
      partList = {}
    }
  end
  local itemCfg = PropsConfig:getCfgById(itemId)
  if not itemCfg then
    return false
  end
  local curCount = #self.partPlaceItems[userId][itemId].partList
  if curCount <= 0 then
    return true
  end
  if os.time() <= self.partPlaceItems[userId][itemId].partList[curCount].bornTime then
    return false
  end
  return true
end

function PartManagerHelper:addOnePlacePart(userId, itemId)
  if not self.partPlaceItems[userId] then
    self.partPlaceItems[userId] = {}
  end
  if not self.partPlaceItems[userId][itemId] then
    self.partPlaceItems[userId][itemId] = {
      partList = {}
    }
  end
  local itemCfg = PropsConfig:getCfgById(itemId)
  if not itemCfg then
    return
  end
  local temp = {
    bornTime = os.time()
  }
  table.insert(self.partPlaceItems[userId][itemId].partList, temp)
  return true
end

function PartManagerHelper:inputOnePlacePartData(userId, itemId, part)
  local isValid = true
  if not self.partPlaceItems[userId] then
    isValid = false
  end
  if not self.partPlaceItems[userId][itemId] then
    isValid = false
  end
  if isValid then
    for _, v in ipairs(self.partPlaceItems[userId][itemId].partList) do
      if not v.part then
        v.part = part
        v.partId = part:getInstanceID()
        break
      end
    end
    local itemCfg = PropsConfig:getCfgById(itemId)
    if itemCfg then
      local curCount = #self.partPlaceItems[userId][itemId].partList
      if itemCfg.throwMaxNum ~= 0 and curCount > itemCfg.throwMaxNum then
        self:removePlacePartByIndex(userId, itemId, 1)
      end
    end
  end
end

function PartManagerHelper:outputOnePlacePartInvalidData(userId, itemId)
  if self.partPlaceItems[userId] and self.partPlaceItems[userId][itemId] and self.partPlaceItems[userId][itemId].partList then
    for i, v in ipairs(self.partPlaceItems[userId][itemId].partList) do
      if not v.part then
        table.remove(self.partPlaceItems[userId][itemId].partList, i)
        break
      end
    end
  end
end

function PartManagerHelper:removePlacePartByIndex(userId, itemId, index)
  if not self.partPlaceItems[userId] then
    return
  end
  if not self.partPlaceItems[userId][itemId] then
    return
  end
  if not self.partPlaceItems[userId][itemId].partList[index] then
    return
  end
  local part = self.partPlaceItems[userId][itemId].partList[index].part
  if part and part:isValid() then
    self:doDestroyPart(part)
  end
  table.remove(self.partPlaceItems[userId][itemId].partList, index)
end

function PartManagerHelper:forceUsingPlayersQuit(instance)
  local nodes = {}
  Lib.getInstanceAllChild(instance, nodes, Define.ABILITY.AABB)
  for _, part in ipairs(nodes) do
    for userId in pairs(part.usingLadderPlayers or {}) do
      local player = Game.GetPlayerByUserId(userId)
      if player then
        player:SetForceClimb(false, 0, 0)
      end
    end
    part.usingLadderPlayers = nil
  end
end

function PartManagerHelper:doDestroyPart(part)
  if not part or not part:isValid() then
    return
  end
  self:updateChildInteractState(part)
  EmergencyHelper:destroyKindlingPart(part)
  part:destroy()
end

function PartManagerHelper:updateChildInteractState(part)
  if not part or not part:isValid() then
    return
  end
  local count = part:getChildrenCount()
  for i = 0, count - 1 do
    local childPart = part:getChildAt(i)
    self:updateChildInteractState(childPart)
  end
  self:removePartInteractState(part)
end

function PartManagerHelper:removePartInteractState(part)
  if not part or not part:isValid() then
    return
  end
  self:forceUsingPlayersQuit(part)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.removePartInteractState then
    partClass:removePartInteractState(part)
  end
  self:removePartInteractPlayer(part)
end

function PartManagerHelper:getPartInteractEntity(part)
  if not part or not part:isValid() then
    return
  end
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.getPartInteractEntity then
    return partClass:getPartInteractEntity(part)
  end
end

function PartManagerHelper:getPartTypeClass(part)
  if not part or not part:isValid() then
    return
  end
  if not part.properties then
    return
  end
  local partName = part.properties.name
  if not partName then
    return
  end
  local prop = InteractEventConfig:getCfgById(partName)
  if not prop or not prop.func then
    return
  end
  local className = Define.PART_NAME_TYPE[prop.func]
  if className and self.partTypeClass[className] then
    if prop.func == "onTriggerAssociated" then
      if prop.params[7] and tonumber(prop.params[7]) == 1 then
        return self.partTypeClass[className]
      end
    else
      return self.partTypeClass[className]
    end
  end
end

function PartManagerHelper:cleanPartInteractData(entity, idx)
  local partId = entity:getInteractionPartID()
  if partId ~= "" then
    local part = Instance.getByInstanceId(partId)
    if not part or not part:isValid() then
      return
    end
    local partClass = self:getPartTypeClass(part)
    if partClass and partClass.cleanPartEntityInfo then
      local sitIdx = idx or entity:getSitPartIdx()
      partClass:cleanPartEntityInfo(partId, sitIdx)
    end
  end
end

function PartManagerHelper:cleanSingleInteractData(entity)
  local partId = entity:getSingleInteractPartID()
  if partId ~= "" then
    local part = Instance.getByInstanceId(partId)
    if not part or not part:isValid() then
      return
    end
    local partClass = self:getPartTypeClass(part)
    if partClass and partClass.cleanSinglePartInfo then
      partClass:cleanSinglePartInfo(partId)
    end
  end
end

function PartManagerHelper:checkPartIsCanInteraction(part, fromEntity, params, isBreak)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.checkPartIsCanInteraction then
    return partClass:checkPartIsCanInteraction(part, fromEntity, params, isBreak)
  end
  return true
end

function PartManagerHelper:getPartFurnitureSitIdx(part)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.getPartFurnitureSitIdx then
    return partClass:getPartFurnitureSitIdx(part)
  end
  return false
end

function PartManagerHelper:updatePartParamsInfo(part, params)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePartParamsInfo then
    local partID = part:getInstanceID()
    partClass:updatePartParamsInfo(partID, params)
  end
end

function PartManagerHelper:updatePartEntityInfo(part, sitIdx, objID, isBreak)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePartEntityInfo then
    partClass:updatePartEntityInfo(part, sitIdx, objID, isBreak)
  end
end

function PartManagerHelper:getPartRideInfoWithSitIdx(part, sitIdx)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.getPartRideInfoWithSitIdx then
    return partClass:getPartRideInfoWithSitIdx(part, sitIdx)
  end
end

function PartManagerHelper:updateEffectOnPart(type, part, params, isBreak)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePartEffectState then
    partClass:updatePartEffectState(part, params, isBreak)
  end
end

function PartManagerHelper:playLimitEffectOnPart(type, part, params)
  self:updateEffectOnPart(type, part, params)
  if params[5] and params[5] ~= "" then
    local lifeTime = tonumber(params[5])
    part.effectLifeTimer = World.Timer(lifeTime, function()
      if not part or not part:isValid() then
        return false
      end
      local partClass = self:getPartTypeClass(part)
      if partClass and partClass.updatePartEffectState then
        local partId = part:getInstanceID()
        partClass:removeOnePartEffect(partId)
      end
      if params[6] and params[6] ~= "" then
        local reLifeTime = tonumber(params[6])
        part.effectReLifeTimer = World.Timer(reLifeTime, function()
          if not part or not part:isValid() then
            return false
          end
          PartManagerHelper:playLimitEffectOnPart(type, part, params)
        end)
      end
    end)
  end
end

function PartManagerHelper:updateFireLightOnPart(type, player, part, params)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updateLightFireState then
    partClass:updateLightFireState(player, part, params)
  end
end

function PartManagerHelper:removeOccupationInfo(userId)
  local PartOccupationManager = T(Lib, "PartOccupationManager")
  PartOccupationManager:removeOccupationInfo(userId)
end

function PartManagerHelper:updateOccupationState(type, player, part, params)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updateOccupationState then
    partClass:updateOccupationState(player, part, params)
  end
end

function PartManagerHelper:loginSyncPartInteractState(player)
  local PartFurnitureHelper = T(Lib, "PartFurnitureHelper")
  PartFurnitureHelper:loginSyncFurnitureInteractState(player)
  local PartSingleHelper = T(Lib, "PartSingleHelper")
  PartSingleHelper:loginSyncSingleInteractState(player)
  local PartEffectHelper = T(Lib, "PartEffectHelper")
  PartEffectHelper:loginSyncPartEffectState(player)
  local PartLightHelper = T(Lib, "PartLightHelper")
  PartLightHelper:loginSyncLightState(player)
  local PartPrinterHelper = T(Lib, "PartPrinterHelper")
  PartPrinterHelper:loginSyncPrinterState(player)
  local PartPhotographHelper = T(Lib, "PartPhotographHelper")
  PartPhotographHelper:loginSyncPictureState(player)
  local PlayerPhotographHelper = T(Lib, "PlayerPhotographHelper")
  PlayerPhotographHelper:loginSyncPhotographInfo(player)
  self:pushClientBiddingPart(player)
  self:pushClientBindPart(player)
end

function PartManagerHelper:updatePrinterState(player, type, part, params, fromFunc)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePrinterState then
    partClass:updatePrinterState(player, type, part, params, fromFunc)
  end
end

function PartManagerHelper:updatePhotographAreaState(player, type, part, params)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePhotographAreaState then
    partClass:updatePhotographAreaState(player, type, part, params)
  end
end

function PartManagerHelper:updatePlayerPhotographInfo(player, part, params)
  local partClass = self:getPartTypeClass(part)
  if partClass and partClass.updatePlayerPhotographInfo then
    partClass:updatePlayerPhotographInfo(player, part, params)
  end
end

local function getTargetHouseOwner(target)
  local houseModel = target:findFirstAncestor("house")
  if houseModel then
    local instanceId = houseModel:getInstanceID()
    local locationList = HouseManager:getLocationList()
    for _, v in pairs(locationList) do
      if v.houseId == instanceId then
        return v.ownerId
      end
    end
  end
end

function PartManagerHelper:clearBarrier(player, bombID, explodePos, target)
  local map = player and player:isValid() and player.map
  local range = 2
  local bombName = ""
  if bombID then
    local bomb = Instance.getByInstanceId(bombID)
    bombName = bomb.properties.name
    if bomb and bomb:isValid() then
      Plugins.CallTargetPluginFunc("part_manager", "destroyPart", bomb)
    end
  end
  local minPos = {
    x = explodePos.x - range,
    y = explodePos.y - range,
    z = explodePos.z - range
  }
  local maxPos = {
    x = explodePos.x + range,
    y = explodePos.y + range,
    z = explodePos.z + range
  }
  local isDestroy = false
  local targetPart = {}
  if not map then
    return
  end
  local parts = map:getTouchParts(minPos, maxPos)
  if parts then
    local hasFirePointList = {}
    local locationId, ownerId = HouseManager:checkPlayerIsOtherVisit(player)
    for _, part in pairs(parts) do
      if part:isValid() and PropsAttrConfig:isBombInteract(part.properties.name) and part.operationRotateInfo == nil then
        if part.properties.name == "small_fire_point" and bombName == "g2052_c4_bomb" then
          table.insert(hasFirePointList, part:getInstanceID())
          if locationId then
            EmergencyHelper:addKindlingList(locationId, ownerId, part:getInstanceID(), false)
          end
        end
        Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, player, true)
        table.insert(targetPart, part)
        isDestroy = true
      end
    end
    if bombName == "g2052_c4_bomb" and #hasFirePointList <= 0 then
      player:onPlaceSmallFirePoint(target, explodePos)
    end
  end
  
  local function searchSpecificPart(parts, name)
    for _, part in pairs(parts) do
      if part.properties.name == name then
        return true
      end
    end
    return false
  end
  
  local function searchCauseCrimePart(parts)
    for _, part in pairs(parts) do
      local partName = part:getProperty("name")
      if PropsAttrConfig:isPublicCrimeWhenDestroy(partName) then
        return partName
      end
    end
    return false
  end
  
  if isDestroy then
    local partName = searchCauseCrimePart(targetPart)
    if partName then
      if player and player:isValid() then
        if player.robberCountDown then
          player.robberCountDown()
        end
        player.robberCountDown = World.LightTimer("RobberGoneTime", World.cfg.robberGoneTime, function()
          if player and player:isValid() then
            Plugins.CallTargetPluginFunc("profession", "resetAsBaseProfession", player, true)
          end
        end)
        Plugins.CallTargetPluginFunc("profession", "updatePlayerProfession", player, Define.CareerType.Robber, true)
        player:sendPacket({
          pid = "eventBroadcast",
          type = Define.PART_EVENT.Explode_Vault_Gate,
          fromUid = player.platformUserId
        })
        MessageNoticeManager:pushMessageNotice(Define.MessageNoticeType.BANK_VAULT_GATE_OPEN, Game.GetAllPlayers())
        local prop = InteractEventConfig:getCfgById(partName)
        if prop then
          local closeTime = tonumber(prop.params[5])
          local rotateTime = tonumber(prop.params[6])
          print("-------------------------------------- getMessageNoticeId: closeTime ", closeTime, rotateTime)
          if closeTime and rotateTime then
            World.Timer(closeTime + rotateTime, function()
              MessageNoticeManager:pushMessageNotice(Define.MessageNoticeType.BANK_VAULT_GATE_CLOSE, Game.GetAllPlayers())
            end)
            local cfg = MessageConfig:getCfgById(Define.MessageNoticeType.BANK_VAULT_GATE_OPEN)
            if cfg then
              local forwardTime = tonumber(cfg.p1)
              if forwardTime then
                World.Timer(math.max(20, closeTime + rotateTime - forwardTime * 20), function()
                  MessageNoticeManager:pushMessageNotice(Define.MessageNoticeType.BANK_VAULT_GATE_WILL_CLOSE, Game.GetAllPlayers())
                end)
              end
            end
          end
        end
      end
    elseif searchSpecificPart(targetPart, "house_baoxianxiang_door") and player and player:isValid() then
      local targetUid = getTargetHouseOwner(targetPart[1])
      if targetUid then
        local player_target = Game.GetPlayerByUserId(targetUid)
        if player_target then
          player_target:sendPacket({
            pid = "eventBroadcast",
            type = Define.PART_EVENT.Explode_House_Safe,
            fromUid = player.platformUserId
          })
          MessageNoticeManager:pushMessageNotice(Define.MessageNoticeType.HOUSE_SAFE_BOX_OPEN, {player_target})
        end
        if targetUid ~= player.platformUserId then
          if player.robberCountDown2 then
            player.robberCountDown2()
          end
          player.robberCountDown2 = World.LightTimer("RobberGoneTime2", World.cfg.robberGoneTime, function()
            if player and player:isValid() then
              Plugins.CallTargetPluginFunc("profession", "resetAsBaseProfession", player, true)
            end
          end)
          Plugins.CallTargetPluginFunc("profession", "updatePlayerProfession", player, Define.CareerType.Robber, true)
        end
      end
    end
  end
end

function PartManagerHelper:doPartMoveOperation(target, moveDir, moveTime, callbackFunc)
  local rotation = target:getRotation()
  local distance = Lib.correctMoveDistance(rotation, moveDir)
  local scene = target:getScene()
  local offset = distance / moveTime
  local count = 0
  World.Timer(1, function()
    count = count + 1
    scene.move({target}, offset, true)
    if count == moveTime then
      if callbackFunc then
        callbackFunc()
      end
      return
    end
    return true
  end)
end

function PartManagerHelper:updatePartInteractPlayer(part, objID, isInteracting)
  if not part or not part:isValid() then
    return
  end
  if not part.interactPlayerList then
    part.interactPlayerList = {}
  end
  if isInteracting then
    part.interactPlayerList[objID] = true
  else
    part.interactPlayerList[objID] = false
    for id, val in pairs(part.interactPlayerList) do
      if val then
        local player = World.CurWorld:getEntity(id)
        if player and player:isValid() then
          Plugins.CallTargetPluginFunc("interaction_ui", "updatePlayerInteractPart", player, part:getInstanceID(), isInteracting)
        end
      end
    end
    part.interactPlayerList = {}
  end
end

function PartManagerHelper:removePartInteractPlayer(part)
  if not part or not part:isValid() then
    return
  end
  if not part.interactPlayerList then
    return
  end
  local partId = part:getInstanceID()
  for id, val in pairs(part.interactPlayerList) do
    if val then
      local player = World.CurWorld:getEntity(id)
      if player and player:isValid() then
        Plugins.CallTargetPluginFunc("interaction_ui", "updatePlayerInteractPart", player, partId, false)
      end
    end
  end
  part.interactPlayerList = nil
end

function PartManagerHelper:updateBindPlayerList(partList, objID, isInteracting)
  for _, partID in pairs(partList) do
    if isInteracting then
      self.bindPlayerList[partID] = objID
    else
      self.bindPlayerList[partID] = nil
    end
  end
  self:pushClientBindPart()
end

function PartManagerHelper:checkIsCanBindInteraction(part, player)
  local partId = part:getInstanceID()
  if self.bindPlayerList[partId] then
    if self.bindPlayerList[partId] == player.objID then
      return true
    else
      return false
    end
  else
    return true
  end
end

function PartManagerHelper:removeBindPlayerInfo(objID)
  local hasChange = false
  for partID, _ in pairs(self.bindPlayerList) do
    if self.bindPlayerList[partID] == objID then
      self.bindPlayerList[partID] = nil
      hasChange = true
    end
  end
  if hasChange then
    self:pushClientBindPart()
  end
end

function PartManagerHelper:pushClientBindPart(player)
  local packet = {
    pid = "SCPushClientBindPart",
    params = self.bindPlayerList
  }
  if player and player:isValid() then
    player:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

PartManagerHelper:init()
