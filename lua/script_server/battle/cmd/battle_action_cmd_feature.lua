local BattleActionCmdFeature = Lib.class("BattleActionCmdFeature", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdFeature:execute(battleField)
  Lib.logDebug("BattleActionCmdFeature:execute")
  if not self.caster or not self.caster:isValid() then
    battleField:setAllStateReady(true)
    return false
  end
  local caster = self.caster.isPlayer and self.caster:getBattlePet() or self.caster
  if caster and caster:isValid() then
    caster:addPkmBirthEffectBuff()
  else
    battleField:setAllStateReady(true)
  end
  return true
end

return BattleActionCmdFeature
