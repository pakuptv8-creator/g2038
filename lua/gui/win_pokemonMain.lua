local RechargeAwardConfig = T(Config, "RechargeAwardConfig")
local LuaTimer = T(Lib, "LuaTimer")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local DailyLotteryConfig = T(Config, "DailyLotteryConfig")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local subscribeEvent = require("script_client.event_cache")

function M:init()
  WinBase.init(self, "PokemonMain.json", false)
  self:initUI()
  self:initEvent()
  self.initExtraWnd()
  self:resetPlayerInfo()
  if World.cfg.isCloseLotteryEntrance then
    local curPickList = Me:getCurLotteryPickList()
    local curlotteryNum = Me:getCurLotteryNum()
    if #curPickList <= 3 and curlotteryNum <= 0 then
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], false)
      UI:closeWnd("dailyLottery")
    end
  end
end

function M:initUI()
  self.lytPokemonMainBattlePanel = self:child("PokemonMain-BattlePanel")
  self.lytPokemonMainSafePanel = self:child("PokemonMain-SafePanel")
  self.lytPokemonMainRTLayout = self:child("PokemonMain-RTLayout")
  self.lytPokemonMainMiniMap = self:child("PokemonMain-MiniMap")
  self.lytPokemonMainMiniMap:SetAlpha(0.0)
  self.btnPokemonMainDrive = self:child("PokemonMain-Drive")
  self.btnPokemonMainBackHome = self:child("PokemonMain-BackHome")
  self.btnPokemonMainShop = self:child("PokemonMain-Shop")
  self.txtPokemonMainShopTitle = self:child("PokemonMain-ShopTitle")
  self.txtPokemonMainShopTitle:SetText(Lang:toText("ui_shop"))
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_SHOP_BTN_RED, self.btnPokemonMainShop, -5, 5)
  self.btnPokemonMainSubscribe = self:child("PokemonMain-Subscribe")
  self.txtPokemonMainSubscribeTitle = self:child("PokemonMain-SubscribeTitle")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_SUBSCRIBE_RED, self.btnPokemonMainSubscribe, -5, 5)
  self.lstPokemonMainPlayerInfoList = self:child("PokemonMain-PlayerInfoList")
  self.lyPokemonMainTeamInfoPanel = self:child("PokemonMain-TeamInfoPanel")
  local teamNode = UIMgr:new_widget("pokemonPlayerTeamInfo")
  teamNode:invoke("initViewData")
  self.lyPokemonMainTeamInfoPanel:AddChildWindow(teamNode)
  self.btnPokemonMainTimingGift = self:child("PokemonMain-TimingGift")
  self.txtPokemonMainTimingTitle = self:child("PokemonMain-TimingTitle")
  self.txtPokemonMainTimingTitle:SetText("00:00:00")
  self.btnPokemonMainTimingGift:SetVisible(false)
  self.btnPokemonMainGrowthGift = self:child("PokemonMain-GrowthGift")
  self.txtPokemonMainGrowthTitle = self:child("PokemonMain-GrowthTitle")
  self.txtPokemonMainGrowthTitle:SetText("00:00:00")
  self.btnPokemonMainGrowthGift:SetVisible(false)
  self.btnPokemonMainReward = self:child("PokemonMain-Reward")
  self:child("PokemonMain-reward_title_text"):SetText(Lang:toText("ui_daily_reward"))
  self:child("PokemonMain-reward_confirm_text"):SetText(Lang:toText("ui_reward_confirm"))
  self.txtPokemonMainRewardNuw = self:child("PokemonMain-reward_nuw")
  self.imgPokemonMainRewardIcon = self:child("PokemonMain-reward_icon")
  self.lytPokemonMainDailyFDiamondsReward = self:child("PokemonMain-daily_fDiamonds_reward")
  self.btnPokemonMainRewardConfirm = self:child("PokemonMain-reward_confirm ")
  self.imgPokemonMainSprayCountdownIcon = self:child("PokemonMain-spray_countdown_icon")
  self.txtPokemonMainSprayCountdownNum = self:child("PokemonMain-spray_countdown_num")
  UIMgr.MainUIMenuManage:initOneShowTypeMenu(Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU, self:root(), -200, 70)
  UIMgr.MainUIMenuManage:initOneShowTypeMenu(Define.Menu_BTN_SHOW_TYPE.BOTTOM_RIGHT_MENU, self:root(), -20, -20)
  self:updateRightTopRootPos()
  local unlockMod = PlayerExpConfig:getUnlockModByLv(10)
  self:showLimitModule(unlockMod)
  self:updateGloryHallState()
  local luckyMenuBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[1])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_LUCKY_EGG_RED, luckyMenuBtn, -5, 5)
  local dailyLotteryBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[2])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_DAILY_LOTTERY_RED, dailyLotteryBtn, -5, 5)
  self.awardStatus = 0
  local firstRechargeBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[3])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_FIRST_RECHARGE_RED, firstRechargeBtn, -5, 5)
  local regularGiftBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[4])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_REGULAR_GIFT_RED, regularGiftBtn, -5, 5)
  local dailyTaskBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[5])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_DAILY_TASK_RED, dailyTaskBtn, -5, 5)
  local petMenuBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[6])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_PET_RED, petMenuBtn, -5, 5)
  local bookMenuBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[7])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_PET_BOOK_BTN_RED, bookMenuBtn, -5, 5)
  local teamMenuBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[9])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_TEAM_RED, teamMenuBtn, -5, 5)
  local blessMenuBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[11])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.MAIN_BLESS_RED, blessMenuBtn, -5, 5)
  local limitedTimeActivityBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[17])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LIMITED_TIME_ACTIVITY, limitedTimeActivityBtn, -5, 5)
  local limitedTimeActivityBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[15])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.COMBINATION_GIFT, limitedTimeActivityBtn, -5, 5)
  local limitedTimeActivityBtn = UIMgr.MainUIMenuManage:getMenuBtnByName(Define.Menu_BTN_NAME[16])
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.SIGNAL_GIFT, limitedTimeActivityBtn, -5, 5)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainDrive event : EventButtonClick", self.btnPokemonMainDrive, UIEvent.EventButtonClick, function()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainBackHome event : EventButtonClick", self.btnPokemonMainBackHome, UIEvent.EventButtonClick, function()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainShop event : EventButtonClick", self.btnPokemonMainShop, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("ui", "shop")
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainSubscribe event : EventButtonClick", self.btnPokemonMainSubscribe, UIEvent.EventButtonClick, function()
    Plugins.CallTargetPluginFunc("subscribe_vip", "UpdateSubscribeVipUIOpen", true)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainReward event : EventButtonClick", self.btnPokemonMainReward, UIEvent.EventButtonClick, function()
    if not World.cfg.useFDiamonds then
      self.btnPokemonMainReward:SetVisible(false)
      return
    end
    self:onShowDailyFDiamondsRewardWnd()
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainRewardConfirm event : EventButtonClick", self.btnPokemonMainRewardConfirm, UIEvent.EventButtonClick, function()
    if not World.cfg.useFDiamonds then
      self.lytPokemonMainDailyFDiamondsReward:SetVisible(false)
      self.btnPokemonMainReward:SetVisible(false)
      return
    end
    Me:sendPacket({
      pid = "GetDailyFDiamondsReward"
    })
    self.lytPokemonMainDailyFDiamondsReward:SetVisible(false)
    self.btnPokemonMainReward:SetVisible(false)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainTimingGift event : EventButtonClick", self.btnPokemonMainTimingGift, UIEvent.EventButtonClick, function()
    UI:openWnd("pokemonGiftBag", Define.TRIGGER_GIFT_TYPE.TIME)
  end)
  self:lightSubscribe("error!!!!! script_client win_pokemonMain btnPokemonMainGrowthGift event : EventButtonClick", self.btnPokemonMainGrowthGift, UIEvent.EventButtonClick, function()
    UI:openWnd("pokemonGiftBag", Define.TRIGGER_GIFT_TYPE.GROW)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_CHANGE_BATTLE_PET", Event.EVENT_CHANGE_BATTLE_PET, function()
    Lib.logDebug("EVENT_CHANGE_BATTLE_PET")
    self:resetPlayerInfo()
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_PLAYER_ITEM_MODIFY", Event.EVENT_PLAYER_ITEM_MODIFY, function()
    Me:pagingItemsByBagType()
  end)
  subscribeEvent(Event.EVENT_FORCE_GUIDE, function(index)
    Lib.logInfo("EVENT_FORCE_GUIDE index = ", index)
    Me:gameBehaviorReport("gui_task", index)
    if index >= Define.GUIDE_INDEX.SELECT_INIT_POKEMON and index <= Define.GUIDE_INDEX.FINISH_SELECT_POKEMON then
      self:dealSelectGuide(index)
    elseif index >= Define.GUIDE_INDEX.UPGRADE_POKEMON_OPEN_PACKET and index <= Define.GUIDE_INDEX.FINISH_UPGRADE_POKEMON or index == Define.GUIDE_INDEX.OPEN_FOLLOW_PET or index == Define.GUIDE_INDEX.CONFIRM_FOLLOW_PET then
      self:dealUpgradeGuide(index)
    elseif index >= Define.GUIDE_INDEX.FILL_POKEMON_OPEN_PACKET and index <= Define.GUIDE_INDEX.FINISH_FILL_POKEMON then
      self:dealFillGuide(index)
    elseif index >= Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY and index <= Define.GUIDE_INDEX.FINISH_TAKE_TEN then
      self:dealLuckyGuide(index)
    elseif index >= Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_PACKET and index <= Define.GUIDE_INDEX.FINISH_WAKE_POKEMON then
      self:dealWakeGuide(index)
    elseif index >= Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO and index <= Define.GUIDE_INDEX.FINISH_CAPTURE_POKEMON then
      self:dealCaptureGuide(index)
    else
      self:openGuide(index)
    end
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_PLAYER_LEVEL_UP", Event.EVENT_PLAYER_LEVEL_UP, function(lv, unlockMod)
    self.unlockMod = unlockMod
    self:showLimitModule(unlockMod)
  end)
  Lib.subscribeEvent(Event.EVENT_GAIN_POKEMON, function()
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_PET_RED, true)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_SHOW_CHEATING", Event.EVENT_SHOW_CHEATING, function(name, time, pay)
    local content = {
      "gui_cheating_content",
      name,
      os.date("%y%m%d", time),
      pay
    }
    UI:getWnd("pokemonCommonDialog"):onShow("gui_cheating_title", content, nil, Define.COMMON_DIALOG_MODE.NOBUTTON)
  end)
  Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_CLIENT_CHANGE_SCENE_MAP", Event.EVENT_CLIENT_CHANGE_SCENE_MAP, function()
    self:updateRightTopRootPos()
  end)
