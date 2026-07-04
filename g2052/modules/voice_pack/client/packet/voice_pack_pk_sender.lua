local CVoicePackPkSender = T(Player, "PackageSender")

function CVoicePackPkSender:sendPlayVoicePack(id)
  if not Me.voicePackData then
    return
  end
  if not Me.voicePackData:hasVoicePack(id) then
    return
  end
  Me:sendPacket({
    pid = "PlayVoicePack",
    id = id
  })
end
