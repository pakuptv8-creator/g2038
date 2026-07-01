local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local skillEffectCfg = T(Config, "SkillEffectConfig")
local SkillConfig = T(Config, "SkillConfig")
local RaceConfig = T(Config, "RaceConfig")
local setting = require("common.setting")
local flyTextImgset = {
  red = "red_numbers",
  green = "green_numbers",
  yellow = "yellow_numbers",
  white = "white_numbers",
  yishang = "yishang_numbers"
}

function EntityServer:ShowFlyText(textList, from, flyImgset)
  local imgset = "red_numbers"
  if flyImgset and flyTextImgset[flyImgset] then
    imgset = flyTextImgset[flyImgset]
  end
  local packet = {
    pid = "ShowTextUIOnEntity",
    FollowObjID = self.objID,
    textList = textList,
    imgset = imgset,
    justSelf = false
  }
  if from and from.battleField then
    from.battleField:sendBattleFieldBroadcast(packet)
  end
end

local engine_EntityServer_Create = EntityServer.Create

function EntityServer.Create(params, func)
  local entity = engine_EntityServer_Create(params, func)
  if not entity then
    Lib.logError("EntityServer.Create not entity", params.cfgName)
  end
  if entity and entity:cfg() then
    if entity:cfg().isGloryDoor then
      GloryHallMgr:setDoorEntity(entity:cfg().gloryDoorId, entity.objID)
    end
    if entity:cfg().isGloryDoorName then
      GloryHallMgr:setDoorNameTxt(entity:cfg().gloryDoorId, entity.objID)
    end
  end
  return entity
end

function EntityServer:getMyTeamMate()
  local objID = self:getMyTeamMateId()
  if not objID then
    return nil
  end
  return World.CurWorld:getEntity(objID)
end

function EntityServer:getPokemon()
  return self.pokemon
end

function EntityServer:getMaster()
  return self.master
end

local engine_startAI = EntityServer.startAI

function EntityServer:startAI()
  engine_startAI(self)
end

local engine_stopAI = EntityServer.stopAI

function EntityServer:stopAI()
  engine_stopAI(self)
end

