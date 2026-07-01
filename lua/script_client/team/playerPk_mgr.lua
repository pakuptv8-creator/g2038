local playerPkMgr = L("playerPkMgr", {})

function playerPkMgr:init()
  self.requestRefuseList = {}
end

function playerPkMgr:requestPkBattle(targetID)
  local target = World.CurWorld:getEntity(targetID)
  if not target or not target:isValid() then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
    return
  end
  if not target.isPlayer then
    return
  end
  if self.lastRequestTime then
    if os.time() - self.lastRequestTime <= World.cfg.requestInteractionCDTime then
      return
    end
  else
    self.lastRequestTime = os.time()
  end
  if self.requestRefuseList[targetID] then
    local remainTime = World.cfg.refuseInteractionCDTime - (os.time() - self.requestRefuseList[targetID])
    if 0 < remainTime then
      Client.ShowTip(1, string.format(Lang:toText("gui_send_request_cd_time"), target.name, remainTime), 60)
      return
    end
  end
  Me:sendPlayerAction(Define.PLAYER_ACTION.PK, targetID, function()
    Client.ShowTip(1, string.format(Lang:toText("gui_send_request_pk_player"), target.name), 60)
  end)
end

function playerPkMgr:syncRequestPKPlayer(fromID)
  if not Me:isCanShowOneInteractionWnd("pokemonRequestPkDialog", fromID) then
    return
  end
  UI:getWnd("pokemonRequestPkDialog"):onShow(true, fromID)
end

function playerPkMgr:clickPlayerIsTooFar(fromID)
  local target = World.CurWorld:getEntity(fromID)
  if not target or not target:isValid() then
    Client.ShowTip(1, Lang:toText("tips_target_is_to_far"), 40)
    return true
  end
  local MePos = Me:getPosition()
  if (Lib.v3(MePos.x, MePos.y, MePos.z) - target:getPosition()):len() > World.cfg.clickPlayerDistance then
    Client.ShowTip(1, Lang:toText("gui_interactionUI_to_far"), 40)
    return true
  end
  return false
end

function playerPkMgr:refusePKRequest(fromID)
  local from1 = World.CurWorld:getEntity(fromID)
  if not from1 or not from1:isValid() then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
    return
  end
  Me:sendPacket({
    pid = "refuseOthersPkRequest",
    fromID = fromID
  })
end

function playerPkMgr:agreePKRequest(fromID)
  if self:clickPlayerIsTooFar(fromID) then
    return
  end
  local from1 = World.CurWorld:getEntity(fromID)
  if not from1 or not from1:isValid() then
    Client.ShowTip(1, Lang:toText("gui_player_offline"), 60)
    return
  end
  if Me:getInNpc() ~= 0 or from1:getInNpc() ~= 0 then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_tip_can_not_invitate"), 60)
    return
  end
  Client.ShowTip(1, string.format(Lang:toText("gui_tip_agree_request"), from1.name), 60)
  Me:sendPacket({
    pid = "agreeOthersPkRequest",
    fromID = fromID
  })
end

function playerPkMgr:syncPkRequestRefused(targetID)
  local target = World.CurWorld:getEntity(targetID)
  Client.ShowTip(1, string.format(Lang:toText("gui_tip_refuse_pk_request"), target.name), 60)
  self.requestRefuseList[targetID] = os.time()
end

function playerPkMgr:syncPkRequestAgreed(targetID)
  local target = World.CurWorld:getEntity(targetID)
  Client.ShowTip(1, string.format(Lang:toText("gui_tip_agreed_pk_request"), target.name), 60)
end

playerPkMgr:init()
return playerPkMgr
