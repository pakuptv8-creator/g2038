local Pokemon = Lib.class("Pokemon")
local PokemonConfig = T(Config, "PokemonConfig")
local SkillConfig = T(Config, "SkillConfig")
local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
local LuaTimer = T(Lib, "LuaTimer")
local SkillEffectConfig = T(Config, "SkillEffectConfig")
local BlessItemConfig = T(Config, "BlessItemConfig")
local setting = require("common.setting")
local Json = require("cjson")
local PokemonInfoKey = {
  uid = {
    default = nil,
    saveDb = true,
    toClient = true
  },
  cfgId = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  curName = {
    default = "",
    saveDb = true,
    toClient = true
  },
  ballId = {
    default = 1,
    saveDb = true,
    toClient = true
  },
  sex = {
    default = 1,
    saveDb = true,
    toClient = true
  },
  level = {
    default = 1,
    saveDb = true,
    toClient = true
  },
  wake = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  star = {
    default = 1,
    saveDb = true,
    toClient = true
  },
  curExp = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  curHp = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  hpBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  speedBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  pAtkBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  sAtkBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  pDefBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  sDefBless = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  skillList = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  passiveList = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  studySkillList = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  buffList = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  masterId = {
    default = 0,
    saveDb = false,
    toClient = true
  },
  entityObjId = {
    default = 0,
    saveDb = false,
    toClient = true
  },
  captured = {
    default = false,
    saveDb = false,
    toClient = true
  },
  npcCfgId = {
    default = 0,
    saveDb = false,
    toClient = true
  },
  battleMaxHp = {
    default = 0,
    saveDb = false,
    toClient = true
  },
  foughtCount = {
    default = 0,
    saveDb = false,
    toClient = true
  },
  longRoundEffectbuffList = {
    default = "[]",
    saveDb = true,
    toClient = true
  },
  isMutated = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  isFollowPet = {
    default = false,
    saveDb = true,
    toClient = true
  },
  isLocked = {
    default = 0,
    saveDb = true,
    toClient = true
  },
  wakeRedPointShow = {
    default = false,
    saveDb = false,
    toClient = true
  },
  newRedPointShow = {
    default = false,
    saveDb = false,
    toClient = true
  },
  canLevelUpRedPointShow = {
    default = false,
    saveDb = false,
    toClient = true
  },
  canStarUpRedShow = {
    default = false,
    saveDb = false,
    toClient = true
  },
  canBlessRedPointShow = {
    default = false,
    saveDb = false,
    toClient = true
  }
}
local AttributeKey = {
  level = true,
  star = true,
  wake = true
}

function Pokemon.getPokemonInfoKey()
  return PokemonInfoKey
end

function Pokemon:ctor(info)
  self.attr = info
  PokemonConfig:updateAttribute(self)
end

function Pokemon:setMasterId(userId)
  self:setValue("masterId", userId)
end

function Pokemon:getMaster()
  return self.master
end

function Pokemon:getMasterId()
  return self:getValue("masterId")
end

function Pokemon:setEntityObjId(objId)
  self:setValue("entityObjId", objId)
end

function Pokemon:getEntityObjId()
  return self:getValue("entityObjId")
end

function Pokemon:setCaptured(isCaptured)
  self:setValue("captured", isCaptured)
end

function Pokemon:getCaptured()
  return self:getValue("captured")
end

function Pokemon:getCfgFullName()
  if self:isMutated() then
    return self:getCfg().mutateFullName
  else
    return self:getCfg().fullName
  end
end

function Pokemon:isSkillAbnormalBuff(effectId)
  local buffList = self:getLongRoundEffectbuffList()
  for key, val in pairs(buffList) do
    if val.skilleffectId == effectId and val.abnormalType > 0 then
      return true
    end
  end
  return false
end

function Pokemon:getUid()
  return self:getValue("uid")
end

function Pokemon:getObjId()
  return self.objId
end

function Pokemon:getCfgId()
  return self:getValue("cfgId")
end

function Pokemon:getCfg()
  if not self.cfg then
    self.cfg = Lib.copy(PokemonConfig:getConfigById(self:getCfgId()) or {})
  end
  return self.cfg
end

function Pokemon:getNcpCfgId()
  return self:getValue("npcCfgId")
end

function Pokemon:getNpcCfg()
  local npcId = self:getNcpCfgId()
  if npcId == 0 then
    return nil
  end
  return NPCPokemonConfig:getPokemonById(npcId)