end

function M:updateRightTopRootPos()
  local miniMap = World.CurMap.cfg.miniMap
  if miniMap then
    UIMgr.MainUIMenuManage:updateOneShowTypeMenuPos(Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU, -200, 70)
  else
    UIMgr.MainUIMenuManage:updateOneShowTypeMenuPos(Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU, -15, 70)
  end
end

function M:dealSelectGuide(index)
  if index == Define.GUIDE_INDEX.SELECT_INIT_POKEMON then
    UI:getWnd("pokemonOpenScreen"):onShow()
  end
  self:openGuide(index)
end

function M:dealUpgradeGuide(index)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[9], true)
  if index == Define.GUIDE_INDEX.UPGRADE_POKEMON_OPEN_PACKET then
  elseif index == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_POKEMON then
    if not UI:isOpen("pokemonPacket") then
      UI:getWnd("pokemonPacket"):onShow("battle")
      UI:getWnd("pokemonPacket"):selectTab(1)
    end
  elseif index == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_UPGRADE then
  elseif index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CONFIRM_UPGRADE then
    UI:getWnd("pokemonPacket"):openPopupUpgrade()
  elseif index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_UPGRADE then
  elseif index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_PACKET then
    Lib.logDebug("UPGRADE_POKEMON_CLOSE_PACKET")
    UI:getWnd("pokemonGuide"):onShow(false)
    Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
    return
  elseif index == Define.GUIDE_INDEX.FINISH_UPGRADE_POKEMON then
    if UI:isOpen("pokemonPacket") then
      UI:closeWnd("pokemonPacket")
    end
  elseif index == Define.GUIDE_INDEX.OPEN_FOLLOW_PET then
    if not UI:isOpen("pokemonPacket") then
      UI:getWnd("pokemonPacket"):onShow("battle")
      UI:getWnd("pokemonPacket"):selectTab(1)
    end
    UI:getWnd("pokemonPacket"):hidePopupUpgrade()
  elseif index == Define.GUIDE_INDEX.CONFIRM_FOLLOW_PET then
    Lib.logInfo("CONFIRM_FOLLOW_PET")
  end
  self:openGuide(index)
