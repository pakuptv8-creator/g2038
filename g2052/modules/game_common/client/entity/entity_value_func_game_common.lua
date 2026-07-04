local SoundConfig = T(Config, "SoundConfig")
local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local soundDistance = World.cfg.soundDistance or {1, 5}

function Entity.ValueFunc:curInteractiveSound(value)
  if not self.isPlayer then
    return
  end
  if self.curInteractiveSoundId then
    Me:stopSound(self.curInteractiveSoundId)
    self.curInteractiveSoundId = nil
  end
  if value ~= "" then
    local soundInfo = SoundConfig:getSound(value)
    if soundInfo then
      local sound = soundInfo.sound
      sound = "asset" .. sound
      self.curInteractiveSoundId = self:play3dSound(sound, soundInfo.loop)
      TdAudioEngine.Instance():setSoundsVolume(self.curInteractiveSoundId, soundInfo.volume)
      TdAudioEngine.Instance():set3DRollOffMode(self.curInteractiveSoundId, Sound3DRollOffType.LINEAR)
      TdAudioEngine.Instance():set3DMinMaxDistance(self.curInteractiveSoundId, soundDistance[1], soundDistance[2])
    end
  end
end

function Entity.ValueFunc:curWatchTelevision(value)
  if value then
    self:showTVInteractionUI(value, true)
  elseif self.curScreenId then
    self:showTVInteractionUI(self.curScreenId, false)
  end
  self.curScreenId = value
end

function Entity.ValueFunc:textVipColor(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_UPDATE_VIP_CHAT_TEXT, value)
  end
end

function Entity.ValueFunc:activityDress(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_ACTIVITY_DRESS_UPDATE, value)
  end
end

function Entity.ValueFunc:activityCar(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_ACTIVITY_CAR_UPDATE, value)
  end
end

function Entity.ValueFunc:activityPet(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_ACTIVITY_PET_UPDATE, value)
  end
end

function Entity.ValueFunc:isWatchedAd(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_WATCH_AD_UPDATE)
  end
end
