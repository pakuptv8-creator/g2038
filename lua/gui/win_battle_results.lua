local NPCConfig = T(Config, "NPCConfig")
local GloryConfig = T(Config, "GloryConfig")
local SkillConfig = T(Config, "SkillConfig")
local LuaTimer = T(Lib, "LuaTimer")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local M = _ENV.M
local adStatus = {showAd = 1, adFinish = 2}

function M:init()
  WinBase.init(self, "battle_results.json", false)
  self:initUI()
  self:initEvent()
end

function M:initUI()
  self.lytBattleResultsRewardWin = self:child("battle_results-reward_win")
  self.imgBattleResultsRewardBg = self:child("battle_results-reward_bg")
  self.imgBattleResultsRewardTitle = self:child("battle_results-reward_title")
  self.txtBattleResultsRewardTitleText = self:child("battle_results-reward_title_text")
  self.imgBattleResultsBg = self:child("battle_results-bg")
  self.gvBattleResultsRewardList = self:child("battle_results-reward_list")
  self.imgBattleResultsRewardCoinsIcon = self:child("battle_results-reward_coins_icon")
  self.txtBattleResultsRewardCoinsName = self:child("battle_results-reward_coins_name")
  self.txtBattleResultsRewardCoinsName:SetText(Lang:toText("common_coin"))
  self.txtBattleResultsRewardCoinsNum = self:child("battle_results-reward_coins_num")
  self.txtBattleResultsRewardCoinAddition = self:child("battle_results-reward_coin_addition")
  self.imgBattleResultsRewardExpIcon = self:child("battle_results-reward_exp_icon")
  self.txtBattleResultsRewardExpName = self:child("battle_results-reward_exp_name")
  self.txtBattleResultsRewardExpName:SetText(Lang:toText("common_exp"))
  self.txtBattleResultsRewardExpNum = self:child("battle_results-reward_exp_num")
  self.btnBattleResultsRewardContinue = self:child("battle_results-reward_continue")
  self:child("battle_results-reward_continue_text"):SetText(Lang:toText("ui_continue"))
  self.btnBattleResultsRewardAd = self:child("battle_results-reward_ad")
  self:child("battle_results-reward_ad_text"):SetText(Lang:toText("ui.ad.double.reward"))
  self.lytBattleResultsUpgradeWin = self:child("battle_results-upgrade_win")
  self.imgBattleResultsUpgradeBg = self:child("battle_results-upgrade_bg")
  self.imgBattleResultsUpgradePet = self:child("battle_results-upgrade_pet")
  self.lytBattleResultsUpgradePetList = self:child("battle_results-upgrade_pet_list")
  self.imgBattleResultsUpgradeAbility = self:child("battle_results-upgrade_ability")
  self.imgBattleResultsUpgradeAbilityBg = self:child("battle_results-upgrade_ability_bg")
  self.imgBattleResultsUpgradeAbilityBg5 = self:child("battle_results-upgrade_ability_bg_5")
  self.imgBattleResultsUpgradeAbilityBg6 = self:child("battle_results-upgrade_ability_bg_6")
  self.lytBattleResultsHp = self:child("battle_results-hp")
  self.imgBattleResultsHpIcon = self:child("battle_results-hp_icon")
  self.txtBattleResultsHpName = self:child("battle_results-hp_name")
  self.txtBattleResultsHpName:SetText(Lang:toText("attr_hp"))
  self.txtBattleResultsHpNum = self:child("battle_results-hp_num")
  self.txtBattleResultsHpVar = self:child("battle_results-hp_var")
  self.lytBattleResultsSpd = self:child("battle_results-spd")
  self.imgBattleResultsSpdIcon = self:child("battle_results-spd_icon")
  self.txtBattleResultsSpdName = self:child("battle_results-spd_name")
  self.txtBattleResultsSpdName:SetText(Lang:toText("attr_spd"))
  self.txtBattleResultsSpdNum = self:child("battle_results-spd_num")
  self.txtBattleResultsSpdVar = self:child("battle_results-spd_var")
  self.lytBattleResultsAtk = self:child("battle_results-atk")
  self.imgBattleResultsAtkIcon = self:child("battle_results-atk_icon")
  self.txtBattleResultsAtkName = self:child("battle_results-atk_name")
  self.txtBattleResultsAtkName:SetText(Lang:toText("attr_atk"))
  self.txtBattleResultsAtkNum = self:child("battle_results-atk_num")
  self.txtBattleResultsAtkVar = self:child("battle_results-atk_var")
  self.lytBattleResultsDef = self:child("battle_results-def")
  self.imgBattleResultsDefIcon = self:child("battle_results-def_icon")
  self.txtBattleResultsDefName = self:child("battle_results-def_name")
  self.txtBattleResultsDefName:SetText(Lang:toText("attr_def"))
  self.txtBattleResultsDefNum = self:child("battle_results-def_num")
  self.txtBattleResultsDefVar = self:child("battle_results-def_var")
  self.lytBattleResultsMAtk = self:child("battle_results-mAtk")
  self.imgBattleResultsMAtkIcon = self:child("battle_results-mAtk_icon")
  self.txtBattleResultsMAtkName = self:child("battle_results-mAtk_name")
  self.txtBattleResultsMAtkName:SetText(Lang:toText("attr_matk"))
  self.txtBattleResultsMAtkNum = self:child("battle_results-mAtk_num")
  self.txtBattleResultsMAtkVar = self:child("battle_results-mAtk_var")
  self.lytBattleResultsMDef = self:child("battle_results-mDef")
  self.imgBattleResultsMDefIcon = self:child("battle_results-mDef_icon")
  self.txtBattleResultsMDefName = self:child("battle_results-mDef_name")
  self.txtBattleResultsMDefName:SetText(Lang:toText("attr_mdef"))
  self.txtBattleResultsMDefNum = self:child("battle_results-mDef_num")
  self.txtBattleResultsMDefVar = self:child("battle_results-mDef_var")
  self.imgBattleCountDownBg = self:child("battle_results-CountDown-Bg")
  self.txtBattleCountDownText = self:child("battle_results-CountDown-Text")
  self.txtBattleCountDownText:SetText(Lang:toText("battle_result_count_down_text"))
  self.txtBattleCountDown = self:child("battle_results-CountDown")
  self.txtBattleCoinsX2 = self:child("battle_results-reward_coins_x2")
  self.txtBattleExpX2 = self:child("battle_results-reward_exp_x2")
  self.txtBattleCoinsX2:SetText("x2")
  self.txtBattleExpX2:SetText("x2")
  self.gvTabList = UIMgr:new_widget("grid_view")
  self.gvTabList:SetClipChild(false)
  self.lytBattleResultsUpgradePetList:AddChildWindow(self.gvTabList)
  self.gvTabList:SetAutoColumnCount(false)
  self.gvTabList:SetVerticalAlignment(0)
  self.gvTabList:SetMoveAble(false)
  self.gvTabList:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.gvTabList:InitConfig(0, 0, 1)
  self.levelUpCheck = {}
  self:initSkillLayout()
  self:alwaysSubscribe()