function EntityServer:getRandomCanUseSkillId()
  local pokemon = self:getBattlePet() and self:getBattlePet():getPokemon() or self:getPokemon()
  if not pokemon then
    Lib.logError("getRandomCanUseSkillId not pokemon", self.objID)
    return -1
  end
  local tbValidSkill = {}
  for _, skill in pairs(pokemon:getSkillList() or {}) do
    if skill.curTimes > 0 then
      table.insert(tbValidSkill, skill)
    end
  end
  if 0 < #tbValidSkill then
    return tbValidSkill[math.random(#tbValidSkill)].skillId
  else
    return World.cfg.defaultSkillId
  end
end

local engine_spawnInfo = EntityServer.spawnInfo

function EntityServer:spawnInfo(receiver)
  local info = engine_spawnInfo(self, receiver)
  info.needHide = self.needHide
  return info
end

function EntityServer:canBattle()
  for _, battlePetId in pairs(self:getValue("battlePetList") or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet then
      if battlePet:getCurHp() > 0 then
        return true
      end
    else
      Lib.logError("EntityServer canBattle getPokemon not battlePet!!!", self.objID, battlePetId)
    end
  end
  return false
end

function EntityServer:setBattlePet(pet)
  self.battlePet = pet
  if pet and pet:isValid() then
    pet.master = self
    pet:setValue("masterId", self.objID, not self.isPlayer)
    pet:getPokemon().master = self
    self.battlePokemonObjId = pet:getPokemon().objId
  end
end

function EntityServer:getBattlePet()
  return self.battlePet
end

function EntityServer:getBattlePokemonObjId()
  return self.battlePokemonObjId
end

function EntityServer:setBattleAttr(pokemon, battleField)
  pokemon:setEntityObjId(self.objID)
  self.pokemon = pokemon
  self.pokemonObjId = pokemon.objId
  self:setPokemonId(pokemon:getObjId())
  pokemon.entity = self
  local foughtCount = pokemon:getFoughtCount() or 0
  pokemon:setFoughtCount(foughtCount + 1)
  if foughtCount == 0 then
    pokemon:setBattleMaxHp(pokemon:getMaxHp())
  end
  self:setMaxHp(pokemon:getMaxHp())
  self:setSpeed(pokemon:getSpeed())
  self:setPAtk(pokemon:getPhysicalAtk())
  self:setSAtk(pokemon:getSpecialAtk())
  self:setPDef(pokemon:getPhysicalDef())
  self:setSDef(pokemon:getSpecialDef())
  self:setPAtkRBonus(0)
  self:setSAtkRBonus(0)
  self:setSpeedRBonus(0)
  self.curHp = pokemon:getCurHp()
  if self:cfg() and self:cfg().wakeEffect then
    local tbWakeEffect = self:cfg().wakeEffect
    local nAwake = pokemon and pokemon:getWake() or 0
    if tbWakeEffect[nAwake] then
      self:addBuff(tbWakeEffect[nAwake])
    end
  end
end

local engine_destroy = EntityServer.destroy

function EntityServer:destroy()
  if self.isHostAI then
    for _, battlePetId in pairs(self:getValue("battlePetList") or {}) do
      local battlePet = PokemonManager:getPokemon(battlePetId)
      if battlePet then
        battlePet:onDestroy()
      end
    end
  end
  return engine_destroy(self)
end

local function getSameRaceRate(from, skillInfo)
  local sameRaceRate = 1
  if from and from:isValid() then
    local fromPokemon = from:getPokemon()
    if fromPokemon then
      local fromRace = fromPokemon:getRace()
      if fromRace == (skillInfo and skillInfo.race or 0) then
        sameRaceRate = 1
      end
    end
  end
  Lib.logInfo("@Skill Race influence to damge,sameRaceRate:" .. sameRaceRate)
  return sameRaceRate
end

local function getRaceRate(target, skillInfo)
  local selfPokemon = target:getPokemon()
  local raceRate = 1
  local skillRaceData = RaceConfig:getRaceDataById(skillInfo and skillInfo.race or 0)
  local selfRace = 0
  if selfPokemon then
    selfRace = selfPokemon:getRace()
    raceRate = skillRaceData and skillRaceData[selfRace] or 1
  end
  Lib.logInfo("@Skill Race influence to damge,selfRace:" .. selfRace .. ",skillInfo.race:" .. skillInfo.race .. ",raceRate:" .. raceRate)
  return raceRate
end

local function getDamageRate(target)
  local hurtSubPct = target and target:isValid() and target:getHurtSubPct() or 1
  local rate = math.max(1 + hurtSubPct, 0.3)
  Lib.logInfo("@Skill Race influence to damge,hurtSubPct:" .. hurtSubPct .. ",DamageRate:" .. rate)
  return rate
end

local function getOtherRate(from, skillInfo)
  return 1
end

local function getTargetNumRate(from, skillInfo)
  local targetNumrate = 1
  if skillInfo.count == 2 and from and from.battleField then
    local enemyList = from.battleField:getEnemyDataList(from) or {}
    if 1 < #enemyList then
      targetNumrate = 0.75
    end
  end
  Lib.logInfo("@Skill Race influence to damge,targetNumrate:" .. targetNumrate)
  return targetNumrate
end

local function checkCanDamage(from, target, skillInfo)
  local damageResult = false
  if not skillInfo then
    return damageResult
  end
  if skillInfo.count == 1 and type(skillInfo.attackTargetId) == "number" then
    if target.objID == skillInfo.attackTargetId then
      damageResult = true
    end
  else
    local battleField = from and from.battleField
    local enemyList = battleField and battleField:getEnemyDataList(from) or {}
    for _, enemy in pairs(enemyList or {}) do
      if enemy and enemy:isValid() then
        local enemyPkm = enemy.isPlayer and enemy:getBattlePet() or enemy
        if enemyPkm and enemyPkm:isValid() and enemyPkm.objID == target.objID then
          damageResult = true
          return damageResult
        end
      end
    end
  end
  return damageResult
end

local function processTriggerSkillDamgeEffect(from, target, damage, owner)
  local function deal(pFrom, pTarget, trigger, effectId, key, realDamage, round)
    if trigger == Define.SkillTriggerType.skillDamage then
      local effectCfg = skillEffectCfg:getConfigById(effectId)
      
      if effectCfg and effectCfg.dcm > 0 then
        local castDcm = math.random(1, 100)
        if castDcm <= effectCfg.dcm * 100 then
          local buffCfg = setting:fetch("buff", effectCfg.effectFullname)
          if effectCfg.target == 1 then
            SkillEffectMgr:triggerSkillDamageEffect(pFrom, buffCfg, effectId, key, {damage = realDamage, round = round})
          else
            SkillEffectMgr:triggerSkillDamageEffect(pTarget, buffCfg, effectId, key, {damage = realDamage, round = round})
          end
        end
      end
    end
  end
  
  local roundSkillEffcts = owner and owner.pokemon and owner.pokemon:getLongRoundEffectbuffList() or {}
  for key, effect in pairs(roundSkillEffcts) do
    deal(from, target, effect.trigger, effect.skilleffectId, key, damage, effect.round)
  end
  local addSkillEffcts = owner and owner:getAddSkillEffects() or {}
  for key, effect in pairs(addSkillEffcts) do
    deal(from, target, effect.trigger, effect.skilleffectId, key, damage, effect.round)
  end
end

function EntityServer:doDamage(info)
  if not self:isValid() then
    return 0
  end
  if self:isWatch() then
    return 0
  end
  local damage, from, isRebound = info.damage, info.from, info.isRebound
  damage = self:calcDamage(info)
  local damageCause = assert(info.cause, "must have a cause of doDamage")
  Trigger.CheckTriggers(self:cfg(), "ENTITY_PRE_DAMAGE", {
    obj1 = self,
    obj2 = from,
    damageIsCrit = info.damageIsCrit or false,
    damage = damage,
    skillName = info.skillName
  })
  local oriDamage = damage
  if 0 < self:prop("undamageable") and damageCause ~= "ENGINE_TOUCHDOWN" then
    return 0
  elseif damage <= 0 then
    return 0
  elseif 0 >= self.curHp then
    return 0
  elseif isRebound then
    self:tryAddHp(from, -damage)
    if 0 >= self.curHp then
      self:onDead({
        from = from and not from.removed and from or nil,
        cause = damageCause or "ENGINE_DO_DAMAGE_REBOUND"
      })
    end
    return damage
  end
  if 0 < self:prop("enableDamageProtection") and self.lastDamageTime and self.lastDamageTime + self:prop("damageProtectionTime") > World.Now() then
    return
  end
  local immue = self:data("immue")
  if immue.lastDamage == nil then
    immue.lastDamage = 0
    immue.hurtResistantTime = 0
  end
  local isOpenImmue = World.cfg.isOpenImmue == nil and true or World.cfg.isOpenImmue
  if isOpenImmue and immue.hurtResistantTime >= World.Now() then
    if damage <= immue.lastDamage then
      return 0
    end
    damage = -self:tryAddHp(from, -damage + immue.lastDamage)
    immue.lastDamage = immue.lastDamage + damage
  else
    immue.hurtResistantTime = World.Now() + (self:cfg().hurtResistantTime or 20)
    immue.lastDamage = damage
    damage = -self:tryAddHp(from, -damage)
  end
  self.lastDamageTime = World.Now()
  Trigger.CheckTriggers(self:cfg(), "ENTITY_DAMAGE", {
    obj1 = self,
    obj2 = from,
    damageIsCrit = info.damageIsCrit or false,
    damage = damage,
    oriDamage = oriDamage,
    skillName = info.skillName,
    cause = damageCause
  })
  if from then
    Trigger.CheckTriggers(from:cfg(), "ENTITY_DODAMAGE", {
      obj1 = from,
      obj2 = self,
      damageIsCrit = info.damageIsCrit or false,
      damage = damage,
      oriDamage = oriDamage,
      skillName = info.skillName
    })
  end
  if self.isPlayer and from then
    self:sendPacket({
      pid = "BeAttacked",
      fromId = from.objID
    })
  end
  if from and from ~= self then
    if 0 < damage then
      local lifeSteal = from:prop("lifeSteal") * damage
      if 0 < lifeSteal then
        from:tryAddHp(from, lifeSteal)
      end
      local dmgRebound = self:prop("dmgRebound") * damage
      if 0 < dmgRebound then
        from:doDamage({
          damage = dmgRebound,
          from = self,
          isRebound = true,
          cause = "ENGINE_DO_DAMAGE_REBOUND"
        })
      end
    end
    if from and from:isValid() and 0 < from.curHp then
      self:handleAIEvent("onHurt", from, damage)
    end
  end
  local damageVpConsume = self:prop("damageVpConsume")
  self:addVp(-damageVpConsume)
  if not self.removed and 0 >= self.curHp then
    self:onDead({
      from = from and not from.removed and from or nil,
      skillName = info.skillName,
      cause = damageCause or "ENGINE_DODAMAGE"
    })
  end
  return damage
end

local function processDelEffectSkillOnRelife(self)
  local roundSkillEffcts = self.pokemon and self.pokemon:getLongRoundEffectbuffList() or {}
  local addSkillEffcts = self:getAddSkillEffects() or {}
  local tempRoundSkillEffcts = Lib.copy(roundSkillEffcts)
  local tempAddSkillEffcts = Lib.copy(addSkillEffcts)
  for key, effect in pairs(tempRoundSkillEffcts) do
    local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
    if effectCfg.effectSkillType >= Define.EffectSkillType.fanji then
      roundSkillEffcts[key] = nil
      self:removeTypeBuff("fullName", effect.buffCfg.fullName)
    end
  end
  for key, effect in pairs(tempAddSkillEffcts) do
    local effectCfg = skillEffectCfg:getConfigById(effect.skilleffectId)
    if effectCfg.effectSkillType >= Define.EffectSkillType.fanji then
      addSkillEffcts[key] = nil
      self:removeTypeBuff("fullName", effect.buffCfg.fullName)
    end
  end
  self.pokemon:setLongRoundEffectbuffList(roundSkillEffcts)
  self:setAddSkillEffects(addSkillEffcts)
end

function EntityServer:tryAddHp(from, hp)
  local realDamage = 0
  local roundSkillEffcts = self.pokemon and self.pokemon:getLongRoundEffectbuffList() or {}
  local addSkillEffcts = self:getAddSkillEffects() or {}
  local skillInfo = from.curSkillBaseInfo
  if 0 >= self.curHp + hp then
    local result = false
    for key, effect in pairs(roundSkillEffcts) do
      if effect and effect.trigger == Define.SkillTriggerType.onDead then
        realDamage = self:addHp(1 - self.curHp)
        result = SkillEffectMgr:triggerDeadEffect(self, effect.buffCfg, effect.skilleffectId, key, effect.round)
        if result then
          SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.relife, from, self)
          if skillInfo then
            SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.relife, from, self, skillInfo and skillInfo.skill_effect or {})
          else
            Lib.logWarning("warning: skill From have no curSkillBaseInfo!", from and from.name, from and from.objID)
          end
          return realDamage
        end
      end
    end
    for key, effect in pairs(addSkillEffcts) do
      if effect and effect.trigger == Define.SkillTriggerType.onDead then
        realDamage = self:addHp(1 - self.curHp)
        result = SkillEffectMgr:triggerDeadEffect(self, effect.buffCfg, effect.skilleffectId, key, effect.round)
        if result then
          SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.relife, from, self)
          if skillInfo then
            SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.relife, from, self, skillInfo and skillInfo.skill_effect or {})
          else
            Lib.logWarning("warning: skill From have no curSkillBaseInfo!", from and from.name, from and from.objID)
          end
          return realDamage
        end
      end
    end
    realDamage = self:addHp(hp)
  else
    realDamage = self:addHp(hp)
  end
  return realDamage
