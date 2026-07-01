local BattleActionCmdBall = Lib.class("BattleActionCmdBall", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdBall:execute(battleField)
  if battleField.npcId or battleField.mode == Define.BATTLE_MODE.PVP then
    battleField:setAllStateReady(true)
    return false
  end
  if not self.target or not self.target:isValid() then
    battleField:setAllStateReady(true)
    return false
  end
  local item, slot = self.caster:inspectBagItemByItemId(self.param)
  local SpriteBallConfig = T(Config, "SpriteBallConfig")
  local config = SpriteBallConfig:getSpriteBallConfig(self.param)
  if not config or not item then
    battleField:setAllStateReady(true)
    return false
  end
  local useFinish = self.caster:useBagItem(slot, item:full_name())
  if not useFinish then
    battleField:setAllStateReady(true)
    return false
  end
  local pokemon = self.target:getPokemon()
  local hpCoe = 1.25 * pokemon:getBattleMaxHp() / (1 * pokemon:getBattleMaxHp() + 0.25 * pokemon:getCurHp()) - 1
  local addition = config.condition == pokemon:getRace() and config.addition or 0
  local stateCoe = 0
  local result = pokemon:getCatchProbability() + hpCoe + (config.base + addition) + stateCoe
  local tb = {}
  if 1 <= result then
    table.insert(tb, true)
  else
    for _ = 1, 4 do
      if result <= math.random() then
        table.insert(tb, false)
        break
      else
        table.insert(tb, true)
      end
    end
  end
  Lib.logDebug("BattleActionCmdBall:execute", "param " .. self.param, "result " .. result, hpCoe, config.base, addition, stateCoe)
  battleField:sendBattleFieldBroadcast({
    pid = "BallResult",
    caster = self.caster.objID,
    casterBp = self.caster:getBpIndex(),
    targetBp = self.target:getBpIndex(),
    target = pokemon:getObjId(),
    objID = self.target.objID,
    ballID = config.id,
    result = tb
  })
  self.caster:setCatchTarget(self.target)
  if tb[#tb] then
    self.caster:capturePokemon(pokemon, self.param)
    Lib.logDebug("POKEMON_CAPTURE pokemon:getCfg().id = ", pokemon:getCfg().id)
    self.caster:updateTaskStatus(Define.TASK_TYPE.POKEMON_CAPTURE, 1, pokemon:getCfg().id, 1)
  else
    self.caster.catchFailCount = self.caster.catchFailCount or 0
    self.caster.catchFailCount = self.caster.catchFailCount + 1
    self.caster:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.CAPTURE_FAIL, self.caster.catchFailCount)
    if math.random() < pokemon:getRunawayProbability() then
      local BattleActionCmdFactory = require("script_server.battle.cmd.battle_action_cmd_factory")
      battleField.battleActionQueue:push(BattleActionCmdFactory.create({
        caster = self.target,
        target = self.target,
        type = Define.BATTLE_ACTION.RUNAWAY_ENEMY
      }), 1)
    end
  end
  Lib.reportData(self.caster, {
    "battle_catch",
    tb[#tb] and 1 or 0
  })
  self.caster:cacheAction(Define.BATTLE_ACTION.BALL)
  return tb[#tb]
end

return BattleActionCmdBall