end

function M:initSkillLayout()
  self.skillItems = {}
  self.lyBattleList = self:child("battle_results-Battle-List")
  self.lySkillLayout = self:child("battle_results-Right-Layout")
  self.lyDesc = self:child("battle_results-Desc-Layout")
  self.lySkill = self:child("battle_results-Skill-Layout")
  self.lyUnlearnedSkill = self:child("battle_results-UnlearnedSkill-Layout")
  local width = self.lySkill:GetPixelSize().x
  local height = self.lySkill:GetPixelSize().y
  local itemWidth = 394
  local itemHeight = 59
  for index = 1, 4 do
    local item = UIMgr:new_widget("pokemon_skill_cell")
    local diffX = 0
    diffX = math.fmod(index, 2) == 1 and 0 or itemWidth + 30
    local positionX = 15 + diffX
    local diffY = (math.ceil(index / 2) - 1) * (itemHeight + 26)
    local positionY = 13 + diffY
    item:SetArea({0, positionX}, {0, positionY}, {0, itemWidth}, {0, itemHeight})
    self.lySkill:AddChildWindow(item)
    self.skillItems[index] = item
    self:lightSubscribe("error!!!!! script_client win_battle_results pokemon_skill_cell-index" .. index .. " event : EventWindowClick", item, UIEvent.EventWindowClick, function()
      self:selectSkillItem(item)
    end)
  end
  self.unlearnedItem = UIMgr:new_widget("pokemon_skill_cell")
  self.unlearnedItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyUnlearnedSkill:AddChildWindow(self.unlearnedItem)
  self.lyUnlearnedSkill:SetVisible(false)
  self:lightSubscribe("error!!!!! script_client win_battle_results unlearnedItem event : EventWindowClick", self.unlearnedItem, UIEvent.EventWindowClick, function()
    self:showSKillDetail(self.unlearnedItem)
  end)
  self.descItem = UIMgr:new_widget("pokemon_skill_detail_cell")
  self.descItem:SetArea({0, 0}, {0, 0}, {1, 0}, {1, 0})
  self.lyDesc:AddChildWindow(self.descItem)
