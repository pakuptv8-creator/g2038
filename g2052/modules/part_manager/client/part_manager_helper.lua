local PartManagerHelper = T(Lib, "PartManagerHelper")
local SoundConfig = T(Config, "SoundConfig")

function PartManagerHelper:init()
  self.swingRenderTickListener = {}
  self.slideLadderRenderTickListener = {}
  self.furniturePartList = {}
  self.singlePartList = {}
  self.printerPartList = {}
  self.printingPaperPartList = {}
  self.biddingPartList = {}
  self.bindPlayerList = {}
  Lib.lightSubscribeEvent("error!!!!! : EVENT_PLAYER_LOGOUT", Event.EVENT_PLAYER_LOGOUT, function(playerInfo)
    if playerInfo then
      if self.swingRenderTickListener[playerInfo.objID] then
        self.swingRenderTickListener[playerInfo.objID]()
        self.swingRenderTickListener[playerInfo.objID] = nil
      end
      if self.slideLadderRenderTickListener[playerInfo.objID] then
        self.slideLadderRenderTickListener[playerInfo.objID]()
        self.slideLadderRenderTickListener[playerInfo.objID] = nil
      end
    end
  end)
end

function PartManagerHelper:startSlideLadder(entity, player, packet)
  if not entity or not entity:isValid() then
    return
  end
  self.slideLadderRenderTickListener[entity.objID] = Lib.lightSubscribeEvent("error!!!!! : Interact lib event : EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
    entity:ladderRenderTick()
  end)
  if player.objID == Me.objID then
    local bm = Blockman.instance
    local cameraInfo = bm:getCameraInfo()
    self.cameraSaveData = {
      curInfo = cameraInfo.curInfo
    }
    self.ladderYaw, self.ladderPitch = bm:viewerRenderYaw(), bm:viewerRenderPitch()
    self.ladderViewDis = bm:viewerRenderDistance()
  end
  entity:StartSlideLadderInteract(player, packet.ladderPartId, packet.triggerPartId)
end

function PartManagerHelper:stopSlideLadder(objID, playerId)
  if self.slideLadderRenderTickListener[objID] then
    self.slideLadderRenderTickListener[objID]()
    self.slideLadderRenderTickListener[objID] = nil
  end
  local desPos
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    desPos = entity:getSocketPosition("Bone002")
  end
  local player = World.CurWorld:getEntity(playerId)
  if player and player:isValid() then
    desPos = desPos or player:getPosition()
    player:setPos(desPos)
    player:setActorHide(false)
  else
  end
  if playerId == Me.objID then
    if desPos then
      Me:setPos(desPos)
    else
      desPos = Me:getPosition()
    end
    Me:setActorHide(false)
    local bm = Blockman.instance
    if self.cameraSaveData and self.cameraSaveData.curInfo then
      bm:setPersonView(self.cameraSaveData.curInfo.curPersonView)
      bm:setCanSwitchView(self.cameraSaveData.curInfo.canSwitchView)
      Me:changeCameraView(desPos, Me:getRotationYaw(), Me:getRotationPitch(), self.cameraSaveData.curInfo.distance, 10)
    else
      bm:setPersonView(Define.PersonView.THIRD)
      Me:changeCameraView(desPos, Me:getRotationYaw(), Me:getRotationPitch(), 4, 10)
    end
    Me:sendPacket({
      pid = "onFinishSlideLadderInteract",
      playerId = playerId
    })
  end
end

function PartManagerHelper:startSwing(entity, part, oldGravity)
  if not entity or not entity:isValid() then
    return
  end
  if not part or not part:isValid() then
    return
  end
  self:stopSwing(entity)
  self.swingRenderTickListener[entity.objID] = Lib.lightSubscribeEvent("error!!!!! : Interact lib event : EVENT_CLIENT_HANDLE_TICK", Event.EVENT_CLIENT_HANDLE_TICK, function()
    entity:tick()
  end)
  entity:doPlayerDoSwing(part, oldGravity)
end

function PartManagerHelper:stopSwing(entity)
  if not entity or not entity:isValid() then
    return
  end
  if self.swingRenderTickListener[entity.objID] then
    self.swingRenderTickListener[entity.objID]()
    self.swingRenderTickListener[entity.objID] = nil
  end
  entity:onPlayerStopSwing()
end

function PartManagerHelper:initFurniturePartData(partID, totalSitNum)
  self.furniturePartList[partID] = {
    partID = partID,
    passengers = {},
    totalSitNum = totalSitNum or 1,
    curSitNum = 0
  }
end

function PartManagerHelper:SyncFurnitureInteractState(packet)
  self.furniturePartList = Lib.copy(packet.dataList)
end

