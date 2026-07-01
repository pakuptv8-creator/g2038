local PokemonServer = require("script_common.pokemon.pokemon")
local uuid = require("common.uuid")
local PokemonConfig = T(Config, "PokemonConfig")
local SkillConfig = T(Config, "SkillConfig")
local LuaTimer = T(Lib, "LuaTimer")
local NPCPokemonConfig = T(Config, "NPCPokemonConfig")
local PokemonInfoKey = PokemonServer.getPokemonInfoKey()

local function initPokemonInfo(info)
  info = info or {}
  local new_info = {}
  for key, infoRule in pairs(PokemonInfoKey) do
    new_info[key] = info[key] or infoRule.default
  end
  return new_info
end

local function levelUp(self)
  Lib.logDebug("Pokemon:levelUp curLevel = ", self:getLevel())
  self:setLevel(self:getLevel() + 1)
  self:setCurExp(0)
  self:recoveryAll()
  local studySkillList = PokemonConfig:getStudyActiveSkill(self:getCfgId(), self:getLevel())
  for _, studySkill in pairs(studySkillList) do
    self:addStudySkill(studySkill)
  end
end

function PokemonServer.randomCreate(pokemonId, level, star)
  level = level or 1
  local info = initPokemonInfo({cfgId = pokemonId, level = level})
  local newPokemon = PokemonServer.new(info, true)
  local newStar = newPokemon:getCfg().starLevel
  if star and 0 < star then
    newStar = star
  end
  newPokemon:setStar(newStar)
  newPokemon:reSetSkillList()
  newPokemon:recoveryAll()
  return newPokemon
end

function PokemonServer.npcCreate(npcId, strength, playerLevel)
  Lib.logDebug("npcCreate id = ", npcId)
  Lib.logDebug("npcCreate strength = ", strength)
  Lib.logDebug("npcCreate playerLevel = ", playerLevel)
  local npc_pokemon_config = NPCPokemonConfig:getPokemonById(npcId)
  Lib.logDebug("npc_pokemon_config = ", Lib.v2s(npc_pokemon_config))
  local level = 0
  if strength == -1 then
    level = npc_pokemon_config.level
  else
    level = playerLevel + strength
  end
  Lib.logDebug("npcCreate level = ", level)
  local pokemonId = npc_pokemon_config.pokemon_id
  local info = initPokemonInfo({cfgId = pokemonId, level = level})
  local newPokemon = PokemonServer.new(info, true)
  newPokemon:setValue("npcCfgId", npcId)
  local is_random_skill = npc_pokemon_config.is_random_skill
  if is_random_skill == 1 then
    newPokemon:reSetSkillList()
  elseif is_random_skill == 0 then
    local skillList = {}
    for i = 1, #npc_pokemon_config.active_skill_list do
      local skillId = npc_pokemon_config.active_skill_list[i]
      local skill_config = SkillConfig:getConfigById(skillId)
      table.insert(skillList, {
        skillId = skillId,
        curTimes = skill_config.max_number,
        maxTimes = nil
      })
    end
    newPokemon:setSkillList(skillList)
  end
  if npc_pokemon_config.npc_star ~= 0 then
    newPokemon:setStar(npc_pokemon_config.npc_star)
  end
  if npc_pokemon_config.npc_wake ~= 0 then
    for i = 1, npc_pokemon_config.npc_wake do
      Lib.logDebug("npc pokemon wakeup")
      newPokemon:wakeUp()
    end
  end
  newPokemon:recoveryAll()
  return newPokemon
end

local common_ctor = PokemonServer.ctor

function PokemonServer:ctor(info, isNew)
  common_ctor(self, initPokemonInfo(info))
  self.subscribeList = {}
  if not self:getUid() then
    self:setValue("uid", uuid(), true)
  end
  if isNew then
    self.traceback = debug.traceback()
    self.createTime = os.time()
  end
end

local common_setMasterId = PokemonServer.setMasterId

function PokemonServer:setMasterId(userId)
  common_setMasterId(self, userId)
  self.traceback = nil
  self.createTime = nil