end

function M:selectSkillItem(selectItem)
  for index, item in pairs(self.skillItems) do
    item:invoke("onChecked", false)
    if selectItem == item then
      self.selectIndex = index
      self.selectSkillId = item:invoke("getSkill").skillId
      Lib.logDebug("self.selectIndex", self.selectIndex)
      item:invoke("onChecked", true)
      self:showSKillDetail(item)
    end
  end
end

function M:showSKillDetail(item)
  local skill = item:invoke("getSkill")
  self.descItem:invoke("updateInfo", skill)
end

function M:initEvent()
  self:lightSubscribe("error!!!!! script_client win_battle_results btnBattleResultsRewardContinue event : EventButtonClick", self.btnBattleResultsRewardContinue, UIEvent.EventButtonClick, function()
    if Me:isInBattle() then
      Me:leaveBattleField()
    end
    if #self.petExpList == 0 then
      self:onHide()
      return
    end
    self:exchangeToShowPetUpPage()
  end)
  self:lightSubscribe("error!!!!! script_client win_battle_results btnBattleResultsRewardAd event : EventButtonClick", self.btnBattleResultsRewardAd, UIEvent.EventButtonClick, function()
    if Me:getPlayerLevel() >= 20 then
      Me:requestWatchAd(Define.AdvertisingType.Battle)
    end
  end)
end

function M:alwaysSubscribe()
  Lib.lightSubscribeEvent("error!!!!! script_client win_battle_results Lib event : EVENT_POKEMON_LEVEL_UP", Event.EVENT_POKEMON_LEVEL_UP, function(objId, valueAddList)
    if not self.levelUpCheck[objId] then
      self.levelUpCheck[objId] = valueAddList
      self.levelUpCheck[objId].addLv = 1
    else
      self.levelUpCheck[objId].add_maxHp = self.levelUpCheck[objId].add_maxHp + valueAddList.add_maxHp
      self.levelUpCheck[objId].add_speed = self.levelUpCheck[objId].add_speed + valueAddList.add_speed
      self.levelUpCheck[objId].add_pAtk = self.levelUpCheck[objId].add_pAtk + valueAddList.add_pAtk
      self.levelUpCheck[objId].add_sAtk = self.levelUpCheck[objId].add_sAtk + valueAddList.add_sAtk
      self.levelUpCheck[objId].add_pDef = self.levelUpCheck[objId].add_pDef + valueAddList.add_pDef
      self.levelUpCheck[objId].add_sDef = self.levelUpCheck[objId].add_sDef + valueAddList.add_sDef
      self.levelUpCheck[objId].addLv = self.levelUpCheck[objId].addLv + 1
    end
    self.hasLevelUp = true
  end)
end

function M:subscribeEvent()
end

