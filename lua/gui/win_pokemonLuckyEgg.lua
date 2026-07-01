local LuaTimer = T(Lib, "LuaTimer")
local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
local PokemonLuckyExtraConfig = T(Config, "PokemonLuckyExtraConfig")
local PokemonLuckyRareConfig = T(Config, "PokemonLuckyRareConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local UIAnimationManager = T(UILib, "UIAnimationManager")
local UIRedDotMgr = require("script_client.ui.ui_red_dot_manager")
local LuckyEggTabRes = {
  [Define.LuckyEggTabType.flashTab] = {
    tabTitleTxt = Lang:toText("gui_lucky_egg_flash"),
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_angel_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_flash_ticket",
    selectTabIcon = "set:pokemon_lucky_egg.json image:img_0_flashicon_over",
    normalTabIcon = "set:pokemon_lucky_egg.json image:img_0_flashicon_on",
    buyBtnTitleColor = "\226\150\162FFA40502",
    buyBtnPriceColor = "\226\150\162FFFFFE00",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_red"
  },
  [Define.LuckyEggTabType.eliteTab] = {
    tabTitleTxt = Lang:toText("gui_lucky_egg_elite"),
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_elite_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_elite_ticket",
    selectTabIcon = "set:pokemon_lucky_egg.json image:img_0_eliteicon_over",
    normalTabIcon = "set:pokemon_lucky_egg.json image:img_0_eliteicon_on",
    buyBtnTitleColor = "\226\150\162FFC22500",
    buyBtnPriceColor = "\226\150\162FF871700",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_yellow"
  },
  [Define.LuckyEggTabType.normalTab] = {
    tabTitleTxt = Lang:toText("gui_lucky_egg_normal"),
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_norm_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_norm_ticket",
    selectTabIcon = "set:pokemon_lucky_egg.json image:img_0_normicon_over",
    normalTabIcon = "set:pokemon_lucky_egg.json image:img_0_normicon_on",
    buyBtnTitleColor = "\226\150\162FF14608E",
    buyBtnPriceColor = "\226\150\162FF0A3F5F",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_blue"
  }
}

function M:init()
  WinBase.init(self, "PokemonLuckyEgg.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgBg = self:child("PokemonLuckyEgg-bg")
  self.lytDraw = self:child("PokemonLuckyEgg-Draw")
  self.lytEggContent = self:child("PokemonLuckyEgg-egg-content")
  self.btnCardPoolBtn = self:child("PokemonLuckyEgg-cardPoolBtn")
  self.txtCardPoolTxt = self:child("PokemonLuckyEgg-cardPoolTxt")
  self.imgCardPoolIcon = self:child("PokemonLuckyEgg-cardPoolIcon")
  self.txtSTitle = self:child("PokemonLuckyEgg-STitle")
  self.lytRewardBg = self:child("PokemonLuckyEgg-reward-bg")
  self.txtRewardTitle = self:child("PokemonLuckyEgg-rewardTitle")
  self.imgRewardGoodBg = self:child("PokemonLuckyEgg-rewardGoodBg")
  self.imgRewardGoodIcon = self:child("PokemonLuckyEgg-rewardGoodIcon")
  self.txtRewardProcess = self:child("PokemonLuckyEgg-rewardProcess")
  self.btnProbabilityBtn = self:child("PokemonLuckyEgg-probabilityBtn")
  self.txtProbabilityTxt = self:child("PokemonLuckyEgg-probabilityTxt")
  self.lytTabPanel = self:child("PokemonLuckyEgg-tabPanel")
  self.lytTab1 = self:child("PokemonLuckyEgg-Tab1")
  self.imgNormalTab1 = self:child("PokemonLuckyEgg-normalTab1")
  self.imgSelectTab1 = self:child("PokemonLuckyEgg-selectTab1")
  self.imgTabIcon1 = self:child("PokemonLuckyEgg-TabIcon1")
  self.txtTabTitle1 = self:child("PokemonLuckyEgg-TabTitle1")
  self.lytTab2 = self:child("PokemonLuckyEgg-Tab2")
  self.imgNormalTab2 = self:child("PokemonLuckyEgg-normalTab2")
  self.imgSelectTab2 = self:child("PokemonLuckyEgg-selectTab2")
  self.imgTabIcon2 = self:child("PokemonLuckyEgg-TabIcon2")
  self.txtTabTitle2 = self:child("PokemonLuckyEgg-TabTitle2")
  self.lytTab3 = self:child("PokemonLuckyEgg-Tab3")
  self.imgNormalTab3 = self:child("PokemonLuckyEgg-normalTab3")
  self.imgSelectTab3 = self:child("PokemonLuckyEgg-selectTab3")
  self.imgTabIcon3 = self:child("PokemonLuckyEgg-TabIcon3")
  self.txtTabTitle3 = self:child("PokemonLuckyEgg-TabTitle3")
  self.imgTabTimeBg = self:child("PokemonLuckyEgg-tabTimeBg")
  self.imgTabTimeIcon = self:child("PokemonLuckyEgg-tabTimeIcon")
  self.txtTabTimeTxt = self:child("PokemonLuckyEgg-tabTimeTxt")
  self.imgTicketPanel = self:child("PokemonLuckyEgg-ticketPanel")
  self.txtTicketTitle = self:child("PokemonLuckyEgg-ticketTitle")
  self.imgTicketIcon = self:child("PokemonLuckyEgg-ticketIcon")
  self.txtTicketCount = self:child("PokemonLuckyEgg-ticketCount")
  self.btnTakeBtn1 = self:child("PokemonLuckyEgg-takeBtn1")
  self.txtTakeTile1 = self:child("PokemonLuckyEgg-takeTile1")
  self.txtTakePrice1 = self:child("PokemonLuckyEgg-takePrice1")
  self.imgTakeIcon1 = self:child("PokemonLuckyEgg-takeIcon1")
  self.txtTakeTicket1 = self:child("PokemonLuckyEgg-takeTicket1")
  self.btnTakeBtn10 = self:child("PokemonLuckyEgg-takeBtn10")
  self.txtTakeTile10 = self:child("PokemonLuckyEgg-takeTile10")
  self.txtTakePrice10 = self:child("PokemonLuckyEgg-takePrice10")
  self.imgTakeIcon10 = self:child("PokemonLuckyEgg-takeIcon10")
  self.txtTakeTicket10 = self:child("PokemonLuckyEgg-takeTicket10")
  self.lytTakeMust = self:child("PokemonLuckyEgg-takeMust")
  self.txtTakeMustTxt = self:child("PokemonLuckyEgg-takeMustTxt")
  self.txtTakeMustStar = self:child("PokemonLuckyEgg-takeMustStar")
  self.txtTakeMustCount = self:child("PokemonLuckyEgg-takeMustCount")
  self.lytModelPanel = self:child("PokemonLuckyEgg-egg-modelPanel")
  self.actorEggModel = self:child("PokemonLuckyEgg-eggModel")
  self.btnBtnClose = self:child("PokemonLuckyEgg-BtnClose")
  self.lytCoverBg = self:child("PokemonLuckyEgg-coverBg")
  self.lytLeftContent = self:child("PokemonLuckyEgg-leftContent")
  self.lytMidContent = self:child("PokemonLuckyEgg-midContent")
  self.lytRightContent = self:child("PokemonLuckyEgg-rightContent")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.txtTakeMustStar:AddChildWindow(self.itemStarLevel)
  self.itemStarLevel:invoke("updateUI", 4, 0, 2)
  self.btnWishBtn = self:child("PokemonLuckyEgg-wishBtn")
  self.txtWishTitle = self:child("PokemonLuckyEgg-wishTitle")
  self.imgEggShadowBg = self:child("PokemonLuckyEgg-eggShadowBg")
  self.modelEffect1 = self:child("PokemonLuckyEgg-modelEffect1")
  self.modelEffect2 = self:child("PokemonLuckyEgg-modelEffect2")
  self.rewardEffect = self:child("PokemonLuckyEgg-rewardEffect")
  self.rewardEffect:SetVisible(false)
  self.lyFlashRedPanelReward = self:child("PokemonLuckyEgg-flash_red_panel_reward")
  self.lyFlashRedPanelReward:SetVisible(false)
  self.lyEliteRedPanelReward = self:child("PokemonLuckyEgg-elite_red_panel_reward")
  self.lyEliteRedPanelReward:SetVisible(false)
  self.lyNormalRedPanelReward = self:child("PokemonLuckyEgg-normal_red_panel_reward")
  self.lyNormalRedPanelReward:SetVisible(false)
  self.lyEliteRedPanelTen = self:child("PokemonLuckyEgg-elite_red_panel_ten")
  self.lyEliteRedPanelTen:SetVisible(false)
  self.lyNormalRedPanelTen = self:child("PokemonLuckyEgg-normal_red_panel_ten")
  self.lyNormalRedPanelTen:SetVisible(false)
  self.lyFlashRedPanelTen = self:child("PokemonLuckyEgg-flash_red_panel_ten")
  self.lyFlashRedPanelTen:SetVisible(false)
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED, self.lytTab1, 0, 0, "LuckyEggFlashTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED, self.lytTab2, 0, 0, "LuckyEggEliteTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED, self.lytTab3, 0, 0, "LuckyEggNormalTab")
  local parentType = Define.UI_RED_DOT_TYPE.LUCKY_EGG_TAB_RED
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, self.lyEliteRedPanelTen, 0, 0, "LuckyEggEliteTen", nil, parentType, "LuckyEggEliteTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_EXTRA_AWARD, self.lyEliteRedPanelReward, 0, 0, "LuckyEggEliteAward", nil, parentType, "LuckyEggEliteTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, self.lyNormalRedPanelTen, 0, 0, "LuckyEggNormalTen", nil, parentType, "LuckyEggNormalTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_EXTRA_AWARD, self.lyNormalRedPanelReward, 0, 0, "LuckyEggNormalAward", nil, parentType, "LuckyEggNormalTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, self.lyFlashRedPanelTen, 0, 0, "LuckyEggFlashTen", nil, parentType, "LuckyEggFlashTab")
  UIRedDotMgr:addOneRedNodeByKey(Define.UI_RED_DOT_TYPE.LUCKY_EGG_EXTRA_AWARD, self.lyFlashRedPanelReward, 0, 0, "LuckyEggFlashAward", nil, parentType, "LuckyEggFlashTab")
  self.imgRewardPBG = self:child("PokemonLuckyEgg-rewardPBG")
  self.imgRewardFrame = self:child("PokemonLuckyEgg-rewardFrame")
  self.btnShop = self:child("PokemonLuckyEgg-Shop")
  self.btnBtnSkip = self:child("PokemonLuckyEgg-BtnSkip")
  self.tabInitPosY = {}
  self.tabInitPosY[1] = self.lytTab1:GetYPosition()
  self.tabInitPosY[2] = self.lytTab2:GetYPosition()
  self.tabInitPosY[3] = self.lytTab3:GetYPosition()
  self.txtSTitle:SetText(Lang:toText("gui_lucky_egg_title"))
  self.txtCardPoolTxt:SetText(Lang:toText("gui_lucky_egg_card_pool"))
  self.txtRewardTitle:SetText(Lang:toText("gui_lucky_egg_extra_reward"))
  self.txtProbabilityTxt:SetText(Lang:toText("gui_lucky_egg_probability"))
  self.txtTicketTitle:SetText(Lang:toText("gui_lucky_egg_ticket_title"))
  self.txtWishTitle:SetText(Lang:toText("gui_lucky_egg_wish_btn"))
  self:initCurrency()
  self:adapterUIShow()