end

function PokemonServer:addExp(exp, player)
  local master = Game.GetPlayerByUserId(self:getMasterId())
  local maxLevel = math.min(master:getPlayerLevel(), PokemonConfig:getStarConfig(self:getStar()).levelMax)
  local maxExp = self:getMaxExp()
  local curExp = self:getCurExp()
  if maxExp == 0 then
    return exp
  end
  if maxExp <= curExp + exp then
    local extraExp = exp + curExp - maxExp
    if maxLevel <= self:getLevel() then
      self:setCurExp(maxExp)
      return extraExp
    end
    levelUp(self)
    if player then
      player:pokemonNewDesign(self, Define.newDesignEventKey.LEVEL_UP, "level", self:getLevel() - 1, self:getLevel())
      player:sortPokemonList()
      player:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.PET_LEVEL_UP, self:getLevel())
    end
    return self:addExp(extraExp, player)
  else
    self:setCurExp(math.floor(curExp + exp + 0.5))
    return 0
  end
end

function PokemonServer:evolution()
  if not self:canEvolution() then
    return false
  end
  local oldName = self:getCfg().name
  local old_cfgId = self:getCfgId()
  local nextEvolutionId = self:getCfg().nextEvolutionId
  if not PokemonConfig:getConfigById(nextEvolutionId) then
    Lib.logError("Pokemon:evolution nextEvolutionId not exist,  nextEvolutionId =", nextEvolutionId)
    return
  end
  self:setValue("cfgId", nextEvolutionId)
  self:recoveryAll()
  local master = Game.GetPlayerByUserId(self:getMasterId())
  if master and master:isValid() then
    master:sendPacket({
      pid = "showEvolution",
      cfgId = old_cfgId
    })
    master:addPokemonBook(self:getCfgId())
    master:addBuff("myplugin/bgm_buff_revolution", 40)
    local curFollowPetId = tostring(master:getCurFollowPetId())
    if curFollowPetId ~= "0" and curFollowPetId == self:getObjId() then
      master:removeFollowPetEntity(true, curFollowPetId)
      master:createFollowPetEntity(self:getCfgFullName(), self:getObjId())
      master:setCurFollowPetId(self:getObjId())
      master:setFollowPokemon(self:getObjId())
    end
    local skillList = self:getPassiveSkillList()
    local tipsInfo = {
      tipType = Define.WORLD_TIP_TYPE.EVOLVE,
      playerName = master.name,
      mapIdName = "",
      quality = self:getQuality(),
      pkmName = self:getCfg().name,
      oldName = oldName,
      skillName = "",
      growthSCount = 0,
      ownerName = "",
      starLevel = self:getStarLevel(),
      syntheticNum = skillList and #skillList or 0
    }
    master:sendSpecialWorldCommonTips(tipsInfo)
  end
  return true
end