end

function M:dealCaptureGuide(index)
  if index == Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO then
  elseif index == Define.GUIDE_INDEX.CAPTURE_POKEMON_USE_BALL then
  elseif index == Define.GUIDE_INDEX.CAPTURE_POKEMON_CONFIRM_BALL then
    UI:getWnd("battle_main"):openCommandWinByType(3)
  elseif index == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
    UI:getWnd("pokemonCapture"):onShow()
    return
  elseif index == Define.GUIDE_INDEX.FINISH_CAPTURE_POKEMON then
  end
  self:openGuide(index)
end

function M:dealFillGuide(index)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[9], true)
  if index == Define.GUIDE_INDEX.FILL_POKEMON_OPEN_PACKET then
  elseif index == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_EMPTY then
    if not UI:isOpen("pokemonPacket") then
      UI:getWnd("pokemonPacket"):onShow("battle")
    end
  elseif index == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_POKEMON then
    UI:getWnd("pokemonPacket"):showReplace()
  elseif index == Define.GUIDE_INDEX.FILL_POKEMON_SAVE_QUEUE then
  elseif index == Define.GUIDE_INDEX.FINISH_FILL_POKEMON then
    if UI:isOpen("pokemonPacket") then
      UI:closeWnd("pokemonPacket")
    end
  elseif index == Define.GUIDE_INDEX.FILL_POKEMON_CLOSE_PACKET then
    UI:getWnd("pokemonReplace"):clickSave()
    return
  end
  self:openGuide(index)
