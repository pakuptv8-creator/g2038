local Player = _ENV.Player

function Player:requestEditorRecommendGameList(pageNo, pageSize)
  pageSize = pageSize or Define.ModMapOnceNum
  local language = World.Lang or "en_US"
  local parentGameId = World.cfg.modParentGameId or World.GameName
  AsyncProcess.GetRecommendGameList(language, Me.platformUserId, parentGameId, function(data)
    Lib.emitEvent(Event.EVENT_MOD_EDITOR_UPDATE_RECOMMEND, data)
  end, pageNo, pageSize)
end

function Player:requestModMainEventList()
  local language = World.Lang or "en_US"
  AsyncProcess.GetModTopEventList(language, function(data)
    Lib.emitEvent(Event.EVENT_MOD_MAIN_TOP_EVENT_SHOW, data)
  end)
end

function Player:requestEditorGameDetailInfo(subGameId, parentGameId)
  local language = World.Lang or "en_US"
  local parentGameId = parentGameId or World.cfg.modParentGameId or World.GameName
  AsyncProcess.GetModGameDetailInfo(language, subGameId, parentGameId, function(data)
    UI:openWnd("modMapInfo", data)
  end)
end

function Player:addModFocusOnPlayer(targetId)
  AsyncProcess.AddModFollowPlayer(targetId, function(data)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, targetId, data.followStatus)
  end)
end

function Player:removeModFocusOnPlayer(targetId)
  AsyncProcess.RemoveModFollowPlayer(targetId, function(data)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, targetId, data.followStatus)
  end)
end

function Player:isMyModFocusOnPlayer(targetId)
  local targetIds = {targetId}
  AsyncProcess.GetModFollowRelation(targetIds, function(data)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_FOLLOW_STATE, targetId, data[1].followStatus)
  end)
end

function Player:requestModFollowPlayerList(pageNo)
  AsyncProcess.GetModFollowPlayerList(pageNo, function(data)
  end)
end

function Player:requestModFollowMapList(pageNo)
  local language = World.Lang or "en_US"
  local pageSize = Define.ModMapOnceNum
  AsyncProcess.GetModFollowPlayerMapList(language, pageNo, pageSize, function(data)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_FOLLOW_MAP_LIST, data)
  end)
end

function Player:requestEditorGameRankInfo(rankType, pageNo)
  local pageSize = Define.ModRankOnceNum
  AsyncProcess.GetModRank(rankType, pageNo, pageSize, function(resp)
    local data = resp.data
    Lib.emitEvent(Event.EVENT_MOD_RANK_UPDATE_DATA, rankType, data)
  end)
end

function Player:requestModFriendMapList(pageNo)
  local pageSize = Define.ModFriendsPageSize
  AsyncProcess.GetFriendsMods(pageNo, pageSize, function(resp)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_FRIEND_MAP_LIST, resp.data)
  end)
end

function Player:requestModMyMapList(pageNo)
  local pageSize = Define.ModMapOnceNum
  local parentGameId = World.cfg.modParentGameId or World.GameName
  AsyncProcess.GetMyModGameList(parentGameId, Me.platformUserId, pageNo, pageSize, function(data)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_MY_MAP_LIST, data)
  end)
end

function Player:requestModTopicList(pageNo)
  local pageSize = Define.ModMainTopicPageSize
  AsyncProcess.GetTopicMods(pageNo, pageSize, function(resp)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_TOPIC_LIST, resp.data)
  end)
end

function Player:requestModTopicDetailList(topicId, pageNo)
  local pageSize = Define.ModDetailTopicPageSize
  AsyncProcess.GetTopicDetailsMods(topicId, pageNo, pageSize, function(resp)
    Lib.emitEvent(Event.EVENT_MOD_UPDATE_TOPIC_DETAIL, resp.data)
  end)
end
