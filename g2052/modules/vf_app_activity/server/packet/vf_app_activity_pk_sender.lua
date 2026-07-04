local SVfAppActivityPkSender = T(Player, "PackageSender")

function SVfAppActivityPkSender:sendGetGameBadgeSuccess(player, data)
  player:sendPacket({
    pid = "GetGameBadgeSuccess",
    data = data
  })
end
