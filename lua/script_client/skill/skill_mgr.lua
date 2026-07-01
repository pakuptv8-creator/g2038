local SkillMgr = L("SkillMgr", {})

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
  local targrtpos = from:getPosition() + pos
  return targrtpos
end

function SkillMgr:castSkill(skillName, target)
  local cfg = Skill.Cfg(skillName)
  if not cfg then
    return
  end
  if cfg.isNeedAppointTarget and (not target or not target:isValid()) then
    print("error: Skill [" .. skillName .. "] need to Appoint an attacked target!!!")
    return
  end
  if target and target:isValid() then
    local BoundingBox = target:getBoundingBox()
    local targetPos = getTargetPos({
      x = 0,
      y = 0,
      z = BoundingBox[1] + 0.5
    }, target)
    local curPos = Me:getPosition()
    local imcV3 = Lib.v3cut(targetPos, curPos)
    Skill.Cast(skillName, {
      backPos = curPos,
      targetID = target.objID,
      startPos = targetPos,
      targetPos = targetPos,
      linePosValue = imcV3,
      needPre = true
    })
  else
    Skill.Cast(skillName)
  end
end

return SkillMgr
