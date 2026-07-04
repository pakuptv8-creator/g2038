local handles = T(Player, "PackageHandlers")
local VoicePackConfig = T(Config, "VoicePackConfig")

function handles:SyncVoicePackData(packet)
  if not Me.voicePackData then
    local CVoicePackData = require("client.data.c_voice_pack_data")
    Me.voicePackData = CVoicePackData.new(Me)
  end
  Me.voicePackData:setVoices(packet.voices)
end

function handles:PlayVoicePack(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity then
    return
  end
  local cfg = VoicePackConfig:getCfgById(packet.id)
  if not cfg then
    return
  end
  if not Me:getPosition():inArea(entity:getPosition(), cfg.distance) then
    return
  end
  if not Me.voicePackData then
    return
  end
  Me.voicePackData:playVoice(entity, cfg)
end
