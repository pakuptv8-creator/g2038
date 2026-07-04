local handles = T(Player, "PackageHandlers")
local SVoicePackPkSender = T(Player, "PackageSender")
local GameReport = T(Game, "Report")

function handles:PlayVoicePack(packet)
  if not self.voicePackData then
    return
  end
  if not self.voicePackData:hasVoicePack(packet.id) then
    return
  end
  SVoicePackPkSender:sendPlayVoicePack(self, packet.id)
  GameReport:report("kol_voice_play", {
    voice_id = packet.id
  }, self)
end