end

function Pokemon:getBookId()
  return self:getCfg().bookId
end

function Pokemon:getIcon()
  return self:getCfg().icon or ""
end

function Pokemon:getIconFrame()
  return PokemonConfig:getQualityFrame(self:getCfgId())
end

function Pokemon:getQuality()
  return self:getCfg().quality or 1
end

function Pokemon:getDebuffIcon()
  if self:isDead() then
    return "set:pokemon_battle.json image:state_dead"
  end
  local buffList = self:getLongRoundEffectbuffList()
  for key, val in pairs(buffList) do
    if val.abnormalType > 0 then
      return SkillEffectConfig:getEffectIconByDisplay(val.skilleffectId)
    end
  end
  return ""
end

function Pokemon:isAbnormalState()
  local buffList = self:getLongRoundEffectbuffList()
  for key, val in pairs(buffList) do
    if val.abnormalType > 0 then
      return true
    end
  end
  return false
end

function Pokemon:getMaxExp(level)
  return PokemonConfig:getMaxExp(self:getCfgId(), level or self:getLevel())
end

function Pokemon:getRace()
  return self:getCfg().race
end

function Pokemon:getCatchProbability()
  return self:getCfg().catchProbability
end

function Pokemon:getRunawayProbability()
  return self:getCfg().runawayProbability
end

function Pokemon:setBattleMaxHp(battleMaxHp)
  self:setValue("battleMaxHp", battleMaxHp)
end

function Pokemon:getBattleMaxHp()
  return self:getValue("battleMaxHp")
end

function Pokemon:getMaxHp()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_hp ~= -1 then
    return npc_config.npc_hp
  end
  return self:getValue("maxHp") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.Hp) + self:getHpMutate()
end

function Pokemon:getSpeed()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_speed ~= -1 then
    return npc_config.npc_speed
  end
  return self:getValue("speed") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.Speed) + self:getSpeedMutate()
end

function Pokemon:getPhysicalAtk()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_pAtk ~= -1 then
    return npc_config.npc_pAtk
  end
  return self:getValue("pAtk") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.PAtk) + self:getPAtkMutate()
end

function Pokemon:getSpecialAtk()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_sAtk ~= -1 then
    return npc_config.npc_sAtk
  end
  return self:getValue("sAtk") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.SAtk) + self:getSAtkMutate()
end

function Pokemon:getPhysicalDef()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_pDef ~= -1 then
    return npc_config.npc_pDef
  end
  return self:getValue("pDef") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.PDef) + self:getPDefMutate()
end

function Pokemon:getSpecialDef()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.npc_sDef ~= -1 then
    return npc_config.npc_sDef
  end
  return self:getValue("sDef") + self:getBlessValue(Define.POKEMON_ATTR_TYPE.SDef) + self:getSDefMutate()
end

function Pokemon:getFightPower()
  local skillFightPower = 0
  for _, skill in pairs(self:getSkillList()) do
    skillFightPower = skillFightPower + SkillConfig:getSkillScoreById(skill.skillId)
  end
  for _, skillId in pairs(self:getPassiveSkillList()) do
    skillFightPower = skillFightPower + SkillConfig:getSkillScoreById(skillId)
  end
  skillFightPower = skillFightPower + SkillConfig:getSkillScoreById(self:getFeatures())
  local fight_power = skillFightPower + self:getMaxHp() * World.cfg.hpPowerModifier + self:getSpeed() * World.cfg.speedPowerModifier + self:getPhysicalAtk() * World.cfg.pAtkPowerModifier + self:getSpecialAtk() * World.cfg.sAtkPowerModifier + self:getPhysicalDef() * World.cfg.pDefPowerModifier + self:getSpecialDef() * World.cfg.sDefPowerModifier
  return math.floor(fight_power + 0.5)
end

function Pokemon:getStarLevel()
  return self:getStar()
end

function Pokemon:getSkillStudyMap()
  -- ULTRA HACK: Allow learning any skill from the complete SkillConfig
  local allSkills = SkillConfig:getAllConfig()
  local map = {}
  for skillId, _ in pairs(allSkills) do
    map[tostring(skillId)] = true
  end
  -- Even skills already learned can be "re-learned" to swap slots easily
  return map
end

