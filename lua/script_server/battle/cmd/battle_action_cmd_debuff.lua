local BattleActionCmdDeBuff = Lib.class("BattleActionCmdDeBuff", require("script_server.battle.cmd.battle_action_cmd"))
local World = _ENV.World

function BattleActionCmdDeBuff:execute(battleField)
  Lib.logDebug("BattleActionCmdDeBuff:execute")
  local pTarget = World.CurWorld:getEntity(self.param.tagetId)
  if pTarget and pTarget:isValid() then
    SkillEffectMgr:triggerRoundEndEffect(pTarget, self.param.buffCfg, self.param.skilleffectId, self.param.key, self.param.round)
  else
    battleField:setAllStateReady(true)
  end
  return true
end

return BattleActionCmdDeBuff
