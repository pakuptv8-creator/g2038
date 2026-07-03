local Skill = _ENV.Skill
local SkillConfig = T(Config, "SkillConfig")
local skillEffectCfg = T(Config, "SkillEffectConfig")

function Skill.CastByServer(packet)
  Lib.logInfo("________CastByServer:", packet.uid or "not uid", packet.skillId, packet.fromID, packet.targetID, packet.isEffectTrigger)
  local cfg = Skill.Cfg(packet.name)
  local from = World.CurWorld:getEntity(packet.fromID)
  if not from or not from:isValid() then
    return
  end
  if cfg.isMainSkill then
    from:data("main").curCastMainSkill = tonumber(packet.skillId)
    local skill_config = SkillConfig:getConfigById(packet.skillId)
    if not skill_config then
      perror("execute:Define.BATTLE_ACTION.SKILL fail,cant find skill cfg by this id:", packet.skillId)
      return
    end
    if packet.tbAttackTargetId then
      skill_config.attackTargetId = packet.tbAttackTargetId
    end
    from:setCurSkillBaseInfo(skill_config)
    local delayTime = 0
    if skill_config.skill_effect then
      for i = 1, #skill_config.skill_effect do
        local skillEffctId = skill_config.skill_effect[i]
        local effectCfg = skillEffectCfg:getConfigById(skillEffctId)
        if effectCfg and 0 < effectCfg.timingDelay then
          delayTime = 20
        end
      end
    end
    packet.delayTime = packet.delayTime or delayTime
    from:setCurSkillBaseInfo(skill_config)
  end
  if not (from and from:isControl()) or packet.needPre then
    cfg:preCast(packet, from)
  end
  Skill.DoStartCast(from, cfg, packet)
  cfg:cast(packet, from)
end

function Skill.DoStartCast(from, cfg, packet)
  if cfg.skillTime and cfg.isMainSkill then
    local delayTime = 0
    World.Timer(1, function()
      if from and from:isValid() then
        from:data("main").curCastMainSkill = nil
        from:resetCurSkillBaseInfo()
        Lib.logInfo("______________DoStartCast:", packet.uid or "not uid", packet.skillId, packet.fromID, packet.targetID, packet.isEffectTrigger)
        Me:sendPacket({
          pid = "SyncCasktMainSkillReady",
          fromID = packet.fromID,
          targetID = packet.targetID,
          skillId = packet.skillId,
          uid = packet.uid or "not uid",
          isEffectTrigger = packet.isEffectTrigger or false
        })
      else
        Me:notifyStateReady()
        Lib.logError("error:not from or not from:isValid when Skill.DoStartCast:", cfg.skillTime, cfg.isMainSkill, cfg.fullName)
      end
    end)
  end
end

RETURN()
