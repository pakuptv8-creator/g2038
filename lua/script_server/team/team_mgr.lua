local LuaTimer = T(Lib, "LuaTimer")

function TeamMgr:requestJoinTeam(from, target)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  if not (target and target:isValid()) or not target.isPlayer then
    return
  end
  if from:isJoinTeam() or target:isJoinTeam() then
    return
  end
  target:sendPacket({
    pid = "syncRequestJoinTeam",
    fromID = from.objID,
    fromName = from.name
  })
end

function TeamMgr:agreeJoinTeam(from, target)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  if not (target and target:isValid()) or not target.isPlayer then
    return
  end
  if from:isJoinTeam() or target:isJoinTeam() then
    return
  end
  local captainDate = {
    captainID = from.objID,
    teamMateID = target.objID,
    isCaptain = 1
  }
  local teamMateDate = {
    captainID = from.objID,
    teamMateID = from.objID,
    isCaptain = 0
  }
  from:setMyTeam(captainDate)
  target:setMyTeam(teamMateDate)
  from:addBuff("myplugin/team_sign_effect_buff")
  target:addBuff("myplugin/disable_collision_buff")
  from:sendPacket({
    pid = "syncAgreeJoinTeam",
    fromID = from.objID,
    targetID = target.objID
  })
  target:sendPacket({
    pid = "syncAgreeJoinTeam",
    fromID = from.objID,
    targetID = target.objID
  })
end

function TeamMgr:refuseJoinTeam(from, target)
  if not (from and from:isValid()) or not from.isPlayer then
    return
  end
  if not (target and target:isValid()) or not target.isPlayer then
    return
  end
  from:sendPacket({
    pid = "syncRefuseJoinTeam",
    fromID = from.objID,
    targetID = target.objID
  })
end

function TeamMgr:leaveTeam(player)
  if not (player and player:isValid()) or not player.isPlayer then
    return
  end
  if not player:isJoinTeam() then
    return
  end
  local teamMateID = player:getMyTeamMateId()
  if teamMateID then
    local teamMate = World.CurWorld:getObject(teamMateID)
    if teamMate and teamMate:isValid() then
      if teamMate:isTeamCaptain() then
        teamMate:removeTypeBuff("fullName", "myplugin/team_sign_effect_buff")
      else
        teamMate:removeTypeBuff("fullName", "myplugin/disable_collision_buff")
      end
      teamMate:setMyTeam(nil)
      do
        local status = teamMate:getMapUnlockByPos()
        Lib.logDebug("leaveTeam mate status = ", status)
        if status == 0 then
          Lib.logDebug("leaveTeam mate battleField = ", teamMate.battleField)
          teamMate:setIsReturnHome(true)
          LuaTimer:schedule(function()
            Lib.logDebug("level is not fullfied, telegraph to home town")
            teamMate:telegraphToMap(1)
            teamMate:setIsReturnHome(false)
          end, 5000)
        end
        teamMate:sendPacket({
          pid = "syncLeaveTeam",
          status = status
        })
        teamMate:setBattlePreType(Define.MEET_PKM_TYPE.NO_MEET_PKM)
        teamMate:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.NO_MEET_PKM)
      end
    end
  end
  if player:isTeamCaptain() then
    player:removeTypeBuff("fullName", "myplugin/team_sign_effect_buff")
  else
    player:removeTypeBuff("fullName", "myplugin/disable_collision_buff")
  end
  player:setMyTeam(nil)
  local status = player:getMapUnlockByPos()
  Lib.logDebug("leaveTeam self status = ", status)
  if status == 0 then
    Lib.logDebug("leaveTeam self battleField = ", player.battleField)
    player:setIsReturnHome(true)
    LuaTimer:schedule(function()
      Lib.logDebug("level is not fullfied, telegraph to home town")
      player:telegraphToMap(1)
      player:setIsReturnHome(false)
    end, 5000)
  end
  player:sendPacket({
    pid = "syncLeaveTeam",
    status = status
  })
  player:setBattlePreType(Define.MEET_PKM_TYPE.NO_MEET_PKM)
  player:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.NO_MEET_PKM)
end

function TeamMgr:enterBattleField(captain, battleField, index, campId, enemyList)
  if not (captain and captain:isValid()) or not captain:isTeamCaptain() then
    return
  end
  local teamMate = captain:getMyTeamMate()
  if not teamMate then
    return
  end
  index = index or 2
  campId = campId or Define.CAMP.CAMP_NONE
  enemyList = enemyList or {}
  captain:enterBattleField(battleField, index, campId, enemyList)
  teamMate:enterBattleField(battleField, index + 1, campId, enemyList)
end

function TeamMgr:leaveBattleField(captain)
  if not (captain and captain:isValid()) or not captain:isTeamCaptain() then
    return
  end
  local teamMate = captain:getMyTeamMate()
  if not teamMate or not teamMate:isValid() then
    return
  end
  captain:leaveBattleField()
  teamMate:leaveBattleField()
end

function TeamMgr:onPlayerLogout(player)
  TeamMgr:leaveTeam(player)
end

return TeamMgr
