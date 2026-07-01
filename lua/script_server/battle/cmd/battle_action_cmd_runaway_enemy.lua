local BattleActionCmdRunawayEnemy = Lib.class("BattleActionCmdRunawayEnemy", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdRunawayEnemy:execute(battleField)
  Lib.logDebug("BattleActionCmdRunawayEnemy:execute")
  local pokemon = self.target:getPokemon()
  pokemon:setRunaway(true)
  battleField:sendBattleFieldBroadcast({
    pid = "RunawayEnemy",
    name = pokemon:getName(),
    pkmObjId = pokemon:getObjId()
  })
  if self.target and self.target:isValid() then
    self.target:destroy()
  end
  return true
end

return BattleActionCmdRunawayEnemy