end

function M:adapterUIShow()
  UIMgr.UIShowManage:adapterFixedSize(self.lytModelPanel, 1280, 720)
  UIMgr.UIShowManage:adapterFixedSize(self.lytLeftContent, 1280, 720)
  UIMgr.UIShowManage:adapterFixedSize(self.lytMidContent, 1280, 720)
  UIMgr.UIShowManage:adapterFixedSize(self.lytRightContent, 1280, 720)
end

function M:initCurrency()
  self.llCurrencyMoney = self:child("PokemonLuckyEgg-Currency-Money")
  self.llGoldDiamond = self:child("PokemonLuckyEgg-Gold-Diamond")
  self.llCashCoupon = self:child("PokemonLuckyEgg-Cash-Coupon")
  local money_currency = UIMgr:new_widget("common_currency")
  money_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  money_currency:invoke("setCurrencyType", "gold_coin")
  self.llCurrencyMoney:AddChildWindow(money_currency)
  local diamonds_currency = UIMgr:new_widget("common_currency")
  diamonds_currency:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  diamonds_currency:invoke("setCurrencyType", World.cfg.useFDiamonds and "fDiamonds" or "gDiamonds")
  self.llGoldDiamond:AddChildWindow(diamonds_currency)
  local cash_coupon = UIMgr:new_widget("common_currency")
  cash_coupon:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  cash_coupon:invoke("setCurrencyType", "gameCashCoupon")
  self.llCashCoupon:AddChildWindow(cash_coupon)
