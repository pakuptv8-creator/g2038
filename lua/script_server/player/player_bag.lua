local PokemonManager = require("script_server.pokemon.pokemon_manager")
local setting = require("common.setting")
local SkillConfig = T(Config, "SkillConfig")
local BlessItemConfig = T(Config, "BlessItemConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local Player = _ENV.Player

function Player:determineBackpackCapacity(items)
  local my_tray = self:tray():fetch_tray(1)
  local needCapacity = {}
  local engagedPosition = {}
  for fullName, count in pairs(items) do
    needCapacity[fullName] = count
    for i = 1, my_tray:capacity() do
      if not engagedPosition[i] then
        local item = my_tray:fetch_item(i)
        if not item then
          local cfg = setting:fetch("item", fullName)
          local num = needCapacity[fullName] - cfg.stack_count_max
          needCapacity[fullName] = num
          engagedPosition[i] = true
          if num <= 0 then
            needCapacity[fullName] = 0
            break
          end
        elseif item:full_name() == fullName then
          local vacancy = item:stack_count_max() - item:stack_count()
          if vacancy >= needCapacity[fullName] then
            needCapacity[fullName] = 0
            engagedPosition[i] = true
            break
          else
            if 0 < vacancy then
              needCapacity[fullName] = needCapacity[fullName] - vacancy
            end
            engagedPosition[i] = true
          end
        end
      end
    end
  end
  local residue = 0
  for _, count in pairs(needCapacity) do
    residue = residue + count
  end
  if residue == 0 then
    return true
  end
  return false
end

function Player:inspectBagItemByItemId(itemId)
  local my_tray = self:tray():fetch_tray(1)
  for slot, item in pairs(my_tray._slots or {}) do
    local cfg = item:cfg()
    if cfg and cfg.itemId == itemId then
      return item, slot
    end
  end
  return false
end

function Player:inspectBagItemByFullName(fullName)
  local my_tray = self:tray():fetch_tray(1)
  for slot, item in pairs(my_tray._slots or {}) do
    local full_name = item:full_name()
    if full_name == fullName then
      return item, slot
    end
  end
  return false
end

function Player:useBagItem(slot, fullName)
  Lib.logDebug("useBagItem fullName = ", fullName)
  self:updateTaskStatus(Define.TASK_TYPE.ITEM_USE, 1, fullName, 1)
  return self:tray():use_item(1, slot)
end

function Player:useBagItemByFullName(full_name, count, check, mglichst, proc, reason, related)
  self:updateTaskStatus(Define.TASK_TYPE.ITEM_USE, 1, full_name, 1)
  self:tray():remove_item(full_name, count, check, mglichst, proc, reason, related)
end

function Player:obtainItemsByFullName(fullName, count, obtainWays)
  if not self:tray():add_item(fullName, count, nil, true) then
    return false
  end
  local cfg = setting:fetch("item", fullName)
  if tonumber(cfg.itemType) == Define.ITEM_TYPE.EXP then
    local canLevelUpPokemonList = self:getCanLevelUpList(fullName, count)
    self:sendPacket({
      pid = "updateExpItemDo",
      indexList = canLevelUpPokemonList
    })
  elseif tonumber(cfg.itemType) == Define.ITEM_TYPE.Bless then
    local blessCfg = BlessItemConfig:getConfigByFullName(fullName)
    local canBlessPokemonIndexList = {}
    local battlePokemonList = self:getBattlePokemon()
    for index, pokemon in pairs(battlePokemonList) do
      if pokemon:getBlessTimes(blessCfg.bless_type) < pokemon:getBlessLimit(blessCfg.bless_type) then
        table.insert(canBlessPokemonIndexList, index)
      end
    end
    self:sendPacket({
      pid = "gainBlessItemDo",
      canBlessPokemonIndexList = canBlessPokemonIndexList
    })
  end
  return self:data("tray"):add_item(fullName, count, nil, false, obtainWays)
end

function Player:getTrayItemCountByFullName(fullName)
  local my_tray = self:tray():fetch_tray(1)
  local count = my_tray:count_item_num_by_fullname(fullName)
  return count
end

local function onUseSkillItem(self, params, item)
  local pokemon = self:getSelfPokemon(params.objId)
  if not pokemon then
    return
  end
  local skillId = item:cfg().skillId
  pokemon:studySkillByItem(skillId, params.skill_pos)
  self:updateAllPokemonPower()
end

local function onUseBlessItem(self, params, item)
  local pokemon = self:getPokemon(params.objId)
  if not pokemon then
    return
  end
  local item_config = BlessItemConfig:getAllConfig(item:cfg().fullName)
  local skillId = item:cfg().skillId
  pokemon:studySkillByItem(skillId, params.skill_pos)
  self:updateAllPokemonPower()
end

local function onUseCureItem(self, params, item)
  local cfg = item:cfg()
  local battlePetList = self:getValue("battlePetList")
  local pokemonList = PokemonManager:getPokemonList(battlePetList)
  local curBattlePetList = self:getValue("curBattlePetList")
  local battlePet = PokemonManager:getPokemonList(curBattlePetList)
  local correctPet = {}
  local correctBattlePet = false
  for _, pokemon in pairs(pokemonList) do
    if pokemon:getObjId() == params.target then
      correctPet = {pokemon}
    end
  end
  if cfg.group and not params.target then
    correctPet = pokemonList
  end
  if self:isInBattle() then
    for _, pokemon in pairs(correctPet) do
      for _, pet in pairs(battlePet) do
        if pokemon:getObjId() == pet:getObjId() then
          correctBattlePet = true
        end
      end
    end
    self:cacheBattleItemUse(cfg.cureType)
  end
  if correctBattlePet then
    if not self.battleField then
      return
    end
    self.battleField:onBattleAction(self, {
      type = Define.BATTLE_ACTION.ITEM,
      param = {
        pets = correctPet,
        skillId = params.skillId,
        item = item,
        slot = params.slot
      }
    })
    return false
  else
    for _, pet in pairs(correctPet) do
      if cfg.cureType then
        pet:useCureItem(item, params.skillId)
      end
    end
    return true
  end
end

function Player:onPetTargetUseItem(packet)
  local params = packet.params
  local my_tray = self:tray():fetch_tray(1)
  local item = my_tray:fetch_item(params.slot)
  if not item or item:full_name() ~= params.fullName then
    if self:isInBattle() then
    end
    return
  end
  local useOnTheSpot = true
  if packet.type == Define.ITEM_TYPE.CURE then
    useOnTheSpot = onUseCureItem(self, params, item)
  end
  if packet.type == Define.ITEM_TYPE.SKILL then
    onUseSkillItem(self, params, item)
  end
  if not useOnTheSpot then
    return
  end
  self:useBagItem(params.slot, params.fullName)
  return true
end

function Player:onUseItem(packet)
  local params = packet.params
  local my_tray = self:tray():fetch_tray(1)
  local item = my_tray:fetch_item(params.slot)
  if not item or item:full_name() ~= params.fullName then
    return
  end
  local cfg = item:cfg()
  if not cfg then
    return
  end
  if packet.type == Define.ITEM_TYPE.SPRAY then
    local dose = cfg.dose or 0
    local endTime = os.time() + dose * 60
    self:setValue("sprayEndTime", endTime)
  end
  self:useBagItem(params.slot, params.fullName)
  return true
end

function Player:useExpItem(params)
  if not (params and params.objId) or not params.fullName then
    return
  end
  local pokemon = self:getSelfPokemon(params.objId)
  if not pokemon then
    return
  end
  local maxLevel = PokemonConfig:getStarConfig(pokemon:getStar()).levelMax
  if maxLevel <= pokemon:getLevel() then
    return 1
  end
  local old_level = pokemon:getLevel()
  if old_level >= self:getPlayerLevel() then
    return 0
  end
  local petExpList = {}
  local itemCount = self:getTrayItemCountByFullName(params.fullName)
  if not itemCount or itemCount < 1 then
    return
  end
  local cfg = setting:fetch("item", params.fullName)
  if not cfg then
    return
  end
  local addExp = 0
  if cfg.dose == 1 then
    local upgradeExp = pokemon:getMaxExp() - pokemon:getCurExp()
    pokemon:addExp(upgradeExp, self)
    addExp = upgradeExp
    self:useBagItemByFullName(params.fullName, 1, false, nil, nil, "use_exp_item")
  elseif params.type == Define.USE_EXP_ITEM_TYPE.ONCE_ITEM then
    pokemon:addExp(cfg.dose, self)
    addExp = cfg.dose
    self:useBagItemByFullName(params.fullName, 1, false, nil, nil, "use_exp_item")
  elseif params.type == Define.USE_EXP_ITEM_TYPE.ONCE_LEVEL then
    local upgradeExp = pokemon:getMaxExp() - pokemon:getCurExp()
    local needCount = math.ceil(upgradeExp / cfg.dose)
    if itemCount < needCount then
      needCount = itemCount
    end
    pokemon:addExp(cfg.dose * needCount, self)
    addExp = cfg.dose * needCount
    self:useBagItemByFullName(params.fullName, needCount, false, nil, nil, "use_exp_item")
  end
  if old_level < pokemon:getLevel() then
    self:sendPacket({
      pid = "StoreRewardResult",
      petExpList = {
        {
          objId = pokemon:getObjId(),
          exp = addExp
        }
      }
    })
    Lib.logDebug("player bag use exp item guide")
    if not self:isGuideFinish() then
      Lib.logDebug("use exp item self:getCurGuideIndex() = ", self:getCurGuideIndex())
      if self:getCurGuideIndex() == Define.GUIDE_INDEX.UPGRADE_POKEMON_CONFIRM_UPGRADE then
        local guide_data = PokemonGuideConfig:getGuideData(Define.GUIDE_INDEX.FINISH_UPGRADE_POKEMON)
        if guide_data then
          self:getGuideReward(guide_data)
        end
      end
    end
    self:updateAllPokemonPower()
  end
  local canLevelUpPokemonList = self:getCanLevelUpList()
  self:sendPacket({
    pid = "updateExpItemDo",
    indexList = canLevelUpPokemonList,
    checkFalse = true
  })
  return true
end

function Player:onSellItem(packet)
  local params = packet.params
  local my_tray = self:tray():fetch_tray(1)
  local item = my_tray:fetch_item(params.slot)
  if not item or item:full_name() ~= params.fullName then
    return
  end
  local stack_count = item:stack_count()
  local cfg = item:cfg()
  if not cfg and not cfg.sellingPrice then
    return
  end
  local result = self:removeTrayItem({
    tid = 1,
    slot = params.slot,
    count = params.count
  })
  if result then
    local count = stack_count > params.count and params.count or stack_count
    self:addCurrency("gold_coin", count * cfg.sellingPrice, "sellItem")
  end
  return result
end

function Player:getCanLevelUpList(itemFullName, addCount)
  local haveLevelUpExpItem
  local tolExpCanAdd = 0
  local cfgs = setting:modCfgs("item")
  for _fullName, _cfg in pairs(cfgs) do
    if tonumber(_cfg.itemType) == Define.ITEM_TYPE.EXP then
      local dose = _cfg.dose
      local itemCount = self:getTrayItemCountByFullName(_fullName)
      if itemFullName and addCount then
        itemCount = itemCount + (itemFullName == _fullName and addCount or 0)
      end
      if dose == 1 and 0 < itemCount then
        haveLevelUpExpItem = true
        break
      end
      tolExpCanAdd = tolExpCanAdd + dose * itemCount
    end
  end
  local canLevelUpPokemonList = {}
  local battlePokemonList = self:getBattlePokemon()
  for index, pokemon in pairs(battlePokemonList) do
    local starMaxLevel = PokemonConfig:getStarConfig(pokemon:getStar()).levelMax
    local playerMaxLevel = self:getPlayerLevel()
    local expToLevelUp = pokemon:getMaxExp(pokemon:getLevel()) - pokemon:getCurExp()
    if (haveLevelUpExpItem or tolExpCanAdd >= expToLevelUp) and starMaxLevel > pokemon:getLevel() and playerMaxLevel > pokemon:getLevel() then
      table.insert(canLevelUpPokemonList, index)
    end
  end
  return canLevelUpPokemonList
end
