local Entity = _ENV.Entity
local ProfessionalHelper = T(Lib, "ProfessionalHelper")
local PropsConfig = T(Config, "PropsConfig")

function Entity:StartSlideLadderInteract(player, ladderPartId, triggerPartId)
  self:playClientAction("slide", -1, true)
  self:setAlwaysAction("slide")
  if not player or not player:isValid() then
    return
  end
  self.SlideLadderPlayer = player
  local triggerPart = Instance.getByInstanceId(triggerPartId)
  if triggerPart and triggerPart:isValid() then
    self.SlideLadderPlayer:setPos(triggerPart:getPosition())
  else
  end
  if player.objID == Me.objID then
    local bm = Blockman.instance
    local cameraInfo = bm:getCameraInfo()
    self.cameraSaveData = {
      curInfo = cameraInfo.curInfo
    }
    bm:setPersonView(4)
    self.ladderYaw, self.ladderPitch = bm:viewerRenderYaw(), bm:viewerRenderPitch()
    self.ladderViewDis = bm:viewerRenderDistance()
    Me:sendPacket({
      pid = "doStartSlideLadder",
      objID = Me.objID
    })
  end
  if self.ladderRenderTickListener then
    self.ladderRenderTickListener()
    self.ladderRenderTickListener = nil
  end
  self.curLadderTick = 0
  self.beginLadder = true
end

function Entity:doStopSlideLadderInteract(playerId)
  if self.ladderRenderTickListener then
    self.ladderRenderTickListener()
    self.ladderRenderTickListener = nil
  end
  local pos = self:getSocketPosition("Bone002")
  local player = World.CurWorld:getEntity(playerId)
  if player and player:isValid() then
    player:setPos(pos)
    player:setActorHide(false)
  else
  end
  self.beginLadder = false
  self.ladderPart = nil
  if playerId == Me.objID then
    Me:setPos(pos)
    Me:setActorHide(false)
    local bm = Blockman.instance
    if self.cameraSaveData and self.cameraSaveData.curInfo then
      bm:setPersonView(self.cameraSaveData.curInfo.curPersonView)
      bm:setCanSwitchView(self.cameraSaveData.curInfo.canSwitchView)
      Me:changeCameraView(pos, Me:getRotationYaw(), Me:getRotationPitch(), self.cameraSaveData.curInfo.distance, 10)
    else
      bm:setPersonView(Define.PersonView.THIRD)
      Me:changeCameraView(pos, Me:getRotationYaw(), Me:getRotationPitch(), 4, 10)
    end
    Me:sendPacket({
      pid = "onFinishSlideLadderInteract",
      pos = pos,
      playerId = playerId
    })
  end
end

function Entity:ladderRenderTick()
  if not self.beginLadder then
    return
  end
  self.curLadderTick = self.curLadderTick + 1
  if self and self:isValid() then
    local pos = self:getSocketPosition("Bone002")
    if self.curLadderTick > 1 then
      if self.SlideLadderPlayer and self.SlideLadderPlayer:isValid() then
        self.SlideLadderPlayer:setPos(pos)
        if self.SlideLadderPlayer.objID == Me.objID then
          self.ladderViewDis = self.ladderViewDis + 1.0
          if self.ladderViewDis > 10 then
            self.ladderViewDis = 10
          end
          local desPos = Vector3.lerp(self.curPos or pos, pos, 0.3)
          Me:changeCameraView(desPos, self.ladderYaw, self.ladderPitch, self.ladderViewDis, 1)
          self.curPos = desPos
        end
      else
        print("warming:self.SlideLadderPlayer is not valid")
      end
    end
  end
end

function Entity:doPlayerDoSwing(part, oldGravity)
  self.inUsePropEventListener = Lib.subscribeEvent(Event.EVENT_UPDATE_IN_USE_PROP, function(inUseProp, objID)
    if objID == self.objID and self.tempViewEntity and self.tempViewEntity:isValid() then
      self.tempViewEntity:copyHeadInfo(self)
    end
  end)
  self.curTick = 0
  if part and part:isValid() then
    self.initSwingPos = part:getPosition()
    self.initRotation = part:getRotation()
    self.oldSwingPos = Lib.copy(self.initSwingPos)
    self.oldRotation = Lib.copy(self.initRotation)
  end
  self.tempViewEntity = EntityClient.CreateClientEntity({
    cfgName = World.cfg.playerCfg,
    pos = self:getPosition(),
    name = ""
  })
  if self.tempViewEntity and self.tempViewEntity:isValid() then
    self.tempViewEntity:changeActor(self:checkSex() == 1 and self:cfg().actorName or self:cfg().actorGirlName or self:cfg().actorName)
    self.tempViewEntity:copyHeadInfo(self)
    self.tempViewEntity:addClientBuff("myplugin/swing_buff")
    self.tempViewEntity:playClientAction("sit1", -1)
    self.tempViewEntity:setAlwaysAction("sit1")
    self:initSwingInfo(part, oldGravity)
  end
end

function Entity:initSwingInfo(part, oldGravity)
  if self:getOnSwingState() == 0 then
    self:onPlayerStopSwing()
    return
  end
  self:setActorHide(true)
  self.curTick = 0
  self.LastTransformTick = 0
  self.swingPart = part
  self.oldGravity = oldGravity
  self.swingAxis = Lib.createV3ByString("1#0#0")
  self.swingBase = Lib.createV3ByString("0#3#0")
  local pos = self.swingBase * -1
  local q1 = Quaternion.fromEulerAngle(self.initRotation.x, self.initRotation.y, self.initRotation.z)
  self.curSwingPartPos = q1 * pos
  if self.tempViewEntity and self.tempViewEntity:isValid() then
    self.curPlayerPos = self.tempViewEntity:getPosition()
  else
    self.curPlayerPos = self:getPosition()
  end
  self.isFirstBeginning = true
  self.swingAngle = 1
  self.lastPartRotationX = 0
  self.swingTotalTime = self:cfg() and self:cfg().swingMinTime or 10
  self.anglePerFrame = self:cfg() and self:cfg().swingMinAnglePerFrame or 0.5
  part:setUseCollide(false)
  self:data("main").beginSwing = true