function PartManagerHelper:updateFurnitureInteractState(packet)
  if not self.furniturePartList[packet.partID] then
    self:initFurniturePartData(packet.partID, packet.totalSitNum)
  end
  if packet.totalSitNum then
    self.furniturePartList[packet.partID].totalSitNum = packet.totalSitNum
  end
  if packet.isSitDown then
    self.furniturePartList[packet.partID].passengers[packet.userId] = packet.sitIdx
    self.furniturePartList[packet.partID].curSitNum = self.furniturePartList[packet.partID].curSitNum + 1
  else
    self.furniturePartList[packet.partID].passengers[packet.userId] = nil
    self.furniturePartList[packet.partID].curSitNum = self.furniturePartList[packet.partID].curSitNum - 1
  end
  Me.surroundingCd = 0
  Me:startScanningSurroundingParts()
end

function PartManagerHelper:SyncSingleInteractState(packet)
  self.singlePartList = Lib.copy(packet.dataList)
end

function PartManagerHelper:updateSingleInteractState(packet)
  self.singlePartList[packet.partID] = packet.objID
  Me.surroundingCd = 0
  Me:startScanningSurroundingParts()
end

function PartManagerHelper:SyncPrinterInteractState(packet)
  self.printerPartList = {}
  for _, printInfo in pairs(packet.dataList) do
    self.printerPartList[printInfo.partID] = printInfo
  end
  self.printingPaperPartList = {}
  for partID, printInfo in pairs(self.printerPartList) do
    self.printingPaperPartList[printInfo.paperID] = printInfo.state
  end
end

function PartManagerHelper:updatePrinterInteractState(packet)
  self.printingPaperPartList[packet.paperID] = packet.state
  if not self.printerPartList[packet.partID] then
    self.printerPartList[packet.partID] = {}
  end
  self.printerPartList[packet.partID].state = packet.state
  self.printerPartList[packet.partID].paperID = packet.paperID
  self.printerPartList[packet.partID].printerBgm = packet.printerBgm
  if packet.state == Define.PRINTER_STATE.inPrinter then
    local soundInfo = SoundConfig:getSound(packet.printerBgm)
    if soundInfo then
      if self.printerPartList[packet.partID] and self.printerPartList[packet.partID].soundId then
        Me:stopSound(self.printerPartList[packet.partID].soundId)
        self.printerPartList[packet.partID].soundId = nil
      end
      local sound = soundInfo.sound
      sound = "asset" .. sound
      self.printerPartList[packet.partID].soundId = TdAudioEngine.Instance():play3dSound(sound, packet.partPos, soundInfo.loop, 1, 1.0, 100.0)
      TdAudioEngine.Instance():setSoundsVolume(self.printerPartList[packet.partID].soundId, soundInfo.volume)
      local soundDistance = World.cfg.soundDistance or {1, 5}
      TdAudioEngine.Instance():set3DRollOffMode(self.printerPartList[packet.partID].soundId, Sound3DRollOffType.LINEAR)
      TdAudioEngine.Instance():set3DMinMaxDistance(self.printerPartList[packet.partID].soundId, soundDistance[1], soundDistance[2])
    end
  elseif packet.state == Define.PRINTER_STATE.endPrinter and self.printerPartList[packet.partID] and self.printerPartList[packet.partID].soundId then
    Me:stopSound(self.printerPartList[packet.partID].soundId)
    self.printerPartList[packet.partID].soundId = nil
  end
end

function PartManagerHelper:updateClientBiddingPart(params)
  self.biddingPartList = params
end

function PartManagerHelper:updateClientBindPart(params)
  self.bindPlayerList = params
end

function PartManagerHelper:checkBiddingPartInteract(parentID, partName)
  local tenderInfo = self.biddingPartList[parentID]
  if not tenderInfo then
    return false
  end
  local TenderingSignManager = T(Lib, "TenderingSignManager")
  return TenderingSignManager:checkTenderPartInteract(tenderInfo.signKey, partName)
end

function PartManagerHelper:IsCanShowInteractPopForMe(partID)
  if self.bindPlayerList[partID] and self.bindPlayerList[partID] ~= Me.objID then
    return false
  end
  if self.singlePartList[partID] then
    return false
  end
  if self.furniturePartList[partID] then
    local userId = Me.platformUserId
    if self.furniturePartList[partID].passengers[userId] then
      return false
    else
      return self.furniturePartList[partID].curSitNum < self.furniturePartList[partID].totalSitNum
    end
  end
  if self.printerPartList[partID] then
    return self.printerPartList[partID].state == Define.PRINTER_STATE.notPrinter
  end
  if self.printingPaperPartList[partID] then
    return self.printingPaperPartList[partID] == Define.PRINTER_STATE.endPrinter
  end
  local part = Instance.getByInstanceId(partID)
  if part and part:isValid() then
    local parent = part:getParent()
    if parent and parent:isValid() then
      local parentID = parent:getInstanceID()
      if self.biddingPartList[parentID] then
        return self:checkBiddingPartInteract(parentID, part.name)
      end
    end
  end
  return true
end

PartManagerHelper:init()
