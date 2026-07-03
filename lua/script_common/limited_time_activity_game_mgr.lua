local setting = require("common.setting")
local LimitedTimeActivityGameMgr = _ENV.LimitedTimeActivityGameMgr
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local LimitedTimeGiftCombinedConfig = T(Config, "LimitedTimeGiftCombinedConfig")
local LimitedTimeGiftSignalConfig = T(Config, "LimitedTimeGiftSignalConfig")
if World.isClient then
  local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
  
  -- ULTRA HACK: Show all activities
  function LimitedTimeActivityGameMgr:checkGroupActivityIsCanShow(wndType)
    return true
  end

  function LimitedTimeActivityGameMgr:addSpecialCell(parent, itemInfo, area)
    if not parent then
      return
    end
    local type = itemInfo.awardType
    local isNeed = false
    local specialCell = parent:GetChildByName("SpecialPKMCell")
    if specialCell then
      specialCell:SetVisible(false)
    end
    if type == 3 then
      local specialCell = parent:GetChildByName("SpecialPKMCell")
      if not specialCell then
        local cell = UIMgr:new_widget("pokemonLuckyPoolItem")
        cell:SetName("SpecialPKMCell")
        cell:SetHorizontalAlignment(1)
        if area then
          cell:SetArea(area[1] or {0, 0}, area[2] or {0, 0}, area[3] or {0, 90}, area[4] or {0, 114})
        else
          cell:SetArea({0, 0}, {0, 0}, {0, 90}, {0, 114})
        end
        parent:AddChildWindow(cell)
        specialCell = cell
      end
      if specialCell and itemInfo then
        local pkmInfo = Lib.copy(PokemonConfig:getConfigById(itemInfo.itemId))
        if not pkmInfo then
          specialCell:SetVisible(false)
          return
        end
        pkmInfo.newStar = tonumber(itemInfo.extraParams)
        specialCell:invoke("setSpecialModel", pkmInfo)
        specialCell:SetVisible(true)
        isNeed = true
      end
    end
    return isNeed
  end
  
  function LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(value)
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[15], value)
  end
  
  function LimitedTimeActivityGameMgr:updateSignalLimitBtnShow(value)
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[16], value)
  end
  
  function LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
    local needShowLimitTimeActivity = LimitedTimeActivityGameMgr:checkGroupActivityIsCanShow(Define.LIMITED_TIME_ACTIVITY_WND.COMMON_WND)
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[17], needShowLimitTimeActivity)
  end
  
  function LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnRedDot(value)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LIMITED_TIME_ACTIVITY, value)
  end
  
  function LimitedTimeActivityGameMgr:updateCombinedLimitBtnRedDot(value)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.COMBINATION_GIFT, value)
  end
  
  function LimitedTimeActivityGameMgr:updateSignalLimitBtnRedDot(value)
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.SIGNAL_GIFT, value)
  end
  
  function LimitedTimeActivityGameMgr:limitTimeAwardItemClickFunc(data, dx, dy)
    if data.awardType == 1 then
      UI:getWnd("pokemonItemDetail"):onShow(data.itemName, dx, dy)
    elseif data.awardType == 3 then
      UI:getWnd("pokemonLuckyDetails"):onShow(true, data.itemId)
    end
  end
  
  function LimitedTimeActivityGameMgr:checkLimitTimeActivityIsUnlock()
    local unlockMod = PlayerExpConfig:getUnlockModByLv(Me:getPlayerLevel())
    if unlockMod[Define.MODULE_TYPE.LIMIT_TIME_ACTIVITY] then
      return true
    end
    return false
  end
  
  function LimitedTimeActivityGameMgr:checkDrawContent(luckyDrawType)
    local battlePetList = Me:getValue("packetPetList")
    local needCount = luckyDrawType == Define.LUCKY_DRAW_TYPE.TEN and 10 or 1
    if #battlePetList + needCount > World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
        if not ret then
          return
        end
        UI:getWnd("pokemonPacket"):onShow("packet")
      end)
      return false
    end
    return true
  end
  
  function LimitedTimeActivityGameMgr:clientClickBoughtBtn(activityType, params)
    if activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
      if UI:getWnd("limitTimeCombination"):getBuyingState() then
        return
      end
      UI:getWnd("pokemonCommonDialog"):onShow("gui.limit.time.common.tips", "gui.limit.time.buy.confirm", function(ret)
        if not ret then
          return
        end
        if activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
          Lib.emitEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, true)
          Me:sendPacket({
            pid = "CSBuyLimitCombinationGift",
            activityId = params.activityId,
            id = params.id
          })
        end
      end)
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
      local giftNum = info.giftNum or 1
      if giftNum <= 0 then
        giftNum = 1
      end
      local item
      if info.activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
        item = LimitedTimeGiftCombinedConfig:getCfgById(info.id)
      elseif info.activityType == Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT then
        item = LimitedTimeGiftSignalConfig:getCfgById(info.id)
      end
      if item then
        local giftItemInfo = {}
        for key, val in pairs(item.giftContent) do
          local itemData = {}
          local goodInfo = LimitedTimeGiftItemConfig:getCfgById(val)
          if goodInfo.awardType == 1 then
            itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.ITEM
            itemData.item = goodInfo.itemName
            itemData.count = goodInfo.itemCount * giftNum
            itemData.highlight = false
          elseif goodInfo.awardType == 2 then
            itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.GOLD
            itemData.item = "item"
            itemData.count = goodInfo.itemCount * giftNum
            itemData.highlight = false
          elseif goodInfo.awardType == 3 then
            itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.PET
            itemData.item = goodInfo.itemId
            itemData.count = goodInfo.itemCount * giftNum
            itemData.highlight = false
          end
          table.insert(giftItemInfo, itemData)
        end
        UI:openWnd("buyGiftTip", giftItemInfo)
      else
        local message = Lang:toText("gui.limit.time.buy.success")
        Me:showCommonTip(1, message, 40)
      end
    else
      local message = Lang:toText("gui.limit.time.buy.fail")
      Me:showCommonTip(1, message, 40)
    end
  end
  
  function LimitedTimeActivityGameMgr:showBuyFailTip()
    UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_lack_money", function(ret)
      if not ret then
        return
      end
      Interface.onRecharge(1)
    end)
  end
  
  function LimitedTimeActivityGameMgr:getItemInfo(item)
    local data = {}
    if item.awardType == 1 then
      local cfg = setting:fetch("item", item.itemName)
      if cfg then
        data.itemIcon = cfg.icon
        data.itemCount = item.itemCount
        data.itemName = cfg.itemName
        if item.quality then
          data.quality = item.quality
        else
          data.quality = cfg.rarity
        end
      end
    elseif item.awardType == 2 then
      data.itemIcon = item.itemIcon
      data.itemCount = item.itemCount
      data.itemName = "common_coin"
      data.quality = item.quality
    elseif item.awardType == 3 then
      local pkmInfo = PokemonConfig:getConfigById(item.itemId)
      if pkmInfo then
        data.itemIcon = pkmInfo.icon
        data.itemCount = item.itemCount
        data.itemName = pkmInfo.name
        if item.quality then
          data.quality = item.quality
        else
          data.quality = pkmInfo.quality + 2
        end
        local cfg = setting:fetch("entity", pkmInfo.fullName)
        if cfg then
          data.actorName = cfg.actorName
          data.uiScale = cfg.uiScale and cfg.uiScale * 0.3 or 0.3
          data.uiOffset = cfg.uiActorOffset
        end
        data.itemIconFrame = ""
      end
    end
    return data
  end
