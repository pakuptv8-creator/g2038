local BattleActionCmdNone = Lib.class("BattleActionCmdNone", require("script_server.battle.cmd.battle_action_cmd"))
local LuaTimer = T(Lib, "LuaTimer")

function BattleActionCmdNone:execute(battleField)
  Lib.logDebug("BattleActionCmdNone:execute", self.param or 1000)
  battleField.waitFlag = true
  LuaTimer:cancel(self.waitTimer)
  self.waitTimer = LuaTimer:schedule(function()
    battleField.waitFlag = false
    battleField:setAllStateReady(true)
  end, self.param or 1000)
  return true
end

return BattleActionCmdNone
