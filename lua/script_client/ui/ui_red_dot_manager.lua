local UIRedDotMgr = L("UIRedDotMgr", {})
local LuaTimer = T(Lib, "LuaTimer")
local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local BlessItemConfig = T(Config, "BlessItemConfig")
local InitParentRedType = {
  [Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED] = Define.UI_RED_DOT_TYPE.MAIN_LUCKY_EGG_RED,
  [Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED] = Define.UI_RED_DOT_TYPE.MAIN_REGULAR_GIFT_RED,
  [Define.UI_RED_DOT_TYPE.PET_BOOK_ITEM_RED] = Define.UI_RED_DOT_TYPE.MAIN_PET_BOOK_BTN_RED,
  [Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE] = Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED,
  [Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_STAR_UP] = Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED,
  [Define.UI_RED_DOT_TYPE.TEAM_CELL_EMPTY] = Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED,
  [Define.UI_RED_DOT_TYPE.PET_CAN_LEVEL_UP] = Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED,
  [Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_BTN] = Define.UI_RED_DOT_TYPE.TEAM_UPGRADE_TAB,
  [Define.UI_RED_DOT_TYPE.TEAM_RISE_BTN] = Define.UI_RED_DOT_TYPE.TEAM_RISE_TAB,
  [Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT] = Define.UI_RED_DOT_TYPE.TEAM_RISE_BTN,
  [Define.UI_RED_DOT_TYPE.TEAM_RISE_CONFIRM] = Define.UI_RED_DOT_TYPE.TEAM_RISE_SELECT,
  [Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_BTN] = Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_TAB,
  [Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_SELECT] = Define.UI_RED_DOT_TYPE.TEAM_STAR_UP_BTN,
  [Define.UI_RED_DOT_TYPE.BLESS_PET_RED] = Define.UI_RED_DOT_TYPE.MAIN_BLESS_RED
}
local InitRedEffectRes = {
  [Define.UI_RED_DOT_TYPE.MAIN_DAILY_TASK_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_REGULAR_GIFT_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_DAILY_LOTTERY_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_LUCKY_EGG_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_SHOP_BTN_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_FIRST_RECHARGE_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_PET_BOOK_BTN_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_PET_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_BLESS_RED] = "effect",
  [Define.UI_RED_DOT_TYPE.LIMITED_TIME_ACTIVITY] = "effect",
  [Define.UI_RED_DOT_TYPE.COMBINATION_GIFT] = "effect",
  [Define.UI_RED_DOT_TYPE.SIGNAL_GIFT] = "effect",
  [Define.UI_RED_DOT_TYPE.MAIN_SUBSCRIBE_RED] = "effect"
}

function UIRedDotMgr:init()
  self.redDotTypeNode = {}
  self:initEvent()
  LuaTimer:scheduleTimer(function()
    self:loginRefreshAllRedState()
  end, 3000, 1)
end

function UIRedDotMgr:addOneRedNodeByKey(redType, parentNode, posX, posY, redKey, redResType, parentType, parentKey)
  local redKey = redKey or 1
  if not self.redDotTypeNode[redType] then
    self.redDotTypeNode[redType] = {}
  end
  if not self.redDotTypeNode[redType][redKey] then
    self.redDotTypeNode[redType][redKey] = {}
    self.redDotTypeNode[redType][redKey].childRedList = {}
    self.redDotTypeNode[redType][redKey].isVisible = false
  end
  if parentNode and not self.redDotTypeNode[redType][redKey].node then
    local curResType = redResType or InitRedEffectRes[redType]
    local nodeKey = redType .. "_" .. redKey
    local redNode = self:createRedNodeRes(nodeKey, posX, posY, curResType)
    parentNode:AddChildWindow(redNode)
    self.redDotTypeNode[redType][redKey].node = redNode
    self.redDotTypeNode[redType][redKey].node:SetVisible(self.redDotTypeNode[redType][redKey].isVisible)
  end
  local parentType = parentType or InitParentRedType[redType]
  local parentKey = parentKey or 1
  if parentType and self.redDotTypeNode[parentType] and self.redDotTypeNode[parentType][parentKey] then
    self.redDotTypeNode[redType][redKey].parentType = parentType
    self.redDotTypeNode[redType][redKey].parentKey = parentKey
    local childTemp = {childType = redType, childKey = redKey}
    table.insert(self.redDotTypeNode[parentType][parentKey].childRedList, childTemp)
  end
