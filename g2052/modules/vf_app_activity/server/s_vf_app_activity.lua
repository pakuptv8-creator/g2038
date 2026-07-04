local SVfAppActivityPkSender = T(Player, "PackageSender")
local SVfAppActivity = {}

function SVfAppActivity:addGameBadge(player)
  AsyncProcess.AddGameBadge(player.platformUserId, player.language, function(data)
    if not player:isValid() then
      return
    end
    SVfAppActivityPkSender:sendGetGameBadgeSuccess(player, data)
  end)
end

function SVfAppActivity:removeGameBadge(player)
  AsyncProcess.RemoveGameBadge(player.platformUserId)
end

return SVfAppActivity