end

function M:initEvent()
  self:subscribe(self.btnShop, UIEvent.EventButtonClick, function()
    Me:gameBehaviorReport("ui", "shop")
    UI:getWnd("pokemon_Shop"):onShow(true)
  end)
  self:subscribe(self.btnCardPoolBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonLuckyPool"):onShow(true, self.curSelectTab)
  end)
  self:subscribe(self.btnProbabilityBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonLuckyProbability"):onShow(true, self.curSelectTab)
  end)
  self:subscribe(self.imgRewardGoodIcon, UIEvent.EventWindowClick, function()
    UI:getWnd("pokemonLuckyExtra"):onShow(true, self.curSelectTab)
  end)
  self:subscribe(self.lytTab1, UIEvent.EventWindowClick, function()
    self.curSelectTab = 1
    self:updateTabViewShow()
  end)
  self:subscribe(self.lytTab2, UIEvent.EventWindowClick, function()
    self.curSelectTab = 2
    self:updateTabViewShow()
  end)
  self:subscribe(self.lytTab3, UIEvent.EventWindowClick, function()
    self.curSelectTab = 3
    self:updateTabViewShow()
  end)
  self:subscribe(self.btnTakeBtn1, UIEvent.EventButtonClick, function()
    local battlePetList = Me:getValue("packetPetList")
    if #battlePetList + 1 > World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
        if not ret then
          return
        end
        UI:getWnd("pokemonPacket"):onShow("packet")
      end)
    else
      self:clickTakeLuckyEgg(0)
    end
  end)
  self:subscribe(self.btnTakeBtn10, UIEvent.EventButtonClick, function()
    local battlePetList = Me:getValue("packetPetList")
    if #battlePetList + 1 > World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
        if not ret then
          return
        end
        UI:getWnd("pokemonPacket"):onShow("packet")
      end)
    else
      if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM and UI:isOpen("pokemonGuide") then
        UI:getWnd("pokemonGuide"):onShow(false)
      end
      self:clickTakeLuckyEgg(1)
    end
  end)
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CLOSE_LUCKY then
      Me:gotoNextGuide()
    else
      if Me:getGainFirstOrangePet() == 1 then
        Me:isCanShowGiftBgWnd(Define.TRIGGER_GIFT_TYPE.TIME)
      end
      self:onHide()
    end
  end)
  self:subscribe(self.btnBtnSkip, UIEvent.EventButtonClick, function()
    self:endAllTakeEggAnimation()
  end)
  self:subscribe(self.btnWishBtn, UIEvent.EventButtonClick, function()
    UI:getWnd("pokemonLuckyWish"):onShow(true, self.curSelectTab)
  end)
