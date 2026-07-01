local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local Player = _ENV.Player
local BuyingTips = Define.BuyingTips

function Player:verifyTriggerGiftCondition(conditionType, info, notShowWnd)
  local triggerGifts = TriggerGiftConfig:getSettings()
  local trigger = conditionType .. "#" .. info
  local triggerGiftInfo = self:getTriggerGiftInfo()
  local haveBuyGiftInfo = self:getHaveBuyGiftInfo()
  local count = TriggerGiftConfig:getTriggerGiftNumByTrigger(trigger)
  local haveTestedIds = {}
  for i = 1, count do
    local verifyBy = false
    local newGiftId = 0
    for _, triggerGift in pairs(triggerGifts) do
      if triggerGift.trigger == trigger and not haveTestedIds[triggerGift.id] then
        haveTestedIds[triggerGift.id] = true
        if triggerGiftInfo[triggerGift.id] then
          if conditionType == Define.GIFT_TRIGGER_CONDITION.ON_LINE then
            self.onlineTime = 0
          end
          break
        end
        if not (not triggerGift.premiseGiftId or haveBuyGiftInfo[triggerGift.premiseGiftId]) then
          break
        end
        local existSameType = false
        for _, giftId in pairs(triggerGift.sameTypeGift or {}) do
          if triggerGiftInfo[giftId] then
            existSameType = true
            break
          end
        end
        if existSameType then
          break
        end
        triggerGiftInfo[triggerGift.id] = os.time() + triggerGift.duration * 3600
        newGiftId = triggerGift.id
        verifyBy = true
      end
    end
    if verifyBy then
      self:setTriggerGiftInfo(triggerGiftInfo)
      if conditionType == Define.GIFT_TRIGGER_CONDITION.ON_LINE then
        self:setValue("onlineGiftBagStatus", false)
      end
      local level = tonumber(self:getPlayerLevel())
      local isOpenOnLineGift = PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.MAIN_FIRST_RECHARGE, level)
      if not notShowWnd and isOpenOnLineGift then
        self:sendPacket({
          pid = "showNewTriggerGift",
          giftId = newGiftId
        })
      end
    end
  end
end

function Player:setGiftVanish(giftId)
  local triggerGiftInfo = self:getTriggerGiftInfo()
  for id, time in pairs(triggerGiftInfo) do
    if id == giftId then
      triggerGiftInfo[id] = nil
    end
  end
  self:setTriggerGiftInfo(triggerGiftInfo)
end

function Player:verifyGiftDue()
  local triggerGiftInfo = self:getTriggerGiftInfo()
  for id, time in pairs(triggerGiftInfo) do
    if time < os.time() then
      self:setGiftVanish(id)
    end
  end
end

function Player:sendThreeSelOne(targetGiftId)
  self:cacheThreeSel(targetGiftId)
end

local function buyTriggerGiftResult(self, result, giftId)
  self.isBuyingGift = false
  self:sendPacket({
    pid = "TriggerGiftBuyResult",
    result = result,
    giftId = giftId
  })
end

local function onBuyGiftSuccess(self, targetGiftId, giftItemsInfo)
  self:setGiftVanish(targetGiftId)
  local haveBuyGiftInfo = self:getHaveBuyGiftInfo()
  if haveBuyGiftInfo[targetGiftId] and type(haveBuyGiftInfo[targetGiftId]) == "number" then
    haveBuyGiftInfo[targetGiftId] = haveBuyGiftInfo[targetGiftId] + 1
  else
    haveBuyGiftInfo[targetGiftId] = 1
  end
  self:setHaveBuyGiftInfo(haveBuyGiftInfo)
  for index, info in pairs(giftItemsInfo) do
    if info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET then
      if type(info.item) == "table" then
        self:sendThreeSelOne(targetGiftId)
      else
        for i = 1, info.count do
          self:randomPokemon(info.item, info.petStarLevel)
        end
      end
    elseif info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.GOLD then
      self:addCurrency(info.item, info.count, "trigger_gift")
    elseif info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.ITEM then
      self:obtainItemsByFullName(info.item, info.count, "trigger_gift")
    end
  end
  self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.BUY_GIFT, targetGiftId)
  local giftInfo = TriggerGiftConfig:getGiftById(targetGiftId)
  local price = math.ceil(giftInfo.original * giftInfo.discount)
  local costParts = {
    unit_price = price,
    total_price = price * 1,
    counts = 1,
    change_key = targetGiftId,
    gift_id = targetGiftId
  }
  if giftInfo and giftInfo.type == Define.TRIGGER_GIFT_TYPE.GROW then
    self:diamondCostNewDesign(Define.newDesignEventKey.GROW_GIFT_COST, costParts)
  else
    self:diamondCostNewDesign(Define.newDesignEventKey.LIMITED_GIFT_COST, costParts)
  end
