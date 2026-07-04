local LimitedTimeActivityGameMgr = _ENV.LimitedTimeActivityGameMgr
local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")
local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local AppearanceConfig = T(Config, "AppearanceConfig")
local PetConfig = T(Config, "PetConfig")
local CarConfig = T(Config, "CarConfig")
local HouseConfig = T(Config, "HouseConfig")
if World.isClient then
  function LimitedTimeActivityGameMgr:addSpecialCell(parent, itemInfo, area)
    return false
  end
  
  function LimitedTimeActivityGameMgr:getServerTime()
    return os.time()
  end
  
  function LimitedTimeActivityGameMgr:initActivityMenu()
    if not self.LimitedTimeActivityMenu then
      local mainWnd = UI:getWnd("gameMain")
      if mainWnd then
        local menu = UIMgr:new_widget("limitedTimeActivityMenu", {
          va = 1,
          ha = 2,
          area = {
            {0, -77},
            {0, -10},
            {0, 250},
            {0, 80}
          },
          cellW = 100,
          font = "HT12"
        })
        mainWnd.lytActivityPanel:AddChildWindow(menu)
        self.LimitedTimeActivityMenu = menu
      end
      Lib.subscribeEvent(Event.EVENT_UPDATE_DAY_FIRST_LOGIN, function()
        LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
      end)
    end
    return self.LimitedTimeActivityMenu
  end
  
  function LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(value)
    local menu = self:initActivityMenu()
    if menu then
      menu:invoke("updateMenuBtn", Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT, value)
    end
  end
  
  function LimitedTimeActivityGameMgr:updateSignalLimitBtnShow(value)
    local menu = self:initActivityMenu()
    if menu then
      menu:invoke("updateMenuBtn", Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT, value)
    end
  end
  
  function LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
    local menu = self:initActivityMenu()
    if menu then
      menu:invoke("updateMenuBtn", Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY)
    end
  end
  
  function LimitedTimeActivityGameMgr:checkDrawContent()
    return true
  end
  
  function LimitedTimeActivityGameMgr:checkGroupActivityIsCanShow(activityWndType)
    local group = LimitTimeClientHelper:getActivitiesInCommonWnd(activityWndType)
    local needShowLimitTimeActivity = false
    for _, v in pairs(group) do
      if LimitTimeClientHelper:checkActiveIsOpen(v.type) then
        needShowLimitTimeActivity = true
        break
      end
    end
    return needShowLimitTimeActivity
  end
  
  function LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnRedDot(value)
    Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_ENTRY_RED_DOY, value, Define.LIMITED_TIME_ACTIVITY_MENU.LIMITED_TIME_ACTIVITY)
  end
  
  function LimitedTimeActivityGameMgr:updateCombinedLimitBtnRedDot(value)
    Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_ENTRY_RED_DOY, value, Define.LIMITED_TIME_ACTIVITY_MENU.COMBINATION_GIFT)
  end
  
  function LimitedTimeActivityGameMgr:updateSignalLimitBtnRedDot(value)
    Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY_ENTRY_RED_DOY, value, Define.LIMITED_TIME_ACTIVITY_MENU.SIGNAL_GIFT)
  end
  
  function LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(data, dx, dy)
    local params = {}
    local item = self:getItemInfo(data)
    params.name = data.showName or item.name
    params.icon = item.itemIcon
    params.count = item.itemCount
    params.dec = data.showDesc or item.dec
    params.quality = item.quality
    UI:openWnd("limitedTimeActivityItemDialog", params)
  end
  
  function LimitedTimeActivityGameMgr:limitTimeExtraItemClickFunc(data, dx, dy)
    LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(data, dx, dy)
  end
  
  function LimitedTimeActivityGameMgr:checkLimitTimeActivityIsUnlock()
    return true
  end
  
  function LimitedTimeActivityGameMgr:clientClickBoughtBtn(activityType, params)
    if activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
      if UI:getWnd("limitTimeCombination"):getBuyingState() then
        return
      end
      UI:getWnd("commonDialog"):onShow(true, {
        title = Lang:toText("gui.limit.time.common.tips"),
        desc = Lang:toText("gui.limit.time.buy.confirm"),
        confirmCallback = function()
          Lib.emitEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, true)
          Me:sendPacket({
            pid = "CSBuyLimitCombinationGift",
            activityId = params.activityId,
            id = params.id
          })
        end,
        cancelCallback = function()
        end
      })
    elseif activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT then
      if UI:getWnd("limitTimeSignalWnd"):getBuyingState() then
        return
      end
      Lib.emitEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, true)
      Me:sendPacket({
        pid = "CSBuyLimitSignalGift",
        activityId = params.activityId,
        id = params.id
      })
    end
  end
  
  function LimitedTimeActivityGameMgr:showBoughtResultTips(info)
    if info.result then
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "gui.limit.time.buy.success")
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "gui.limit.time.buy.fail")
    end
    Lib.emitEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO)
  end
  
  function LimitedTimeActivityGameMgr:showPlayMustWinLotterySuccess()
    Lib.emitEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO)
  end
  
  function LimitedTimeActivityGameMgr:showBuyFailTip()
    UI:getWnd("commonDialog"):onShow(true, {
      title = Lang:toText("g2052.gui.bidding_rank.preview_tip"),
      desc = Lang:toText("gui.whether.enter.recharge"),
      confirmCallback = function()
        Interface.onRecharge(1)
      end,
      cancelCallback = function()
      end
    })
  end
  
  local function getItemHaveStatus(data)
    local goodData = LimitedTimeGiftItemConfig:getCfgById(data.giftContent[1])
    local isHave = Me:checkBusinessItemUnlock(goodData.awardType, goodData.itemId)
    return isHave
  end
  
  function LimitedTimeActivityGameMgr:checkSignalItemCanBought(data, signalLimitGiftData)
    local isHave = getItemHaveStatus(data)
    if data.limitCounts < 0 then
      return not isHave
    end
    if signalLimitGiftData[data.giftKey] then
      local boughtNum = 0
      if signalLimitGiftData[data.giftKey] == true then
        boughtNum = 1
      else
        boughtNum = signalLimitGiftData[data.giftKey] or 0
      end
      if isHave then
      end
      return boughtNum < data.limitCounts
    else
      return not isHave
    end
  end
  
  function LimitedTimeActivityGameMgr:getItemInfo(item)
    local data = {}
    if item.awardType == 1 then
      local cfg = AppearanceConfig:getCfgById(item.itemId)
      if cfg then
        data.itemIcon = cfg.icon
        data.itemCount = item.itemCount
        data.itemName = item.itemName or ""
        if item.quality then
          data.quality = item.quality
        else
          data.quality = cfg.rarity
        end
      end
    elseif item.awardType == 2 then
      local cfg = PetConfig:getCfgById(item.itemId)
      if cfg then
        data = item
      end
    elseif item.awardType == 3 then
      local cfg = CarConfig:getCfgById(item.itemId)
      if cfg then
        data.itemIcon = cfg.icon
        data.itemCount = item.itemCount
        data.itemName = cfg.throwCfgName
        data.quality = item.quality
      end
    elseif item.awardType == 4 then
      data = item
    end
    return data
  end