end

function M:subscribeEvent()
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LUCKY_EGG_INFO, function(luckyResult)
    self:updateEggModelShow(2, luckyResult)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_UPDATE_LUCKY_EGG_FAIL, function()
    self:updateCoverBgShow(false)
  end)
  self._allEvent[#self._allEvent + 1] = Lib.subscribeEvent(Event.EVENT_PUSH_CUR_SERVER_TIME, function(curServerTime)
    self.curDistanceTime = curServerTime - os.time()
    self:startFlashTabDownTime()
  end)
end

function M:clickTakeLuckyEgg(takeType)
  if self.lytCoverBg:IsVisible() then
    return
  end
  if Me:isInPreBattleOrBattle() then
    return
  end
  if takeType == 1 then
    if self.curSelectTab == Define.LuckyEggTabType.eliteTab then
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, false, nil, nil, "LuckyEggEliteTen")
    elseif self.curSelectTab == Define.LuckyEggTabType.normalTab then
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, false, nil, nil, "LuckyEggNormalTen")
    elseif self.curSelectTab == Define.LuckyEggTabType.flashTab then
      UIRedDotMgr:updateRedNodeShowByRedType(Define.UI_RED_DOT_TYPE.LUCKY_EGG_TEN_BTN, false, nil, nil, "LuckyEggFlashTen")
    end
  end
  local priceData = PokemonLuckyPriceConfig:getDataByPoolIdAndTakeType(self.curSelectTab, takeType)
  if self:checkItemMoney(priceData) then
    local packet = {
      pid = "takeLuckyEggAward",
      tabType = self.curSelectTab,
      takeType = takeType
    }
    Me:sendPacket(packet)
    self:updateCoverBgShow(true)
  elseif priceData.currencyType == 3 then
    UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_not_sufficient_funds", function(ret)
      if not ret then
        return
      end
      UI:openWnd("pokemon_gold_exchange")
    end)
  else
    UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "ui_lack_money", function(ret)
      if not ret then
        return
      end
      Interface.onRecharge(1)
    end)
  end