end

function Entity:copyHeadInfo(target)
  if not target or not target:isValid() then
    return
  end
  local nameInfo = target:getHeadShowNameText()
  self:setShowName1(nameInfo, World.cfg.headFont or "HT24", World.cfg.headFontHeight or 0)
  local DramaClientHelper = T(Lib, "DramaClientHelper")
  local shapeScale = 1
  if DramaClientHelper:checkInTemplateMod(Define.DramaTemplateKey.Giant) then
    shapeScale = target:getGiantShape() or 1
  else
    shapeScale = target:getShapeScale() or 1
  end
  self:updateBoundingVolume(shapeScale)
  local inUseItem = target:getInUseProp()
  if inUseItem then
    local itemInfo = PropsConfig:getCfgById(inUseItem.itemId)
    local buffs = itemInfo.buffs
    if not buffs then
      return
    end
    local curIndex = inUseItem.index
    if self.curInUseItem and self.curInUseItem == curIndex then
      return
    end
    if buffs[curIndex] then
      if self.curCopyBuff then
        self:removeClientTypeBuff("fullName", self.curCopyBuff)
      end
      self:addClientBuff(buffs[curIndex])
      self.curCopyBuff = buffs[curIndex]
      self.curInUseItem = curIndex
    end
  elseif self.curCopyBuff then
    self:removeClientTypeBuff("fullName", self.curCopyBuff)
  end
  local skinData = target:data("skins")
  self:applySkin(skinData)
end

function Entity:tick()
  self.curTick = self.curTick + 1
  self:swing()
end

function Entity:swing()
  if not self or not self:isValid() then
    self:onPlayerStopSwing()
    return
  end
  if not self:data("main").beginSwing then
    return
  end
  if not self.swingPart or not self.swingPart:isValid() then
    self:onPlayerStopSwing()
    return
  end
  if not self.tempViewEntity or not self.tempViewEntity:isValid() then
    self:onPlayerStopSwing()
    return
  end
  if self:getOnSwingState() == 0 then
    self:onPlayerStopSwing()
    return
  end
  local curPartRotationX = self.lastRotation and self.lastRotation.x or self.swingPart:getRotation().x
  if curPartRotationX <= 0 and 0 < self.lastPartRotationX or 0 <= curPartRotationX and 0 > self.lastPartRotationX then
    self:reFreshSwingData()
  end
  local totalAngle = self.swingTotalTime * self.anglePerFrame
  if 180 < totalAngle then
    totalAngle = 180
  end
  if totalAngle / 2 < math.abs(curPartRotationX) then
    if self.isFirstBeginning then
      self.swingTotalTime = self.swingTotalTime * 2
      self.isFirstBeginning = false
    end
    self.LastTransformTick = self.curTick
    self.swingAngle = -self.swingAngle
  end
  self.lastPartRotationX = curPartRotationX
  self.initSwingPos = self.swingPart:getPosition()
  local newRotation = self.initRotation + self.swingAxis * (self.swingAngle * self.anglePerFrame)
  local q2 = Quaternion.fromEulerAngle(newRotation.x, newRotation.y, newRotation.z)
  local newPos = q2 * (self.swingBase * -1)
  local offsetPos = newPos - self.curSwingPartPos
  self.swingPart:setRotation(newRotation)
  self.lastRotation = newRotation
  local desPos = self.initSwingPos + offsetPos
  self.swingPart:setPosition(desPos)
  self.curSwingPartPos = newPos
  local yaw = -newRotation.y
  local pitch = newRotation.x
  local newPlayerPos = self.curPlayerPos + offsetPos * 2
  self.tempViewEntity:setPos(newPlayerPos, yaw, pitch)
  self.curPlayerPos = newPlayerPos
  self.initRotation = newRotation
end

function Entity:reFreshSwingData()
  local initAnglePerFrame = self:cfg() and self:cfg().swingMinAnglePerFrame or 0.5
  if Me.objID == self.objID then
    if Me.swingSpeedRate and Me.swingSpeedRate > 0 then
      self.anglePerFrame = initAnglePerFrame * (1 + self:getSwingSpeedRate() * 5)
    else
      self.anglePerFrame = self:cfg() and self:cfg().swingMinAnglePerFrame or 0.5
    end
  elseif 0 < self:getSwingSpeedRate() then
    self.anglePerFrame = initAnglePerFrame * (1 + self:getSwingSpeedRate() * 5)
  else
    self.anglePerFrame = self:cfg() and self:cfg().swingMinAnglePerFrame or 0.5
  end
end

function Entity:onPlayerStopSwing()
  if self.swingPart and self.swingPart:isValid() then
    self.swingPart:setUseCollide(true)
    self.swingPart:setRotation(self.oldRotation)
    self.swingPart:setPosition(self.oldSwingPos)
  end
  if self and self:isValid() then
    self:setRotationPitch(0)
    self:data("main").beginSwing = false
    self:setActorHide(false)
  end
  if self.inUsePropEventListener then
    self.inUsePropEventListener()
    self.inUsePropEventListener = nil
  end
  if self.tempViewEntity and self.tempViewEntity:isValid() then
    self.tempViewEntity:destroy()
    self.tempViewEntity = nil
  end
end
