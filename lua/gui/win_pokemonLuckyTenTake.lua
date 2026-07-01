local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local RaceConfig = T(Config, "RaceConfig")
local LuaTimer = T(Lib, "LuaTimer")
local PokemonConfig = T(Config, "PokemonConfig")
local UIAnimationManager = T(UILib, "UIAnimationManager")
local LuckyEggTabRes = {
  [1] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_angel_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_flash_ticket",
    buyBtnTitleColor = "\226\150\162FFA40502",
    buyBtnPriceColor = "\226\150\162FFFFFE00",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_red"
  },
  [2] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_elite_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_elite_ticket",
    buyBtnTitleColor = "\226\150\162FFC22500",
    buyBtnPriceColor = "\226\150\162FF871700",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_yellow"
  },
  [3] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_norm_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_norm_ticket",
    buyBtnTitleColor = "\226\150\162FF14608E",
    buyBtnPriceColor = "\226\150\162FF0A3F5F",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_blue"
  }
}

function M:init()
  WinBase.init(self, "PokemonLuckyTenTake.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgBg = self:child("PokemonLuckyTenTake-bg")
  self.lytTake = self:child("PokemonLuckyTenTake-Take")
  self.lytContent = self:child("PokemonLuckyTenTake-content")
  self.imgTicketPanel = self:child("PokemonLuckyTenTake-ticketPanel")
  self.txtTicketTitle = self:child("PokemonLuckyTenTake-ticketTitle")
  self.imgTicketIcon = self:child("PokemonLuckyTenTake-ticketIcon")
  self.txtTicketCount = self:child("PokemonLuckyTenTake-ticketCount")
  self.txtTitle = self:child("PokemonLuckyTenTake-title")
  self.lytPkmList = self:child("PokemonLuckyTenTake-pkmList")
  self.btnConfirmBtn = self:child("PokemonLuckyTenTake-confirmBtn")
  self.txtConfirmTxt = self:child("PokemonLuckyTenTake-confirmTxt")
  self.btnAgainBtn = self:child("PokemonLuckyTenTake-againBtn")
  self.txtTakePrice = self:child("PokemonLuckyTenTake-takePrice")
  self.imgTakeIcon = self:child("PokemonLuckyTenTake-takeIcon")
  self.txtAgainTips = self:child("PokemonLuckyTenTake-againTips")
  self.imgTakeTicket = self:child("PokemonLuckyTenTake-takeTicket")
  self.btnBtnClose = self:child("PokemonLuckyTenTake-BtnClose")
  self.lytModel = self:child("PokemonLuckyTenTake-model")
  self.modelEffect1 = self:child("PokemonLuckyTenTake-modelEffect1")
  self.modelEffect2 = self:child("PokemonLuckyTenTake-modelEffect2")
  self.actorEggModel = self:child("PokemonLuckyTenTake-eggModel")
  self.btnBtnSkip = self:child("PokemonLuckyTenTake-BtnSkip")
  self.imgRaceIcon = self:child("PokemonLuckyTenTake-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyTenTake-starIcon")
  self.imgNewIcon = self:child("PokemonLuckyTenTake-newIcon")
  self.txtNameTxt = self:child("PokemonLuckyTenTake-nameTxt")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.txtShowNextTxt = self:child("PokemonLuckyTenTake-showNextTxt")
  self.txtTicketTitle:SetText(Lang:toText("gui_lucky_egg_ticket_title"))
  self.txtConfirmTxt:SetText(Lang:toText("gui_lang_tip_sure"))
  self.txtTitle:SetText(Lang:toText("gui_lucky_egg_congratulation_again"))
  self.txtShowNextTxt:SetText(Lang:toText("gui_lucky_egg_show_next_pkm"))
  self.itemList = {}
  for i = 1, 10 do
    self.itemList[i] = UIMgr:new_widget("pokemonLuckyTenItem")
    local itemParent = self:child("PokemonLuckyTenTake-pkmItem" .. i)
    itemParent:AddChildWindow(self.itemList[i])
  end
end

function M:initEvent()
  self:subscribe(self.lytModel, UIEvent.EventWindowClick, function()
    self:updatePkmModelPanel()
  end)
  self:subscribe(self.btnBtnSkip, UIEvent.EventButtonClick, function()
    for i, pkmInfo in pairs(self.curPkmList) do
      if not pkmInfo.isShow then
        Me:sendPacket({
          pid = "sendEggResultTip",
          luckyResult = pkmInfo
        })
      end
    end
    self:updateShowPanelType(2)
  end)
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CLOSE then
      Me:gotoNextGuide()
    end
    self:onHide()
  end)
  self:subscribe(self.btnAgainBtn, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() >= Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY and Me:getCurGuideIndex() <= Define.GUIDE_INDEX.FINISH_TAKE_TEN then
      return
    end
    if Me:isInPreBattleOrBattle() then
      return
    end
    local battlePetList = Me:getValue("packetPetList")
    if #battlePetList + 10 > World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
        if not ret then
          return
        end
        UI:getWnd("pokemonPacket"):onShow("packet")
      end)
    else
      UI:getWnd("pokemonLuckyEgg"):clickTakeLuckyEgg(1)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView(poolId, pkmList)
  self.curPoolId = poolId
  self.curPkmList = pkmList
  self.tipList = pkmList
  self:initContentInfo(poolId, pkmList)
  self.curShowPkm = 0
  self:updatePkmModelPanel()
  self:updateShowPanelType(1)
