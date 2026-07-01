local BattleStateWaitCommand = Lib.class("BattleStateWaitCommand", require("script_server.battle.state.battle_state"))
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")

function BattleStateWaitCommand:enter()
  Lib.logDebug("BattleStateWaitCommand:enter", self.battleField.rounds)
  self.battleField.roundStartTime = os.time()
  for _, player in pairs(self.battleField.playerList or {}) do
    if player then
      local canBattle = player:canBattle()
      player:setCmdReady(not canBattle or not player:isValid())
      player:sendPacket({
        pid = "roundStart",
        rounds = self.battleField.rounds,
        canBattle = canBattle
      })
      Lib.logDebug("sendPacket roundStart", player.name, canBattle)
    end
  end
  if self.battleField.rounds >= World.cfg.maxRound or self.battleField:checkBattleEnd() then
    self.battleField.isMaxRound = true
    self.battleField:changeBattleState("End")
  end
end

function BattleStateWaitCommand:update(tick)
  if self.battleField:checkCmdReady() then
    self.battleField:changeBattleState("ExecuteCommand")
  end
  self.battleField.roundStartTime = self.battleField.roundStartTime or os.time()
  if os.time() - self.battleField.roundStartTime >= World.cfg.operationTime + 10 then
    Lib.logError("BattleStateWaitCommand too long!!!", tostring(self.battleField.uid), self.battleField.mode, self.battleField.rounds)
    Lib.logError("*************** playerList State ***************")
    for _, player in pairs(self.battleField.playerList or {}) do
      Lib.logError(tostring(player.platformUserId), player.name, tostring(player.cmdReady), tostring(player.stateReady))
    end
    self.battleField:setAllCmdReady(true)
  end
end

function BattleStateWaitCommand:leave()
  Lib.logDebug("BattleStateWaitCommand:leave")
  self.battleField:doAIPolicy()
  self.battleField:doHostingPolicy()
  self.battleField:setAllCmdReady(false)
end

return BattleStateWaitCommand