end

function player_touchdown(entity)
  if entity.isPlayer and not entity:isInBattle() then
    entity:setMapPos("map001", World.cfg.initPos)
  end
end

local function calVulnerabilityEffectDamage(from, target, damage)
  local dcm = 0
  local realdamage = damage
  if not (from and from:isValid() and target) or not target:isValid() then
    return realdamage, dcm
  end
  local AddSkillEffects = target:getAddSkillEffects() or {}
  local isHaveVulnerabilityEffect = false
  local vulnerabilityEffect, vulnerabilityEffectKey, vulnerabilityEffectCfg
  for i, v in pairs(AddSkillEffects) do
    local effectCfg = skillEffectCfg:getConfigById(v.skilleffectId)
    if effectCfg and effectCfg.isVulnerability == 1 then
      isHaveVulnerabilityEffect = true
      vulnerabilityEffectCfg = effectCfg
      vulnerabilityEffect = v
      vulnerabilityEffectKey = i
    end
  end
  if isHaveVulnerabilityEffect and vulnerabilityEffectCfg and vulnerabilityEffect and vulnerabilityEffectKey then
    local roundSkillEffcts = target.pokemon:getLongRoundEffectbuffList()
    local curAbnormalType = 0
    local isAbnormalEffect = false
    for i, v in pairs(roundSkillEffcts) do
      if 0 < v.abnormalType then
        isAbnormalEffect = true
        curAbnormalType = v.abnormalType
      end
    end
    if isAbnormalEffect and 0 < curAbnormalType and curAbnormalType == vulnerabilityEffectCfg.intger then
      realdamage = realdamage * (1 + vulnerabilityEffectCfg.dcm)
      dcm = vulnerabilityEffectCfg.dcm
      SkillEffectMgr:triggerVulnerabilityEffect(from, vulnerabilityEffect.buffCfg, vulnerabilityEffect.skilleffectId, vulnerabilityEffectKey, vulnerabilityEffect.round)
    end
  end
  return realdamage, dcm