else
  function LimitedTimeActivityGameMgr:checkIsCanBuy(player, item)
    if not item then
      return false
    end
    return true
  end
  
  function LimitedTimeActivityGameMgr:operationBuy(player, item, callback)
    local isCanBuy = self:checkIsCanBuy(player, item)
    if isCanBuy then
      local totalPrice = item.price
      if totalPrice < 0 then
        if callback then
          callback(false, item)
        end
        self:pushClientBoughtResult(player, item, false)
        return
      end
      if totalPrice == 0 then
        self:onBuySuccess(player, item)
        if callback then
          callback(true, item)
        end
      else
        local uniqueId = "limited_time_activity_" .. (item.activityId or 0) .. "_" .. (item.id or 0)
        Lib.payMoney(player, uniqueId, 0, totalPrice, function(isSucceed)
          if isSucceed then
            self:onBuySuccess(player, item)
          else
            self:pushClientBoughtResult(player, item, false)
          end
          if callback then
            callback(isSucceed, item)
          end
        end)
      end
    elseif callback then
      callback(false, item)
    end
  end
  
  local function onGetReward(player, item, giftNum)
    for _, val in pairs(item.giftContent) do
      local goodInfo = LimitedTimeGiftItemConfig:getCfgById(val)
      if goodInfo.awardType == 1 then
        player:addActivityDress(goodInfo.itemId)
      elseif goodInfo.awardType == 2 then
        player:addActivityPet(goodInfo.itemId)
      elseif goodInfo.awardType == 3 then
        player:addActivityCar(goodInfo.itemId)
      elseif goodInfo.awardType == 4 then
        player:addActivityHouse(goodInfo.itemId)
        local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(goodInfo.awardType, goodInfo.itemId)
        if goodsCfg then
          local businessData = player:getBusinessData()
          businessData[goodsCfg.goodsId] = true
          player:setBusinessData(businessData)
        end
      end
    end
  end
  
  function LimitedTimeActivityGameMgr:onBuySuccess(player, item)
    local giftNum = item.giftNum or 1
    if giftNum <= 0 then
      giftNum = 1
    end
    onGetReward(player, item, giftNum)
    self:reportLimitTimeBuySuccess(player.platformUserId, item)
    self:pushClientBoughtResult(player, item, true)
  end
  
  function LimitedTimeActivityGameMgr:onPlayerGetReward(player, item)
    if not player or not player:isValid() then
      return false
    end
    local giftNum = item.giftNum or 1
    local isCanBuy = self:checkIsCanBuy(player, item)
    if not isCanBuy then
      return false
    end
    onGetReward(player, item, giftNum)
    self:pushClientGrantResult(player, item)
    return true
  end
  
  function LimitedTimeActivityGameMgr:pushClientGrantResult(player, item)
    if not player or not player:isValid() then
      return
    end
    player:sendPacket({
      pid = "SCGetLimitTimeCardReward",
      item = item
    })
  end
  
  function LimitedTimeActivityGameMgr:reportLimitTimeBuySuccess(userId, item)
    local activityInfo = LimitedTimeActivityConfig:getCfgById(item.activityId)
    if activityInfo.type == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT or activityInfo.type == Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT then
      local eventKey = "limited_giftpack_buy"
      local parts = {
        limited_gift_id = item.id,
        activity_id = item.activityId
      }
      GameAnalytics.NewDesign(userId, eventKey, parts)
    elseif activityInfo.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW then
      local eventKey = "limited_draw_buy"
      local parts = {
        activity_id = item.activityId,
        draw_id = item.id,
        buy_activity_price = item.price,
        lucky_draw_type = item.luckyDrawType
      }
      GameAnalytics.NewDesign(userId, eventKey, parts)
    elseif activityInfo.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD then
      local eventKey = "monthly_card_buy"
      local parts = {
        activity_id = item.activityId,
        card_id = item.id
      }
      GameAnalytics.NewDesign(userId, eventKey, parts)
    elseif activityInfo.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL then
      local eventKey = "turntable_buy"
      local parts = {
        activity_id = item.activityId,
        buy_activity_price = item.price,
        turntable_id = item.id
      }
      GameAnalytics.NewDesign(userId, eventKey, parts)
    end
  end
  
  function LimitedTimeActivityGameMgr:pushClientBoughtResult(player, item, result)
    if not item or not item.activityId then
      return
    end
    local activityInfo = LimitedTimeActivityConfig:getCfgById(item.activityId)
    if result and activityInfo.type ~= Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT and activityInfo.type ~= Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT and activityInfo.type ~= Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
      return
    end
    player:sendPacket({
      pid = "SCLimitTimeItemBoughtResult",
      activityType = activityInfo.type,
      activityId = item.activityId,
      id = item.id,
      giftNum = item.giftNum or 1,
      result = result
    })
  end
end
return LimitedTimeActivityGameMgr
