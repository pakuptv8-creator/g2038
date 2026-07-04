local SoundConfig = T(Config, "SoundConfig")
local soundDistance = World.cfg.soundDistance or {1, 5}
local InteractionHelper = T(Lib, "InteractionHelper")

function Entity.EntityProp:hideActor(value, add, cfg, id)
  if add then
    self:setEntityHide(true)
  else
    self:setEntityHide(false)
  end
end

function Entity.EntityProp:loseControlGlassesUI(value, add, cfg, id)
  if not self.isPlayer == true then
    return
  end
  if self.objID ~= Me.objID then
    return
  end
  Lib.emitEvent(Event.EVENT_UPDATE_LOSE_CONTROL_GLASSES_UI, add)
end

function Entity.EntityProp:telescopeUI(value, add, cfg, id)
  if not self.isPlayer == true then
    return
  end
  if self.objID ~= Me.objID then
    return
  end
  Lib.emitEvent(Event.EVENT_UPDATE_TELESCOPE_UI, add)
end

function Entity.EntityProp:telescopeLikeCamera(value, add, cfg, id)
  if not self.isPlayer == true then
    return
  end
  if self.objID ~= Me.objID then
    return
  end
  if add then
    self:openTelescopeLikeCameraMode(value.fovAngle, value.forbidFovAngleOp, value.view, value.firstViewActor)
  else
    self:closeTelescopeLikeCameraMode()
  end
end

function Entity.EntityProp:actionMap(value, add, buff)
  local actionKey = "buff_" .. buff.id
  local actionPriority = buff.cfg.actionPriority or Define.ActionMapPriority.normalPriority
  local InteractionHelper = T(Lib, "InteractionHelper")
  InteractionHelper:updateActionMapState(self.objID, value, add, actionKey, actionPriority)
end

function Entity.EntityProp:propActionState(value, add, buff)
  local InteractionHelper = T(Lib, "InteractionHelper")
  if not next(value) then
    return
  end
  if add then
    local actionKey = "propAction_" .. buff.id
    local actionData = {
      priority = Define.ActionMapPriority.propPriority,
      actionName = value.idle or "idle",
      actionTime = -1,
      actionType = "propAction"
    }
    InteractionHelper:updateEntityActionData(self.objID, actionKey, true, actionData)
  else
    local actionKey = "propAction_" .. buff.id
    InteractionHelper:updateEntityActionData(self.objID, actionKey, false)
  end
end

function Entity.EntityProp:skin(value, add, cfg, id)
  if self.isPlayer then
    return
  end
  if add then
    self:applySkin(value)
  else
    local reset = {}
    for m, _ in pairs(value) do
      reset[m] = 0
    end
    self:applySkin(reset)
  end
end

function Entity.EntityProp:alpha(value, add, cfg)
  local buffCfg = cfg.cfg or {}
  if add then
    if self.alphaDelayTimer then
      self.alphaDelayTimer()
      self.alphaDelayTimer = nil
      self:setAlpha(1)
    end
    if self.alterAlpha then
      self.alterAlpha()
      self.alterAlpha = nil
    end
    self.alphaDelayTimer = Me:timer(buffCfg.delayTime or 20, function()
      if self and self:isValid() then
        self:setAlpha(value)
      end
    end)
    self.alterAlpha = Me:timer(buffCfg.alphaTime or 100, function()
      if self and self:isValid() then
        self:setAlpha(1)
      end
    end)
  end
end

function Entity.EntityProp:soundEffect(value, add, cfg)
  if add then
    local soundInfo = SoundConfig:getSound(value)
    if soundInfo then
      local sound = soundInfo.sound
      sound = "asset" .. sound
      cfg.soundId = self:play3dSound(sound, soundInfo.loop)
      self.curItemSoundId = cfg.soundId
      local volume = soundInfo.volume
      self.curItemSoundVolume = volume
      TdAudioEngine.Instance():setSoundsVolume(cfg.soundId, volume)
      TdAudioEngine.Instance():set3DRollOffMode(cfg.soundId, Sound3DRollOffType.LINEAR)
      TdAudioEngine.Instance():set3DMinMaxDistance(cfg.soundId, soundDistance[1], soundDistance[2])
    end
  elseif cfg.soundId then
    self:stopSound(cfg.soundId)
    self.curItemSoundId = nil
  end
