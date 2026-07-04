local InteractSoundHelper = T(Lib, "InteractSoundHelper")
local InteractEventConfig = T(Config, "InteractEventConfig")
local SoundConfig = T(Config, "SoundConfig")
local soundDistance = World.cfg.soundDistance or {1, 5}
InteractSoundHelper.soundIds = {}
InteractSoundHelper.audioNodes = {}
InteractSoundHelper.loopSounds = {}

function InteractSoundHelper:init()
  self.volume = 1
  self.rollOffType = "LINEARSQUARE"
  self.isLoop = false
  World.Timer(20, function()
    self:monitorPartSurvival()
    return true
  end)
end

local function verifyPlayObject(instanceId, triggerType)
  if not instanceId then
    return
  end
  local instance = Instance.getByInstanceId(instanceId)
  if not instance or not instance:isValid() then
    return
  end
  local config = InteractEventConfig:getCfgById(instance.name)
  if not config and not config.triggerSound then
    return
  end
  local soundInfo = SoundConfig:getSound(config[triggerType])
  if not soundInfo then
    return
  end
  return true, instance, soundInfo
end

function InteractSoundHelper:playSound(data)
  local instanceId = data.instanceId
  local triggerType = data.triggerType
  local ok, instance, soundInfo = verifyPlayObject(instanceId, triggerType)
  if not ok then
    return
  end
  local filePath = soundInfo.sound
  filePath = "asset" .. filePath
  if World.isClient then
    if self.soundIds[instanceId] then
      self:stopSound(data)
    end
    local pos = instance:getPosition() or Me:getPosition()
    local soundId = TdAudioEngine.Instance():play3dSound(filePath, pos, soundInfo.loop, 1, 1.0, 100.0)
    TdAudioEngine.Instance():setSoundsVolume(soundId, soundInfo.volume)
    TdAudioEngine.Instance():set3DRollOffMode(soundId, Sound3DRollOffType[self.rollOffType])
    TdAudioEngine.Instance():set3DMinMaxDistance(soundId, soundDistance[1], soundDistance[2])
    self.soundIds[instanceId] = soundId
    if data.isToOthers then
      Me:sendPacket({
        pid = "SendSoundToOthers",
        data = data
      })
    end
  else
    if soundInfo.loop then
      self.loopSounds[instanceId] = data
    end
    WorldServer.BroadcastPacket({
      pid = "clientPlayInteractSound",
      data = data
    })
  end
end

function InteractSoundHelper:stopSound(data)
  local instanceId = data.instanceId
  local triggerType = data.triggerType
  if World.isClient then
    local soundId = self.soundIds[instanceId]
    if soundId then
      TdAudioEngine.Instance():stopSound(soundId)
      self.soundIds[instanceId] = nil
    end
  else
    local ok, instance, soundInfo = verifyPlayObject(instanceId, triggerType)
    if soundInfo and soundInfo.loop then
      self.loopSounds[instanceId] = nil
    end
    WorldServer.BroadcastPacket({
      pid = "clientStopInteractSound",
      data = data
    })
  end
end

function InteractSoundHelper:sendPlayLoopSounds(player)
  player:sendPacket({
    pid = "SendPlayLoopSounds",
    loopSounds = self.loopSounds
  })
end

function InteractSoundHelper:monitorPartSurvival()
  for id, v in pairs(self.loopSounds or {}) do
    local node = Instance.getByInstanceId(id)
    if not node or not node:isValid() then
      self:stopSound({
        instanceId = id,
        triggerType = "triggerSound",
        isFollow = true
      })
    end
  end
end

InteractSoundHelper:init()
return InteractSoundHelper
