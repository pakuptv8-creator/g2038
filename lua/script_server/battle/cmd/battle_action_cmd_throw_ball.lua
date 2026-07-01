local BattleActionCmdThrowBall = Lib.class("BattleActionCmdThrowBall", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdThrowBall:execute(battleField)
  Lib.logDebug("BattleActionCmdThrowBall:execute")
  return true
end

return BattleActionCmdThrowBall
