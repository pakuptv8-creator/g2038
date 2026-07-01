require("common.missile")

local function checkCanHit(from, target, skillInfo)
  local hitResult = false
  if not skillInfo then
    return hitResult
  end
  if skillInfo.count == 1 and type(skillInfo.attackTargetId) == "number" then
    if target.objID == skillInfo.attackTargetId then
      hitResult = true
    end
  else
    local battleField = from and from.battleField
    local enemyList = battleField and battleField:getEnemyDataList(from) or {}
    for _, enemy in pairs(enemyList or {}) do
      if enemy and enemy:isValid() then
        local enemyPkm = enemy.isPlayer and enemy:getBattlePet() or enemy
        if enemyPkm and enemyPkm:isValid() and enemyPkm.objID == target.objID then
          hitResult = true
          return hitResult
        end
      end
    end
  end
  return hitResult
end

local oldOnHitEntity = MissileServer.onHitEntity

function MissileServer:onHitEntity()
  local from = self.world:getObject(self.params.fromID)
  local target = self:lastHitEntity()
  local skillInfo = from.curSkillBaseInfo
  local canHit = checkCanHit(from, target, skillInfo)
  if not canHit then
    Lib.logError("_______MissileServer:onHitEntity\239\188\140can not hit the skill Target:missile = " .. self:cfg().fullName .. ",target = " .. target:cfg().fullName .. ",curHp = " .. target.curHp)
    print("__________MissileServer:onHitEntity_not canHit:", from:cfg().fullName, target:cfg().fullName, target.objID, target.curHp, skillInfo and skillInfo.attackTargetId)
    return
  end
  oldOnHitEntity(self)
end