end

function M:updateCoverBgShow(show)
  self.lytCoverBg:SetVisible(show)
  self.lytEggContent:SetVisible(not show)
end

function M:initTabListShow(selectTab)
  self.curSelectTab = selectTab or World.cfg.luckyEggTabsSort[1]
  self:updateTabBtnShow()
  self:startFlashTabDownTime()
  self:updateTabViewShow()
end

function M:updateTabBtnShow()
  self.imgTabTimeBg:SetVisible(false)
  self.lytTab1:SetVisible(false)
  self.lytTab2:SetVisible(false)
  self.lytTab3:SetVisible(false)
  local openTabList = {}
  local flashTabIsOpen = false
  local remainTime = self:getFlashTabRemainTime()
  for key, val in pairs(World.cfg.luckyEggTabsSort) do
    if val == Define.LuckyEggTabType.flashTab then
      if 0 < remainTime then
        table.insert(openTabList, val)
        flashTabIsOpen = true
      end
    else
      table.insert(openTabList, val)
    end
  end
  for key, val in pairs(openTabList) do
    self["lytTab" .. val]:SetYPosition(self.tabInitPosY[key])
    self["lytTab" .. val]:SetVisible(true)
    if val == Define.LuckyEggTabType.flashTab then
      self.imgTabTimeBg:SetVisible(true)
    end
    if not flashTabIsOpen and self.curSelectTab == Define.LuckyEggTabType.flashTab then
      self.curSelectTab = val
      self:updateTabViewShow()
    end
  end
end

function M:getFlashTabRemainTime()
  local flashEndTime = os.time(World.cfg.luckyEggFlashEndTime)
  local curTime = os.time() + self.curDistanceTime
  local remainTime = flashEndTime - curTime
  return remainTime or 0
end

function M:startFlashTabDownTime()
  if self.flashDownTimer then
    LuaTimer:cancel(self.flashDownTimer)
    self.flashDownTimer = nil
  end
  local remainTime = self:getFlashTabRemainTime()
  if 0 < remainTime then
    local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(remainTime))
    local remainDay = math.floor(remainTime / 3600 / 24)
    if remainDay <= 0 then
      self.txtTabTimeTxt:SetText(text)
    else
      self.txtTabTimeTxt:SetText(remainDay .. "D  " .. text)
    end
    self.flashDownTimer = LuaTimer:scheduleTimer(function()
      remainTime = remainTime - 1
      local text = string.format("%02d:%02d:%02d", Lib.timeFormatting(remainTime))
      local remainDay = math.floor(remainTime / 3600 / 24)
      if remainDay <= 0 then
        self.txtTabTimeTxt:SetText(text)
      else
        self.txtTabTimeTxt:SetText(remainDay .. "D  " .. text)
      end
      if remainTime < 0 then
        self.txtTabTimeTxt:SetText("00:00:00")
        self:updateTabBtnShow()
        if self.flashDownTimer then
          LuaTimer:cancel(self.flashDownTimer)
          self.flashDownTimer = nil
        end
      end
    end, 1000)
  end
end

function M:initView(selectTab)
  self.curDistanceTime = 0
  Me:sendPacket({
    pid = "requestCurServerTime"
  })
  self:initTabListShow(selectTab)
  self:updateCoverBgShow(false)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  UIRedDotMgr:updateLuckyEggExtraRedShow()
end

