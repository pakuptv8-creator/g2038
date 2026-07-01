local BattleStateWaitReady = Lib.class("BattleStateWaitReady", require("script_server.battle.state.battle_state"))

function BattleStateWaitReady:enter()
  Lib.logDebug("BattleStateWaitReady:enter")
  self.enterTime = os.time()
end

function BattleStateWaitReady:update(tick)
  if self.battleField:isPlayerFull() or os.time() - self.enterTime >= 10 then
    self.battleField:changeBattleState("WaitStart")
  end
end

function BattleStateWaitReady:leave()
  Lib.logDebug("BattleStateWaitReady:leave")
end

return BattleStateWaitReady