end

local function getDamgeByEquation(skillInfo, from, self)
  local damage = 0
  local sameRaceRate = getSameRaceRate(from, skillInfo)
  local raceRate = getRaceRate(self, skillInfo)
  local targetNumrate = getTargetNumRate(from, skillInfo)
  local demageRate = getDamageRate(self)
  local otherRate = getOtherRate(from, skillInfo)
  if skillInfo.hurt_type == 3 then
    local effectHurt = from:getEffectivePower(skillInfo.hurt)
    damage = effectHurt
  elseif skillInfo.hurt_type == 1 then
    local A = math.max(from:getEffectivePAtk() - self:getEffectivePDef(), from:getEffectivePAtk() * 0.3)
    local randomNum = 1.1 - 0.15 * math.random()
    local B = sameRaceRate * raceRate * targetNumrate * demageRate * targetNumrate * otherRate * randomNum
    local effectHurt = from:getEffectivePower(skillInfo.hurt)
    damage = A * B * effectHurt / 100
  elseif skillInfo.hurt_type == 2 then
    local A = math.max(from:getEffectiveSAtk() - self:getEffectiveSDef(), from:getEffectiveSAtk() * 0.3)
    local randomNum = 1.1 - 0.15 * math.random()
    local B = sameRaceRate * raceRate * targetNumrate * demageRate * targetNumrate * otherRate * randomNum
    local effectHurt = from:getEffectivePower(skillInfo.hurt)
    damage = A * B * effectHurt / 100
  end
  return damage
end

function EntityServer:calcDamage(info)
  local damage = 0
  if self.isPlayer or not info.from then
    return damage
  end
  local skillInfo = info.from.curSkillBaseInfo
  if info.isBuffDamage then
    if 0 < info.damage then
      local textList = {}
      local numStr = tostring(math.floor(info.damage))
      for i = 1, #numStr do
        local num = numStr:sub(i, i)
        table.insert(textList, num)
      end
      self:ShowFlyText(textList, info.from, "red")
    end
    if skillInfo then
      SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.beHurt, info.from, self)
      SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.beHurt, info.from, self, skillInfo.skill_effect)
    end
    return info.damage
  end
  local canDamage = checkCanDamage(info.from, self, skillInfo)
  if not canDamage then
    return 0
  end
  if not info.from:data("main").skillDamage then
    info.from:data("main").skillDamage = {}
  end
  local raceRate = getRaceRate(self, skillInfo)
  if skillInfo.isAccuracy then
    damage = getDamgeByEquation(skillInfo, info.from, self)
    SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.damage, info.from, self)
    SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.damage, info.from, self, skillInfo.skill_effect)
    SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.beHurt, info.from, self)
    SkillEffectMgr:addInitiativeSkillEffect(skillInfo.id, Define.SkillEffectTiming.beHurt, info.from, self, skillInfo.skill_effect)
  else
    Lib.logDebug("\233\151\170\233\129\191\239\188\129\239\188\129\239\188\129")
    local textList = {}
    local numStr = "MISS"
    for i = 1, #numStr do
      local num = numStr:sub(i, i)
      table.insert(textList, num)
    end
    self:ShowFlyText(textList, self, "white")
    info.from:data("main").skillDamage[tonumber(skillInfo.id)] = damage
    processTriggerSkillDamgeEffect(info.from, self, damage, info.from)
    processTriggerSkillDamgeEffect(info.from, self, damage, self)
    return damage
  end
  damage = math.floor(damage + 0.5)
  local realdamge, dcm = calVulnerabilityEffectDamage(info.from, self, damage)
  local flyImgset = "red"
  if 0 < damage then
    local textList = {}
    if 0 < dcm then
      flyImgset = "yishang"
      table.insert(textList, "h")
    elseif 1 < raceRate then
      flyImgset = "yellow"
      table.insert(textList, "h")
    elseif raceRate == 1 then
      flyImgset = "red"
    elseif raceRate < 1 then
      table.insert(textList, "h")
      flyImgset = "white"
    end
    local numStr = tostring(math.floor(realdamge))
    for i = 1, #numStr do
      local num = numStr:sub(i, i)
      table.insert(textList, num)
    end
    self:ShowFlyText(textList, info.from, flyImgset)
  end
  damage = realdamge
  info.from:data("main").skillDamage[tonumber(skillInfo.id)] = damage
  processTriggerSkillDamgeEffect(info.from, self, damage, info.from)
  processTriggerSkillDamgeEffect(info.from, self, damage, self)
  return damage
end

function EntityServer:setCurSkillBaseInfo(skillCfg)
  self.curSkillBaseInfo = skillCfg
end

function EntityServer:resetCurSkillBaseInfo()
  self.curSkillBaseInfo = nil
end