function M:updateEggModelShow(actionType, luckyResult)
  if actionType == 1 then
    self.actorEggModel:SetActor1("g2038_egg_" .. self.curSelectTab .. ".actor", "idle")
    self.actorEggModel:UpdateSelf(1)
    self.modelEffect1:SetVisible(false)
    self.modelEffect2:SetVisible(false)
    self.actorEggModel:SetWidth({0, 500})
    self.actorEggModel:SetHeight({0, 500})
    if self.takeSoundSit then
      Me:stopSound(self.takeSoundSit)
    end
    self.imgEggShadowBg:SetYPosition({0, 200})
    self:updateSkipBtnShow(false)
    self:updateCoverBgShow(false)
  else
    self.curLuckyResult = luckyResult
    self:playEggTakeNarrow()
    self:updateSkipBtnShow(true)
    self:updateCoverBgShow(true)
  end
end

function M:playEggTakeNarrow()
  self.actorEggModel:SetWidth({0, 500})
  self.actorEggModel:SetHeight({0, 500})
  if self.animationEgg then
    UIAnimationManager:stop(self.animationEgg)
    self.animationEgg = nil
  end
  self.animationEgg = UIAnimationManager:play(self.actorEggModel, "luckyEggAnimation")
  self.imgEggShadowBg:SetYPosition({0, 145})
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  self.effectTimer = LuaTimer:scheduleTimer(function()
    self:playEggTakeShake()
  end, 1000, 1)
end

function M:playEggTakeShake()
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  self.takeSoundSit = Me:playSoundByKey("lucky_taking")
  self.modelEffect1:SetVisible(true)
  self.modelEffect1:UnprepareEffect()
  self.modelEffect1:SetEffectName("g2038_choudan_bg_1.effect")
  local maxQuality = self:getTheMaxQuality(self.curLuckyResult)
  self.actorEggModel:SetActor1("g2038_egg_" .. self.curSelectTab .. ".actor", "start" .. maxQuality)
  self.actorEggModel:UpdateSelf(1)
  self.effectTimer = LuaTimer:scheduleTimer(function()
    self:playEggTakeLight()
  end, 4400, 1)
end

function M:playEggTakeLight()
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  self.modelEffect2:SetVisible(true)
  self.modelEffect2:UnprepareEffect()
  self.modelEffect2:SetEffectName("g2038_choudan_boom_1.effect")
  self.effectTimer = LuaTimer:scheduleTimer(function()
    self:endAllTakeEggAnimation()
  end, 500, 1)
end

function M:endAllTakeEggAnimation()
  if self.animationEgg then
    UIAnimationManager:stop(self.animationEgg)
    self.animationEgg = nil
  end
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  self:updateCountAndTicket()
  UIRedDotMgr:updateLuckyEggExtraRedShow()
  if Me:isInPreBattleOrBattle() then
    return
  end
  if #self.curLuckyResult == 1 then
    UI:getWnd("pokemonLuckyOnceTake"):onShow(true)
    UI:getWnd("pokemonLuckyOnceTake"):initView(self.curSelectTab, self.curLuckyResult[1])
  else
    UI:getWnd("pokemonLuckyTenTake"):onShow(true)
    UI:getWnd("pokemonLuckyTenTake"):initView(self.curSelectTab, self.curLuckyResult)
  end
  self.actorEggModel:RemoveActor()
  self:updateEggModelShow(1)
end

function M:getTheMaxQuality()
  local maxQuality = 1
  for key, pkmInfo in pairs(self.curLuckyResult) do
    local config = PokemonConfig:getConfigById(pkmInfo.cfgId)
    if maxQuality < config.quality then
      maxQuality = config.quality
    end
  end
  return maxQuality
end

