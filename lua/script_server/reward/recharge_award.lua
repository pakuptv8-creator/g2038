local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
local setting = require("common.setting")
local rechargeAward = {}

function rechargeAward:rechargeAwardOperation(player, awardType, awardStatus)
  if player.isReceivingFirst then
    return
  end
  player.isReceivingFirst = true
  local awardStatus = player:getRechargeAwardStatus()
  local awardType = awardStatus + 1
  local allItems, condition = RechargeAwardConfig:getRewardTypeItems(awardType)
  if not condition then
    player.isReceivingFirst = false
    return
  end
  local items = {}
  for key, val in pairs(allItems) do
    if val.goodType == 3 then
      items[val.fullName] = val.count
    end
  end
  local isPutBag = player:determineBackpackCapacity(items)
  if not isPutBag then
    player:sendPacket({
      pid = "showCommonTips",
      message = "gui_bag_not_enough",
      time = 40
    })
    player.isReceivingFirst = false
    return false
  end
  for _, item in pairs(allItems or {}) do
    if item.goodType == 1 then
      local battlePetList = player:getValue("packetPetList")
      if #battlePetList >= World.cfg.maxBoxPetsCnt then
        player:sendPacket({
          pid = "showCommonTips",
          message = "gui_lucky_egg_receive_fail_full"
        })
        player.isReceivingFirst = false
        return false
      end
    end
  end
  self:onReceiveAward(player, allItems, awardStatus)
end

function rechargeAward:onReceiveAward(player, items, awardStatus)
  for _, item in pairs(items or {}) do
    self:onReceiveItem(player, item)
  end
  player:setRechargeAwardStatus(awardStatus + 1)
  player:sendPacket({
    pid = "showCommonTips",
    message = "gui_receive_success_text",
    time = 40
  })
  player.isReceivingFirst = false
  local parts = {
    "firstRecharge_success",
    1
  }
  GameAnalytics.Design(player.platformUserId, 1, parts)
  local costParts = {award_status = awardStatus}
  player:commonNewDesign(Define.newDesignEventKey.FIRST_RECHARGE_RECEIVE, costParts)
end

function rechargeAward:onReceiveItem(player, item)
  if item.goodType == 1 then
    player:randomPokemon(item.pkmId)
  elseif item.goodType == 2 then
    player:addCurrency("gold_coin", item.count, "rechargeAward")
  elseif item.goodType == 3 then
    player:obtainItemsByFullName(item.fullName, item.count, "receive_recharge_item")
  end
end

return rechargeAward
