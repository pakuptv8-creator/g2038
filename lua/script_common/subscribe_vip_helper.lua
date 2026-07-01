local SubscribeVipHelper = _ENV.SubscribeVipHelper
if World.isClient then
  local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
  
  function SubscribeVipHelper:clientClickSubscribeVipReward()
    Me:requestSubscribeVipReward()
  end
  
  function SubscribeVipHelper:updateSubscribeMainBtnRedDot(value)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_SUBSCRIBE_RED, value)
  end
  
  function SubscribeVipHelper:ShowClientDistributeResult(resultCode, items)
    if resultCode == 0 then
      if items then
        local giftItemInfo = {}
        for itemName, itemNum in pairs(items) do
          local itemData = {}
          itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.ITEM
          itemData.item = itemName
          itemData.count = itemNum
          table.insert(giftItemInfo, itemData)
        end
        UI:getWnd("buyGiftTip"):onShow(true, giftItemInfo, "subscribe_vip_distribute_reward_success")
      else
        local message = Lang:toText("subscribe_vip_distribute_reward_success")
        Me:showCommonTip(1, message, 40)
      end
    elseif resultCode == 1 then
      local message = Lang:toText("gui_bag_not_enough")
      Me:showCommonTip(1, message, 40)
    end
  end
else
  function SubscribeVipHelper:checkIsCanDistribute(player, items)
    local isPutBag = player:determineBackpackCapacity(items)
    
    if not isPutBag then
      SubscribeVipHelper:pushClientDistributeResult(player, 1)
      return false
    end
    return true
  end
  
  function SubscribeVipHelper:distributeSubscribeVipReward(player, subscribeVipStage)
    local subscribeRewardState = player:getSubscribeRewardState()
    local subscribe_vipSetting = World.cfg.subscribe_vipSetting
    local items = {}
    if subscribeVipStage == Define.SubscribeVIPStage.Normal then
      if not subscribeRewardState[Define.SubscribeVIPStage.Normal] then
        items[subscribe_vipSetting.normalVipRewardName] = subscribe_vipSetting.normalVipRewardNum
      end
    elseif subscribeVipStage == Define.SubscribeVIPStage.Height then
      if not subscribeRewardState[Define.SubscribeVIPStage.Normal] then
        items[subscribe_vipSetting.normalVipRewardName] = subscribe_vipSetting.normalVipRewardNum
      end
      if not subscribeRewardState[Define.SubscribeVIPStage.Height] then
        if items[subscribe_vipSetting.heightVipRewardName] then
          items[subscribe_vipSetting.heightVipRewardName] = items[subscribe_vipSetting.heightVipRewardName] + subscribe_vipSetting.heightVipRewardNum
        else
          items[subscribe_vipSetting.heightVipRewardName] = subscribe_vipSetting.heightVipRewardNum
        end
      end
    end
    if SubscribeVipHelper:checkIsCanDistribute(player, items) then
      for itemName, itemNum in pairs(items) do
        player:obtainItemsByFullName(itemName, itemNum, "subscribeVipReward")
      end
      SubscribeVipHelper:pushClientDistributeResult(player, 0, items)
      return true
    end
    return false
  end
end
