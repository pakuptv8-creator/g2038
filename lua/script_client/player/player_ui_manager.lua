local Player = _ENV.Player
local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local RegularGiftConfig = T(Config, "RegularGiftConfig")

function Player:checkLoginAutoShowGiftWnd()
  UIMgr:registerWindowCallBack("pokemonMain", function()
    if self:isCanShowRechargeWnd() then
      UI:getWnd("pokemon_recharge_award"):onShow(true)
    else
      local tempPr = math.random(1, 100)
      if tempPr <= World.cfg.loginGiftProbability then
        Me.loginCheckLoginGiftBg = true
        self:checkLoginGiftBagUIIsInit()
      end
    end
  end)
end

function Player:checkLoginGiftBagUIIsInit()
  if UI:isOpen("pokemonGuide") then
    return false
  end
  if Me.giftBagUIIsInit and Me.loginCheckLoginGiftBg then
    Me.loginCheckLoginGiftBg = false
    self:isCanShowOthersGiftWnd()
  end
end

function Player:checkDeadAutoShowGiftWnd()
  if UI:isOpen("pokemonGuide") then
    return false
  end
  local tempPr = math.random(1, 100)
  if tempPr <= World.cfg.deadGiftProbability then
    self:isCanShowOthersGiftWnd()
  end
end

function Player:isCanShowRechargeWnd()
  if UI:isOpen("pokemonGuide") then
    return false
  end
  local level = tonumber(Me:getPlayerLevel())
  if PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.MAIN_FIRST_RECHARGE, level) then
    local awardStatus = self:getRechargeAwardStatus()
    local _, condition = RechargeAwardConfig:getRewardTypeItems(awardStatus + 1)
    if condition then
      return true
    end
  end
  return false
end

function Player:isCanShowGiftBgWnd(curGiftType)
  local level = tonumber(Me:getPlayerLevel())
  local isOpenOnLineGift = PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.MAIN_FIRST_RECHARGE, level)
  if not isOpenOnLineGift then
    return false
  end
  local triggerGiftInfo = Me:getTriggerGiftInfo()
  local giftData = {}
  for id, time in pairs(triggerGiftInfo or {}) do
    local gift = TriggerGiftConfig:getGiftById(id)
    if gift then
      local giftType = gift.type
      if giftType == curGiftType and time - os.time() > 0 and 0 < gift.autoWeight then
        table.insert(giftData, {
          id = id,
          time = time,
          weight = gift.autoWeight,
          triggerType = gift.triggerType
        })
      end
    end
  end
  table.sort(giftData, function(a, b)
    return a.time < b.time
  end)
  if 0 < #giftData then
    for i = 1, #giftData do
      giftData[i].index = i
      if curGiftType == Define.TRIGGER_GIFT_TYPE.TIME and Me:getGainFirstOrangePet() == 1 and giftData[i].triggerType == Define.GIFT_TRIGGER_CONDITION.ORANGE_PET then
        Me:setGainFirstOrangePet(2)
        UI:openWnd("pokemonGiftBag", curGiftType, i)
        return
      end
    end
    local item = Lib.randomItemByWeight(1, giftData, false)
    local index = item[1].index
    if 0 < index then
      UI:openWnd("pokemonGiftBag", curGiftType, index)
      if curGiftType == Define.TRIGGER_GIFT_TYPE.TIME and Me:getGainFirstOrangePet() == 1 then
        Me:setGainFirstOrangePet(2)
      end
      return true
    end
  else
    return false
  end
end

function Player:isCanShowOthersGiftWnd()
  local level = tonumber(Me:getPlayerLevel())
  if self:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME) then
  elseif self:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.GROW) then
  elseif PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.MAIN_REGULAR_GIFT, level) then
    local giftList = RegularGiftConfig:getAllConfig()
    local giftData = {}
    for id, val in pairs(giftList or {}) do
      if not giftData[val.giftType] and val.autoWeight > 0 then
        giftData[val.giftType] = {
          giftType = val.giftType,
          weight = val.autoWeight
        }
      end
    end
    if 0 < #giftData then
      local item = Lib.randomItemByWeight(1, giftData, false)
      UI:getWnd("pokemonRegularGift"):onShow(true, item[1].giftType)
    end
  end
end