function M:initView()
end

function M:exchangeToShowPetUpPage(right_away)
  self:upDatePokemonList(right_away)
  self.lytBattleResultsRewardWin:SetVisible(false)
  self.lytBattleResultsUpgradeWin:SetVisible(true)
  self.imgBattleResultsUpgradeAbility:SetVisible(false)
  self.lySkillLayout:SetVisible(false)
  self:playLvUp()
  UI:getWnd("battle_dialog"):showDialogText({
    text = Lang:getMessage("battle_result_pet_exp"),
    isHideMask = true
  })
  if self.hasLevelUp then
    self.hasLevelUp = false
    Me:playSoundByKey("pkm_level_up")
  end
end

function M:onAdFinish()
  self:updateAdUi(adStatus.adFinish)
end

function M:updateAdUi(status)
  self.txtBattleCoinsX2:SetVisible(false)
  self.txtBattleExpX2:SetVisible(false)
  self.btnBattleResultsRewardContinue:SetXPosition({0, 0})
  self.btnBattleResultsRewardAd:SetVisible(false)
  if Me:getPlayerLevel() >= 20 then
    if status == adStatus.showAd then
      self.btnBattleResultsRewardContinue:SetXPosition({0, -160})
      self.btnBattleResultsRewardAd:SetVisible(true)
    elseif status == adStatus.adFinish then
      self.txtBattleCoinsX2:SetVisible(true)
      self.txtBattleExpX2:SetVisible(true)
      self.btnBattleResultsRewardAd:SetVisible(false)
    end
  end
end

function M:showBattleResult(packet, fromBattle)
  UI:openWnd("battle_results")
  self.isFromBattle = fromBattle
  self.isInBattle = Me:isInBattle()
  self.petExpList = packet.petExpList
  packet.reward = packet.reward or {}
  self.lytBattleResultsRewardWin:SetVisible(true)
  self.lytBattleResultsUpgradeWin:SetVisible(false)
  self.imgBattleCountDownBg:SetVisible(false)
  self:updateAdUi(adStatus.showAd)
  self.txtBattleResultsRewardTitleText:SetText(Lang:toText(packet.result and "battle_result_win" or "battle_result_lost"))
  self.txtBattleResultsRewardCoinsNum:SetText(packet.coin or 0)
  if self.isFromBattle then
    local subscribe_vipSetting = World.cfg.subscribe_vipSetting
    if Me:getSubscribeGameState() and 0 < subscribe_vipSetting.coinAddition then
      local text = "(+" .. subscribe_vipSetting.coinAddition .. "%)"
      self.txtBattleResultsRewardCoinAddition:SetText(text)
    else
      self.txtBattleResultsRewardCoinAddition:SetText("")
    end
  else
    self.txtBattleResultsRewardCoinAddition:SetText("")
  end
  self.txtBattleResultsRewardExpNum:SetText(packet.exp or 0)
  self.gvBattleResultsRewardList:RemoveAllItems()
  self.gvBattleResultsRewardList:InitConfig(20, 0, 14)
  self.gvBattleResultsRewardList:SetMoveAble(false)
  for _, item in pairs(packet.reward) do
    local node = UIMgr:new_widget("pokemon_item_cell")
    node:invoke("initViewDataWithoutAdapter", item[1], item[2], function(_, dx, dy)
      UI:getWnd("pokemonItemDetail"):onShow(item[1], dx, dy)
    end)
    node:SetHorizontalAlignment(0)
    node:SetVerticalAlignment(1)
    self.gvBattleResultsRewardList:AddItem(node, true)
  end
  self.gvBattleResultsRewardList:SetArea({0, 0}, {0, -191}, {
    0,
    #packet.reward * 110
  }, {0, 100})
  if not packet.coin and not packet.exp then
    self:exchangeToShowPetUpPage(true)
  end
  if packet.pokemonList and 0 < #packet.pokemonList then
    Me.needShowCapture = true
  end
  if Me.needShowCapture then
    if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_CONFIRM_BALL then
      Me:gotoNextGuide()
    else
      UI:getWnd("pokemonCapture"):onShow()
    end
  end