end

function M:updateLimitActivityBtn()
  local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
  if LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT) then
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[15], true)
  else
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[15], false)
  end
  if LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT) then
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[16], true)
  else
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[16], false)
  end
  local needShowLimitTimeActivity = LimitedTimeActivityGameMgr:checkGroupActivityIsCanShow(Define.LIMITED_TIME_ACTIVITY_WND.COMMON_WND)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[17], needShowLimitTimeActivity)
end

function M:dealLuckyGuide(index)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[1], true)
  if index == Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY then
  elseif index == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
    if not UI:isOpen("pokemonLuckyEgg") then
      UI:getWnd("pokemonLuckyEgg"):onShow(true)
    end
  elseif index == Define.GUIDE_INDEX.TAKE_TEN_CLOSE then
  elseif index == Define.GUIDE_INDEX.TAKE_TEN_CLOSE_LUCKY then
  elseif index == Define.GUIDE_INDEX.FINISH_TAKE_TEN then
    UI:getWnd("pokemonLuckyEgg"):onHide()
  end
  self:openGuide(index)
end

function M:dealWakeGuide(index)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[9], true)
  if index == Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_PACKET then
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_TAB then
    if not UI:isOpen("pokemonPacket") then
      UI:getWnd("pokemonPacket"):onShow("battle")
      UI:getWnd("pokemonPacket"):selectTab(4)
    end
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_WND then
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_ADD_MATERIAL then
    UI:getWnd("pokemonPacket"):openWake()
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_MATERIAL then
    UI:getWnd("pokemonWake"):showWakeSelect()
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_MATERIAL then
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_WAKE then
    UI:getWnd("pokemonWake"):hideWakeSelect()
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_WND then
    UI:getWnd("pokemonWake"):checkWakeUp()
    return
  elseif index == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_PACKET then
    UI:getWnd("pokemonWake"):confirmWakeUp()
    return
  elseif index == Define.GUIDE_INDEX.FINISH_WAKE_POKEMON and UI:isOpen("pokemonPacket") then
    UI:closeWnd("pokemonPacket")
  end
  self:openGuide(index)
end

function M:openGuide(index)
  Lib.logInfo("openGuide index = ", index)
  UI:getWnd("pokemonGuide"):onShow(true, index)
  Lib.emitEvent(Event.EVENT_HIDE_BLOCK_INPUT)
end

