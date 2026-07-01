local RotaryTableAward = T(Store, "RotaryTableAward")
local M = RotaryTableAward
local PokemonRotaryTableConfig = T(Config, "PokemonRotaryTableConfig")

function M:init()
end

function M:operationTakeRotary(player, rotaryType)
  if player.isTakingRotary then
    return
  end
  player.isTakingRotary = true
  local tableData = PokemonRotaryTableConfig:getCfgByRotaryType(rotaryType)
  for _, val in pairs(tableData) do
    if val.fullName ~= "" then
      local items = {}
      items[val.fullName] = val.award_num * val.ratio_num
      local isPutBag = player:determineBackpackCapacity(items)
      if not isPutBag then
        player:sendPacket({
          pid = "pushRotaryTableResult",
          state = false,
          message = "gui_bag_not_enough"
        })
        player.isTakingRotary = false
        return false
      end
    elseif val.pkm_id ~= 0 then
      local battlePetList = player:getValue("packetPetList")
      if #battlePetList + val.award_num * val.ratio_num >= World.cfg.maxBoxPetsCnt then
        player:sendPacket({
          pid = "pushRotaryTableResult",
          message = "gui_lucky_egg_buy_fail_full",
          state = false
        })
        player.isTakingRotary = false
        return false
      end
    end
  end
  if tableData[1].isPay then
    local success
    player:doConsumeDiamonds("gDiamonds", tableData[1].price_num, function(ret)
      success = ret
      if ret then
        self:onTakeSuccess(player, rotaryType)
      else
        player:sendPacket({
          pid = "pushRotaryTableResult",
          state = false,
          message = "gui_lucky_egg_take_fail"
        })
        player.isTakingRotary = false
      end
    end, Define.GAME_GIFT_UNIQUE_ID .. 777777)
  else
    local checkMoney = player:payCurrency(Coin:coinNameByCoinId(tableData[1].currencyType), tableData[1].price_num, false, false, "lucky_egg_gold")
    if checkMoney then
      self:onTakeSuccess(player, rotaryType)
    else
      player:sendPacket({
        pid = "pushRotaryTableResult",
        state = false,
        message = "gui_lucky_egg_take_fail"
      })
      player.isTakingRotary = false
    end
  end
end

local function getRotaryCountStr(count)
  if 10 <= count then
    return "10_INF_rotary_count"
  else
    return count .. "_rotary_count"
  end
end

function M:onTakeSuccess(player, rotaryType)
  local resultID
  local firstRotaryTable = player:getValue("firstRotaryTable")
  if firstRotaryTable[rotaryType] == nil then
    resultID = self:getCurResultWithWeight(rotaryType, true)
  else
    resultID = self:getCurResultWithWeight(rotaryType, false)
  end
  local resultData = PokemonRotaryTableConfig:getCfgById(resultID)
  if resultData.pkm_id ~= 0 then
    for i = 1, resultData.award_num * resultData.ratio_num do
      player:randomPokemon(resultData.pkm_id)
    end
  elseif resultData.goldIcon ~= "" then
    player:addCurrency("gold_coin", resultData.award_num * resultData.ratio_num, "rechargeAward")
  elseif resultData.fullName ~= "" then
    player:obtainItemsByFullName(resultData.fullName, resultData.award_num * resultData.ratio_num, "receive_recharge_item")
  end
  player:sendPacket({
    pid = "pushRotaryTableResult",
    state = true,
    resultID = resultID
  })
  player.isTakingRotary = false
  if not player.recordRotaryTable then
    player.recordRotaryTable = {}
  end
  if not player.recordRotaryTable[rotaryType] then
    player.recordRotaryTable[rotaryType] = {}
  end
  if firstRotaryTable[rotaryType] == nil or firstRotaryTable[rotaryType] == true then
    firstRotaryTable[rotaryType] = 1
  else
    firstRotaryTable[rotaryType] = firstRotaryTable[rotaryType] + 1
  end
  player:setValue("firstRotaryTable", firstRotaryTable)
  local countStr = getRotaryCountStr(firstRotaryTable[rotaryType])
  local changeKey = ""
  if rotaryType == Define.RotaryTabType.goldTab then
    local parts = {
      "CoinWheel_success",
      1
    }
    GameAnalytics.Design(player.platformUserId, 1, parts)
    local parts2 = {
      "CoinWheel_play_times",
      countStr
    }
    GameAnalytics.Design(player.platformUserId, 1, parts2)
    if player.recordRotaryTable[rotaryType].lastResult and os.time() - player.recordRotaryTable[rotaryType].lastTime <= 30 then
      local parts = {
        "CoinWheel_last_play",
        player.recordRotaryTable[rotaryType].lastResult
      }
      GameAnalytics.Design(player.platformUserId, 1, parts)
    end
    changeKey = "coin_wheel_cost"
  else
    local parts = {
      "CandyWheel_success",
      1
    }
    GameAnalytics.Design(player.platformUserId, 1, parts)
    local parts2 = {
      "CandyWheel_play_times",
      countStr
    }
    GameAnalytics.Design(player.platformUserId, 1, parts2)
    if player.recordRotaryTable[rotaryType].lastResult and os.time() - player.recordRotaryTable[rotaryType].lastTime <= 30 then
      local parts = {
        "CandyWheel_last_play",
        player.recordRotaryTable[rotaryType].lastResult
      }
      GameAnalytics.Design(player.platformUserId, 1, parts)
    end
    changeKey = "candy_wheel_cost"
  end
  player.recordRotaryTable[rotaryType].lastResult = resultID
  player.recordRotaryTable[rotaryType].lastTime = os.time()
  local costParts = {
    unit_price = resultData.price_num,
    total_price = resultData.price_num,
    counts = 1,
    change_key = changeKey,
    result_id = resultID
  }
  player:diamondCostNewDesign(Define.newDesignEventKey.ROTARY_TABLE_COST, costParts)
end

function M:getCurResultWithWeight(rotaryType, isFirst)
  local tableData = PokemonRotaryTableConfig:getCfgByRotaryType(rotaryType)
  local minNum = 1
  local maxNum = 0
  for _, val in ipairs(tableData) do
    if isFirst then
      maxNum = maxNum + val.first_weight
    else
      maxNum = maxNum + val.normal_weight
    end
  end
  local num = math.random(minNum, maxNum)
  local curWeight = 0
  for _, val in ipairs(tableData) do
    if isFirst then
      curWeight = curWeight + val.first_weight
    else
      curWeight = curWeight + val.normal_weight
    end
    if num <= curWeight then
      return val.id
    end
  end
  return 0
end

M:init()
return M