end

function UIRedDotMgr:updateRedNodeShowByRedType(redType, visible, posX, posY, redKey, redResType, parentType, parentKey)
  if visible and parentType and parentKey then
    self:updateRedNodeShowByRedType(parentType, visible, nil, nil, parentKey)
  end
  local redKey = redKey or 1
  if self.redDotTypeNode[redType] == nil then
    self:addOneRedNodeByKey(redType, nil, posX, posY, redKey, redResType, parentType, parentKey)
  elseif self.redDotTypeNode[redType][redKey] == nil then
    self:addOneRedNodeByKey(redType, nil, posX, posY, redKey, redResType, parentType, parentKey)
  end
  self.redDotTypeNode[redType][redKey].isVisible = visible
  if self.redDotTypeNode[redType][redKey].node then
    self.redDotTypeNode[redType][redKey].node:SetVisible(visible)
  end
  if self.redDotTypeNode[redType][redKey].parentType then
    if visible then
      self:updateParentRedShowByChild(self.redDotTypeNode[redType][redKey].parentType, self.redDotTypeNode[redType][redKey].parentKey)
    else
      self:updateParentRedHideByChild(self.redDotTypeNode[redType][redKey].parentType, self.redDotTypeNode[redType][redKey].parentKey)
    end
  end
end

function UIRedDotMgr:updateParentRedShowByChild(redType, redKey)
  if self.redDotTypeNode[redType] == nil then
    return
  end
  if self.redDotTypeNode[redType][redKey] == nil then
    return
  end
  self:updateRedNodeShowByRedType(redType, true, nil, nil, redKey)
end

function UIRedDotMgr:updateParentRedHideByChild(redType, redKey)
  local isAllHide = true
  for _, childTemp in pairs(self.redDotTypeNode[redType][redKey].childRedList) do
    if self.redDotTypeNode[childTemp.childType][childTemp.childKey].isVisible then
      isAllHide = false
    end
  end
  if isAllHide then
    self:updateRedNodeShowByRedType(redType, false, nil, nil, redKey)
  end
end

function UIRedDotMgr:getRedShowStateByRedType(redType, redKey)
  local redKey = redKey or 1
  if self.redDotTypeNode[redType] and self.redDotTypeNode[redType][redKey] then
    return self.redDotTypeNode[redType][redKey].isVisible
  end
  return false
end

function UIRedDotMgr:removeRedNodeByRedType(redType, redKey)
  if redType and redKey and self.redDotTypeNode[redType] and self.redDotTypeNode[redType][redKey] then
    self.redDotTypeNode[redType][redKey].node = nil
  end
end

function UIRedDotMgr:createOneRedNodeSignal(nodeKey, parentNode, posX, posY, redResType)
  local redNode = self:createRedNodeRes(nodeKey, posX, posY, redResType)
  parentNode:AddChildWindow(redNode)
  return redNode
end

function UIRedDotMgr:createRedNodeRes(nodeKey, posX, posY, redResType)
  local redNode = GUIWindowManager.instance:CreateGUIWindow1("StaticImage", "redNode" .. (nodeKey or ""))
  if redResType == "effect" then
    redNode:UnprepareEffect()
    redNode:SetEffectName("reddot.effect")
    redNode:SetArea({
      0,
      posX or 0
    }, {
      0,
      posY or 0
    }, {0, 19}, {0, 19})
  else
    redNode:SetImage("set:pokemon_shop.json image:img_red_dian")
    redNode:SetArea({
      0,
      posX or 0
    }, {
      0,
      posY or 0
    }, {0, 17}, {0, 19})
  end
  redNode:SetVisible(false)
  redNode:SetTouchable(false)
  redNode:SetVerticalAlignment(0)
  redNode:SetHorizontalAlignment(2)
  return redNode
end

