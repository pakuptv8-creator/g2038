local BattleActionCmdSkill = Lib.class("BattleActionCmdSkill", require("script_server.battle.cmd.battle_action_cmd"))

function BattleActionCmdSkill:execute(battleField)
  Lib.logDebug("BattleActionCmdSkill:execute", self.param)
  if not self.target then
    self.target = battleField:reSelectTarget(nil, self.caster)
  elseif not self.target:isValid() then
    self.target = battleField:reSelectTarget(self.target:getPokemon(), self.caster)
  end
  if not (self.caster and self.caster:isValid() and self.target) or not self.target:isValid() then
    Lib.logError("BattleActionCmdSkill:execute error", "caster", self.caster == nil, self.caster and self.caster:isValid(), "target", self.target == nil, self.target and self.target:isValid())
    battleField:setAllStateReady(true)
    return
  end
  local caster = (self.caster.isPlayer or self.caster.isHostAI) and self.caster:getBattlePet() or self.caster
  local target = (self.target.isPlayer or self.target.isHostAI) and self.target:getBattlePet() or self.target
  local isDefaultSkill = caster.pokemon:canUseDefaultSkill()
  if not caster.pokemon:useSkill(self.param) then
    battleField:setAllStateReady(true)
    return true
  end
  if caster:isValid() and caster.curHp > 0 and target:isValid() and target.curHp > 0 then
    if isDefaultSkill then
      SkillMgr:castSkill(caster, World.cfg.defaultSkillId, target)
    else
      SkillMgr:castSkill(caster, self.param, target)
    end
  else
    battleField:setAllStateReady(true)
  end
  return true
end

return BattleActionCmdSkill
