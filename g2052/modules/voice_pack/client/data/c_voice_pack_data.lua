local VoicePackConfig = T(Config, "VoicePackConfig")
local IVoicePackData = require("common.data.i_voice_pack_data")
local CVoicePackData = class("CVoicePackData", IVoicePackData)
local CurPlaySoundID = {}

function CVoicePackData:setVoices(voices)
  self.voices = voices or {}
end

function CVoicePackData:getVoiceCfgList()
  local cfgs = {}
  for _, id in pairs(self.voices) do
    table.insert(cfgs, VoicePackConfig:getCfgById(id))
  end
  return cfgs
end

function CVoicePackData:playVoice(player, cfg)
  local soundId = CurPlaySoundID[player.objID]
  if soundId then
    TdAudioEngine.Instance():stopSound(soundId)
  end
  soundId = TdAudioEngine.Instance():play2dSound(cfg.path, false, 1)
  CurPlaySoundID[player.objID] = soundId
  local volume = cfg.volume or 1
  local selfPos = Me:getPosition()
  local maxDis = cfg.distance
  local distance = math.min(selfPos:distance(player:getPosition()), maxDis)
  volume = volume * (maxDis - distance) / maxDis
  TdAudioEngine.Instance():setSoundsVolume(soundId, volume)
  if Me.showChatBubble then
    Me:showChatBubble({
      pageType = "world",
      objID = player.objID,
      msgType = 1,
      msg = Lang:toText(cfg.name)
    })
  end
end

return CVoicePackData