end

function M:upDatePokemonList(right_away)
  self.items = {}
  self.pokemonItems = {}
  self.gvTabList:RemoveAllItems()
  self.upgrade_show_list = {}
  local odjIds = {}
  for _, expInfo in pairs(self.petExpList) do
    table.insert(odjIds, expInfo.objId)
  end
  local petExpAddition = 0
  local subscribe_vipSetting = World.cfg.subscribe_vipSetting
  if self.isFromBattle and Me:getSubscribeGameState() and 0 < subscribe_vipSetting.petExpAddition then
    petExpAddition = subscribe_vipSetting.petExpAddition
  end
  self:unsubscribe(self.lytBattleResultsUpgradeWin)
  Me:playSoundByKey("upgrade_bar")
  Me:getPokemonList(odjIds, function(pokemonList)
    for index, pokemon in pairs(pokemonList) do
      local item = UIMgr:new_widget("pokemon_head_exp_cell")
      self.levelUpCheck[pokemon:getObjId()] = self.levelUpCheck[pokemon:getObjId()] or {}
      item:invoke("onChecked", false)
      item:invoke("subscribeTickDoneCallback", function()
        for _, pokemonItem in pairs(self.pokemonItems) do
          if pokemonItem:invoke("getIsTicking") == true then
            return
          end
        end
        if right_away then
          LuaTimer:schedule(function()
            UI:closeWnd("battle_dialog")
            self:onCheckedUpgradeShowList()
          end, 0)
          return
        end
        local closeTimeWait = 2000
        if right_away then
          closeTimeWait = 0
        end
        local autoClose = LuaTimer:scheduleTimer(function()
          self:unsubscribe(self.lytBattleResultsUpgradeWin)
          UI:closeWnd("battle_dialog")
          self:onCheckedUpgradeShowList()
        end, closeTimeWait, 1)
        self:lightSubscribe("error!!!!! script_client win_battle_results lytBattleResultsUpgradeWin event : EventWindowClick", self.lytBattleResultsUpgradeWin, UIEvent.EventWindowClick, function()
          LuaTimer:cancel(autoClose)
          UI:closeWnd("battle_dialog")
          self:onCheckedUpgradeShowList()
        end)
      end)
      item:invoke("updateInfo", pokemon, not right_away and self.petExpList[index].exp or 0, petExpAddition)
      table.insert(self.pokemonItems, item)
      if self.levelUpCheck[pokemon:getObjId()].addLv or 0 < 0 then
        table.insert(self.upgrade_show_list, index)
      end
      self.gvTabList:AddItem(item)
      self.items[index] = item
    end
  end)
end

function M:playLvUp()
  for i = 0, self.gvTabList:GetItemCount() - 1 do
    self.gvTabList:GetItem():invoke("playLvUp")
  end
end

function M:onCheckedUpgradeShowList()
  self:unsubscribe(self.lytBattleResultsUpgradeWin)
  if not UI:isOpen("battle_results") then
    return
  end
  if #self.upgrade_show_list == 0 then
    self:onHide()
    return
  end
  self:onCheckedPetClick(table.remove(self.upgrade_show_list, 1))
end

function M:onCheckedPetClick(index)
  for _index, item in pairs(self.items) do
    if _index == index then
      item:invoke("onChecked", true)
      self:showPokemonInfo(item:invoke("getPokemon"))
    else
      item:invoke("onChecked", false)
    end
  end
end

