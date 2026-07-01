require("common.missile")
local SkillPerformConfig = T(Config, "SkillPerformConfig")

local function checkCanHit(from, target, skillInfo)
  local hitResult = false
  if not skillInfo then
    return hitResult
  end
  if skillInfo.count == 1 and type(skillInfo.attackTargetId) == "number" then
    if target.objID == skillInfo.attackTargetId then
      hitResult = true
    end
  elseif type(skillInfo.attackTargetId) == "table" then
    for i = 1, #skillInfo.attackTargetId do
      if skillInfo.attackTargetId[i] == target.objID then
        hitResult = true
        return hitResult
      end
    end
  end
  return hitResult
end

function MissileClient:onHitEntity()
  local from = World.CurWorld:getEntity(self.params.fromID)
  local cfg = self:cfg()
  local target = self:lastHitEntity()
  local skillInfo = from.curSkillBaseInfo
  local canHit = checkCanHit(from, target, skillInfo)
  if not canHit then
    Lib.logError("_______MissileClient:onHitEntity\239\188\140can not hit the skill Target:missile = " .. self:cfg().fullName .. ",target = " .. target:cfg().fullName)
    return
  end
  if from and from:isValid() and cfg and (cfg.hitEntitySound or cfg.hitSound) then
    local curCastMainSkill = from:data("main").curCastMainSkill
    local SkillPerformCfg = SkillPerformConfig:getSkillPerformConfig(curCastMainSkill)
    if SkillPerformCfg and SkillPerformCfg.hitEffectOwner and SkillPerformCfg.hitEffectOwner == cfg.fullName then
      if cfg.hitEntitySound then
        cfg.hitEntitySound.sound = SkillPerformCfg.hitSound
      end
      if cfg.hitSound then
        cfg.hitSound.sound = SkillPerformCfg.hitSound
      end
    end
  end
  local target = self:lastHitEntity()
  local pos = self:getPosition()
  local eyePos = target:getEyePos()
  local headHit = pos.y <= eyePos.y + 0.3 and pos.y >= eyePos.y - 0.3
  local headEffect = cfg.hitHeadEffect
  local hitEffect = cfg.hitEntityEffect or cfg.hitEffect
  local effect = headHit and headEffect or hitEffect
  self:castEffect(effect)
  self:playSound(cfg.hitEntitySound or cfg.hitSound, cfg, true)
  if from and from:isControl() then
    Lib.emitEvent(Event.EVENT_ON_HIT_ENTITY, {target = target, headHit = headHit})
  end
  Missile.onHitEntity(self)
end

function MissileClient:castEffect(effect)
  if not effect then
    return
  end
  local from = World.CurWorld:getEntity(self.params.fromID)
  if from and from:isValid() then
    local curCastMainSkill = from:data("main").curCastMainSkill
    local SkillPerformCfg = SkillPerformConfig:getSkillPerformConfig(curCastMainSkill)
    if SkillPerformCfg then
      if SkillPerformCfg.startEffectOwner and SkillPerformCfg.startEffectOwner == (self:cfg() and self:cfg().fullName) then
        if effect.path then
          effect.path = string.gsub(effect.path, effect.effect, SkillPerformCfg.startEffect)
        end
        effect.effect = SkillPerformCfg.startEffect
      elseif SkillPerformCfg.skillEffectOwner and SkillPerformCfg.skillEffectOwner == (self:cfg() and self:cfg().fullName) then
        if effect.path then
          effect.path = string.gsub(effect.path, effect.effect, SkillPerformCfg.skillEffect)
        end
        effect.effect = SkillPerformCfg.skillEffect
      elseif SkillPerformCfg.hitEffectOwner and SkillPerformCfg.hitEffectOwner == (self:cfg() and self:cfg().fullName) then
        if effect.path then
          effect.path = string.gsub(effect.path, effect.effect, SkillPerformCfg.hitEffect)
        end
        effect.effect = SkillPerformCfg.hitEffect
      end
    end
  end
  if not effect.path then
    local cfg = self:cfg()
    effect.path = ResLoader:filePathJoint(cfg, effect.effect)
  end
  if not effect.isFixedPosition then
    self:playEffect(effect.path, effect.once, effect.time or -1, effect.pos, effect.yaw or 0, effect.pitch or 0, effect.roll or 0)
  else
    Blockman.instance:playEffectByPos(effect.effect, self:getPosition(), 0, effect.time or 500)
  end
end