function M:openPacket()
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_PLAYER_RECHARGE_STATUS", Event.EVENT_PLAYER_RECHARGE_STATUS, function(value)
    self.awardStatus = value
    self:updateFirstRedShow(value)
    self:updateFirstBtnShow()
    UI:getWnd("pokemon_recharge_award"):upDataWinInfo(self.awardStatus)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_PLAYER_RECHARGE_SUM", Event.EVENT_PLAYER_RECHARGE_SUM, function()
    self:updateFirstRedShow(Me:getRechargeAwardStatus())
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_DAILY_LOTTERY_RESPONE", Event.EVENT_DAILY_LOTTERY_RESPONE, function(index, crlcle, pickList)
    if World.cfg.isCloseLotteryEntrance then
      local curPickList = Me:getCurLotteryPickList()
      local curlotteryNum = Me:getCurLotteryNum()
      if #curPickList <= 3 and curlotteryNum <= 0 then
        UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], false)
        UI:closeWnd("dailyLottery")
        return
      end
    end
    local curCircle = Me:getCurLotteryCircle()
    local maxCircle = DailyLotteryConfig:getMaxCircle()
    if curCircle > maxCircle then
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], false)
    end
  end)
  self._allEvent[#self._allEvent + 1] = Lib.lightSubscribeEvent("error!!!!! script_client win_pokemonMain Lib event : EVENT_GYM_FINISH_CHANGE", Event.EVENT_GYM_FINISH_CHANGE, function()
    self:updateGloryHallState()
  end)
end

function M:updateGloryHallState()
  if Me:getGymFinish(World.cfg.gloryHallOpenGymId) == 1 then
    UIMgr.MainUIMenuManage:setMenuBtnColorProgram(Define.Menu_BTN_NAME[13], "NORMAL")
  else
    UIMgr.MainUIMenuManage:setMenuBtnColorProgram(Define.Menu_BTN_NAME[13], "GRAY")
  end
end

function M:initExtraWnd()
  UIMgr:registerWindow("battle_main")
  UIMgr:registerWindow("pokemonCapture")
  UIMgr:registerWindow("pokemonBag")
  UIMgr:registerWindow("battle_results")
  UIMgr:registerWindow("pokemon_Shop")
  UIMgr:registerWindow("pokemon_recharge_award")
  UIMgr:registerWindow("pokemonBigMap")
  UIMgr:registerWindow("pokemonRegularGift")
  UIMgr:registerWindow("pokemonGiftBag")
  UIMgr:registerWindow("pokemonPacket")
end

function M:initView()
end

function M:showLimitModule(unlockMod)
  self.btnPokemonMainShop:SetVisible(unlockMod[Define.MODULE_TYPE.MAIN_SHOP])
  self.btnPokemonMainSubscribe:SetVisible(unlockMod[Define.MODULE_TYPE.MAIN_SUBSCRIBE])
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[9], unlockMod[Define.MODULE_TYPE.MAIN_QUEUE], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[8], unlockMod[Define.MODULE_TYPE.MAIN_BAG], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[7], unlockMod[Define.MODULE_TYPE.MAIN_BOOK], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[6], unlockMod[Define.MODULE_TYPE.MAIN_PET], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[5], unlockMod[Define.MODULE_TYPE.MAIN_DAILY_TASK], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[1], unlockMod[Define.MODULE_TYPE.MAIN_LUCKY_EGG], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[4], unlockMod[Define.MODULE_TYPE.MAIN_REGULAR_GIFT], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[11], unlockMod[Define.MODULE_TYPE.MAIN_BLESS], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[10], unlockMod[Define.MODULE_TYPE.MAIN_LEADERBOARD], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[13], unlockMod[Define.MODULE_TYPE.MAIN_GLORY_HALL], true)
  UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[14], unlockMod[Define.MODULE_TYPE.MAIN_ROTARY_TABLE], true)
  if World.cfg.isCloseLotteryEntrance then
    local curPickList = Me:getCurLotteryPickList()
    local curlotteryNum = Me:getCurLotteryNum()
    if #curPickList <= 3 and curlotteryNum <= 0 then
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], false)
      UI:closeWnd("dailyLottery")
    else
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], unlockMod[Define.MODULE_TYPE.MAIN_DAILY_LOTTERY], true)
    end
  else
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[2], unlockMod[Define.MODULE_TYPE.MAIN_DAILY_LOTTERY], true)
  end
  self:updateFirstBtnShow()
  self:updateLimitActivityBtn()
end

function M:updateFirstBtnShow()
  if self.unlockMod and self.unlockMod[Define.MODULE_TYPE.MAIN_FIRST_RECHARGE] then
    local _, condition = RechargeAwardConfig:getRewardTypeItems(self.awardStatus + 1)
    if condition then
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[3], true, true)
    else
      UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[3], false, true)
    end
  else
    UIMgr.MainUIMenuManage:setMenuBtnVisible(Define.Menu_BTN_NAME[3], false, true)
  end
  UIMgr.MainUIMenuManage:updateMenuBtnPosShow(Define.Menu_BTN_SHOW_TYPE.TOP_RIGHT_MENU)
  UIMgr.MainUIMenuManage:updateMenuBtnPosShow(Define.Menu_BTN_SHOW_TYPE.BOTTOM_RIGHT_MENU)