function M:showPokemonInfo(pokemon)
  self.cur_pokemon = pokemon
  self.imgBattleResultsUpgradeAbility:SetVisible(true)
  self.lySkillLayout:SetVisible(false)
  self.curHp = pokemon:getCurHp()
  self.txtBattleResultsHpNum:SetText(pokemon:getMaxHp())
  self.txtBattleResultsSpdNum:SetText(pokemon:getSpeed())
  self.txtBattleResultsAtkNum:SetText(pokemon:getPhysicalAtk())
  self.txtBattleResultsDefNum:SetText(pokemon:getPhysicalDef())
  self.txtBattleResultsMAtkNum:SetText(pokemon:getSpecialAtk())
  self.txtBattleResultsMDefNum:SetText(pokemon:getSpecialDef())
  if self.levelUpCheck[pokemon:getObjId()] then
    local attrUp = self.levelUpCheck[pokemon:getObjId()]
    self.txtBattleResultsHpVar:SetVisible(true)
    self.txtBattleResultsSpdVar:SetVisible(true)
    self.txtBattleResultsAtkVar:SetVisible(true)
    self.txtBattleResultsDefVar:SetVisible(true)
    self.txtBattleResultsMAtkVar:SetVisible(true)
    self.txtBattleResultsMDefVar:SetVisible(true)
    self.txtBattleResultsHpVar:SetText("+" .. 0)
    self.txtBattleResultsSpdVar:SetText("+" .. 0)
    self.txtBattleResultsAtkVar:SetText("+" .. 0)
    self.txtBattleResultsDefVar:SetText("+" .. 0)
    self.txtBattleResultsMAtkVar:SetText("+" .. 0)
    self.txtBattleResultsMDefVar:SetText("+" .. 0)
    local durFrame = 10
    local time = 20
    self.txtBattleResultsHpVar:SetTextWithJump("+" .. attrUp.add_maxHp, false, durFrame, time)
    self.txtBattleResultsSpdVar:SetTextWithJump("+" .. attrUp.add_speed, false, durFrame, time)
    self.txtBattleResultsAtkVar:SetTextWithJump("+" .. attrUp.add_pAtk, false, durFrame, time)
    self.txtBattleResultsDefVar:SetTextWithJump("+" .. attrUp.add_pDef, false, durFrame, time)
    self.txtBattleResultsMAtkVar:SetTextWithJump("+" .. attrUp.add_sAtk, false, durFrame, time)
    self.txtBattleResultsMDefVar:SetTextWithJump("+" .. attrUp.add_sDef, false, durFrame, time)
  else
    self.txtBattleResultsHpVar:SetVisible(false)
    self.txtBattleResultsSpdVar:SetVisible(false)
    self.txtBattleResultsAtkVar:SetVisible(false)
    self.txtBattleResultsDefVar:SetVisible(false)
    self.txtBattleResultsMAtkVar:SetVisible(false)
    self.txtBattleResultsMDefVar:SetVisible(false)
  end
  World.Timer(1, function()
    UI:getWnd("battle_dialog"):showDialogText({
      text = string.format(PokemonConfig:getColorByQuality(pokemon:getQuality()) .. Lang:getMessage("battle_result_pet_up"), pokemon:getName(), pokemon:getLevel()),
      isHideMask = true,
      yesCb = function()
        self:checkStudyList()
      end
    })
  end)
end

function M:checkStudyList()
  local study_skill = self.cur_pokemon:getStudySkillList()
  if 0 < #study_skill then
    self:showStudySKill(study_skill[1].skillId)
    return
  end
  self:onCheckedUpgradeShowList()
end