function PokemonServer:reSetSkillList()
  for level = 1, self:getLevel() do
    local studySkillList = PokemonConfig:getStudyActiveSkill(self:getCfgId(), level)
    for _, studySkill in pairs(studySkillList) do
      self:addStudySkill(studySkill)
    end
  end
  local allSkillList = self:getStudySkillList()
  for pos = 1, 4 do
    if #allSkillList == 0 then
      break
    end
    local randomIndex = math.random(1, #allSkillList)
    local skill = table.remove(allSkillList, randomIndex)
    self:studySkill(skill.skillId, pos)
  end
  self:setStudySkillList({})
end

function PokemonServer:addStudySkill(studySkill)
  local studySkillList = self:getStudySkillList()
  for _, skill in pairs(self:getSkillList()) do
    if tostring(skill.skillId) == tostring(studySkill.skillId) then
      return false
    end
  end
  for _, skill in pairs(studySkillList) do
    if tostring(skill.skillId) == tostring(studySkill.skillId) then
      return false
    end
  end
  table.insert(studySkillList, studySkill)
  self:setStudySkillList(studySkillList)
  return true
end

function PokemonServer:removeStudySkill(skillId)
  local studySkillList = self:getStudySkillList()
  for index, skill in pairs(studySkillList) do
    if tostring(skill.skillId) == tostring(skillId) then
      table.remove(studySkillList, index)
      self:setStudySkillList(studySkillList)
      return skill
    end
  end
end

function PokemonServer:studySkill(skillId, pos)
  local skillList = self:getSkillList()
  if not pos or pos > #skillList + 1 then
    pos = #skillList + 1
  end
  if 4 < pos then
    return false
  end
  local skill = self:removeStudySkill(skillId)
  if not skill then
    return false
  end
  if skillList[pos] then
  else
  end
  skillList[pos] = skill
  self:setSkillList(skillList)
  return true
end

function PokemonServer:cleanSkillAttributeBuff(effectName)
  local buffList = self:getBuffList()
  for _, fullName in pairs(Define.SKILL_ATTRIBUTE_BUFF or {}) do
    buffList[fullName] = nil
  end
  self:setBuffList(buffList)
end

function PokemonServer:lock(value)
  self:setLocked(value)
end

function PokemonServer:starUp()
  self:setStar(self:getStar() + 1)
  self:recoveryAll()
end

function PokemonServer:wakeUp()
  local curWake = self:getWake()
  local newWake = curWake + 1
  if newWake <= self:getMaxWake() then
    self:setWake(newWake)
    self:recoveryAll()
    self:evolution()
    local master = Game.GetPlayerByUserId(self:getMasterId())
    if master and master:isValid() and master.isPlayer then
      local curFollowPetId = tostring(master:getCurFollowPetId())
      if curFollowPetId ~= "0" and curFollowPetId == self:getObjId() then
        local entity = master:getFollowPetEntity()
        if entity and entity:isValid() and entity:cfg() and entity:cfg().wakeEffect then
          local tbWakeEffect = entity:cfg().wakeEffect
          for i = 1, #tbWakeEffect do
            if i == newWake then
              if tbWakeEffect[newWake] then
                entity:addBuff(tbWakeEffect[newWake])
              end
            else
              entity:removeTypeBuff("fullName", tbWakeEffect[i])
            end
          end
        end
      end
    end
  end
end

function PokemonServer:mutate()
  self:setMutate()
  self:recoveryAll()
end

function PokemonServer:addBless(attr_type, bless_level, times)
  times = times or 1
  local bless_table = self:getBlessByType(attr_type)
  local hasUseTimes = bless_table[tostring(bless_level)] or 0
  bless_table[tostring(bless_level)] = hasUseTimes + times
  self:setBlessByType(attr_type, bless_table)
end

function PokemonServer:removeBless(attr_type, bless_level, times)
  print("removeBless", attr_type, bless_level, times)
  local bless_table = self:getBlessByType(attr_type)
  local hasUseTimes = bless_table[tostring(bless_level)] or 0
  if times < hasUseTimes then
    bless_table[tostring(bless_level)] = hasUseTimes - times
  else
    bless_table[tostring(bless_level)] = nil
  end
  self:setBlessByType(attr_type, bless_table)
end

function PokemonServer:recoveryAll()
  self:recoveryHp()
  local buffList = self:getLongRoundEffectbuffList()
  for key, cfg in pairs(buffList or {}) do
    if cfg.abnormalType > 0 then
      buffList[key] = nil
    end
  end
  self:setLongRoundEffectbuffList(buffList)
  self:recoverySkill()
end

function PokemonServer:recoveryHp()
  self:setCurHp(self:getMaxHp())
end

function PokemonServer:recoverySkill(skillId, addTimes)
  local skillList = self:getSkillList()
  for _, skill in pairs(skillList) do
    local skillConfig = SkillConfig:getConfigById(skill.skillId)
    if skillConfig then
      local maxTimes = skill.maxTimes or skillConfig.max_number
      local curTimes = skill.curTimes
      if addTimes and 0 < addTimes then
        curTimes = curTimes + addTimes
      end
      if skillId then
        if skill.skillId == skillId then
          if addTimes and 0 < addTimes and maxTimes >= curTimes then
            skill.curTimes = curTimes
          else
            skill.curTimes = maxTimes
          end
        end
      elseif addTimes and 0 < addTimes and maxTimes >= curTimes then
        skill.curTimes = curTimes
      else
        skill.curTimes = maxTimes
      end
    end
  end
  self:setSkillList(skillList)
end

function PokemonServer:studySkillByItem(skillId, pos)
  local skill_config = SkillConfig:getConfigById(skillId) or {}
  self:addStudySkill({
    skillId = skillId,
    curTimes = skill_config.max_number
  })
  if not self:studySkill(skillId) then
    self:studySkill(skillId, pos)
  end
end

function PokemonServer:syncToClient()
  for key, keyRule in pairs(PokemonInfoKey) do
    if keyRule.toClient then
      self:setValue(key, self:getValue(key))
    end
  end
end

function PokemonServer:putPlayer(userId)
  if not self.subscribeList[userId] then
    self.subscribeList[userId] = 1
    return true
  end
  return false
end

function PokemonServer:removePlayer(userId)
  local packet = {
    pid = "PokemonRemove",
    objId = self.objId
  }
  local player = Game.GetPlayerByUserId(userId)
  if player then
    player:sendPacket(packet)
  end
  self.subscribeList[userId] = nil
end

function PokemonServer:removeAllPlayer()
  for userId, _ in pairs(self.subscribeList) do
    self:removePlayer(userId)
  end
end

function PokemonServer:getEntity()
  return self.entity
end

local common_setValue = PokemonServer.setValue

function PokemonServer:setValue(key, value, noSync)
  local success = common_setValue(self, key, value)
  if not success then
    return
  end
  if noSync then
    return
  end
  local packet = {
    pid = "PokemonValue",
    key = key,
    value = value,
    objId = self.objId
  }
  for userId, _ in pairs(self.subscribeList) do
    local player = Game.GetPlayerByUserId(userId)
    if player then
      player:sendPacket(packet)
    end
  end
end

function PokemonServer:useCureItem(item, skillId)
  if not item then
    return
  end
  local cfg = item:cfg()
  if not cfg then
    return
  end
  if not cfg.cureType and type(cfg.cureType) ~= "table" then
    return
  end
  local maxHp = self:isFought() and self:getBattleMaxHp() or self:getMaxHp()
  local curHp = self:getCurHp()
  for _, _type in pairs(cfg.cureType) do
    if _type == Define.CURE_TYPE.LIFE and curHp == 0 then
      local dose = cfg.dose
      if dose > math.floor(dose) or dose == 1 then
        dose = maxHp * dose
      end
      self:setCurHp(dose)
    elseif _type == Define.CURE_TYPE.HP and curHp ~= 0 then
      local dose = cfg.dose
      if dose > math.floor(dose) or dose == 1 then
        dose = maxHp * dose
      end
      self:setCurHp(math.floor(curHp + dose))
    end
    if _type == Define.CURE_TYPE.DBUFF then
      local buffList = self:getLongRoundEffectbuffList()
      if cfg.deBuffFullName then
        if cfg.deBuffFullName == 0 then
          for key, _cfg in pairs(buffList or {}) do
            if 0 < _cfg.abnormalType then
              buffList[key] = nil
            end
          end
        else
          for key, _cfg in pairs(buffList or {}) do
            if _cfg.abnormalType == cfg.deBuffFullName then
              buffList[key] = nil
            end
          end
        end
        self:setLongRoundEffectbuffList(buffList)
      end
    end
    if _type == Define.CURE_TYPE.PP then
      if cfg.ppTarget == Define.CURE_PP_TYPE.ONCE then
        self:recoverySkill(skillId, cfg.dose)
      elseif cfg.ppTarget == Define.CURE_PP_TYPE.ALL then
        self:recoverySkill(false, cfg.dose)
      end
    end
  end
end

function PokemonServer:onDestroy()
  Lib.emitEvent(Event.EVENT_POKEMON_DESTROY, self:getObjId())
end

return PokemonServer