function Entity:addPokemonHp(number)
  if self.isPlayer and not self:isValid() then
    return
  end
  local maxHp = self.curHp + number
  local realLife = number
  if maxHp > self:getMaxHp() then
    realLife = self:getMaxHp() - self.curHp
  end
  self:addHp(realLife)
  local number = math.floor(number)
  local textList = {}
  table.insert(textList, "+")
  local numStr = tostring(number)
  for i = 1, #numStr do
    local num = numStr:sub(i, i)
    table.insert(textList, num)
  end
  self:ShowFlyText(textList, self, "green")
end

function Entity.EntityProp:buffDamage(value, add, buff)
  if add then
    local skillInfo = self.curSkillBaseInfo
    if skillInfo then
      local damage = getDamgeByEquation(skillInfo, self, self)
      damage = math.floor(damage + 0.5)
      self:doDamage({
        damage = damage,
        cause = "SKILL_EFFECT_BUFF_DAMAGE",
        isBuffDamage = true,
        from = self
      })
    end
  end
end

function Entity.EntityProp:cureHpEffect(value, add, buff)
  if add then
  else
    if self.cureItemCfg then
      local dose = self.cureItemCfg.dose
      local maxHp = self:getMaxHp()
      if dose > math.floor(dose) or dose == 1 then
        dose = maxHp * dose
      end
      self:addPokemonHp(dose)
      self.cureItemCfg = nil
    end
    self.battleField:setAllStateReady(true)
  end
end

function Entity.EntityProp:curePpEffect(value, add, buff)
  if add then
  else
    self.battleField:setAllStateReady(true)
  end
end

local function deleteDeBuff(self, abnormalType, skilleffectId)
  local skillEffects = self:getAddSkillEffects()
  for key, value in pairs(skillEffects or {}) do
    if value.abnormalType == abnormalType then
      skillEffects[key] = nil
    end
  end
  self:longRoundEffectProp(false, skilleffectId)
  self:setAddSkillEffects(skillEffects)
end

function Entity.EntityProp:cureDeBuffEffect(value, add, buff)
  if add then
  else
    if self.deBuffFullName then
      local buffList = self.pokemon:getLongRoundEffectbuffList()
      if self.deBuffFullName == 0 then
        for _, cfg in pairs(buffList or {}) do
          if 0 < cfg.abnormalType then
            deleteDeBuff(self, cfg.abnormalType, cfg.skilleffectId)
          end
        end
      else
        for _, cfg in pairs(buffList or {}) do
          if cfg.abnormalType == self.deBuffFullName then
            deleteDeBuff(self, self.deBuffFullName, cfg.skilleffectId)
          end
        end
      end
    end
    self.deBuffFullName = nil
    self.battleField:setAllStateReady(true)
  end
end

local engine_onDead = EntityServer.onDead

function EntityServer:onDead(deathInfo)
  engine_onDead(self, deathInfo)
  local from = deathInfo.from
  if from and from:isValid() then
    Lib.logDebug("from.isEnemy = ", from.isEnemy)
    Lib.logDebug("from.isPlayer = ", from.isPlayer)
    Lib.logDebug("self.isPlayer = ", self.isPlayer)
    if not from.isEnemy and not from.isPlayer and not self.isPlayer and self:getPokemon() then
      local pokemonid = self:getPokemon():getCfg().id
      Lib.logDebug("onDead pokemonid = ", pokemonid)
      local owner = not (not from or from.removed) and from:owner() or nil
      local master = owner:getMaster()
      if master and master:isValid() and master.isPlayer then
        Lib.logDebug("master is player")
        master:updateTaskStatus(Define.TASK_TYPE.POKEMON_BATTLE, 1, pokemonid, 1)
      end
    end
  end
end

function EntityServer:skillEffecttrigger(value, buffCfg, skilleffectId, param)
  local effectCfg = skillEffectCfg:getConfigById(skilleffectId)
  if not effectCfg then
    Lib.logError("Error:can not found effectCfg, effectId =", skilleffectId)
    return
  end
  local from = param and param.from
  if not from or not from:isValid() then
    from = self
  end
  local maxHp = self:getMaxHp()
  if buffCfg.triggerData then
    if buffCfg.triggerData.hurt and buffCfg.triggerData.hurt > 0 then
      local hurtDamge = 0
      if 0 > effectCfg.dcm then
        hurtDamge = math.floor(math.max(-(effectCfg.dcm * maxHp), 1) + 0.5)
        self:doDamage({
          damage = hurtDamge,
          cause = "SKILL_ROUND_EFFECT_DAMAGE",
          isBuffDamage = true,
          from = from
        })
      elseif 0 < effectCfg.dcm then
        hurtDamge = math.floor(effectCfg.dcm * maxHp + effectCfg.intger + 0.5)
        self:addPokemonHp(hurtDamge)
      end
    elseif buffCfg.triggerData.suckBlood and 0 < buffCfg.triggerData.suckBlood then
      local realDamge = param.damage
      local suckBlood = math.floor(effectCfg.intger / 100 * realDamge + 0.5)
      self:addPokemonHp(suckBlood)
    elseif buffCfg.triggerData.revived and 0 < buffCfg.triggerData.revived then
      local suckBlood = math.floor(effectCfg.intger / 100 * maxHp + 0.5)
      self:addPokemonHp(suckBlood)
    elseif buffCfg.triggerData.fantan and 0 < buffCfg.triggerData.fantan then
      local realDamge = param.damage
      local hurtDamge = math.floor(realDamge * ((param.intger or 0) / 100) + 0.5)
      self:doDamage({
        damage = hurtDamge,
        cause = "SKILL_ROUND_EFFECT_DAMAGE",
        isBuffDamage = true,
        from = from
      })
    end
  end
end