else
  function LimitedTimeActivityGameMgr:checkIsCanBuy(player, item)
    if not item then
      return false
    end
    local giftNum = item.giftNum or 1
    if giftNum <= 0 then
      giftNum = 1
    end
    local items = {}
    local petNum = 0
    for key, val in pairs(item.giftContent or {}) do
      local goodInfo = LimitedTimeGiftItemConfig:getCfgById(val)
      if goodInfo.awardType == 1 then
        items[goodInfo.itemName] = goodInfo.itemCount * giftNum
      elseif goodInfo.awardType == 3 then
        petNum = petNum + 1
      end
    end
    local isPutBag = player:determineBackpackCapacity(items)
    if not isPutBag then
      player:sendPacket({
        pid = "showCommonTips",
        message = "gui_bag_not_enough",
        time = 40
      })
      return false
    end
    local battlePetList = player:getValue("packetPetList")
    if #battlePetList + petNum > World.cfg.maxBoxPetsCnt then
      player:sendPacket({
        pid = "showCommonTips",
        message = "gui_lucky_egg_receive_fail_full",
        time = 40
      })
      return false
    end
    return true
  end
  
  local function onGetReward(player, item, giftNum)
    for _, val in pairs(item.giftContent or {}) do
      local goodInfo = LimitedTimeGiftItemConfig:getCfgById(val)
      if goodInfo.awardType == 1 then
        player:obtainItemsByFullName(goodInfo.itemName, goodInfo.itemCount * giftNum, "limited_time_activity_item")
      elseif goodInfo.awardType == 2 then
        player:addCurrency("gold_coin", goodInfo.itemCount * giftNum, "limited_time_activity_item")
      elseif goodInfo.awardType == 3 then
        for i = 1, goodInfo.itemCount * giftNum do
          player:randomPokemon(goodInfo.itemId, tonumber(goodInfo.extraParams))
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
end