function M:showStudySKill(study_skillId)
  local pokemon = self.cur_pokemon
  local skillList = pokemon:getSkillList()
  if #skillList < 4 then
    Me:pokemonStudySkill(pokemon:getObjId(), study_skillId, nil, function()
      UI:getWnd("battle_dialog"):showDialogText({
        text = string.format(PokemonConfig:getColorByQuality(pokemon:getQuality()) .. Lang:getMessage("battle_result_study_success"), pokemon:getName(), Lang:toText(SkillConfig:getSkillNameById(study_skillId))),
        isHideMask = true,
        yesCb = function()
          self:checkStudyList()
        end
      })
    end)
    return
  end
  self.imgBattleResultsUpgradeAbility:SetVisible(false)
  self.lyUnlearnedSkill:SetVisible(true)
  self.lySkillLayout:SetVisible(true)
  self:refreshSKillList()
  self.unlearnedItem:invoke("updateInfoById", study_skillId)
  World.Timer(1, function()
    UI:getWnd("battle_dialog"):showDialogText({
      text = string.format(Lang:getMessage("battle_result_select_skill"), Lang:toText(SkillConfig:getSkillNameById(study_skillId))),
      isHideMask = true,
      yesCb = function()
        Me:showChatShopDialog({
          titleText = Lang:toText("gui.secondConfirm.title"),
          msgText = Lang:toText("gui.confirm.replaceSkill")
        }, function(confirm)
          if confirm then
            Me:pokemonStudySkill(pokemon:getObjId(), study_skillId, self.selectIndex, function()
              self.lyUnlearnedSkill:SetVisible(false)
              UI:getWnd("battle_dialog"):showDialogText({
                text = string.format(PokemonConfig:getColorByQuality(pokemon:getQuality()) .. Lang:getMessage("battle_result_study_replay"), pokemon:getName(), Lang:toText(SkillConfig:getSkillNameById(study_skillId)), Lang:toText(SkillConfig:getSkillNameById(self.selectSkillId))),
                isHideMask = true,
                yesCb = function()
                  self:checkStudyList()
                end
              })
              self:refreshSKillList()
            end)
            return
          end
          self:showStudySKill(study_skillId)
        end)
      end,
      noCb = function()
        Me:pokemonGiveUpSkill(pokemon:getObjId(), study_skillId, function()
          self:checkStudyList()
        end)
      end
    })
  end)
end

function M:starCountDown()
  self.imgBattleCountDownBg:SetVisible(true)
  self.countDownNum = 20
  self.txtBattleCountDown:SetText(self.countDownNum)
  LuaTimer:cancel(self.timerKey or 0)
  self.timerKey = LuaTimer:scheduleTimer(function()
    self.countDownNum = self.countDownNum - 1
    self.txtBattleCountDown:SetText(self.countDownNum)
    if self.countDownNum == 0 then
      Me:sendPacket({
        pid = "autoSkipResult"
      })
    end
  end, 1000, self.countDownNum)
end

function M:refreshSKillList()
  local skillList = self.cur_pokemon:getSkillList()
  for index, item in pairs(self.skillItems) do
    item:invoke("updateInfo", skillList[index])
  end
  self:selectSkillItem(self.skillItems[1])
end

function M:onHide()
  if self.isInBattle and Me:isJoinTeam() then
    if not Me:isReadyCloseResult() then
      Me:setReadyCloseResult(true)
      World.Timer(1, function()
        if Me:isReadyCloseResult() then
          UI:getWnd("battle_dialog"):showDialogText({
            text = Lang:getMessage("battle_result_wait_team"),
            isHideMask = true
          })
        end
      end)
    end
  else
    UI:closeWnd("battle_results")
    UI:closeWnd("battle_dialog")
    if Me.waitShowGlory then
      UI:getWnd("pokemonGloryDialog"):onShow(GloryConfig:getGloryById(Me.waitShowGlory), true)
    end
  end
end

function M:onShow(isShow)
  if isShow then
    if not UI:isOpen(self) then
      UI:openWnd("battle_results")
    else
      self:onHide()
    end
  else
    self:onHide()
  end
end

function M:onOpen()
  self._allEvent = {}
  self.pokemonItems = {}
  self:subscribeEvent()
  self:initView()
  self:root():SetAlwaysOnTop(true)
  UI:getWnd("battle_main"):cleanCountdownTimer()
end

function M:onClose()
  self.levelUpCheck = {}
  if self._allEvent then
    for k, fun in pairs(self._allEvent) do
      fun()
    end
  end
  self:guideLogic()
  LuaTimer:cancel(self.timerKey or 0)
  if Me.needShowCapture then
    UI:getWnd("pokemonCapture"):releasePet()
  end
end

function M:guideLogic()
  if not Me:isGuideFinish() and Me:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
    Me:gotoNextGuide()
  end
end

return M