function M:updateTabViewShow()
  self.imgBg:SetImage(LuckyEggTabRes[self.curSelectTab].eggBgRes)
  self.imgTicketIcon:SetImage(LuckyEggTabRes[self.curSelectTab].ticketResIcon)
  self.txtTakeTile1:SetText(LuckyEggTabRes[self.curSelectTab].buyBtnTitleColor .. Lang:toText("gui_lucky_egg_take1"))
  self.txtTakeTile10:SetText(LuckyEggTabRes[self.curSelectTab].buyBtnTitleColor .. Lang:toText("gui_lucky_egg_take10"))
  self.btnTakeBtn1:SetNormalImage(LuckyEggTabRes[self.curSelectTab].buyBtnRes)
  self.btnTakeBtn1:SetPushedImage(LuckyEggTabRes[self.curSelectTab].buyBtnRes)
  self.btnTakeBtn10:SetNormalImage(LuckyEggTabRes[self.curSelectTab].buyBtnRes)
  self.btnTakeBtn10:SetPushedImage(LuckyEggTabRes[self.curSelectTab].buyBtnRes)
  self.txtSTitle:SetText(Lang:toText("gui_lucky_egg_title" .. self.curSelectTab))
  self.lyFlashRedPanelReward:SetVisible(false)
  self.lyEliteRedPanelReward:SetVisible(false)
  self.lyNormalRedPanelReward:SetVisible(false)
  self.lyFlashRedPanelTen:SetVisible(false)
  self.lyEliteRedPanelTen:SetVisible(false)
  self.lyNormalRedPanelTen:SetVisible(false)
  self.btnWishBtn:SetVisible(false)
  if self.curSelectTab == Define.LuckyEggTabType.eliteTab then
    self.lyEliteRedPanelReward:SetVisible(true)
    self.lyEliteRedPanelTen:SetVisible(true)
    self.btnWishBtn:SetVisible(true)
  elseif self.curSelectTab == Define.LuckyEggTabType.normalTab then
    self.lyNormalRedPanelReward:SetVisible(true)
    self.lyNormalRedPanelTen:SetVisible(true)
  elseif self.curSelectTab == Define.LuckyEggTabType.flashTab then
    self.lyFlashRedPanelReward:SetVisible(true)
    self.lyFlashRedPanelTen:SetVisible(true)
  end
  for i = 1, 3 do
    if i == self.curSelectTab then
      self["imgNormalTab" .. i]:SetVisible(false)
      self["imgSelectTab" .. i]:SetVisible(true)
      self["imgTabIcon" .. i]:SetImage(LuckyEggTabRes[i].selectTabIcon)
      self["txtTabTitle" .. i]:SetText("\226\150\162FF575757" .. LuckyEggTabRes[i].tabTitleTxt)
    else
      self["imgNormalTab" .. i]:SetVisible(true)
      self["imgSelectTab" .. i]:SetVisible(false)
      self["imgTabIcon" .. i]:SetImage(LuckyEggTabRes[i].normalTabIcon)
      self["txtTabTitle" .. i]:SetText("\226\150\162FFFFFFFF" .. LuckyEggTabRes[i].tabTitleTxt)
    end
  end
  self:updateEggModelShow(1)
  self:updateCountAndTicket()
end

