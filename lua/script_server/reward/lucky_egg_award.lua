local LuckyEggAward = T(Store, "LuckyEggAward")
local M = LuckyEggAward
local LuaTimer = T(Lib, "LuaTimer")
local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
local PokemonLuckyPkmConfig = T(Config, "PokemonLuckyPkmConfig")
local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
local PokemonLuckyRareConfig = T(Config, "PokemonLuckyRareConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local PokemonConfig = T(Config, "PokemonConfig")

function M:init()
  self:startCountDown()
end

function M:startCountDown()
  local flashEndTime = os.time(World.cfg.luckyEggFlashEndTime)
  local remainTime = flashEndTime - os.time()
  if remainTime <= 0 then
    return
  end
  self.flashDownTimer = LuaTimer:scheduleTimer(function()
    remainTime = flashEndTime - os.time()
    if remainTime <= 0 then
      self:resetExtraEggInfo()
    end
  end, 1000, remainTime)
end

function M:operationTakeLucky(player, poolId, takeType)
  if poolId == Define.LuckyEggTabType.flashTab then
    local flashEndTime = os.time(World.cfg.luckyEggFlashEndTime)
    local remainTime = flashEndTime - os.time()
    if remainTime <= 0 then
      player:sendPacket({
        pid = "pushLuckyEggFail",
        message = "gui_lucky_egg_take_fail"
      })
      return
    end
  end
  local battlePetList = player:getValue("packetPetList")
  local curTakeNum = 0
  local uniqueId = Define.GAME_GIFT_UNIQUE_ID .. 880 .. poolId
  if takeType == 0 then
    curTakeNum = 1
    uniqueId = uniqueId .. "0" .. curTakeNum
  else
    curTakeNum = 10
    uniqueId = uniqueId .. curTakeNum
  end
  if #battlePetList + curTakeNum > World.cfg.maxBoxPetsCnt then
    player:sendPacket({
      pid = "pushLuckyEggFail",
      message = "gui_lucky_egg_take_full_fail"
    })
    return
  end
  local priceData = PokemonLuckyPriceConfig:getDataByPoolIdAndTakeType(poolId, takeType)
  local bagTicketNum = player:getTrayItemCountByFullName(priceData.fullName)
  if bagTicketNum >= priceData.ticket_count then
    player:useBagItemByFullName(priceData.fullName, priceData.ticket_count, false, nil, nil, "lucky_egg_use")
    self:onTakeSuccess(player, poolId, takeType, 1)
  else
    local totalPrice = priceData.currency_count
    local changeKey = ""
    if takeType == 0 then
      changeKey = "lucky_egg_once"
    else
      changeKey = "lucky_egg_ten"
    end
    local costParts = {
      unit_price = totalPrice,
      total_price = totalPrice,
      counts = 1,
      change_key = changeKey
    }
    if priceData.isPay then
      local success
      player:doConsumeDiamonds("gDiamonds", totalPrice, function(ret)
        success = ret
        if ret then
          self:onTakeSuccess(player, poolId, takeType, 2)
          player:diamondCostNewDesign(Define.newDesignEventKey.LUCKY_EGG_DIAMOND_COST, costParts)
        else
          player:sendPacket({
            pid = "pushLuckyEggFail",
            message = "gui_lucky_egg_take_fail"
          })
        end
      end, uniqueId)
    else
      do
        local checkMoney = player:payCurrency(Coin:coinNameByCoinId(priceData.currencyType), totalPrice, false, false, "lucky_egg_gold")
        if checkMoney then
          self:onTakeSuccess(player, poolId, takeType, 2)
          player:coinCostNewDesign(Define.newDesignEventKey.LUCKY_EGG_COIN_COST, costParts)
        else
          player:sendPacket({
            pid = "pushLuckyEggFail",
            message = "gui_lucky_egg_take_fail"
          })
        end
      end
    end
  end
end

function M:flashEndTimeToStr(endTime)
  local text = ""
  text = string.format("%s_%s_%s_%s_%s_%s", endTime.year, endTime.month, endTime.day, endTime.hour, endTime.min, endTime.sec)
  return text
end

function M:onTakeSuccess(player, poolId, takeType, costType)
  self.luckyEggInfo = player:getLuckyEggInfo()
  if not self.luckyEggInfo[poolId] then
    self.luckyEggInfo[poolId] = {}
    self.luckyEggInfo[poolId].totalTakeCounts = 0
    if poolId == Define.LuckyEggTabType.flashTab then
      self.luckyEggInfo[poolId].flashEndTimeText = self:flashEndTimeToStr(World.cfg.luckyEggFlashEndTime)
    end
  end
  local rareInfo = PokemonLuckyRareConfig:getDataByPoolId(poolId)
  for i = #rareInfo, 1, -1 do
    if self.luckyEggInfo[poolId][rareInfo[i].rare_id] == nil then
      self.luckyEggInfo[poolId][rareInfo[i].rare_id] = 0
    end
  end
  local takeCount = 1
  local parts
  if takeType == 1 then
    takeCount = 10
    if poolId == Define.LuckyEggTabType.flashTab then
      parts = {
        "egg_flash_ten",
        costType
      }
    elseif poolId == Define.LuckyEggTabType.eliteTab then
      parts = {
        "egg_elite_ten",
        costType
      }
    else
      parts = {
        "egg_normal_ten",
        costType
      }
    end
  elseif poolId == Define.LuckyEggTabType.flashTab then
    parts = {
      "egg_flash_one",
      costType
    }
  elseif poolId == Define.LuckyEggTabType.eliteTab then
    parts = {
      "egg_elite_one",
      costType
    }
  else
    parts = {
      "egg_normal_one",
      costType
    }
  end
  GameAnalytics.Design(player.platformUserId, 1, parts)
  local tempCountID = 0
  if takeCount == 10 then
    tempCountID = math.random(2, 10)
  end
  local luckyResult = {}
  for i = 1, takeCount do
    self.luckyEggInfo[poolId].totalTakeCounts = self.luckyEggInfo[poolId].totalTakeCounts + 1
    local curRare = self:getCurTakeLuckyRare(poolId, rareInfo)
    if curRare then
      for i = #rareInfo, 1, -1 do
        if curRare < rareInfo[i].rare_id then
          self.luckyEggInfo[poolId][rareInfo[i].rare_id] = self.luckyEggInfo[poolId][rareInfo[i].rare_id] + 1
        else
          self.luckyEggInfo[poolId][rareInfo[i].rare_id] = 0
        end
      end
      local pkmList = PokemonLuckyPkmConfig:getDataByPoolIdAndRareId(poolId, curRare)
      local weightId = self:getOneKeyWithWeight(pkmList)
      local pokemonId = 0
      local pokemonStar = 0
      if i == 1 and not player:isGuideFinish() and player:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
        pokemonId = player:getInitPokemonId()
        local pokemonCfg = PokemonConfig:getConfigById(pokemonId)
        if pokemonCfg then
          pokemonStar = pokemonCfg.starLevel
        end
      elseif i == tempCountID and not player:isGuideFinish() and player:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
        local allPkmList = PokemonLuckyPkmConfig:getDataByPoolIdAndRareId(poolId, 3)
        local mythicalList = {}
        for key, val in pairs(allPkmList) do
          local pokemonCfg = PokemonConfig:getConfigById(val.pkm_id)
          if pokemonCfg.quality == Define.POKEMON_QUALITY.MYTHICAL then
            table.insert(mythicalList, val)
          end
        end
        if 0 < #mythicalList then
          weightId = self:getOneKeyWithWeight(mythicalList)
          pokemonId = mythicalList[weightId].pkm_id
          pokemonStar = mythicalList[weightId].star
        else
          pokemonId = pkmList[weightId].pkm_id
          pokemonStar = pkmList[weightId].star
        end
      else
        pokemonId = pkmList[weightId].pkm_id
        pokemonStar = pkmList[weightId].star
      end
      local isNew = true
      if player:isHaveCurCfgId(pokemonId) then
        isNew = false
      end
      local pokemon = player:randomPokemon(pokemonId, pokemonStar)
      if pokemon:getQuality() == Define.POKEMON_QUALITY.MYTHICAL then
        pokemon:lock(true)
      end
      local temp = {
        isNew = isNew,
        pkmObjId = pokemon.objId,
        cfgId = pokemonId
      }
      table.insert(luckyResult, temp)
    end
  end
  player:setLuckyEggInfo(self.luckyEggInfo)
  if not player:isGuideFinish() and player:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
    local guide_data = PokemonGuideConfig:getGuideData(Define.GUIDE_INDEX.FINISH_TAKE_TEN)
    player:getGuideReward(guide_data)
    player:setFirstLuckyEgg(true)
  end
  local packet = {
    pid = "pushLuckyEggResult",
    luckyResult = luckyResult
  }
  player:sendPacket(packet)
end

function M:getCurTakeLuckyRare(poolId, rareInfo)
  for i = #rareInfo, 1, -1 do
    if rareInfo[i].end_count > 0 and self.luckyEggInfo[poolId][rareInfo[i].rare_id] + 1 >= rareInfo[i].end_count then
      return rareInfo[i].rare_id
    end
  end
  local weightId = self:getOneKeyWithWeight(rareInfo)
  return rareInfo[weightId].rare_id
end

function M:getOneKeyWithWeight(weightList)
  local minNum = 1
  local maxNum = 0
  for key, val in ipairs(weightList) do
    maxNum = maxNum + val.weight_num
  end
  local num = math.random(minNum, maxNum)
  local curWeight = 0
  for k, val in ipairs(weightList) do
    curWeight = curWeight + val.weight_num
    if num <= curWeight then
      return k
    end
  end
  return 0
end

function M:operationReceiveLuckyExtra(player, extraId)
  if player.isReceivingLuckyExtra then
    return
  end
  player.isReceivingLuckyExtra = true
  local luckyEggExtra = player:getLuckyEggExtra()
  if luckyEggExtra[extraId] then
    player:sendPacket({
      pid = "showCommonTips",
      message = "gui_recharge_received",
      time = 40
    })
    player.isReceivingLuckyExtra = false
    return
  end
  local extraItem = PokemonLuckyExtraConfig:getDataById(extraId)
  local luckyEggInfo = player:getLuckyEggInfo()
  local curCount = 0
  if luckyEggInfo[extraItem.pool_id] then
    curCount = luckyEggInfo[extraItem.pool_id].totalTakeCounts
  end
  if curCount >= extraItem.take_count then
    if 0 < extraItem.pkm_id then
      local battlePetList = player:getValue("packetPetList")
      if #battlePetList + 1 > World.cfg.maxBoxPetsCnt then
        player:sendPacket({
          pid = "showCommonTips",
          message = "gui_lucky_egg_receive_fail_full",
          time = 40
        })
        player.isReceivingLuckyExtra = false
        return false
      end
      player:randomPokemon(extraItem.pkm_id)
    else
      local items = {}
      items[extraItem.fullName] = extraItem.award_count
      local isPutBag = player:determineBackpackCapacity(items)
      if not isPutBag then
        player:sendPacket({
          pid = "showCommonTips",
          message = "gui_bag_not_enough",
          time = 40
        })
        player.isReceivingLuckyExtra = false
        return false
      end
      player:obtainItemsByFullName(extraItem.fullName, extraItem.award_count, "lucky_egg_extra_award")
    end
    luckyEggExtra[extraId] = true
    player:setLuckyEggExtra(luckyEggExtra)
    player:sendPacket({
      pid = "receiveLuckyExtraSuccess",
      extraId = extraId
    })
    player.isReceivingLuckyExtra = false
  end
end

function M:resetExtraEggInfo()
  local playerList = Game.GetAllPlayers()
  for _, player in pairs(playerList) do
    local luckyEggInfo = player:getLuckyEggInfo()
    if luckyEggInfo[Define.LuckyEggTabType.flashTab] then
      self:cleanPlayerLuckyEggInfoByTab(player, Define.LuckyEggTabType.flashTab)
    end
  end
end

function M:checkCleanLuckyFlashAward(player)
  local luckyEggInfo = player:getLuckyEggInfo()
  if luckyEggInfo[Define.LuckyEggTabType.flashTab] then
    if luckyEggInfo[Define.LuckyEggTabType.flashTab].flashEndTimeText ~= self:flashEndTimeToStr(World.cfg.luckyEggFlashEndTime) then
      self:cleanPlayerLuckyEggInfoByTab(player, Define.LuckyEggTabType.flashTab)
    else
      local flashEndTime = os.time(World.cfg.luckyEggFlashEndTime)
      local remainTime = flashEndTime - os.time()
      if remainTime <= 0 then
        self:cleanPlayerLuckyEggInfoByTab(player, Define.LuckyEggTabType.flashTab)
      end
    end
  end
end

function M:cleanPlayerLuckyEggInfoByTab(player, tabType)
  local luckyEggInfo = player:getLuckyEggInfo()
  if luckyEggInfo[tabType] then
    luckyEggInfo[tabType] = nil
    player:setLuckyEggInfo(luckyEggInfo)
  end
  local luckyEggExtra = player:getLuckyEggExtra()
  for extraId, _ in pairs(luckyEggExtra) do
    local extraItem = PokemonLuckyExtraConfig:getDataById(extraId)
    if not extraItem or extraItem.pool_id == tabType then
      luckyEggExtra[extraId] = nil
    end
  end
  player:setLuckyEggExtra(luckyEggExtra)
end

M:init()
return M
