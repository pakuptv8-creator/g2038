local PokemonLuckyPriceConfig = T(Config, "PokemonLuckyPriceConfig")
local RaceConfig = T(Config, "RaceConfig")
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local PokemonConfig = T(Config, "PokemonConfig")
local LuckyEggTabRes = {
  [1] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_angel_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_flash_ticket",
    buyBtnPriceColor = "\226\150\162FFFFFE00",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_red"
  },
  [2] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_elite_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_elite_ticket",
    buyBtnPriceColor = "\226\150\162FF871700",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_yellow"
  },
  [3] = {
    eggBgRes = "plugin/myplugin/luckyEgg/img_0_norm_bg.jpg",
    ticketResIcon = "set:pokemon_lucky_egg.json image:img_0_norm_ticket",
    buyBtnPriceColor = "\226\150\162FF0A3F5F",
    buyBtnRes = "set:pokemon_lucky_egg.json image:btn_0_luckydraw_blue"
  }
}

function M:init()
  WinBase.init(self, "PokemonLuckyOnceTake.json")
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.imgBg = self:child("PokemonLuckyOnceTake-bg")
  self.lytTake = self:child("PokemonLuckyOnceTake-Take")
  self.lytContent = self:child("PokemonLuckyOnceTake-content")
  self.lytNamePanel = self:child("PokemonLuckyOnceTake-namePanel")
  self.imgNameBg = self:child("PokemonLuckyOnceTake-nameBg")
  self.imgNewIcon = self:child("PokemonLuckyOnceTake-newIcon")
  self.txtNameTxt = self:child("PokemonLuckyOnceTake-nameTxt")
  self.imgTicketPanel = self:child("PokemonLuckyOnceTake-ticketPanel")
  self.txtTicketTitle = self:child("PokemonLuckyOnceTake-ticketTitle")
  self.imgTicketIcon = self:child("PokemonLuckyOnceTake-ticketIcon")
  self.txtTicketCount = self:child("PokemonLuckyOnceTake-ticketCount")
  self.btnConfirmBtn = self:child("PokemonLuckyOnceTake-confirmBtn")
  self.txtConfirmTxt = self:child("PokemonLuckyOnceTake-confirmTxt")
  self.btnAgainBtn = self:child("PokemonLuckyOnceTake-againBtn")
  self.txtTakePrice = self:child("PokemonLuckyOnceTake-takePrice")
  self.imgTakeIcon = self:child("PokemonLuckyOnceTake-takeIcon")
  self.imgTakeTicket = self:child("PokemonLuckyOnceTake-takeTicket")
  self.lytTakeMust = self:child("PokemonLuckyOnceTake-takeMust")
  self.txtAgainTitle = self:child("PokemonLuckyOnceTake-againTitle")
  self.imgRaceIcon = self:child("PokemonLuckyOnceTake-raceIcon")
  self.imgStarIcon = self:child("PokemonLuckyOnceTake-starIcon")
  self.btnBtnClose = self:child("PokemonLuckyOnceTake-BtnClose")
  self.lytModel = self:child("PokemonLuckyOnceTake-model")
  self.actorEggModel = self:child("PokemonLuckyOnceTake-eggModel")
  self.itemStarLevel = UIMgr:new_widget("pokemon_star_item_cell")
  self.imgStarIcon:AddChildWindow(self.itemStarLevel)
  self.modelEffect1 = self:child("PokemonLuckyOnceTake-modelEffect1")
  self.modelEffect2 = self:child("PokemonLuckyOnceTake-modelEffect2")
  self.txtTicketTitle:SetText(Lang:toText("gui_lucky_egg_ticket_title"))
  self.txtAgainTitle:SetText(Lang:toText("gui_lucky_egg_take_again"))
  self.txtConfirmTxt:SetText(Lang:toText("gui_lang_tip_sure"))
end