function M:updateCountAndTicket()
  local priceData = PokemonLuckyPriceConfig:getDataByPoolId(self.curSelectTab)
  local isCanTicket = false
  local bagTicketNum = 0
  for key, val in pairs(priceData) do
    if 0 < val.ticket_count then
      isCanTicket = true
    end
    bagTicketNum = Me:getTrayItemCountByFullName(val.fullName)
    if bagTicketNum >= val.ticket_count then
      self["imgTakeIcon" .. key]:SetVisible(false)
      self["txtTakeTicket" .. key]:SetVisible(true)
      self["txtTakeTicket" .. key]:SetImage(LuckyEggTabRes[self.curSelectTab].ticketResIcon)
      self["txtTakePrice" .. key]:SetText(LuckyEggTabRes[self.curSelectTab].buyBtnPriceColor .. val.ticket_count)
    else
      self["imgTakeIcon" .. key]:SetVisible(true)
      self["txtTakeTicket" .. key]:SetVisible(false)
      local currencyIcon = "set:pokemonMain.json image:icon_coin"
      if val.currencyType == 0 or val.currencyType == 4 then
        currencyIcon = "set:pokemonMain.json image:icon_dimond"
      end
      self["imgTakeIcon" .. key]:SetImage(currencyIcon)
      self["txtTakePrice" .. key]:SetText(LuckyEggTabRes[self.curSelectTab].buyBtnPriceColor .. val.currency_count)
    end
  end
  self.imgTicketPanel:SetVisible(isCanTicket)
  self.txtTicketCount:SetText(bagTicketNum)
  self.rewardEffect:SetVisible(false)
  local luckyEggExtra = Me:getLuckyEggExtra()
  local luckyEggInfo = Me:getLuckyEggInfo()
  local curCount = 0
  if luckyEggInfo[self.curSelectTab] then
    curCount = luckyEggInfo[self.curSelectTab].totalTakeCounts
  end
  local extraData = PokemonLuckyExtraConfig:getDataByPoolId(self.curSelectTab)
  for key, val in pairs(extraData) do
    if curCount < val.take_count then
      self.txtRewardProcess:SetText(curCount .. "/" .. val.take_count)
      break
    elseif not luckyEggExtra[val.id] then
      self.rewardEffect:SetVisible(true)
    end
  end
  if curCount >= extraData[#extraData].take_count then
    self.txtRewardProcess:SetText(extraData[#extraData].take_count .. "/" .. extraData[#extraData].take_count)
  end
  local curExtraId = 0
  for k, data in pairs(extraData) do
    if curExtraId == 0 and curCount < data.take_count then
      curExtraId = k
    end
  end
  if curExtraId == 0 then
    curExtraId = 1
  end
  if 0 < extraData[curExtraId].pkm_id then
    local pkmInfo = PokemonConfig:getConfigById(extraData[curExtraId].pkm_id)
    self.imgRewardGoodIcon:SetImage(pkmInfo.icon)
    local qualityFrame = PokemonConfig:getQualityFrame(extraData[curExtraId].pkm_id)
    self.imgRewardFrame:SetImage(qualityFrame)
    self.imgRewardGoodBg:SetVisible(false)
    self.imgRewardPBG:SetVisible(true)
    self.imgRewardFrame:SetVisible(true)
  else
    local setting = require("common.setting")
    local cfg = setting:fetch("item", extraData[curExtraId].fullName)
    if cfg then
      self.imgRewardGoodIcon:SetImage(cfg.icon)
    end
    self.imgRewardGoodBg:SetVisible(true)
    self.imgRewardPBG:SetVisible(false)
    self.imgRewardFrame:SetVisible(false)
  end
  local rareData = PokemonLuckyRareConfig:getMustDataByPoolId(self.curSelectTab)
  if rareData then
    local curRareCount = 0
    if luckyEggInfo[self.curSelectTab] then
      curRareCount = luckyEggInfo[self.curSelectTab][rareData.rare_id] or 0
    end
    local remainCount = rareData.end_count - curRareCount
    if remainCount < 0 then
      remainCount = 0
    end
    self.txtTakeMustCount = self:child("PokemonLuckyEgg-takeMustCount")
    self.txtTakeMustCount:SetText(Lang:toText({
      "gui_lucky_egg_must_lucky1",
      remainCount
    }))
    self.txtTakeMustTxt:SetText(Lang:toText("gui_lucky_egg_must_lucky2"))
    self.lytTakeMust:SetVisible(true)
  else
    self.lytTakeMust:SetVisible(false)
  end
end

function M:checkItemMoney(priceData)
  local bagTicketNum = Me:getTrayItemCountByFullName(priceData.fullName)
  if bagTicketNum >= priceData.ticket_count and priceData.ticket_count > 0 then
    return true
  elseif priceData.isPay then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if asset >= priceData.currency_count then
        return true
      else
      end
    end
  else
    if Coin:countByCoinName(Me, Coin:coinNameByCoinId(priceData.currencyType)) >= priceData.currency_count then
      return true
    else
    end
  end
  return false
end

function M:updateSkipBtnShow(visible)
  self.btnBtnSkip:SetVisible(visible)
  if not Me:isGuideFinish() and Me:getCurGuideIndex() >= Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY and Me:getCurGuideIndex() <= Define.GUIDE_INDEX.FINISH_TAKE_TEN then
    self.btnBtnSkip:SetVisible(false)
  end
end

function M:onHide()
  UI:closeWnd("pokemonLuckyEgg")
end

function M:onShow(isShow, selectTab)
  if isShow then
    if not UI:isOpen(self) then
      Lib.logDebug("isShow lucky egg")
      UI:openWnd("pokemonLuckyEgg", selectTab)
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen(selectTab)
  self._allEvent = {}
  self:subscribeEvent()
  self:initView(selectTab)
  self.btnShop:SetVisible(UI:getWnd("pokemonMain").btnPokemonMainShop:IsVisible())
  self:updateSkipBtnShow(false)
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.effectTimer then
    LuaTimer:cancel(self.effectTimer)
    self.effectTimer = nil
  end
  if self.animationEgg then
    UIAnimationManager:stop(self.animationEgg)
    self.animationEgg = nil
  end
  if self.flashDownTimer then
    LuaTimer:cancel(self.flashDownTimer)
    self.flashDownTimer = nil
  end
  if self.takeSoundSit then
    Me:stopSound(self.takeSoundSit)
  end
end

return M
