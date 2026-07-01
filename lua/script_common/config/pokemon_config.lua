local PokemonConfig = T(Config, "PokemonConfig")
local SkillConfig = T(Config, "SkillConfig")
local settings = {}
local levelSetting = {}
local starSetting = {}
local wakeSetting = {}
local allIds = {}

local function toTable(str)
  local data = Lib.splitString(str or "", "#")
  for key, childStr in pairs(data) do
    data[key] = Lib.splitString(childStr, ",")
    if #data[key] == 1 then
      data[key] = data[key][1]
    end
  end
  return data
end

local function initSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon.csv", 3)
  for _, vConfig in pairs(config) do
    local data = {}
    data.id = tonumber(vConfig.id) or 0
    data.bookId = tonumber(vConfig.bookId) or 0
    data.name = vConfig.name or ""
    data.fullName = vConfig.fullName or ""
    data.mutateFullName = vConfig.mutateFullName or ""
    data.icon = vConfig.icon or ""
    data.sexWeight = toTable(vConfig.sexWeight) or {}
    data.race = tonumber(vConfig.race) or 0
    data.hpBase = tonumber(vConfig.hpBase) or 0
    data.speedBase = tonumber(vConfig.speedBase) or 0
    data.pAtkBase = tonumber(vConfig.pAtkBase) or 0
    data.pDefBase = tonumber(vConfig.pDefBase) or 0
    data.sAtkBase = tonumber(vConfig.sAtkBase) or 0
    data.sDefBase = tonumber(vConfig.sDefBase) or 0
    local evolutionRule = toTable(vConfig.evolutionRule or "0#0")
    if #evolutionRule ~= 2 then
      evolutionRule = {0, 0}
    end
    data.preEvolutionId = 0
    data.nextEvolutionId = tonumber(evolutionRule[1])
    data.evolutionWake = tonumber(evolutionRule[2])
    data.maxWake = tonumber(vConfig.maxWake) or 0
    data.expMultiple = tonumber(vConfig.expMultiple) or 1
    data.catchProbability = tonumber(vConfig.catchProbability) or 1
    data.runawayProbability = tonumber(vConfig.runawayProbability) or 0
    data.uiScale = tonumber(vConfig.uiScale) or 1
    data.uiOffsetZ = tonumber(vConfig.uiOffsetZ) or 0
    data.uiOffsetY = tonumber(vConfig.uiOffsetY) or 0
    data.starLevel = tonumber(vConfig.starLevel) or 1
    data.intro = vConfig.intro or ""
    data.price = tonumber(vConfig.price) or 0
    data.mutateHp = math.floor(tonumber(vConfig.mutateHp) + 0.5) or 0
    data.mutateSpeed = math.floor(tonumber(vConfig.mutateSpeed) + 0.5) or 0
    data.mutatepAtk = math.floor(tonumber(vConfig.mutatepAtk) + 0.5) or 0
    data.mutatepDef = math.floor(tonumber(vConfig.mutatepDef) + 0.5) or 0
    data.mutatesAtk = math.floor(tonumber(vConfig.mutatesAtk) + 0.5) or 0
    data.mutatesDef = math.floor(tonumber(vConfig.mutatesDef) + 0.5) or 0
    data.mutateItem = toTable(vConfig.mutateCost) or {nil, nil}
    data.level_hpMultiple = tonumber(vConfig.level_hpMultiple) or 1
    data.level_speedMultiple = tonumber(vConfig.level_speedMultiple) or 1
    data.level_pAtkMultiple = tonumber(vConfig.level_pAtkMultiple) or 1
    data.level_pDefMultiple = tonumber(vConfig.level_pDefMultiple) or 1
    data.level_sAtkMultiple = tonumber(vConfig.level_sAtkMultiple) or 1
    data.level_sDefMultiple = tonumber(vConfig.level_sDefMultiple) or 1
    data.star_hpMultiple = tonumber(vConfig.star_hpMultiple) or 1
    data.star_speedMultiple = tonumber(vConfig.star_speedMultiple) or 1
    data.star_pAtkMultiple = tonumber(vConfig.star_pAtkMultiple) or 1
    data.star_pDefMultiple = tonumber(vConfig.star_pDefMultiple) or 1
    data.star_sAtkMultiple = tonumber(vConfig.star_sAtkMultiple) or 1
    data.star_sDefMultiple = tonumber(vConfig.star_sDefMultiple) or 1
    data.wake_hpMultiple = tonumber(vConfig.wake_hpMultiple) or 1
    data.wake_speedMultiple = tonumber(vConfig.wake_speedMultiple) or 1
    data.wake_pAtkMultiple = tonumber(vConfig.wake_pAtkMultiple) or 1
    data.wake_pDefMultiple = tonumber(vConfig.wake_pDefMultiple) or 1
    data.wake_sAtkMultiple = tonumber(vConfig.wake_sAtkMultiple) or 1
    data.wake_sDefMultiple = tonumber(vConfig.wake_sDefMultiple) or 1
    data.quality = tonumber(vConfig.quality) or 1
    settings[vConfig.id] = data
    if data.bookId ~= nil and data.bookId ~= 0 then
      allIds[#allIds + 1] = data.id
    end
  end
  for _, cur_config in pairs(settings) do
    if cur_config.nextEvolutionId ~= 0 then
      local next_config = PokemonConfig:getConfigById(cur_config.nextEvolutionId)
      if next_config then
        next_config.preEvolutionId = cur_config.id
      end
    end
  end
end

local function sumTotalAttr(configs, cur_key)
  local cur_config = configs[tostring(cur_key)]
  if not cur_config then
    return {
      total_hp = 0,
      total_speed = 0,
      total_pAtk = 0,
      total_pDef = 0,
      total_sAtk = 0,
      total_sDef = 0
    }
  end
  local last_config = sumTotalAttr(configs, cur_key - 1)
  cur_config.total_hp = cur_config.hp + last_config.total_hp
  cur_config.total_speed = cur_config.speed + last_config.total_speed
  cur_config.total_pAtk = cur_config.pAtk + last_config.total_pAtk
  cur_config.total_pDef = cur_config.pDef + last_config.total_pDef
  cur_config.total_sAtk = cur_config.sAtk + last_config.total_sAtk
  cur_config.total_sDef = cur_config.sDef + last_config.total_sDef
  return cur_config
end

local function initLevelSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_level.csv", 3)
  local maxLevel = 0
  for _, vConfig in pairs(config) do
    local data = {}
    data.level = tonumber(vConfig.level)
    data.exp = tonumber(vConfig.exp) or 0
    data.hp = tonumber(vConfig.hp) or 0
    data.speed = tonumber(vConfig.speed) or 0
    data.pAtk = tonumber(vConfig.pAtk) or 0
    data.pDef = tonumber(vConfig.pDef) or 0
    data.sAtk = tonumber(vConfig.sAtk) or 0
    data.sDef = tonumber(vConfig.sDef) or 0
    maxLevel = math.max(maxLevel, data.level)
    levelSetting[vConfig.level] = data
  end
  sumTotalAttr(levelSetting, maxLevel)
end

local function initStarSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_star.csv", 3)
  local maxStar = 0
  for _, vConfig in pairs(config) do
    local data = {}
    data.star = tonumber(vConfig.star)
    data.levelMax = tonumber(vConfig.levelMax) or 0
    data.starUpCost = toTable(vConfig.starUpCost) or {0, 0}
    data.needSameRace = tonumber(vConfig.needSameRace) or 1
    data.hp = tonumber(vConfig.hp) or 0
    data.speed = tonumber(vConfig.speed) or 0
    data.pAtk = tonumber(vConfig.pAtk) or 0
    data.pDef = tonumber(vConfig.pDef) or 0
    data.sAtk = tonumber(vConfig.sAtk) or 0
    data.sDef = tonumber(vConfig.sDef) or 0
    maxStar = math.max(maxStar, data.star)
    starSetting[vConfig.star] = data
  end
  sumTotalAttr(starSetting, maxStar)
end

local function initWakeSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_wake.csv", 3)
  local maxWake = 0
  for _, vConfig in pairs(config) do
    local data = {}
    data.wake = tonumber(vConfig.wake)
    data.wakeUpCost = tonumber(vConfig.wakeUpCost)
    data.hp = tonumber(vConfig.hp) or 0
    data.speed = tonumber(vConfig.speed) or 0
    data.pAtk = tonumber(vConfig.pAtk) or 0
    data.pDef = tonumber(vConfig.pDef) or 0
    data.sAtk = tonumber(vConfig.sAtk) or 0
    data.sDef = tonumber(vConfig.sDef) or 0
    data.skillId = tonumber(vConfig.sSkillId) or 0
    maxWake = math.max(maxWake, data.wake)
    wakeSetting[vConfig.wake] = data
  end
  sumTotalAttr(wakeSetting, maxWake)
end

local function initStudySetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_study.csv", 3)
  for _, vConfig in pairs(config) do
    local data = PokemonConfig:getConfigById(vConfig.id)
    if data then
      local studyActiveRule = {}
      for _, rule in pairs(toTable(vConfig.studyActiveRule) or {}) do
        if #rule == 2 then
          studyActiveRule[rule[1]] = studyActiveRule[rule[1]] or {}
          table.insert(studyActiveRule[rule[1]], rule[2])
        end
      end
      data.studyActiveRule = studyActiveRule
      data.activeRule = toTable(vConfig.activeRule) or {}
      data.passiveRule = toTable(vConfig.passiveRule) or {}
      data.featuresRule = toTable(vConfig.featuresRule) or {}
    end
  end
end

local function initBlessSetting()
  local config = Lib.read_csv_file(Root.Instance():getGamePath() .. "config/pokemon_bless.csv", 3)
  for _, vConfig in pairs(config) do
    local data = PokemonConfig:getConfigById(vConfig.id)
    if data then
      data.hp_bless_count = toTable(vConfig.hp_bless_count) or {}
      data.speed_bless_count = toTable(vConfig.speed_bless_count) or {}
      data.pAtk_bless_count = toTable(vConfig.pAtk_bless_count) or {}
      data.pDef_bless_count = toTable(vConfig.pDef_bless_count) or {}
      data.sAtk_bless_count = toTable(vConfig.sAtk_bless_count) or {}
      data.sDef_bless_count = toTable(vConfig.sDef_bless_count) or {}
    end
  end
end

local function randomByWeight(weightTable)
  local sumWeight = 0
  for _, data in pairs(weightTable) do
    if #data == 2 then
      sumWeight = sumWeight + tonumber(data[2])
    end
  end
  local randomNum = math.random(1, sumWeight)
  for _, data in pairs(weightTable) do
    if #data == 2 then
      if randomNum <= tonumber(data[2]) then
        return data[1]
      end
      randomNum = randomNum - tonumber(data[2])
    end
  end
end

function PokemonConfig:init()
  initSetting()
  initWakeSetting()
  initLevelSetting()
  initStarSetting()
  initStudySetting()
  initBlessSetting()
end

function PokemonConfig:updateAttribute(pokemon)
  local petInfo = pokemon.attr
  local cfg = self:getConfigById(petInfo.cfgId)
  local oldBattleAttr = {
    maxHp = petInfo.maxHp or 0,
    speed = petInfo.speed or 0,
    pAtk = petInfo.pAtk or 0,
    pDef = petInfo.pDef or 0,
    sAtk = petInfo.sAtk or 0,
    sDef = petInfo.sDef or 0
  }
  petInfo.maxHp = pokemon:getLevelMaxHp() + pokemon:getStarMaxHp() + pokemon:getWakeMaxHp()
  petInfo.speed = pokemon:getLevelSpeed() + pokemon:getStarSpeed() + pokemon:getWakeSpeed()
  petInfo.pAtk = pokemon:getLevelPhysicalAtk() + pokemon:getStarPhysicalAtk() + pokemon:getWakePhysicalAtk()
  petInfo.pDef = pokemon:getLevelPhysicalDef() + pokemon:getStarPhysicalDef() + pokemon:getWakePhysicalDef()
  petInfo.sAtk = pokemon:getLevelSpecialAtk() + pokemon:getStarSpecialAtk() + pokemon:getWakeSpecialAtk()
  petInfo.sDef = pokemon:getLevelSpecialDef() + pokemon:getStarSpecialDef() + pokemon:getWakeSpecialDef()
  petInfo.maxHp = math.floor(petInfo.maxHp + 0.5)
  petInfo.speed = math.floor(petInfo.speed + 0.5)
  petInfo.pAtk = math.floor(petInfo.pAtk + 0.5)
  petInfo.pDef = math.floor(petInfo.pDef + 0.5)
  petInfo.sAtk = math.floor(petInfo.sAtk + 0.5)
  petInfo.sDef = math.floor(petInfo.sDef + 0.5)
  return {
    add_maxHp = petInfo.maxHp - oldBattleAttr.maxHp,
    add_speed = petInfo.speed - oldBattleAttr.speed,
    add_pAtk = petInfo.pAtk - oldBattleAttr.pAtk,
    add_pDef = petInfo.pDef - oldBattleAttr.pDef,
    add_sAtk = petInfo.sAtk - oldBattleAttr.sAtk,
    add_sDef = petInfo.sDef - oldBattleAttr.sDef
  }
end

function PokemonConfig:getFeature(pokemonId)
  local cfg = self:getConfigById(pokemonId)
  return cfg.featuresRule or {}
end

function PokemonConfig:getStudyActiveSkill(pokemonId, level)
  local cfg = self:getConfigById(pokemonId)
  local studyActiveRule = cfg.studyActiveRule
  local skillList = {}
  for _, skillId in pairs(studyActiveRule[tostring(level)] or {}) do
    local skillConfig = SkillConfig:getConfigById(skillId)
    if skillConfig then
      table.insert(skillList, {
        skillId = skillId,
        curTimes = skillConfig.max_number,
        maxTimes = nil
      })
    else
      Lib.logError("Error:can not found skillEffectCfg, effectId =" .. skillId .. ",please check skill.cvs")
    end
  end
  return skillList
end

function PokemonConfig:getUnlockActiveSkill(pokemonId, level)
  local skillList = {}
  for cur_level = 1, level do
    for _, skill in pairs(PokemonConfig:getStudyActiveSkill(pokemonId, cur_level)) do
      table.insert(skillList, skill)
    end
  end
  return skillList
end

function PokemonConfig:getUnlockPassiveSkill(pokemonId, wake)
  local cfg = self:getConfigById(pokemonId)
  local passiveRule = cfg.passiveRule
  local skillList = {}
  for _, skillTable in pairs(passiveRule) do
    local skillId = tonumber(skillTable[1])
    local unlockWake = tonumber(skillTable[2])
    if wake >= unlockWake then
      table.insert(skillList, skillId)
    end
  end
  return skillList
end

function PokemonConfig:getConfigById(pokemonId)
  if not settings[tostring(pokemonId)] then
    print(debug.traceback())
    Lib.logError("not pokemon pokemon config , pokemonId is : " .. pokemonId or 0)
  end
  return settings[tostring(pokemonId)]
end

function PokemonConfig:getMaxExp(pokemonId, level)
  local cfg = self:getConfigById(pokemonId)
  local curMaxExp = levelSetting[tostring(level)] and levelSetting[tostring(level)].exp or 99999
  return math.floor(curMaxExp * cfg.expMultiple + 0.5)
end

function PokemonConfig:getLevelConfig(level)
  if not levelSetting[tostring(level)] then
    Lib.logError("not pokemon level config , level is : " .. level)
  end
  return levelSetting[tostring(level)]
end

function PokemonConfig:getStarConfig(star)
  if not starSetting[tostring(star)] then
    Lib.logError("not pokemon star config , star is : " .. star)
  end
  return starSetting[tostring(star)]
end

function PokemonConfig:getWakeConfig(wake)
  if not wakeSetting[tostring(wake)] then
    Lib.logError("not pokemon wake config , wake is : " .. wake)
  end
  return wakeSetting[tostring(wake)]
end

function PokemonConfig:getAllConfig()
  return settings
end

function PokemonConfig:isSamePokemon(firstCfgId, secondCfgId)
  local firstEvolutionList = self:getEvolutionList(firstCfgId)
  local secondEvolutionList = self:getEvolutionList(secondCfgId)
  return firstEvolutionList[#firstEvolutionList] == secondEvolutionList[#secondEvolutionList]
end

function PokemonConfig:checkMaterial(cur_pokemon, material)
  local star_config = PokemonConfig:getStarConfig(cur_pokemon:getStar())
  local costMap = star_config.starUpCost
  if (cur_pokemon:getRace() == material:getRace() or cur_pokemon:getRace() == 5 or cur_pokemon:getRace() == 6 or star_config.needSameRace == 0) and material:getStar() == tonumber(costMap[2]) and cur_pokemon:getObjId() ~= material:getObjId() then
    return true
  end
  return false
end

function PokemonConfig:getEvolutionList(pokemonId)
  local first_config = PokemonConfig:getConfigById(pokemonId)
  while first_config.preEvolutionId ~= 0 do
    first_config = PokemonConfig:getConfigById(first_config.preEvolutionId)
  end
  local cur_config = first_config
  local evolutionList = {cur_config}
  while cur_config.nextEvolutionId ~= 0 do
    cur_config = PokemonConfig:getConfigById(cur_config.nextEvolutionId)
    table.insert(evolutionList, cur_config)
  end
  return evolutionList
end

function PokemonConfig:getQualityFrame(pokemonId)
  local qualityIconFrame = {
    "set:pokemon_pet_frame.json image:img_0_frame_blue",
    "set:pokemon_pet_frame.json image:img_0_frame_purple",
    "set:pokemon_pet_frame.json image:img_0_frame_orange"
  }
  local config = self:getConfigById(pokemonId)
  return qualityIconFrame[config.quality]
end

function PokemonConfig:getColorByQuality(quality)
  local NameColor = {
    [Define.POKEMON_QUALITY.EPIC] = "\226\150\162FF3992FB",
    [Define.POKEMON_QUALITY.LEGENDARY] = "\226\150\162FFC100FA",
    [Define.POKEMON_QUALITY.MYTHICAL] = "\226\150\162FFFF7C26"
  }
  return NameColor[quality]
end

if World.isClient then
  function PokemonConfig:getPokemonName(pokemonId, curName, noColor)
    local pokemon_config = self:getConfigById(pokemonId)
    
    local colorStr = self:getColorByQuality(pokemon_config.quality)
    if noColor then
      colorStr = ""
    end
    curName = curName or ""
    if curName ~= "" then
      return colorStr .. curName
    end
    return colorStr .. Lang:toText(pokemon_config.name)
  end
end

local function isInTeam(packetPokemon, battlePokemonList)
  for _, battlePokemon in pairs(battlePokemonList) do
    if battlePokemon:getObjId() == packetPokemon:getObjId() then
      return true
    end
  end
end

function PokemonConfig:checkCanRise(pokemon, packetPokemonList, battlePokemonList)
  local wake_config = self:getWakeConfig(pokemon:getWake())
  local costNum = wake_config.wakeUpCost
  for _, packetPokemon in pairs(packetPokemonList) do
    if not isInTeam(packetPokemon, battlePokemonList) and pokemon:getWake() < pokemon:getCfg().maxWake and pokemon:getObjId() ~= packetPokemon:getObjId() and self:isSamePokemon(pokemon:getCfgId(), packetPokemon:getCfgId()) and not packetPokemon:isLocked() then
      costNum = costNum - 1
      if costNum <= 0 then
        return true
      end
    end
  end
  return false
end

function PokemonConfig:getAllIds()
  return allIds
end

PokemonConfig:init()
return PokemonConfig
