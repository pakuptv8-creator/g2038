local PartEffectHelper = T(Lib, "PartEffectHelper")
local PartLightHelper = T(Lib, "PartLightHelper")
local EmergencyHelper = T(Lib, "EmergencyHelper")

function EntityServer:castSelfDefineSkillCallBack(context)
  local fullName = context.fullName
  local skill = Skill.Cfg(fullName)
  if not skill or not skill.callBackSelfDefineSkill then
    return
  end
  local func = self[skill.callBackSelfDefineSkill]
  if not func then
    return
  end
  func(self, context)
end

function EntityServer:clickHandItemStyleSwitch(context)
  local player = context.obj1
  if not player or not player:isValid() then
    return
  end
  player:handItemStyleSwitch()
end

local function signInvolveParts(self, context, parts)
  local fullName = context.fullName
  if not self.involveParts then
    self.involveParts = {}
  end
  if fullName then
    local skill = Skill.Cfg(fullName) or {}
    local needSustainTime = skill.needSustainTime
    if needSustainTime then
      for _, part in pairs(parts) do
        if part and part:isValid() then
          local partId = part:getInstanceID()
          if not self.involveParts[partId] then
            self.involveParts[partId] = os.time()
          end
        end
      end
    end
    return needSustainTime
  end
  return
end

local function verifyWhetherPutOutFire(self, part, needSustainTime)
  if not needSustainTime then
    return true
  end
  local partId = part:getInstanceID()
  local canPutOutFire = false
  if self.involveParts[partId] then
    if part.lastTimeVerify and os.time() - part.lastTimeVerify > 1 then
      self.involveParts[partId] = os.time()
    end
    part.lastTimeVerify = os.time()
    if needSustainTime <= part.lastTimeVerify - self.involveParts[partId] then
      canPutOutFire = true
      self.involveParts[partId] = nil
    end
  end
  return canPutOutFire
end

local function getFrontPos(isSelf, player, dis)
  if isSelf then
    local yaw = math.rad(player:getRotationYaw())
    local pos = player:getEyePos()
    pos.x = pos.x - dis * math.sin(yaw)
    pos.z = pos.z + dis * math.cos(yaw)
    return Lib.tov3(pos)
  end
  local dir = player:getWorldQuaternion() * Lib.v3(0, 0, 1)
  dir:normalize()
  return player:getPosition() + dir * dis
end

function EntityServer:PutOutFire(context, distance, xrange, yrange, zrange)
  local player = context.obj1
  if not player then
    return
  end
  local pos = getFrontPos(player == self, player, distance)
  local minPos = {
    x = pos.x - xrange,
    y = pos.y - yrange,
    z = pos.z - zrange
  }
  local maxPos = {
    x = pos.x + xrange,
    y = pos.y + yrange,
    z = pos.z + zrange
  }
  local parts = self.map:getTouchParts(minPos, maxPos)
  local entities = self.map:getTouchEntities(minPos, maxPos, false)
  local needSustainTime = signInvolveParts(self, context, parts)
  if parts then
    local effectStatus = EmergencyHelper:getEffectStatus()
    for _, part in pairs(parts) do
      if part and part:isValid() then
        local partId = part:getInstanceID()
        local effectInfo = PartEffectHelper:getEffectInfoByPartId(partId)
        local lightInfo = PartLightHelper:getLightInfoByPartId(partId)
        local canPutOutFire = verifyWhetherPutOutFire(self, part, needSustainTime)
        if canPutOutFire and lightInfo and lightInfo.effectName then
          PartLightHelper:removeOnePartLight(partId)
        elseif canPutOutFire and effectInfo and (effectInfo.effectName == "g2030_ranshao.effect" or effectInfo.effectName == "g2052_small_fire.effect" or effectInfo.effectName == "g2052_house_fire.effect") then
          Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, self, true, true)
          if effectInfo.effectName == "g2052_house_fire.effect" then
            self:checkHeartWarmPutOutFire()
          end
        end
        if canPutOutFire and effectStatus and effectStatus[partId] then
          local fireEffectInfo = effectStatus[partId]
          WorldServer.BroadcastPacket({
            pid = "delEmergencyEffect",
            type = Define.EMERGENCY_TYPE.FireDisaster,
            key = fireEffectInfo.id,
            posList = {
              part:getPosition()
            }
          })
          self:checkHeartWarmPutOutFire()
          EmergencyHelper:clearEffectStatus(partId)
        end
      end
    end
  end
  if entities then
    local putOutPlayerFire = false
    for _, entity in ipairs(entities) do
      if entity ~= self then
        local buff = entity:getTypeBuff("fullName", "myplugin/player_on_fire_buff")
        if buff then
          entity:removeTypeBuff("fullName", "myplugin/player_on_fire_buff")
          putOutPlayerFire = true
        end
      end
    end
    if putOutPlayerFire then
      self:checkHeartWarmPutOutFire()
    end
  end
end

function EntityServer:tryToPutOutFire(context)
  self:PutOutFire(context, 2, 2, 2, 2)
end

function EntityServer:checkHeartWarmPutOutFire()
  local professionId = self:getProfessionId()
  if professionId == Define.CareerType.Fireman then
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.PUT_OUT_FIRE)
  end
end
