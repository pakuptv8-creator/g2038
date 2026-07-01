local BattleStateWaitStart = Lib.class("BattleStateWaitStart", require("script_server.battle.state.battle_state"))

function BattleStateWaitStart:enter()
  Lib.logDebug("BattleStateWaitStart:enter")
  if self.battleField.maxPlayerNum > 1 then
    self.battleField:sendBattleFieldBroadcast({
      pid = "StateWaitStart"
    })
  end
end

function BattleStateWaitStart:update(tick)
  if self.battleField:checkStateReady() then
    self.battleField:changeBattleState("Feature")
  end
end

function BattleStateWaitStart:leave()
  Lib.logDebug("BattleStateWaitStart:leave")
end

return BattleStateWaitStart