end

function M:updateShowPanelType(showType)
  if showType == 1 then
    self.lytContent:SetVisible(false)
    self.lytModel:SetVisible(true)
  else
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
      Me:gotoNextGuide()
    end
    self.lytContent:SetVisible(true)
    self.lytModel:SetVisible(false)
    if self.autoSkipTimer then
      LuaTimer:cancel(self.autoSkipTimer)
      self.autoSkipTimer = nil
    end
    if self.showSoundSit then
      Me:stopSound(self.showSoundSit)
    end
    self.showSoundSit = Me:playSoundByKey("lucky_show_ten")
  end
end

function M:initContentInfo(poolId, pkmList)
  self.imgBg:SetImage(LuckyEggTabRes[poolId].eggBgRes)
  self.imgTicketIcon:SetImage(LuckyEggTabRes[poolId].ticketResIcon)
  self.btnAgainBtn:SetNormalImage(LuckyEggTabRes[poolId].buyBtnRes)
  self.btnAgainBtn:SetPushedImage(LuckyEggTabRes[poolId].buyBtnRes)
  self.txtAgainTips:SetText(LuckyEggTabRes[poolId].buyBtnTitleColor .. Lang:toText("gui_lucky_egg_take_again_ten"))
  local priceData = PokemonLuckyPriceConfig:getDataByPoolIdAndTakeType(poolId, 1)
  local isCanTicket = false
  local bagTicketNum = 0
  if 0 < priceData.ticket_count then
    isCanTicket = true
  end
  bagTicketNum = Me:getTrayItemCountByFullName(priceData.fullName)
  if bagTicketNum >= priceData.ticket_count then
    self.imgTakeIcon:SetVisible(false)
    self.imgTakeTicket:SetVisible(true)
    self.imgTakeTicket:SetImage(LuckyEggTabRes[poolId].ticketResIcon)
    self.txtTakePrice:SetText(LuckyEggTabRes[poolId].buyBtnPriceColor .. priceData.ticket_count)
  else
    self.imgTakeIcon:SetVisible(true)
    self.imgTakeTicket:SetVisible(false)
    local currencyIcon = "set:pokemonMain.json image:icon_coin"
    if priceData.currencyType == 0 or priceData.currencyType == 4 then
      currencyIcon = "set:pokemonMain.json image:icon_dimond"
    end
    self.imgTakeIcon:SetImage(currencyIcon)
    self.txtTakePrice:SetText(LuckyEggTabRes[poolId].buyBtnPriceColor .. priceData.currency_count)
  end
  self.imgTicketPanel:SetVisible(isCanTicket)
  self.txtTicketCount:SetText(bagTicketNum)
  self.btnAgainBtn:SetEnabled(true)
  self:updatePkmList(pkmList)
end

function M:updatePkmList(pkmList)
  for i, data in pairs(pkmList) do
    self.itemList[i]:invoke("onDataChanged", data)
  end
end

