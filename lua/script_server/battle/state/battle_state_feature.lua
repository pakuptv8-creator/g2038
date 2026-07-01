local BattleStateFeature = Lib.class("BattleStateFeature", require("script_server.battle.state.battle_state"))
local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")

function BattleStateFeature:enter()
  Lib.logDebug("BattleStateFeature:enter")
  for _, player in pairs(self.battleField.playerList or {}) do
    self.battleField.battleActionQueue:push(BattleActionCmdFactory.create({
      caster = player,
      target = nil,
      type = Define.BATTLE_ACTION.FEATURE
    }))
    player:setStateReady(true)
    player:setCmdReady(true)
  end
end

function BattleStateFeature:update(tick)
  if self.battleField:checkStateReady() then
    self.battleField:changeBattleState("ExecuteCommand")
  end
end

function BattleStateFeature:leave()
  Lib.logDebug("BattleStateFeature:leave")
  self.battleField:setAllCmdReady(false)
end

return BattleStateFeature
