local SkillBase = Skill.GetType("Base")
local CGInterface = CGame.instance:getShellInterface()
local SkillPerformConfig = T(Config, "SkillPerformConfig")

local function playEffect(from, cfg, effect)
  if effect and from and from.isEntity then
    for _, eff in ipairs(effect) do
      from:showEffect(eff, cfg)
    end
    from:showEffect(effect, cfg)
  end
end

local function playAction(from, action, time, isResetAction)
  if from:data("reload").reloadTimer and action ~= "idle" and action ~= "" then
    return
  end
  if from and from.isEntity and action and action ~= "" then
    from:updateUpperAction(action, time, isResetAction)
  end
end

local function playSound(from, self, cfg, sound)
  if sound and from then
    from:data("soundId")[self.fullName] = from:playSound(sound, cfg)
  end
end

local function vibratorOnTime(from, vibratorTime)
  if not (from and vibratorTime) or type(vibratorTime) ~= "number" then
    return
  end
  CGInterface:vibratorOnTime(vibratorTime)
end

local function playFirstViewUIEffect(from, value, add)
  if from.isMainPlayer and value then
    Lib.emitEvent(Event.PLAYE_UI_EFFECT, value, add, value.time or 20)
  end
end

function SkillBase:preCast(packet, from)
  if not from or not from:isValid() then
    return
  end
  local curCastMainSkill = from:data("main").curCastMainSkill
  local SkillPerformCfg = SkillPerformConfig:getSkillPerformConfig(curCastMainSkill)
  if SkillPerformCfg then
    if SkillPerformCfg.startEffectOwner and SkillPerformCfg.startEffectOwner == self.fullName then
      if self.castEffect then
        local oldeffect = self.castEffect.effect
        self.castEffect.effect = SkillPerformCfg.startEffect
        if self.castEffect.path then
          self.castEffect.path = string.gsub(self.castEffect.path, oldeffect, SkillPerformCfg.startEffect)
        end
      end
      if self.castSound then
        local oldeSound = self.castSound.sound
        self.castSound.sound = SkillPerformCfg.startSound
        if self.castSound.path then
          self.castSound.path = string.gsub(self.castSound.path, oldeSound, SkillPerformCfg.startSound)
        end
      end
    elseif SkillPerformCfg.skillEffectOwner and SkillPerformCfg.skillEffectOwner == self.fullName then
      if self.castEffect then
        local oldeffect = self.castEffect.effect
        self.castEffect.effect = SkillPerformCfg.skillEffect
        if self.castEffect.path then
          self.castEffect.path = string.gsub(self.castEffect.path, oldeffect, SkillPerformCfg.skillEffect)
        end
      end
      if self.castSound then
        local oldeSound = self.castSound.sound
        self.castSound.sound = SkillPerformCfg.skillSound
        if self.castSound.path then
          self.castSound.path = string.gsub(self.castSound.path, oldeSound, SkillPerformCfg.skillSound)
        end
      end
    elseif SkillPerformCfg.hitEffectOwner and SkillPerformCfg.hitEffectOwner == self.fullName then
      if self.castEffect then
        local oldeffect = self.castEffect.effect
        self.castEffect.effect = SkillPerformCfg.hitEffect
        if self.castEffect.path then
          self.castEffect.path = string.gsub(self.castEffect.path, oldeffect, SkillPerformCfg.hitEffect)
        end
      end
      if self.castSound then
        local oldeSound = self.castSound.sound
        self.castSound.sound = SkillPerformCfg.hitSound
        if self.castSound.path then
          self.castSound.path = string.gsub(self.castSound.path, oldeSound, SkillPerformCfg.hitSound)
        end
      end
    end
  end
  if self.cdTime and from then
    from:setCD("net_delay", self.netDelay and self.netDelay or 20)
  end
  playAction(from, self.castAction, self.castActionTime, self.isResetAction)
  playEffect(from, self, self.castEffect)
  playSound(from, self, self:getSoundCfg(packet, "castSound", from))
  vibratorOnTime(from, self.castVibratorTime)
  playFirstViewUIEffect(from, self.preCastUIEffect, true)
end
