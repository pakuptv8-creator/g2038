local SVoicePackPkSender = T(Player, "PackageSender")

function SVoicePackPkSender:sendPlayVoicePack(player, id)
  player:sendPacketToTracking({
    pid = "PlayVoicePack",
    objID = player.objID,
    id = id
  }, true)
end
