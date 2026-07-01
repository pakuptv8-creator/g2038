local teamMgr = L("teamMgr", {})

function teamMgr:init()
  self.requestRefuseList = {}
end

function teamMgr:requestJoinTeam(from, target)
  if not from or not from:isValid() and from.isPlayer then
    return
  end
  if not target or not target:isValid() then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_player_offline"), 60)
    return
  end
  if not target.isPlayer then
    return
  end
  local map = World.CurMap
  if map.name == World.cfg.gloryHallMap then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_map_tips"), 60)
    return
  end
  if self.lastRequestTime then
    if os.time() - self.lastRequestTime <= World.cfg.requestInteractionCDTime then
      return
    end
  else
    self.lastRequestTime = os.time()
  end
  if self.requestRefuseList[target.objID] then
    local remainTime = World.cfg.refuseInteractionCDTime - (os.time() - self.requestRefuseList[target.objID])
    if 0 < remainTime then
      Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui_send_request_cd_time"), target.name, remainTime), 60)
      return
    end
  end
  if from:isJoinTeam() or target:isJoinTeam() then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_already_join_team"), 60)
    return
  end
  from:sendPacket({
    pid = "requestJoinTeam",
    fromID = from.objID,
    targetID = target.objID
  })
  Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui_send_request_join_team"), target.name), 60)
end

function teamMgr:syncRequestJoinTeam(fromID)
  if not Me:isCanShowOneInteractionWnd("pokemonRequestTeamDialog", fromID) then
    return
  end
  UI:getWnd("pokemonRequestTeamDialog"):onShow(true, fromID)
end

function teamMgr:agreeOrRefuseJoinTeam(from, target, isAgree)
  if not target or not target:isValid() and target.isPlayer then
    return
  end
  if not from or not from:isValid() then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_player_offline"), 60)
    return
  end
  if not from.isPlayer then
    return
  end
  if isAgree then
    if from:isJoinTeam() or target:isJoinTeam() then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_already_join_team"), 60)
      return
    end
    if from:getInNpc() ~= 0 or target:getInNpc() ~= 0 then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_tip_can_not_invitate"), 60)
      return
    end
    local map = World.CurMap
    if map.name == World.cfg.gloryHallMap then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_team_limit_map_tips"), 60)
      return
    end
    Me:sendPacket({
      pid = "agreeJoinTeam",
      fromID = from.objID,
      targetID = target.objID
    })
  else
    Me:sendPacket({
      pid = "refuseJoinTeam",
      fromID = from.objID,
      targetID = target.objID
    })
  end
end

function teamMgr:syncAgreeJoinTeam(from, target)
  if not target or not target:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  if from.objID == Player.CurPlayer.objID then
    Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui_agree_join_team"), target.name), 60)
    Lib.emitEvent(Event.EVENT_UPDATE_TEAM_PLAYER_INFO, target.objID)
  end
  if target.objID == Player.CurPlayer.objID then
    Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui_join_team"), from.name), 60)
    Lib.emitEvent(Event.EVENT_UPDATE_TEAM_PLAYER_INFO, from.objID)
  end
end

function teamMgr:syncRefuseJoinTeam(from, target)
  if not target or not target:isValid() then
    return
  end
  if not from or not from:isValid() then
    return
  end
  if from.isMainPlayer then
    Me:showCommonTip(Define.CommonTipType.TOP, string.format(Lang:toText("gui_refuse_join_team"), target.name), 60)
    self.requestRefuseList[target.objID] = os.time()
    self.requestRefuseList[target.objID] = os.time()
  end
end

function teamMgr:requestLeaveTeam(player)
  if not (player and player:isValid()) or not player.isPlayer then
    return
  end
  if not player:isJoinTeam() then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_not_join_team"), 60)
    return
  end
  Me:sendPacket({
    pid = "requestLeaveTeam",
    playerID = player.objID
  })
end

teamMgr:init()
return teamMgr
