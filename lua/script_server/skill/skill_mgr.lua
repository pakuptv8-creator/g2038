local SkillConfig = T(Config, "SkillConfig")
local uuid = require("common.uuid")

local function getTargetPos(position, from)
  local yaw = (360 - from:getRotationYaw() + 90) % 360
  local pos = Lib.tov3(Lib.copy(position))
  local new_off_x, new_off_y = pos.x, pos.z
  local arc1 = math.atan(new_off_y, -new_off_x)
  local deg1 = math.deg(arc1)
  local deg2 = yaw - (360 - deg1 + 90) % 360
  local arc2 = math.rad(deg2)
  local len = (new_off_x ^ 2 + new_off_y ^ 2) ^ 0.5
  local offx = len * math.cos(arc2)
  local offy = len * math.sin(arc2)
  pos.x = -offx
  pos.z = offy
  local BpIndex = from:getBpIndex() or 10
  local BpPos = from.battleField:getPosByIndex(BpIndex)
  Lib.logInfo("____cast skill targetPos:", from.objID, BpIndex, from:getRotationYaw(), Lib.v2s({
    x = BpPos.x,
    y = BpPos.y,
    z = BpPos.z
  }), Lib.v2s(from:getPosition()), Lib.v2s(position), Lib.v2s(pos))
  if 0.5 < Lib.getPosDistance(BpPos, from:getPosition()) then
    Lib.logWarning("warning:target is too far from BpPos, set target pos = BpPos")
    local targrtpos = BpPos + pos
    return targrtpos
  end
  local targrtpos = from:getPosition() + pos
  return targrtpos
end

local function SetBodyYaw(entity, yaw)
  local yaw = yaw
  local entity = entity
  local packet = {
    pid = "SetEntityBodyYaw",
    objID = entity.objID,
    rotationYaw = yaw
  }
  entity:sendPacketToTracking(packet, true)
end

local function lookAtTarget(from, target)
  if target.objID == from.objID then
    return
  end
  local v = Lib.v3cut(target:getPosition(), from:getPosition())
  local yaw = Lib.v3AngleXZ(v)
  from:setRotationYaw(yaw or from:getRotationYaw())
  from:syncPosDelay()
  SetBodyYaw(from, yaw)
end

function SkillMgr:castSkill(from, skillId, target, isEffectTrigger)
  local skill_config = SkillConfig:getConfigById(skillId)
  if not skill_config then
    from.battleField:setAllStateReady(true)
    Lib.logError("execute:Define.BATTLE_ACTION.SKILL fail,cant find skill cfg by this id:", skillId)
    return
  end
  local roundSkillEffcts = from.pokemon and from.pokemon:getLongRoundEffectbuffList() or {}
  local castData = {}
  for key, v in pairs(roundSkillEffcts) do
    castData = SkillEffectMgr:triggerCastSkillEffect(from, v.buffCfg, v.skilleffectId, key, v.round)
  end
  if castData.result and not castData.canCast then
    from.battleField:setAllStateReady(true)
    return
  end
  if castData.result and castData.canCast and castData.skillId then
    skillId = castData.skillId
    skill_config = SkillConfig:getConfigById(skillId)
    target = from
  end
  local skillCfg = Lib.copy(skill_config)
  if skill_config.count == 1 then
    if target and target:isValid() then
      skillCfg.attackTargetId = target.objID
    end
  else
    skillCfg.attackTargetId = {}
    local battleField = from and from.battleField
    local enemyList = battleField and battleField:getEnemyDataList(from) or {}
    for _, enemy in pairs(enemyList or {}) do
      if enemy and enemy:isValid() then
        local enemyPkm = enemy.isPlayer and enemy:getBattlePet() or enemy
        if enemyPkm and enemyPkm:isValid() then
          skillCfg.attackTargetId[#skillCfg.attackTargetId + 1] = enemyPkm.objID
        end
      end
    end
  end
  local skillName = skill_config.setting_full_name
  local cfg = Skill.Cfg(skillName)
  if not cfg then
    from.battleField:setAllStateReady(true)
    Lib.logError("SkillMgr:castSkill not found cfg", skillName)
    return
  end
  if cfg.isNeedAppointTarget and (not target or not target:isValid()) then
    from.battleField:setAllStateReady(true)
    Lib.logError("error: Skill [" .. skillName .. "] need to Appoint an attacked target!!!")
    return
  end
  local isAccuracy = true
  if skill_config.accuracy == 0 or from:getEffectiveAccuracy(skill_config.accuracy) >= math.random(1, 100) then
    isAccuracy = true
  else
    Lib.logInfo("castSkill: Skill [" .. skillName .. "][" .. skillId .. "] can not Accuracy target!!!")
    isAccuracy = false
  end
  skillCfg.isAccuracy = isAccuracy
  from:setCurSkillBaseInfo(skillCfg)
  if isEffectTrigger then
    from:data("main").isEffectTriggerState = true
  else
    from:data("main").isEffectTriggerState = false
  end
  local packet = {
    skillId = skillId,
    isEffectTrigger = isEffectTrigger or false
  }
  if target and target:isValid() then
    lookAtTarget(from, target)
    local BoundingBox = target:getBoundingBox()
    local targetPos = getTargetPos({
      x = 0,
      y = 0,
      z = BoundingBox[1] + 0.5
    }, target)
    local BpIndex = from:getBpIndex() or 7
    local BpPos = from.battleField:getPosByIndex(BpIndex)
    local imcV3 = Lib.v3cut(targetPos, BpPos)
    local uid = uuid()
    packet = {
      uid = uid,
      skillId = skillId,
      backPos = {
        x = BpPos.x,
        y = BpPos.y,
        z = BpPos.z
      },
      casterID = from.objID,
      targetID = target.objID,
      startPos = targetPos,
      targetPos = targetPos,
      linePosValue = imcV3,
      needPre = true,
      isEnemy = from.isEnemy,
      casterBp = from:getBpIndex() or 1,
      targetBp = target:getBpIndex() or 7,
      tbAttackTargetId = skillCfg.attackTargetId,
      isEffectTrigger = isEffectTrigger or false
    }
    local masterId = from:getMaster() and from:getMaster().objID or 0
    Lib.logInfo("___________SkillMgr:castSkill:", uid, masterId, from and from:cfg().fullName, from and from.objID, from and from:getBpIndex(), target and target:cfg().fullName, target and target.objID, target and target:getBpIndex(), skillId, packet.isEffectTrigger, Lib.v2s({
      x = BpPos.x,
      y = BpPos.y,
      z = BpPos.z
    }), Lib.v2s(targetPos))
    local result = Skill.Cast(skillName, packet, from)
    if not result then
      from.battleField:setAllStateReady(true)
    end
  else
    local result = Skill.Cast(skillName, packet)
    if not result then
      from.battleField:setAllStateReady(true)
    end
  end
end

return SkillMgr