function Pokemon:getLevelMaxHp(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_hp * self:getCfg().level_hpMultiple
end

function Pokemon:getLevelSpeed(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_speed * self:getCfg().level_speedMultiple
end

function Pokemon:getLevelPhysicalAtk(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_pAtk * self:getCfg().level_pAtkMultiple
end

function Pokemon:getLevelPhysicalDef(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_pDef * self:getCfg().level_pDefMultiple
end

function Pokemon:getLevelSpecialAtk(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_sAtk * self:getCfg().level_sAtkMultiple
end

function Pokemon:getLevelSpecialDef(level)
  return PokemonConfig:getLevelConfig(level or self:getLevel()).total_sDef * self:getCfg().level_sDefMultiple
end

function Pokemon:getStarMaxHp(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_hp * self:getCfg().star_hpMultiple
end

function Pokemon:getStarSpeed(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_speed * self:getCfg().star_speedMultiple
end

function Pokemon:getStarPhysicalAtk(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_pAtk * self:getCfg().star_pAtkMultiple
end

function Pokemon:getStarPhysicalDef(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_pDef * self:getCfg().star_pDefMultiple
end

function Pokemon:getStarSpecialAtk(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_sAtk * self:getCfg().star_sAtkMultiple
end

function Pokemon:getStarSpecialDef(star)
  return PokemonConfig:getStarConfig(star or self:getStar()).total_sDef * self:getCfg().star_sDefMultiple
end

function Pokemon:getWakeMaxHp(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_hp * self:getCfg().wake_hpMultiple
end

function Pokemon:getWakeSpeed(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_speed * self:getCfg().wake_speedMultiple
end

function Pokemon:getWakePhysicalAtk(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_pAtk * self:getCfg().wake_pAtkMultiple
end

function Pokemon:getWakePhysicalDef(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_pDef * self:getCfg().wake_pDefMultiple
end

function Pokemon:getWakeSpecialAtk(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_sAtk * self:getCfg().wake_sAtkMultiple
end

function Pokemon:getWakeSpecialDef(wake)
  return PokemonConfig:getWakeConfig(wake or self:getWake()).total_sDef * self:getCfg().wake_sDefMultiple
end

function Pokemon:getName()
  if self:getValue("curName") ~= "" then
    return self:getValue("curName")
  end
  return self:getCfg().name
end

function Pokemon:setName(name)
  self:setValue("curName", name)
end

function Pokemon:getLevel()
  return self:getValue("level")
end

function Pokemon:setLevel(level)
  self:setValue("level", level)
end

function Pokemon:getStar()
  return self:getValue("star")
end

function Pokemon:setStar(star)
  self:setValue("star", star)
end

function Pokemon:getMaxWake()
  return self:getCfg().maxWake
end

function Pokemon:getWake()
  return self:getValue("wake")
end

function Pokemon:setWake(wake)
  self:setValue("wake", wake)
end

function Pokemon:getCurExp()
  return self:getValue("curExp")
end

function Pokemon:setCurExp(curExp)
  self:setValue("curExp", curExp)
end

function Pokemon:getSex()
  return self:getValue("sex")
end

function Pokemon:setSex(sex)
  self:setValue("sex", sex)
end

function Pokemon:getBallId()
  return self:getValue("ballId") or 0
end

function Pokemon:setBallId(ballId)
  self:setValue("ballId", ballId)
end

function Pokemon:getCurHp()
  return self:getValue("curHp")
end

function Pokemon:setCurHp(curHp)
  local maxHp = self:isFought() and self:getBattleMaxHp() or self:getMaxHp()
  if curHp > maxHp then
    curHp = maxHp
  end
  self:setValue("curHp", curHp)
end

function Pokemon:getAttrByType(attr_type)
  if attr_type == Define.POKEMON_ATTR_TYPE.Hp then
    return self:getMaxHp()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.Speed then
    return self:getSpeed()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PAtk then
    return self:getPhysicalAtk()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PDef then
    return self:getPhysicalDef()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SAtk then
    return self:getSpecialAtk()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SDef then
    return self:getSpecialDef()
  end
end

function Pokemon:getExtraAttrByType(attr_type)
  local passive_list = self:getPassiveSkillList()
  table.insert(passive_list, self:getFeatures())
  local fullNameMap = {
    [Define.POKEMON_ATTR_TYPE.Hp] = "myplugin/skill_life_bonus_buff",
    [Define.POKEMON_ATTR_TYPE.Speed] = "myplugin/skill_speed_buff",
    [Define.POKEMON_ATTR_TYPE.PAtk] = "myplugin/skill_physical_attack_buff",
    [Define.POKEMON_ATTR_TYPE.PDef] = "myplugin/skill_physical_def_buff",
    [Define.POKEMON_ATTR_TYPE.SAtk] = "myplugin/skill_spell_attack_buff",
    [Define.POKEMON_ATTR_TYPE.SDef] = "myplugin/skill_spell_def_buff"
  }
  local sumExtraAttr = 0
  local baseAttr = self:getAttrByType(attr_type)
  local skill_effect_list = SkillConfig:getSkillEffectList(passive_list)
  for _, skill_effect_id in pairs(skill_effect_list) do
    local skill_effect_config = SkillEffectConfig:getConfigById(skill_effect_id)
    if skill_effect_config.timing == 2 and skill_effect_config.effectFullname == fullNameMap[attr_type] then
      sumExtraAttr = sumExtraAttr + baseAttr * skill_effect_config.dcm + skill_effect_config.intger
    end
  end
  return math.floor(sumExtraAttr + 0.5)
end

function Pokemon:getHpBless()
  local jsonStr = self:getValue("hpBless")
  return Json.decode(jsonStr)
end

function Pokemon:setHpBless(hpBless)
  self:setValue("hpBless", Json.encode(hpBless))
end

function Pokemon:getSpeedBless()
  local jsonStr = self:getValue("speedBless")
  return Json.decode(jsonStr)
end

function Pokemon:setSpeedBless(speedBless)
  self:setValue("speedBless", Json.encode(speedBless))
end

function Pokemon:getPAtkBless()
  local jsonStr = self:getValue("pAtkBless")
  return Json.decode(jsonStr)
end

function Pokemon:setPAtkBless(pAtkBless)
  self:setValue("pAtkBless", Json.encode(pAtkBless))
end

function Pokemon:getSAtkBless()
  local jsonStr = self:getValue("sAtkBless")
  return Json.decode(jsonStr)
end

function Pokemon:setSAtkBless(sAtkBless)
  self:setValue("sAtkBless", Json.encode(sAtkBless))
end

function Pokemon:getPDefBless()
  local jsonStr = self:getValue("pDefBless")
  return Json.decode(jsonStr)
end

function Pokemon:setPDefBless(pDefBless)
  self:setValue("pDefBless", Json.encode(pDefBless))
end

function Pokemon:getSDefBless()
  local jsonStr = self:getValue("sDefBless")
  return Json.decode(jsonStr)
end

function Pokemon:setSDefBless(sDefBless)
  self:setValue("sDefBless", Json.encode(sDefBless))
end

function Pokemon:getBlessValue(attr_type)
  local bless_table = self:getBlessByType(attr_type)
  local totalValue = 0
  for bless_level, times in pairs(bless_table) do
    local config = BlessItemConfig:getConfigByTypeAndLevel(attr_type, bless_level)
    totalValue = totalValue + config.bless_value * times
  end
  return totalValue
end

function Pokemon:getBlessLimit(attr_type)
  local bless_rule = {}
  if attr_type == Define.POKEMON_ATTR_TYPE.Hp then
    bless_rule = self:getCfg().hp_bless_count
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.Speed then
    bless_rule = self:getCfg().speed_bless_count
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PAtk then
    bless_rule = self:getCfg().pAtk_bless_count
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PDef then
    bless_rule = self:getCfg().pDef_bless_count
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SAtk then
    bless_rule = self:getCfg().sAtk_bless_count
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SDef then
    bless_rule = self:getCfg().sDef_bless_count
  end
  local limit_count = 0
  for _, rule in pairs(bless_rule or {}) do
    local level = tonumber(rule[1])
    local count = tonumber(rule[2])
    if level > self:getLevel() then
      break
    end
    limit_count = count
  end
  return limit_count
end

function Pokemon:getBlessTimes(attr_type)
  local bless_table = self:getBlessByType(attr_type)
  local blessTimes = 0
  for _, times in pairs(bless_table) do
    blessTimes = blessTimes + times
  end
  return blessTimes
end

function Pokemon:getBlessByType(attr_type)
  if attr_type == Define.POKEMON_ATTR_TYPE.Hp then
    return self:getHpBless()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.Speed then
    return self:getSpeedBless()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PAtk then
    return self:getPAtkBless()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PDef then
    return self:getPDefBless()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SAtk then
    return self:getSAtkBless()
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SDef then
    return self:getSDefBless()
  end
end

function Pokemon:setBlessByType(attr_type, table_value)
  if attr_type == Define.POKEMON_ATTR_TYPE.Hp then
    self:setHpBless(table_value)
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.Speed then
    self:setSpeedBless(table_value)
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PAtk then
    self:setPAtkBless(table_value)
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.PDef then
    self:setPDefBless(table_value)
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SAtk then
    self:setSAtkBless(table_value)
  end
  if attr_type == Define.POKEMON_ATTR_TYPE.SDef then
    self:setSDefBless(table_value)
  end
end

function Pokemon:getHpMutate()
  return self:isMutated() and self:getCfg().mutateHp or 0
end

function Pokemon:getSpeedMutate()
  return self:isMutated() and self:getCfg().mutateSpeed or 0
end

function Pokemon:getPAtkMutate()
  return self:isMutated() and self:getCfg().mutatepAtk or 0
end

function Pokemon:getSAtkMutate()
  return self:isMutated() and self:getCfg().mutatesAtk or 0
end

function Pokemon:getPDefMutate()
  return self:isMutated() and self:getCfg().mutatepDef or 0
end

function Pokemon:getSDefMutate()
  return self:isMutated() and self:getCfg().mutatesDef or 0
end

function Pokemon:getCommonFeature()
  local features = PokemonConfig:getFeature(self:getCfgId())
  return features[1]
end

function Pokemon:getMutateFeature()
  local features = PokemonConfig:getFeature(self:getCfgId())
  return features[2]
end

function Pokemon:isMutated()
  return self:getValue("isMutated") == 1
end

function Pokemon:setMutate()
  self:setValue("isMutated", 1)
end

function Pokemon:getMutateItem()
  local mutateItem = self:getCfg().mutateItem
  return mutateItem
end

function Pokemon:getFeatures()
  if self:isMutated() then
    return self:getMutateFeature()
  end
  return self:getCommonFeature()
end

function Pokemon:getBuffList()
  local jsonStr = self:getValue("buffList")
  return Json.decode(jsonStr)
end

function Pokemon:setBuffList(buffList)
  self:setValue("buffList", Json.encode(buffList))
end

function Pokemon:getLongRoundEffectbuffList()
  local jsonStr = self:getValue("longRoundEffectbuffList")
  local buffList = Json.decode(jsonStr)
  for _, buff in pairs(buffList) do
    local cfg = setting:fetch("buff", buff.fullName)
    buff.buffCfg = cfg
  end
  return buffList
end

function Pokemon:setLongRoundEffectbuffList(buffList)
  local copyList = Lib.copy(buffList)
  for _, buff in pairs(copyList) do
    buff.fullName = buff.buffCfg.fullName
    buff.buffCfg = nil
  end
  self:setValue("longRoundEffectbuffList", Json.encode(copyList))
end

function Pokemon:setSkillList(skillList)
  self:setValue("skillList", Json.encode(skillList))
end

function Pokemon:getSkillList()
  local jsonStr = self:getValue("skillList")
  return Json.decode(jsonStr)
end

function Pokemon:getPassiveSkillList()
  local npc_config = self:getNpcCfg()
  if npc_config and npc_config.is_random_skill == 0 then
    return npc_config.passive_skill_list
  end
  return PokemonConfig:getUnlockPassiveSkill(self:getCfgId(), self:getWake())
end

function Pokemon:setStudySkillList(studySkillList)
  self:setValue("studySkillList", Json.encode(studySkillList))
end

function Pokemon:getStudySkillList()
  local jsonStr = self:getValue("studySkillList")
  return Json.decode(jsonStr)
end

function Pokemon:setStudySkillList(studySkillList)
  self:setValue("studySkillList", Json.encode(studySkillList))
end

function Pokemon:getStudySkillList()
  local jsonStr = self:getValue("studySkillList")
  return Json.decode(jsonStr)
end

function Pokemon:isFought()
  return self:getFoughtCount() > 0
end

function Pokemon:getFoughtCount()
  return self:getValue("foughtCount")
end

function Pokemon:setFoughtCount(count)
  self:setValue("foughtCount", count)
  if count == 0 then
    self:setCurHp(self:getCurHp())
  end
  Lib.logDebug("Pokemon setFoughtCount", tostring(self.objId), tostring(count))
end

function Pokemon:setRunaway(value)
  self.runaway = value
end

function Pokemon:isDead()
  return self:getCurHp() <= 0
end

function Pokemon:isFollowPet()
  return self:getValue("isFollowPet")
end

function Pokemon:setFollowPet(value)
  self:setValue("isFollowPet", value)
end

function Pokemon:getLockedValue()
  return self:getValue("isLocked")
end

function Pokemon:isLocked()
  return self:getValue("isLocked") == 1 and true or false
end

function Pokemon:setLocked(value)
  self:setValue("isLocked", value and 1 or 0)
end

function Pokemon:setValue(key, value)
  local keyRule = PokemonInfoKey[key]
  if not keyRule then
    Lib.logError("Pokemon:setValue key not exist,  key =", key)
    return false
  end
  local oldValue = self.attr[key]
  if value == oldValue then
    return false
  end
  self.attr[key] = value
  if AttributeKey[key] then
    local valueAddList = PokemonConfig:updateAttribute(self)
    if key == "level" and self:getObjId() ~= 0 then
      Lib.emitEvent(Event.EVENT_POKEMON_LEVEL_UP, self:getObjId(), valueAddList)
    end
  end
  if key == "cfgId" then
    self.cfg = nil
  end
  if key == "longRoundEffectbuffList" then
    Lib.emitEvent(Event.EVENT_ADD_EFFECT_DATA_CHANGE, self:getObjId() or 0)
  end
  LuaTimer:cancel(self.changeKey or 0)
  self.changeKey = LuaTimer:schedule(function()
    if self:getObjId() ~= 0 then
      Lib.emitEvent(Event.EVENT_POKEMON_DATA_CHANGE, self:getObjId())
    end
  end, 0)
  return true
end

function Pokemon:getValue(key)
  return self.attr[key]
end

function Pokemon:canUseDefaultSkill()
  local canUse = true
  for _, skill in pairs(self:getSkillList() or {}) do
    if skill.curTimes > 0 then
      canUse = false
      break
    end
  end
  return canUse
end

function Pokemon:useSkill(skillId)
  return true
end

function Pokemon:canEvolution()
  local evolutionWake = self:getCfg().evolutionWake
  return evolutionWake <= self:getWake() and self:getCfg().nextEvolutionId ~= 0
end

function Pokemon:setCanWakeRedPointShow(canWake, noSync)
  self:setValue("wakeRedPointShow", canWake, noSync)
end

function Pokemon:getCanWakeRedPointShow()
  return self:getValue("wakeRedPointShow")
end

function Pokemon:setCanStarUpRedShow(canStarUpRedShow, noSync)
  self:setValue("canStarUpRedShow", canStarUpRedShow, noSync)
end

function Pokemon:getCanStarUpRedShow()
  return self:getValue("canStarUpRedShow")
end

function Pokemon:setIsNewRedPointShow(isNew, noSync)
  self:setValue("newRedPointShow", isNew, noSync)
end

function Pokemon:getIsNewRedPointShow()
  return self:getValue("newRedPointShow")
end

function Pokemon:setCanLevelUpRedPointShow(value, noSync)
  self:setValue("canLevelUpRedPointShow", value, noSync)
end

function Pokemon:getCanLevelUpRedPointShow()
  return self:getValue("canLevelUpRedPointShow")
end

function Pokemon:setCanBlessRedPointShow(value, noSync)
  self:setValue("canBlessRedPointShow", value, noSync)
end

function Pokemon:getCanBlessRedPointShow()
  return self:getValue("canBlessRedPointShow")
end

function Pokemon:isHighQuality()
  return self:getQuality() == Define.POKEMON_QUALITY.MYTHICAL
end

function Pokemon:getClientInfo()
  local info = {}
  for key, keyRule in pairs(PokemonInfoKey) do
    if keyRule.toClient then
      info[key] = self.attr[key] or keyRule.default
    end
  end
  return info
end

function Pokemon:getDBInfo()
  local info = {}
  for key, keyRule in pairs(PokemonInfoKey) do
    if keyRule.saveDb then
      info[key] = self.attr[key] or keyRule.default
    end
  end
  return info
end

return Pokemon
