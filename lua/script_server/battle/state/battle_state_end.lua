local BattleStateEnd = Lib.class("BattleStateEnd", require("script_server.battle.state.battle_state"))

function BattleStateEnd:enter()
  Lib.logDebug("BattleStateEnd:enter")
  for _, player in pairs(self.battleField.playerList or {}) do
    player:enterBattleResult(self.battleField)
  end
end

function BattleStateEnd:update(tick)
end

function BattleStateEnd:leave()
  Lib.logDebug("BattleStateEnd:leave")
end

return BattleStateEnd
