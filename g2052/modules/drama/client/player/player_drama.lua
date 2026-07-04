local Player = _ENV.Player
local DramaClientHelper = T(Lib, "DramaClientHelper")

function Player:requestCreateOneDrama(dramaInfo)
  Plugins.CallTargetPluginFunc("report", "report", "script_create", nil, Me)
  Plugins.CallTargetPluginFunc("game_common", "UpdateCommonWaitWndShow", true)
  local packet = {
    pid = "RequestCreateOneDrama",
    dramaInfo = dramaInfo
  }
  Me:sendPacket(packet)
end

function Player:requestAmendOneDrama(dramaInfo)
  local packet = {
    pid = "RequestAmendOneDrama",
    dramaInfo = dramaInfo
  }
  Me:sendPacket(packet)
end

function Player:requestJoinDrama(id, channel)
  Plugins.CallTargetPluginFunc("game_common", "UpdateCommonWaitWndShow", true)
  local defaultData = {
    script_label = UI:getWnd("dramaMain"):getCurSelectTabIndex()
  }
  Plugins.CallTargetPluginFunc("report", "report", "script_join", defaultData, Me)
  local packet = {
    pid = "RequestJoinDrama",
    id = id,
    channel = channel
  }
  Me:sendPacket(packet)
end

function Player:requestDramaDetailInfo(id)
  AsyncProcess.GetDramaDetailData(function(data)
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_DETAIL_INFO, id, data)
    if DramaClientHelper.curDramaInfo and DramaClientHelper.curDramaInfo.id == id then
      DramaClientHelper:updateCurDramaInfo(data)
    end
  end, id, self.platformUserId)
end

function Player:requestLikesNumByUserID(userId)
  AsyncProcess.GetLikesNumByUserID(function(data)
    Lib.emitEvent(Event.EVENT_DRAMA_UPDATE_LIKES_NUM, data)
  end, userId)
end

function Player:requestLikeRankingList(pageNo, pageSize)
  local pageSize = pageSize or World.cfg.dramaSetting.likeRankingPageSize
  AsyncProcess.GetLikeRankingListWithPage(function(data)
    if data.data then
      Lib.emitEvent(Event.EVENT_DRAMA_LIKE_RANKING_UPDATE, data.data)
    end
  end, pageNo, pageSize)
end

function Player:requestHistoryDrama()
  AsyncProcess.GetHistoryDrama(function(data)
    if data.data then
      Lib.emitEvent(Event.EVENT_DRAMA_HISTORY_UPDATE, data.data)
    end
  end)
end
