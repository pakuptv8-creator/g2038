local BattleStateExecuteCommand = Lib.class("BattleStateExecuteCommand", require("script_server.battle.state.battle_state"))

function BattleStateExecuteCommand:enter()
  Lib.logDebug("BattleStateExecuteCommand:enter", self.battleField.battleActionQueue:size())
  self.battleField:sortBattleActionQueue()
  self.battleField:sendBattleFieldBroadcast({
    pid = "processCommandStart"
  })
  local queue = self.battleField.battleActionQueue
  if not queue:empty() then
    self.battleField:setAllStateReady(false)
    local cmd = queue:front_pop()
    self.battleField:processCommand(cmd)
  else
    Lib.logError("BattleStateExecuteCommand:enter queue empty!!!")
    self.battleField:changeBattleState("WaitCommand")
  end
end

function BattleStateExecuteCommand:update(tick)
  if not self.battleField:checkStateReady() then
    return
  end
  if self.battleField.battleActionQueue:empty() then
    if self.battleField.firstExecuteCommand then
      self.battleField:changeBattleState("WaitCommand")
      self.battleField.firstExecuteCommand = false
    else
      self.battleField:changeBattleState("DeBuff")
    end
  end
end

function BattleStateExecuteCommand:leave()
  Lib.logDebug("BattleStateExecuteCommand:leave")
end

function BattleStateExecuteCommand:notifyStateReady(player, packet)
  Lib.logDebug("BattleStateExecuteCommand notifyStateReady", player.curCmdType)
  if player.curCmdType == Define.BATTLE_ACTION.RUNAWAY and player.cmdResult then
    if player:isJoinTeam() and not player:isTeamCaptain() then
      return
    end
    if player:isTeamCaptain() then
      TeamMgr:leaveBattleField(player)
    else
      player:leaveBattleField()
    end
  end
end

return BattleStateExecuteCommand
