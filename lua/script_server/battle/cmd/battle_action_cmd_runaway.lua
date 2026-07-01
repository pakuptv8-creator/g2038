local BattleActionCmdRunaway = Lib.class("BattleActionCmdRunaway", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdRunaway:execute(battleField)
  if not self.caster or not self.caster:isValid() then
    battleField:setAllStateReady(true)
    return false
  end
  self.caster:cacheAction(Define.BATTLE_ACTION.RUNAWAY)
  if battleField:getBattleMode() == Define.BATTLE_MODE.PVP then
    self:sendBattleActionResult(battleField, {
      type = self.type,
      mode = Define.BATTLE_MODE.PVP,
      campId = self.caster:getCampId()
    })
    return true
  else
    local result = math.min(1, battleField:getPlayerSpeed(self.caster) / battleField:getEnemySpeed(self.caster))
    result = result > math.random()
    self:sendBattleActionResult(battleField, {
      type = self.type,
      mode = Define.BATTLE_MODE.PVE,
      result = result
    })
    Lib.logDebug("BattleActionCmdRunaway:execute", result)
    return result
  end
end

return BattleActionCmdRunaway
