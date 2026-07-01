local AIEvaluator = require("entity.ai.ai_evaluator")
local AIStateChase = require("entity.ai.ai_state_chase")
AIStateChase.NAME = "CHASE"

function AIStateChase:enter()
  local control = self.control
  local entity = control:getEntity()
  local enemy = entity:data("aiData").enemy
  control:setChaseTarget(enemy)
  local chaseSkill = entity:cfg().chaseSkill
  if chaseSkill and chaseSkill.fullName then
    Skill.Cast(chaseSkill.fullName, nil, entity)
  end
  self.endTime = World.Now() + (entity:cfg().chaseInterval or 20)
  local cfg = entity:cfg()
  self.entity = entity
  self.cfg = cfg
  if cfg.isBrightPkm and cfg.signEffect and not entity:getTypeBuff("fullName", cfg.signEffect) then
    entity:addBuff(cfg.signEffect)
  end
end

function AIStateChase:update()
  if not self.cfg.isBrightPkm and AIEvaluator.CanAttackEnemy(self.control) then
    return
  end
  return self.endTime - World.Now()
end

function AIStateChase:exit()
  if self.cfg.isBrightPkm and self.cfg.signEffect then
    self.entity:removeTypeBuff("fullName", self.cfg.signEffect)
  end
  self.control:setChaseTarget(nil)
  self.endTime = nil
end

RETURN(AIStateChase)
