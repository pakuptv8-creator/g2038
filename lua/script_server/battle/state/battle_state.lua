local BattleState = Lib.class("BattleState")

function BattleState:ctor(battleField)
  self.battleField = battleField
end

function BattleState:notifyStateReady(player, packet)
end

function BattleState:enter()
end

function BattleState:update(tick)
end

function BattleState:leave()
end

return BattleState