end

function M:updateFirstRedShow(value)
  local awardStatus = value
  local rewardType = awardStatus + 1
  local rechargeSum = Me:getRechargeSum()
  local _, condition = RechargeAwardConfig:getRewardTypeItems(rewardType)
  if not condition then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_FIRST_RECHARGE_RED, false)
    return
  end
  if 1 <= rechargeSum / condition then
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_FIRST_RECHARGE_RED, true)
  else
    UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.MAIN_FIRST_RECHARGE_RED, false)
  end
end

function M:onShowDailyFDiamondsRewardWnd()
  local day = Me:getActiveDay()
  if World.cfg.dailyFDiamondsReward[day] then
    self.txtPokemonMainRewardNuw:SetText(World.cfg.dailyFDiamondsReward[day])
    self.fDiamondsCount = World.cfg.dailyFDiamondsReward[day]
    self.lytPokemonMainDailyFDiamondsReward:SetVisible(true)
  end
end

local function destroyLuaChildWindow(window)
  local count = window:GetChildCount()
  if count == 0 then
    return
  end
  for index = 1, count do
    local childWindow = window:GetChildByIndex(index - 1)
    destroyLuaChildWindow(childWindow)
    childWindow:invoke("onDestroy")
  end
end

function M:resetPlayerInfo()
  self.lstPokemonMainPlayerInfoList:ClearAllItem()
  local node = UIMgr:new_widget("pokemonPlayerInfo")
  node:invoke("initViewData", Me)
  self.lstPokemonMainPlayerInfoList:AddItem(node, true)
end

function M:updateGiftBtnTime(data)
  if self.giftBtnTimer then
    LuaTimer:cancel(self.giftBtnTimer)
    self.giftBtnTimer = nil
  end
  local maxTime = 0
  local GROW = 0
  local TIME = 0
  if data[Define.TRIGGER_GIFT_TYPE.GROW] and data[Define.TRIGGER_GIFT_TYPE.GROW][1] then
    GROW = data[Define.TRIGGER_GIFT_TYPE.GROW][1].time - os.time()
    GROW = GROW < 0 and 0 or GROW
  end
  if data[Define.TRIGGER_GIFT_TYPE.TIME] and data[Define.TRIGGER_GIFT_TYPE.TIME][1] then
    TIME = data[Define.TRIGGER_GIFT_TYPE.TIME][1].time - os.time()
    TIME = TIME < 0 and 0 or TIME
  end
  if GROW < TIME then
    maxTime = TIME
  else
    maxTime = GROW
  end
  local battleMain = UI:getWnd("battle_main")
  battleMain.btnCanvasGrowthGift:SetVisible(GROW ~= 0)
  battleMain.btnCanvasTimingGift:SetVisible(TIME ~= 0)
  self.btnPokemonMainGrowthGift:SetVisible(GROW ~= 0)
  self.btnPokemonMainTimingGift:SetVisible(TIME ~= 0)
  if maxTime == 0 then
    return
  end
  local time = maxTime
  self.giftBtnTimer = LuaTimer:scheduleTimer(function()
    time = time - 1
    TIME = TIME - 1
    GROW = GROW - 1
    if 0 <= GROW then
      self.txtPokemonMainGrowthTitle:SetText(Lib.getFormatTime(GROW))
      battleMain.txtCanvasGrowthTitle:SetText(Lib.getFormatTime(GROW))
    end
    if 0 <= TIME then
      self.txtPokemonMainTimingTitle:SetText(Lib.getFormatTime(TIME))
      battleMain.txtCanvasTimingTitle:SetText(Lib.getFormatTime(TIME))
    end
    self.btnPokemonMainGrowthGift:SetVisible(0 < GROW)
    self.btnPokemonMainTimingGift:SetVisible(0 < TIME)
    battleMain.btnCanvasGrowthGift:SetVisible(0 < GROW)
    battleMain.btnCanvasTimingGift:SetVisible(0 < TIME)
    if time <= 0 then
      LuaTimer:cancel(self.giftBtnTimer)
      self.giftBtnTimer = nil
    end
  end, 1000, maxTime)
end

function M:onHide()
  UI:closeWnd("pokemonMain")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("pokemonMain")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self:subscribeEvent()
  self:initView()
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
end

return M
