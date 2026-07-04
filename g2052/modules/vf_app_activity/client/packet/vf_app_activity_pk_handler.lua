local handles = T(Player, "PackageHandlers")

function handles:GetGameBadgeSuccess(packet)
  UI:openWnd("get_game_badge_result", packet.data)
end
