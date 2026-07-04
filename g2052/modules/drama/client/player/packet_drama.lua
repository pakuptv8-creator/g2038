local handles = T(Player, "PackageHandlers")
local DramaClientHelper = T(Lib, "DramaClientHelper")

function handles:PushClientUpdateDramaMain(packet)
  Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO)
end

function handles:ResponseCreateDrama(packet)
  if packet.isSuccess then
    UI:closeWnd("dramaMain")
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.prop.send.CDTime")
    Plugins.CallTargetPluginFunc("game_common", "UpdateCommonWaitWndShow", false)
  end
end

function handles:ResponseJoinDrama(packet)
  if packet.isSuccess then
    UI:closeWnd("dramaMain")
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.drama.full.tips")
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO)
    Plugins.CallTargetPluginFunc("game_common", "UpdateCommonWaitWndShow", false)
  end
end

function handles:SyncCurDramaInfo(packet)
  DramaClientHelper:updateCurDramaInfo(packet.params)
end

function handles:SyncCurDramaLikeInfo(packet)
  Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_LIKE_INF, packet.params)
end

function handles:SyncPlayerJoinSuccess(packet)
  local text = Lang:toText({
    "g2052.gui.drama.join.tips",
    packet.nickName or ""
  })
  Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", text)
end

function handles:ResponseThumbUpPlayer(packet)
  if packet.isSuccess then
    DramaClientHelper.thumbUpList[packet.targetUserId] = true
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_WND_INFO)
  else
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.prop.send.CDTime")
  end
  Lib.emitEvent(Event.EVENT_DRAMA_THUMB_UP_RESULT, packet.targetUserId, packet.isSuccess)
end