function EntityServer:longRoundEffectProp(add, effectId)
  local effectCfg = skillEffectCfg:getConfigById(effectId)
  if not effectCfg then
    Lib.logError("error\239\188\154can not found the effectCfg,which skilleffectId = ", effectId)
    return nil
  end
  if effectCfg.abnormalType == Define.SkillAbnormalType.dka then
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.burn then
    if add then
      local pAtkRBonus = self:getPAtkRBonus()
      self:setPAtkRBonus(pAtkRBonus + effectCfg.intger / 100)
    else
      local pAtkRBonus = self:getPAtkRBonus()
      self:setPAtkRBonus(pAtkRBonus - effectCfg.intger / 100)
    end
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.damp then
    if add then
      local sAtkRBonus = self:getSAtkRBonus()
      self:setSAtkRBonus(sAtkRBonus + effectCfg.intger / 100)
    else
      local sAtkRBonus = self:getSAtkRBonus()
      self:setSAtkRBonus(sAtkRBonus - effectCfg.intger / 100)
    end
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.palsy then
    if add then
      local speedRBonus = self:getSpeedRBonus()
      self:setSpeedRBonus(speedRBonus + effectCfg.intger / 100)
    else
      local speedRBonus = self:getSpeedRBonus()
      self:setSpeedRBonus(speedRBonus - effectCfg.intger / 100)
    end
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.sleep then
  elseif effectCfg.abnormalType == Define.SkillAbnormalType.chaos then
  end
end