function UIRedDotMgr:initEvent()
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_REFRESH_PLAYER_BAG", Event.EVENT_REFRESH_PLAYER_BAG, function()
    self:updateLuckyEggTicketNum(Define.LuckyEggTabType.flashTab)
    self:updateLuckyEggTicketNum(Define.LuckyEggTabType.eliteTab)
    self:updateLuckyEggTicketNum(Define.LuckyEggTabType.normalTab)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_RECEIVE_LUCKY_EGG_EXTRA", Event.EVENT_RECEIVE_LUCKY_EGG_EXTRA, function()
    self:updateLuckyEggExtraRedShow()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_DAILY_LOTTERY_NUM_CHANGE", Event.EVENT_DAILY_LOTTERY_NUM_CHANGE, function()
    self:updateDailyLotteryRedShow()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_GET_DAILY_TASK_STATUS_LIST", Event.EVENT_GET_DAILY_TASK_STATUS_LIST, function(task_status_list)
    self:updateDailyTaskRedShow(task_status_list)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_DAILY_TASK_STATUS_CHANGE", Event.EVENT_DAILY_TASK_STATUS_CHANGE, function(task_status_list)
    self:updateDailyTaskRedShow(task_status_list)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_GET_PET_COLLECT", Event.EVENT_GET_PET_COLLECT, function()
    self:updatePetBookNewState()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_CHANGE_BATTLE_PET", Event.EVENT_CHANGE_BATTLE_PET, function()
    self:updateEmptyCellRedPointList()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonBag Lib event : EVENT_CHANGE_PACKET_PET", Event.EVENT_CHANGE_PACKET_PET, function()
    self:updateEmptyCellRedPointList()
  end)
  Lib.subscribeEvent(Event.EVENT_GAIN_BLESS_ITEM, function(canBlessPokemonIndexList)
    for _, index in pairs(canBlessPokemonIndexList) do
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.BLESS_PET_RED, true, nil, nil, index)
    end
  end)
end

function UIRedDotMgr:loginRefreshAllRedState()
  self:updateLuckyEggTicketNum(Define.LuckyEggTabType.flashTab)
  self:updateLuckyEggTicketNum(Define.LuckyEggTabType.eliteTab)
  self:updateLuckyEggTicketNum(Define.LuckyEggTabType.normalTab)
  self:updateLuckyEggExtraRedShow()
  self:updateRegularGiftRedShow()
  self.isOpenedDailyLottery = false
  self:updateDailyLotteryRedShow()
  self.isOpenedDailyTask = false
  self:getDailyTaskData()
  self:updatePetBookNewState()
  self:initWakeRedPointList()
  self:updateEmptyCellRedPointList()
end

function UIRedDotMgr:updateLuckyEggTicketNum(ticketType)
  local fullName = "myplugin/item_ticket_02"
  local redKey = "LuckyEggEliteTen"
  local parentType = Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED
  local parentKey = "LuckyEggEliteTab"
  if ticketType == Define.LuckyEggTabType.normalTab then
    fullName = "myplugin/item_ticket_03"
    redKey = "LuckyEggNormalTen"
    parentKey = "LuckyEggNormalTab"
  elseif ticketType == Define.LuckyEggTabType.flashTab then
    fullName = "myplugin/item_ticket_01"
    redKey = "LuckyEggFlashTen"
    parentKey = "LuckyEggFlashTab"
  end
  local eliteTicketNum = Me:getTrayItemCountByFullName(fullName)
  if 0 < eliteTicketNum and eliteTicketNum % 10 == 0 and not self:getRedShowStateByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, redKey) then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, true, nil, nil, redKey, nil, parentType, parentKey)
  end
end

function UIRedDotMgr:updateLuckyEggExtraRedShow()
  local luckyEggExtra = Me:getLuckyEggExtra()
  local luckyEggInfo = Me:getLuckyEggInfo()
  for curTab = Define.LuckyEggTabType.flashTab, Define.LuckyEggTabType.normalTab do
    local curCount = 0
    if luckyEggInfo[curTab] then
      curCount = luckyEggInfo[curTab].totalTakeCounts
    end
    local extraData = PokemonLuckyExtraConfig:getDataByPoolId(curTab)
    local isHaveExtra = false
    for _, val in pairs(extraData) do
      if curCount >= val.take_count and not luckyEggExtra[val.id] then
        isHaveExtra = true
      end
      local redKey = "LuckyEggEliteAward"
      local parentType = Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED
      local parentKey
      if curTab == Define.LuckyEggTabType.eliteTab then
        redKey = "LuckyEggEliteAward"
        parentKey = "LuckyEggEliteTab"
      elseif curTab == Define.LuckyEggTabType.normalTab then
        redKey = "LuckyEggNormalAward"
        parentKey = "LuckyEggNormalTab"
      elseif curTab == Define.LuckyEggTabType.flashTab then
        redKey = "LuckyEggFlashAward"
        parentKey = "LuckyEggFlashTab"
      end
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_EXTRA_AWARD, isHaveExtra, nil, nil, redKey, nil, parentType, parentKey)
    end
  end
