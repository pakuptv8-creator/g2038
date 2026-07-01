local BattleActionCmd = Lib.class("BattleActionCmd")

function BattleActionCmd:ctor(param)
  self.type = param.type
  self.randomPriority = math.random()
  self.caster = param.caster
  self.target = param.target
  self.param = param.param
  self.executeStartTime = 0
end

function BattleActionCmd:execute(battleField)
  Lib.logDebug("BattleActionCmd:execute")
  return false
end

function BattleActionCmd:sendBattleActionResult(battleField, param)
  battleField:sendBattleFieldBroadcast({
    pid = "BattleActionResult",
    param = param
  })
end

return BattleActionCmd