end

function Player:onBuyTriggerGift(packet)
  local targetGiftId = packet.giftId
  local triggerGiftInfo = self:getTriggerGiftInfo()
  local isExistGift = false
  if self.isBuyingGift then
    return
  end
  self.isBuyingGift = true
  for id, time in pairs(triggerGiftInfo) do
    if id == targetGiftId then
      isExistGift = true
    end
  end
  if not isExistGift then
    buyTriggerGiftResult(self, BuyingTips.not_get, targetGiftId)
    return
  end
  local giftItemsInfo = self:getGiftItems(targetGiftId)
  local gift = TriggerGiftConfig:getGiftById(targetGiftId)
  if not giftItemsInfo or not gift then
    buyTriggerGiftResult(self, BuyingTips.item_error, targetGiftId)
    return
  end
  local price = math.ceil(gift.original * gift.discount)
  if not World.cfg.useFDiamonds then
    self:doConsumeDiamonds("gDiamonds", price, function(ret)
      if ret then
        onBuyGiftSuccess(self, targetGiftId, giftItemsInfo)
        buyTriggerGiftResult(self, BuyingTips.buy_finish, targetGiftId)
      else
        buyTriggerGiftResult(self, BuyingTips.buy_fail, targetGiftId)
      end
    end, Define.GAME_GIFT_UNIQUE_ID .. targetGiftId)
  else
    local checkMoney = self:payCurrency("fDiamonds", price, false, false, "trigger_gift")
    if checkMoney then
      onBuyGiftSuccess(self, targetGiftId, giftItemsInfo)
      buyTriggerGiftResult(self, BuyingTips.buy_finish, targetGiftId)
    else
      buyTriggerGiftResult(self, BuyingTips.buy_fail, targetGiftId)
    end
  end
end

function Player:getGiftItems(targetGiftId)
  local giftItemsInfo = TriggerGiftConfig:getGiftItemsInfoById(targetGiftId)
  local petCount = 0
  local items = {}
  local isAllGold = true
  for _, info in pairs(giftItemsInfo) do
    if info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET then
      petCount = petCount + 1 * info.count
      isAllGold = false
    elseif info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.ITEM then
      if items[info.item] then
        items[info.item] = items[info.item] + info.count
      else
        items[info.item] = info.count
      end
      isAllGold = false
    end
  end
  local canGetItems = self:determineBackpackCapacity(items)
  local canGetPet = true
  local battlePetList = self:getValue("packetPetList")
  if #battlePetList >= World.cfg.maxBoxPetsCnt then
    canGetPet = false
  end
  if canGetItems and canGetPet or isAllGold then
    return giftItemsInfo
  end
  return
end

function Player:petChooseThreeSuccess(petId)
  local threeSelCache = self:getThreeSelCache()
  if type(threeSelCache) == "table" then
    self:cacheThreeSel(0)
    self:randomPokemon(petId)
    return
  end
  local giftItemsInfo = TriggerGiftConfig:getGiftItemsInfoById(threeSelCache)
  local index
  self:cacheThreeSel(0)
  for i, info in pairs(giftItemsInfo or {}) do
    if info.giftType == Define.TRIGGER_GIFT_ITEM_TYPE.PET and type(info.item) == "table" then
      index = i
    end
  end
  if not giftItemsInfo or not index then
    self:randomPokemon(petId)
    return
  end
  self:randomPokemon(petId, giftItemsInfo[index].petStarLevel)
end