end

function UIRedDotMgr:updateRegularGiftRedShow()
  local buyInfo = Me:getRegularBuyInfo()
  local giftList = RegularGiftConfig:getAllConfig()
  local haveFreeBuy = {
    false,
    false,
    false
  }
  for _, itemData in pairs(giftList) do
    local itemId = itemData.id
    local curBuyNum = 0
    if buyInfo[tostring(itemId)] then
      curBuyNum = buyInfo[tostring(itemId)].curBuyNum
    end
    if 0 < itemData.buyCount then
      local remainCount = itemData.buyCount - curBuyNum
      if 0 < remainCount and itemData.finalPrice == 0 then
        haveFreeBuy[itemData.tabId] = true
      end
    elseif itemData.finalPrice == 0 then
      haveFreeBuy[itemData.tabId] = true
    end
  end
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, haveFreeBuy[1], nil, nil, "RegularGiftTabDayBtn")
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, haveFreeBuy[2], nil, nil, "RegularGiftTabWeekBtn")
  UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.REGULAR_GIFT_TAB_RED, haveFreeBuy[3], nil, nil, "RegularGiftTabMonthBtn")
end

function UIRedDotMgr:updateDailyLotteryRedShow()
  local curlotteryNum = Me:getCurLotteryNum()
  if not UIRedDotMgr.isOpenedDailyLottery and Me:isTodayFirstLoginGame() then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_DAILY_LOTTERY_RED, true)
  else
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_DAILY_LOTTERY_RED, 0 < curlotteryNum)
  end
end

function UIRedDotMgr:getDailyTaskData()
  Me:sendPacket({
    pid = "GetDailyTaskStatusList"
  })
end

function UIRedDotMgr:updateDailyTaskRedShow(task_status_list)
  if not UIRedDotMgr.isOpenedDailyTask and Me:isTodayFirstLoginGame() then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_DAILY_TASK_RED, true)
  else
    local haveTaskReceive = false
    for _, task_status in pairs(task_status_list) do
      if task_status.finished == 1 and task_status.rewarded == 0 then
        haveTaskReceive = true
      end
    end
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_DAILY_TASK_RED, haveTaskReceive)
  end
end

function UIRedDotMgr:updatePetBookNewState()
  local isInit = false
  if not self.petBookItemRedState then
    self.petBookItemRedState = {}
    isInit = true
  end
  local bookRecord = Me:getValue("bookRecord")
  local pokemon_configs = PokemonConfig:getAllConfig()
  for _, config in pairs(pokemon_configs) do
    if config.bookId ~= 0 and bookRecord[tostring(config.id)] then
      if isInit then
        self.petBookItemRedState[config.id] = 1
      elseif self.petBookItemRedState[config.id] == nil then
        self.petBookItemRedState[config.id] = 2
        UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.PET_BOOK_ITEM_RED, true, nil, nil, config.id)
      end
    end
  end
end

function UIRedDotMgr:initWakeRedPointList()
  Me:getBattlePokemon(function(battlePokemonList)
    local packetPokemonList = {}
    Me:getPacketPokemon(function(pokemonList)
      packetPokemonList = pokemonList
    end)
    for index, pokemon in pairs(battlePokemonList) do
      local canWake = PokemonConfig:checkCanRise(pokemon, packetPokemonList, battlePokemonList)
      pokemon:setCanWakeRedPointShow(canWake)
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_PET_CELL_RISE, canWake, nil, nil, index)
    end
  end)
end

function UIRedDotMgr:updateEmptyCellRedPointList()
  Me:getBattlePokemon(function(battlePokemonList)
    for index = 1, 4 do
      local enoughPokemon = #Me:getValue("packetPetList") > 0 and 4 > #Me:getValue("battlePetList")
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.TEAM_CELL_EMPTY, not battlePokemonList[index] and enoughPokemon, nil, nil, index)
    end
  end)
end

return UIRedDotMgr