function Entity.EntityProp:spellSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local sAtkRBonus = self:getSAtkRBonus()
    self:setSAtkRBonus(sAtkRBonus + effectCfg.dcm)
    local sAtkNBonus = self:getSAtkNBonus()
    self:setSAtkNBonus(sAtkNBonus + effectCfg.intger)
  else
    local sAtkRBonus = self:getSAtkRBonus()
    self:setSAtkRBonus(sAtkRBonus - effectCfg.dcm)
    local sAtkNBonus = self:getSAtkNBonus()
    self:setSAtkNBonus(sAtkNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:physicalSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local sPtkRBonus = self:getPAtkRBonus()
    self:setPAtkRBonus(sPtkRBonus + effectCfg.dcm)
    local sPtkNBonus = self:getPAtkNBonus()
    self:setPAtkNBonus(sPtkNBonus + effectCfg.intger)
  else
    local sPtkRBonus = self:getPAtkRBonus()
    self:setPAtkRBonus(sPtkRBonus - effectCfg.dcm)
    local sPtkNBonus = self:getPAtkNBonus()
    self:setPAtkNBonus(sPtkNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:speedSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local speedRBonus = self:getSpeedRBonus()
    self:setSpeedRBonus(speedRBonus + effectCfg.dcm)
    local speedNBonus = self:getSpeedNBonus()
    self:setSpeedNBonus(speedNBonus + effectCfg.intger)
  else
    local speedRBonus = self:getSpeedRBonus()
    self:setSpeedRBonus(speedRBonus - effectCfg.dcm)
    local speedNBonus = self:getSpeedNBonus()
    self:setSpeedNBonus(speedNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:spellDefBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local sDefRBonus = self:getSDefRBonus()
    self:setSDefRBonus(sDefRBonus + effectCfg.dcm)
    local sDefNBonus = self:getSDefNBonus()
    self:setSDefNBonus(sDefNBonus + effectCfg.intger)
  else
    local sDefRBonus = self:getSDefRBonus()
    self:setSDefRBonus(sDefRBonus - effectCfg.dcm)
    local sDefNBonus = self:getSDefNBonus()
    self:setSDefNBonus(sDefNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:physicalDefBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local pDefRBonus = self:getPDefRBonus()
    self:setPDefRBonus(pDefRBonus + effectCfg.dcm)
    local pDefNBonus = self:getPDefNBonus()
    self:setPDefNBonus(pDefNBonus + effectCfg.intger)
  else
    local pDefRBonus = self:getPDefRBonus()
    self:setPDefRBonus(pDefRBonus - effectCfg.dcm)
    local pDefNBonus = self:getPDefNBonus()
    self:setPDefNBonus(pDefNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:accuracySkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local accuracyRBonus = self:getAccuracyRBonus()
    self:setAccuracyRBonus(accuracyRBonus + effectCfg.dcm)
    local accuracyNBonus = self:getAccuracyNBonus()
    self:setAccuracyNBonus(accuracyNBonus + effectCfg.intger)
  else
    local accuracyRBonus = self:getAccuracyRBonus()
    self:setAccuracyRBonus(accuracyRBonus - effectCfg.dcm)
    local accuracyNBonus = self:getAccuracyNBonus()
    self:setAccuracyNBonus(accuracyNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:powerSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local powerRBonus = self:getPowerRBonus()
    self:setPowerRBonus(powerRBonus + effectCfg.dcm)
    local powerNBonus = self:getPowerNBonus()
    self:setPowerNBonus(powerNBonus + effectCfg.intger)
  else
    local powerRBonus = self:getPowerRBonus()
    self:setPowerRBonus(powerRBonus - effectCfg.dcm)
    local powerNBonus = self:getPowerNBonus()
    self:setPowerNBonus(powerNBonus - effectCfg.intger)
  end
end

function Entity.EntityProp:damageSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local damageRBonus = self:getHurtSubPct()
    self:setHurtSubPct(damageRBonus + effectCfg.dcm)
  else
    local damageRBonus = self:getHurtSubPct()
    self:setHurtSubPct(damageRBonus - effectCfg.dcm)
  end
end

function Entity.EntityProp:lifeSkillBonus(value, add, buff)
  local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
  if not effectCfg then
    return
  end
  if add then
    local lifeRBonus = self:getLifeRBonus()
    self:setLifeRBonus(lifeRBonus + effectCfg.dcm)
    local lifeNBonus = self:getLifeNBonus()
    self:setLifeNBonus(lifeNBonus + effectCfg.intger)
    self:updatePKMBonusHp()
  elseif self and self:isValid() and self.curHp > 0 then
    local lifeRBonus = self:getLifeRBonus()
    self:setLifeRBonus(lifeRBonus - effectCfg.dcm)
    local lifeNBonus = self:getLifeNBonus()
    self:setLifeNBonus(lifeNBonus - effectCfg.intger)
    self:updatePKMBonusHp()
  end
end

function Entity.EntityProp:singleRecoverHp(value, add, buff)
  if add then
    local effectCfg = skillEffectCfg:getConfigById(buff.effectId)
    if not effectCfg then
      return
    end
    local lastMaxHp = self:getMaxHp()
    local hp = lastMaxHp * effectCfg.dcm + effectCfg.intger
    self:addPokemonHp(hp)
  end
end

function Entity.EntityProp:avoidBattle(value, add, buff)
end

function EntityServer:removeBattleEffectBuff()
  if self.pokemon then
    self:setAddSkillEffects({})
    local tbRoundBuff = self.pokemon:getLongRoundEffectbuffList() or {}
    for key, v in pairs(tbRoundBuff) do
      self:longRoundEffectProp(false, v.skilleffectId)
    end
    self.pokemon:setLongRoundEffectbuffList({})
  end
end

function EntityServer:addPkmBirthEffectBuff()
  SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.enterBattle, self, self)
  self.battleField:setAllStateReady(true)
end

function EntityServer:isImmuneSkillEffect(skilleffectId)
  local AddSkillEffects = self:getAddSkillEffects() or {}
  local immuneSkillEffectId
  local effectRound = 1
  local isBeImmune = false
  for i, v in pairs(AddSkillEffects) do
    for i = 1, #v.tbImmuneSkillEffect do
      if tonumber(v.tbImmuneSkillEffect[i]) == tonumber(skilleffectId) then
        immuneSkillEffectId = v.skilleffectId
        effectRound = v.round
        isBeImmune = true
      end
    end
  end
  local isImmuneTrigger = false
  if isBeImmune and immuneSkillEffectId then
    local effectCfg = skillEffectCfg:getConfigById(immuneSkillEffectId)
    if effectCfg and effectCfg.dcm > 0 then
      local castDcm = math.random(1, 100)
      if castDcm <= effectCfg.dcm * 100 then
        isImmuneTrigger = true
      end
    end
  end
  return isBeImmune and isImmuneTrigger, immuneSkillEffectId, effectRound
end

local function sendBuffPacket(self, buff, packet)
  packet.id = buff.id
  packet.objID = self.objID
  local sync = buff.cfg.sync or "all"
  if sync == "all" then
    self:sendPacketToTracking(packet, true)
  elseif sync == "self" then
    if self.isPlayer then
      self:sendPacket(packet)
    end
  elseif sync == "team" then
    local team = self:getTeam()
    if team then
      team:broadcastPacket(packet)
    end
  elseif sync == "other" then
    self:sendPacketToTracking(packet, false)
  end
end

local function passiveBuffsPick(self, name)
  if not self:cfg().passiveBuffs then
    return false
  end
  local isPick = false
  for _, buff in pairs(self:cfg().passiveBuffs) do
    if buff.name == name then
      isPick = true
      break
    end
  end
  return isPick
end

local function onlyBuffsPick(self, name)
  if not self:cfg().onlyBuffs then
    return false
  end
  local isPick = false
  for _, buffName in pairs(self:cfg().onlyBuffs) do
    if buffName == name then
      isPick = true
      break
    end
  end
  return isPick
end

function EntityServer:addBuff(name, time, from, effectId)
  local cfg = Entity.BuffCfg(name)
  local forPlayer = cfg.forPlayer
  if forPlayer ~= nil and self.isPlayer ~= forPlayer then
    return nil
  end
  if World.cfg.allEntityRejectBuff and not self.isPlayer and not self:cfg().canBuffed and not passiveBuffsPick(self, name) and not onlyBuffsPick(self, name) then
    return nil
  end
  for _, nm in ipairs(cfg.avoidBuff or {}) do
    if not nm:find("/") then
      nm = cfg.plugin .. "/" .. nm
    end
    if self:getTypeBuff("fullName", nm) then
      return nil
    end
  end
  for _, nm in ipairs(cfg.removeBuff or {}) do
    if not nm:find("/") then
      nm = cfg.plugin .. "/" .. nm
    end
    self:removeTypeBuff("fullName", nm)
  end
  local fixTime = cfg.appendTime and "append" or cfg.fixTime
  local buff = fixTime and self:getTypeBuff("fullName", cfg.fullName)
  if buff then
    buff.effectId = effectId or 0
    if buff.timer then
      buff.timer()
      buff.timer = nil
    end
    if buff.endTime or fixTime == "reset" then
      local restTime
      if not time then
        buff.endTime = nil
        restTime = nil
      elseif fixTime == "append" then
        buff.endTime = buff.endTime + time
        restTime = buff.endTime - World.Now()
      elseif fixTime == "reset" then
        buff.endTime = time and World.Now() + time
        restTime = time
      elseif fixTime == "max" then
        local leftTime = buff.endTime - World.Now()
        if time <= leftTime then
          restTime = leftTime
        else
          restTime = time
          buff.endTime = World.Now() + time
        end
      else
        assert(false, string.format("wrong value: %s, value range: append, reset, max", fixTime))
      end
      if restTime then
        buff.timer = self:timer(restTime, EntityServer.removeBuff, self, buff)
      end
      sendBuffPacket(self, buff, {
        pid = "ChangeBuffTime",
        restTime = restTime
      })
    end
  else
    local list = self:data("buff")
    buff = {
      cfg = cfg,
      id = #list + 1,
      owner = self,
      effectId = effectId or 0
    }
    if time then
      buff.endTime = World.Now() + time
      buff.timer = self:lightTimer("removeBuff", time, EntityServer.removeBuff, self, buff)
    end
    list[buff.id] = buff
    sendBuffPacket(self, buff, {
      pid = "AddBuff",
      fromID = from and from:isValid() and from.objID,
      name = name,
      time = time,
      effectId = effectId
    })
    self:calcBuff(buff, true, from)
  end
  if not cfg.appendTime then
    return buff
  end
  buff.addTimes = (buff.addTimes or 0) + 1
  return setmetatable({
    addTime = time or false
  }, {__index = buff, __newindex = buff})
end

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

local function rotateTo(self, pCaster)
  local yaw = Lib.v3AngleXZ(Lib.v3cut(pCaster:getPosition(), self:getPosition()))
  self:setRotationYaw(yaw)
  self:syncPosDelay()
  local packet = {
    pid = "SetEntityBodyYaw",
    objID = self.objID,
    rotationYaw = yaw
  }
  self:sendPacketToTracking(packet, true)
end

function EntityServer:setFollowForceMoveToAll(pos, time)
  self:setForceMove(pos, time)
  self:sendPacket({
    pid = "ForceMoveToSelf",
    pos = pos,
    time = time + 3
  })
end

function EntityServer:syncFollowForceMove(targetID, pos, time)
  self:sendPacket({
    pid = "syncFollowForceMove",
    targetID = targetID,
    pos = pos,
    time = time + 3
  })
end

function EntityServer:playAction(actionName, actionTime)
  local packet = {
    pid = "EntityPlayAction",
    objID = self.objID,
    action = actionName,
    time = actionTime or -1
  }
  self:sendPacketToTracking(packet, true)
end

local function followCaptain(captain, teamMate)
  if captain:data("main").followTimer then
    captain:data("main").followTimer()
  end
  captain:data("main").followTimer = World.Timer(1, function()
    if teamMate and teamMate:isValid() and captain and captain:isValid() then
      if teamMate:isJoinTeam() and captain:getMyTeamMateId() == teamMate.objID then
        rotateTo(teamMate, captain)
        local BoundingBox = captain:getBoundingBox()
        local targetPos = getTargetPos({
          x = 0,
          y = 0,
          z = -(BoundingBox[1] + 0.5)
        }, captain)
        teamMate:setFollowForceMoveToAll(targetPos, 2)
        captain:syncFollowForceMove(teamMate.objID, targetPos, 2)
      else
        if captain:data("main").followTimer then
          captain:data("main").followTimer()
        end
        teamMate:playAction("idle")
        return false
      end
    else
      return false
    end
    return true
  end)
  teamMate:playAction("run")
end

local function pausefollowCaptain(captain, teamMate)
  local BoundingBox = captain:getBoundingBox()
  World.Timer(1, function()
    if teamMate and teamMate:isValid() and captain and captain:isValid() then
      local targetPos = getTargetPos({
        x = 0,
        y = 0,
        z = -(BoundingBox[1] + 0.5)
      }, captain)
      local distance = Lib.getPosDistance(teamMate:getPosition(), targetPos)
      if distance <= 0.01 then
        rotateTo(teamMate, captain)
        World.Timer(10, function()
          if teamMate and teamMate:isValid() and captain and captain:isValid() and not captain.isMoving then
            if captain:data("main").followTimer then
              captain:data("main").followTimer()
            end
            teamMate:playAction("idle")
          end
          return false
        end)
        return false
      end
      return true
    else
      return false
    end
  end)
end

function EntityServer:moveStatusChange(newState, oldState)
  if self.isPlayer and not self:isInBattle() and self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    if teamMateId then
      local teamMate = World.CurWorld:getEntity(teamMateId)
      if teamMate and teamMate:isValid() then
        if newState == 3 or newState == 4 then
          followCaptain(self, teamMate)
        elseif newState == 2 then
          pausefollowCaptain(self, teamMate)
        end
      end
    end
  end
  self:tryStopAnimoji()
  if not self:cfg().isBrightPkm then
    self:handleMoveStateSwitchBuffs(oldState, newState, function(self, fullName)
      local buffCfg = Entity.BuffCfg(fullName)
      if not buffCfg.buffTime then
        return self:addBuff(fullName)
      end
      self:addBuff(fullName, buffCfg.buffTime)
      return nil
    end, self.removeBuff)
  end
  self:handleMoveStateSwitchSkills(oldState, newState, function(self, fullName)
    Skill.Cast(fullName, {}, self)
  end)
end

function EntityServer:isSaveMapPos(map)
  return map.cfg.saveMapPos
end

function EntityServer:telegraphTo(map, pos, gymId)
  if self:isJoinTeam() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:setCurGym(gymId)
      teamMate:setMapPos(map, pos + {
        x = 0,
        y = 0,
        z = -1.5
      })
    end
  end
  self:setMapPos(map, pos)
end

function Entity.ValueFunc:readyCloseResult(isReady)
  if not isReady then
    return
  end
  if self:isJoinTeam() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      if teamMate:isReadyCloseResult() then
        self:closeResult()
        teamMate:closeResult()
      else
        self:sendPacket({
          pid = "startAutoSkipResult"
        })
        teamMate:sendPacket({
          pid = "startAutoSkipResult"
        })
      end
    else
      self:closeResult()
    end
  else
    self:closeResult()
  end
end

function EntityServer:removeBuffById(buffId)
  local list = {}
  for id, buff in pairs(self:data("buff")) do
    if buff and buffId == id then
      list[#list + 1] = buff
    end
  end
  local now = World.Now()
  for _, buff in ipairs(list) do
    local lastTime = false
    if buff.endTime then
      lastTime = buff.endTime - now
    end
    local extraParams = buff.extraParams or {}
    local from = false
    if buff.from then
      from = buff.from
    end
    self:removeBuff(buff)
  end
end