end

function Entity.EntityProp:speedUpAction(value, add, cfg)
  if add and value then
    local _, passenger = next(self:data("passengers"))
    if passenger then
      local player = self.world:getEntity(passenger)
      if player and player:isValid() then
        do
          local actionKey = "speedUpAction"
          local actionData = {
            priority = Define.ActionMapPriority.lowPriority,
            actionName = value,
            actionTime = -1
          }
          InteractionHelper:updateEntityActionData(player.objID, actionKey, true, actionData)
          World.Timer(16, function()
            if not player:isValid() or not player.objID then
              return
            end
            InteractionHelper:updateEntityActionData(player.objID, actionKey, false)
            local actionKey3 = "speedUpAction_3"
            local actionData3 = {
              priority = Define.ActionMapPriority.lowPriority,
              actionName = "g2052_boy_riding_run",
              actionTime = -1,
              refreshBaseAction = true
            }
            InteractionHelper:updateEntityActionData(player.objID, actionKey3, true, actionData3)
            InteractionHelper:updateEntityActionData(player.objID, actionKey3, false)
            if not self:isValid() or not self.objID then
              return
            end
            local actionKeyPet2 = "speedUpActionPet_2"
            local actionDataPet2 = {
              priority = Define.ActionMapPriority.normalPriority,
              actionName = "run",
              actionTime = -1,
              refreshBaseAction = true
            }
            InteractionHelper:updateEntityActionData(self.objID, actionKeyPet2, true, actionDataPet2)
            InteractionHelper:updateEntityActionData(self.objID, actionKeyPet2, false)
          end)
        end
      end
    end
  end
end

function Entity.EntityProp:forceToIdle(value, add, buff)
  local ti = TdAudioEngine.Instance()
  if add then
    local buffs = self:data("buff")
    if not buffs then
      return
    end
    local removeIds = {}
    local removeBuff = buff.cfg.removeBuff or {}
    for id, v in pairs(buffs) do
      for _, re in pairs(removeBuff) do
        if re == v.cfg.fullName then
          removeIds[id] = 1
          break
        end
      end
    end
    for id, _ in pairs(removeIds) do
      local buff = self:data("buff")[id]
      if buff.soundId then
        ti:stopSound(buff.soundId)
      end
    end
  end
end

function Entity.EntityProp:sound(value, add, buff)
  local ti = TdAudioEngine.Instance()
  if add then
    buff.soundId = self:playSound(value, buff.cfg)
    local soundId = buff.soundId
    local volume = tonumber(value.volume)
    if volume then
      ti:setSoundsVolume(soundId, volume)
    end
    local rollOffType = Sound3DRollOffType[value.rollOffType]
    if rollOffType then
      ti:set3DRollOffMode(soundId, rollOffType)
    end
    local distance = value.distance
    if distance then
      ti:set3DMinMaxDistance(soundId, distance[1], distance[2])
    else
      ti:set3DMinMaxDistance(soundId, soundDistance[1], soundDistance[2])
    end
  else
    if value.notAutoOff then
      return
    end
    ti:stopSound(buff.soundId)
  end
end

function Entity.EntityProp:effects(value, add, buff)
  for index, effect in pairs(value) do
    local name = string.format("buff_%d_%d_%d", self.objID, buff.id, index)
    if add then
      self:showEffect(effect, buff.cfg, name)
    else
      self:delEffect(name, effect.smoothRemove)
    end
  end
end

function Entity.EntityProp:buffAction(value, add, buff)
  if not value.isClient then
    return
  end
  local actionData
  if add then
    actionData = value.startAction
  else
    actionData = value.endAction
  end
  if actionData then
    local actionName = actionData.actionName
    local time = actionData.time or -1
    if actionName and actionName ~= "" then
      self:updateUpperAction(actionName, time)
    end
  end
end

function Entity.EntityProp:lockBodyRotation(value, add, buff)
  if add then
    Blockman.Instance().gameSettings:setLockBodyRotation(value)
  else
    Blockman.Instance().gameSettings:setLockBodyRotation(not value)
  end
end

function Entity.EntityProp:actorAlpha(value, add, cfg, id)
  if add then
    self:setAlpha(value)
  else
    self:setAlpha(1)
  end
end