function M:updatePkmModelPanel()
  if self.autoSkipTimer then
    LuaTimer:cancel(self.autoSkipTimer)
    self.autoSkipTimer = nil
  end
  self.curShowPkm = self.curShowPkm + 1
  if self.curPkmList[self.curShowPkm] then
    self:updateShowPanelType(1)
    local pkmInfo = self.curPkmList[self.curShowPkm]
    self.imgNewIcon:SetVisible(pkmInfo.isNew)
    PokemonManager:getPokemon(tonumber(pkmInfo.pkmObjId), function(pokemon)
      if not pokemon then
        Lib.logError("handles PokemonValue not pokemon", pkmInfo.pkmObjId)
        return
      end
      self:updatePkmInfoShow(pokemon)
      Me:sendPacket({
        pid = "sendEggResultTip",
        luckyResult = pkmInfo
      })
      self.curPkmList[self.curShowPkm].isShow = true
    end)
    if World.cfg.luckyEggSkipTime and World.cfg.luckyEggSkipTime > 0 then
      self.autoSkipTimer = LuaTimer:scheduleTimer(function()
        self:updatePkmModelPanel()
      end, World.cfg.luckyEggSkipTime, 1)
    end
  else
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
      Lib.emitEvent(Event.EVENT_OPEN_BLOCK_INPUT)
    end
    self:updateShowPanelType(2)
  end
end

function M:updatePkmInfoShow(pokemon)
  self.imgRaceIcon:SetImage(RaceConfig:getClassifyIcon(pokemon:getRace()))
  self.txtNameTxt:SetText(Lang:toText(pokemon:getName()))
  self.itemStarLevel:invoke("updateUI", pokemon:getStarLevel(), pokemon:getWake(), 0)
  Blockman.instance.gameSettings:setUiActorBrightness({
    x = 1,
    y = 1,
    z = 1
  })
  local entity_cfg = Entity.GetCfg(pokemon:getCfgFullName())
  self.actorEggModel:SetActor1(entity_cfg.actorName, "idle")
  local pokemon_config = PokemonConfig:getConfigById(pokemon:getCfgId())
  self.actorEggModel:SetActorScale(pokemon_config.uiScale)
  if getmetatable(self.actorEggModel).SetActorOffset then
    self.actorEggModel:SetActorOffset({
      x = 0,
      y = 0,
      z = pokemon_config.uiOffsetZ
    })
  end
  self.actorEggModel:SetYPosition({
    pokemon_config.uiOffsetY,
    0
  })
  self.actorEggModel:SetRotateY(-15)
  self.actorEggModel:SetRotateX(10)
  self.modelEffect1:UnprepareEffect()
  self.modelEffect1:SetVisible(false)
  self.modelEffect2:UnprepareEffect()
  self.modelEffect2:SetEffectName("g2038_choudan_bglight_" .. pokemon:getQuality() .. ".effect")
  if self.showSoundSit then
    Me:stopSound(self.showSoundSit)
  end
  self.showSoundSit = Me:playSoundByKey("lucky_show_one")
  if self.animationTxt then
    UIAnimationManager:stop(self.animationTxt)
    self.animationTxt = nil
    self.txtShowNextTxt:SetAlpha(1.0)
  end
  self.animationTxt = UIAnimationManager:play(self.txtShowNextTxt, "luckyEggTxtFadeOut", function()
    self.txtShowNextTxt:SetAlpha(1.0)
  end)
end

function M:onHide()
  UI:closeWnd("pokemonLuckyTenTake")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      if Me:isInPreBattleOrBattle() then
        return
      end
      UI:openWnd("pokemonLuckyTenTake")
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
  self.btnBtnSkip:SetVisible(true)
  if not Me:isGuideFinish() and Me:getCurGuideIndex() >= Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY and Me:getCurGuideIndex() <= Define.GUIDE_INDEX.FINISH_TAKE_TEN then
    self.btnBtnSkip:SetVisible(false)
  end
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.autoSkipTimer then
    LuaTimer:cancel(self.autoSkipTimer)
    self.autoSkipTimer = nil
  end
  if self.showSoundSit then
    Me:stopSound(self.showSoundSit)
  end
  if self.animationTxt then
    UIAnimationManager:stop(self.animationTxt)
    self.animationTxt = nil
  end
end

return M