function M:initEvent()
  self:subscribe(self.btnConfirmBtn, UIEvent.EventButtonClick, function()
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.SELECT_INIT_POKEMON then
      Me:gotoNextGuide()
      Me:sendPacket({pid = "resetInNpc", value = 0})
    end
    self:onHide()
  end)
  self:subscribe(self.btnAgainBtn, UIEvent.EventButtonClick, function()
    if Me:isInPreBattleOrBattle() then
      return
    end
    local battlePetList = Me:getValue("packetPetList")
    if #battlePetList + 1 > World.cfg.maxBoxPetsCnt then
      UI:getWnd("pokemonCommonDialog"):onShow("ui_tip", "gui_lucky_egg_take_fail_full", function(ret)
        if not ret then
          return
        end
        UI:getWnd("pokemonPacket"):onShow("packet")
      end)
    else
      UI:getWnd("pokemonLuckyEgg"):clickTakeLuckyEgg(0)
    end
    self:onHide()
  end)
  self:subscribe(self.btnBtnClose, UIEvent.EventButtonClick, function()
    self:onHide()
  end)
end

function M:subscribeEvent()
end

function M:initView(poolId, pkmInfo)
  if poolId ~= -1 then
    self.btnAgainBtn:SetVisible(true)
    self.imgTicketIcon:SetVisible(true)
    self.imgTicketPanel:SetVisible(true)
    self.txtTicketCount:SetVisible(true)
    self.txtAgainTitle:SetVisible(true)
    self.btnBtnClose:SetVisible(true)
    self.btnConfirmBtn:SetHorizontalAlignment(0)
    self.btnConfirmBtn:SetArea({0.210938, 0}, {-0.0722222, 0}, {0.210938, 0}, {0.125, 0})
    self.imgBg:SetImage(LuckyEggTabRes[poolId].eggBgRes)
    self.imgTicketIcon:SetImage(LuckyEggTabRes[poolId].ticketResIcon)
    self.btnAgainBtn:SetNormalImage(LuckyEggTabRes[poolId].buyBtnRes)
    self.btnAgainBtn:SetPushedImage(LuckyEggTabRes[poolId].buyBtnRes)
    local priceData = PokemonLuckyPriceConfig:getDataByPoolIdAndTakeType(poolId, 0)
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
    self.imgNewIcon:SetVisible(pkmInfo.isNew)
    self.btnAgainBtn:SetEnabled(true)
  else
    self.imgBg:SetImage(LuckyEggTabRes[2].eggBgRes)
    self.imgTicketIcon:SetVisible(false)
    self.btnAgainBtn:SetVisible(false)
    self.imgTicketPanel:SetVisible(false)
    self.txtTicketCount:SetVisible(false)
    self.imgNewIcon:SetVisible(pkmInfo.isNew)
    self.txtAgainTitle:SetVisible(false)
    self.btnBtnClose:SetVisible(false)
    self.btnConfirmBtn:SetHorizontalAlignment(1)
    self.btnConfirmBtn:SetArea({0, 0}, {-0.0722222, 0}, {0.210938, 0}, {0.125, 0})
  end
  PokemonManager:getPokemon(tonumber(pkmInfo.pkmObjId), function(pokemon)
    if not pokemon then
      Lib.logError("handles PokemonValue not pokemon", pkmInfo.pkmObjId)
      return
    end
    self:updatePkmInfoShow(pokemon)
    if poolId ~= -1 then
      Me:sendPacket({
        pid = "sendEggResultTip",
        luckyResult = pkmInfo
      })
    end
  end)
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
  self.showSoundSit = Me:playSoundByKey("lucky_show_one")
end

function M:onHide()
  UI:closeWnd("pokemonLuckyOnceTake")
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      if Me:isInPreBattleOrBattle() then
        return
      end
      UI:openWnd("pokemonLuckyOnceTake")
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
end

function M:onClose()
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  if self.showSoundSit then
    Me:stopSound(self.showSoundSit)
  end
end

return M
