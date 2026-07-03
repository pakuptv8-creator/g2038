local handles = T(Player, "PackageHandlers")
local LuaTimer = T(Lib, "LuaTimer")
local BattleActionManager = require("script_client.battle.battle_action_manager")
local PokemonManager = require("script_client.pokemon.pokemon_manager")
local MovieManager = require("script_client.movie.movie_manager")
local skillEffectCfg = T(Config, "SkillEffectConfig")
local teamMgr = require("script_client.team.team_mgr")
local playerPkMgr = require("script_client.team.playerPk_mgr")
local TriggerGiftConfig = T(Config, "TriggerGiftConfig")
local RegularGiftConfig = T(Config, "RegularGiftConfig")
local RegularGiftItemConfig = T(Config, "RegularGiftItemConfig")
local PokemonGloryHallConfig = T(Config, "PokemonGloryHallConfig")

function handles:enterBattleField(packet)
end

local engine_GMList = handles.GMList

function handles:GMList(packet)
  engine_GMList(self, packet)
  local wnd = UI:getWnd("battle_main")
  if wnd and wnd.btnGM then
    wnd.btnGM:SetVisible(true)
  end
end

function handles:BattleActionResult(packet)
  BattleActionManager:addBattleAction(packet)
  BattleActionManager:resume()
end

function handles:replacePet(packet)
  UI:openWnd("battle_pokemon", false, true)
  Lib.logDebug("handles replacePet")
end

function handles:processCommandStart(packet)
  Lib.logDebug("processCommandStart")
  UI:getWnd("battle_main"):showControlWin(false)
  UI:getWnd("battle_pokemon"):onShow(false)
  UI:closeWnd("pokemonBag")
  UI:closeWnd("battle_select_target")
end

function handles:processCommandEnd(packet)
  Lib.logDebug("processCommandEnd")
  BattleActionManager:resume()
end

local engine_EntityDead = handles.EntityDead

function handles:EntityDead(packet)
  engine_EntityDead(self, packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity and entity:isValid() and Me:isInBattle() then
    entity:updateUpperAction("die", -1)
    Lib.logDebug("updateUpperAction die")
  else
    Lib.logError("handles:EntityDead error!")
  end
end

function handles:roundStart(packet)
  Lib.logDebug("roundStart", packet.rounds, packet.canBattle)
  local wnd = UI:getWnd("battle_main")
  wnd:onShow(true)
  if wnd then
    wnd:showControlWin(true)
    wnd:roundStart(packet)
    wnd.canCommand = true
    if not packet.canBattle then
      Me:notifyStateReady()
      wnd:showControlWin(false)
    end
  end
end

function handles:BattleResult(packet)
  local movie_name = Me:getBattleResultAnimName(packet.result)
  Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, movie_name, function()
    if packet.result then
      handles.RewardResult(self, packet)
    else
      if Me:isInBattle() then
        Me:leaveBattleField()
      end
      if Me.needShowCapture then
        UI:getWnd("pokemonCapture"):onShow()
      end
    end
    -- Auto-heal after battle
    World.Timer(1, function()
        Me:sendPacket({ pid = "recoveryAllByDoctor" })
    end)
  end)
end

function handles:RewardResult(packet)
  local wnd = UI:getWnd("battle_results")
  if wnd then
    wnd:showBattleResult(packet, true)
  end
end

function handles:StoreRewardResult(packet)
  Lib.emitEvent(Event.EVENT_STORE_BATTLE_RESULTS_PACKET, packet)
end

function handles:PokemonValue(packet)
  PokemonManager:getPokemon(packet.objId, function(pokemon)
    if not pokemon then
      Lib.logError("handles PokemonValue not pokemon", packet.objId)
      return
    end
    pokemon:setValue(packet.key, packet.value)
  end)
end

function handles:PokemonRemove(packet)
  PokemonManager:removePokemon(packet.objId)
end

function handles:EntityHide(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity then
    entity:setEntityHide(packet.value or false)
  end
end

function handles:BallResult(packet)
  Lib.logDebug("BallResult", packet.ballID, packet.target, Lib.v2s(packet.result))
  Lib.setPlayableScriptParam("ThrowBallObjId", packet.caster)
  Lib.setPlayableScriptParam("BallTarget", packet.objID)
  Lib.setPlayableScriptParam("BallID", packet.ballID)
  Me.movieCasterBp = packet.casterBp or 1
  Me.movieTargetBp = packet.targetBp or 7
  local BallMovieManager = require("script_client.movie.ball_movie_manager")
  local queue = require("common.stl.queue")
  BallMovieManager.play(queue.new(packet.result), packet.casterBp or 1)
end

function handles:startPlayPreBattleAnimation(packet)
  if packet.meetType == Define.MEET_PKM_TYPE.NO_MEET_PKM then
    UI:getWnd("battle_pre_animation"):onShow(false)
  else
    self:inPreBattleCloseInteractionWnd()
    UI:getWnd("battle_pre_animation"):onShow(true, packet)
  end
end

function handles:showPkmSkillBuffTipWnd(packet)
  local dec = packet.txtContent
  if packet.round < 99 then
    dec = string.format(Lang:toText(packet.txtContent), tonumber(packet.round))
  else
    dec = Lang:toText(packet.txtContent)
  end
  packet.txtContent = dec
  UI:getWnd("battle_effect_tip"):onShow(true)
  UI:getWnd("battle_effect_tip"):showCanvasCharacteristic(packet)
  Lib.emitEvent(Event.EVENT_ADD_SKILL_EFFECT, packet.pkmObjID)
end

function handles:ShowViewMapTip(packet)
  Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.captain.view.map"), -1)
end

function handles:HideViewMapTip(packet)
  UI:getWnd("pokemonCommonTip").onHide()
end

function handles:PrepareTelegraph(packet)
  UI:getWnd("pokemonTransitionMap"):onShow()
end

function handles:CheckTeamateTelegraph(packet)
  local status = packet.status
  local mapId = packet.mapId
  Lib.logDebug("CheckTeamateTelegraph status = ", status)
  Lib.logDebug("CheckTeamateTelegraph mapId = ", mapId)
  if status == 1 then
    Me:sendPacket({
      pid = "PrepareTelegraph"
    })
    UI:getWnd("pokemonTransitionMap"):onShow()
    Me:sendPacket({
      pid = "TelegraphToMap",
      mapId = mapId
    })
  elseif status == 0 then
    UI:getWnd("pokemonCommonDialog"):onShow("gui.title.tip", "gui.map.captain.lack.level", function(ret)
      if not ret then
        return
      end
      Me:sendPacket({
        pid = "PrepareTelegraph"
      })
      UI:getWnd("pokemonTransitionMap"):onShow()
      Me:sendPacket({
        pid = "TelegraphToMap",
        mapId = mapId
      })
    end)
  end
end

function handles:showMapUnlockTip(packet)
  if not packet or not packet.mapId then
    return
  end
  Lib.logDebug("showCommonTip showMapUnlockTip")
  Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.map.teammate.lack.level"), 120)
end

function handles:finishTelegraph(packet)
  Lib.logDebug("finishTelegraph packet = ", Lib.v2s(packet))
  if not packet or not packet.mapId then
    return
  end
  local mapId = packet.mapId
  Lib.logDebug("finishTelegraph mapId = ", mapId)
  LuaTimer:schedule(function()
    UI:getWnd("pokemonTransitionMap"):onHide()
    UI:getWnd("pokemonBigMap"):onHide()
  end, 3000)
end

function handles:syncEnemyQueue(packet)
  local wnd = UI:getWnd("battle_main")
  if packet.type == "ENEMY" then
    wnd:initPveEnemyQueueInfo(packet.queue)
  elseif packet.type == "HOST" then
    wnd:initPveHostInfo(packet.queue)
  end
end

function handles:syncBattleQueue(packet)
  UI:getWnd("battle_main"):initBattleQueue(packet.enemyPetList)
end

function handles:showPokemonRecovery(packet)
  UI:getWnd("pokemonRecovery"):onShow()
end

function handles:finishSelectInitPokemon(packet)
  local pkmInfo = packet.pkmInfo
  UI:getWnd("pokemonLuckyOnceTake"):onShow(true)
  UI:getWnd("pokemonLuckyOnceTake"):initView(-1, pkmInfo)
end

function handles:isPlayerReady(packet)
  local wnd = UI:getWnd("battle_main")
  if wnd then
    wnd:showInfoCenter(packet.value or false)
  end
end

function handles:StateWaitStart(packet)
end

function handles:ThrowBall(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity or not entity:isValid() then
    Lib.logError("handles ThrowBall not entity")
    return
  end
  Lib.setPlayableScriptParam("ThrowBallObjId", packet.objID)
  Lib.setPlayableScriptParam("ThrowBallObjId2", -1)
  Lib.setPlayableScriptParam("curBattlePetName", packet.name)
  Lib.setPlayableScriptParam("BallID", packet.ballId)
  local param
  local movie = MovieManager.onPlayCutscene((entity.isPlayer or packet.isHostAI) and Me:getThrowBallAnimName(Me:getCampId() ~= entity:getCampId(), true) or packet.bpIndex == 7 and "throw_ball_npc" or "throw_ball_4", false, function()
    Me:notifyStateReady()
  end, param)
  Me.timeLine = movie:getTimeLine()
end

function handles:BattleFieldInfo(packet)
  Lib.logDebug("BattleFieldInfo", Lib.v2s(packet))
  if packet.mode == Define.BATTLE_MODE.PVP then
    CGame.Instance():SetMaxFps(World.cfg.maxFps)
  end
  Me.battleFieldInfo = {
    mode = packet.mode,
    maxPlayerNum = packet.maxPlayerNum,
    npcId = packet.npcId,
    curEnemyNameList = packet.curEnemyNameList,
    curEnemyIdList = packet.curEnemyIdList,
    enemyQueueCount = packet.enemyQueueCount
  }
  if self:isReverseCamera() then
    self:initBattleCameraView(World.CurMap.cfg.cameraCfg, true)
  end
end

function handles:EntitySpawn(packet)
  Game.EntitySpawn(self, packet, function(entity)
    if packet.needHide then
      entity:setEntityHide(true)
    end
    if entity and entity:cfg() then
      if entity:cfg().randomIdleAction then
        entity:createRandomAction()
      end
      if entity:cfg().interactionUI and entity:cfg().interactionUI.id and entity:cfg().interactionUI.isPVPGYM == true then
        Me:sendPacket({
          pid = "ChangePVPEntityByObj",
          objID = entity.objID
        })
      end
    end
  end)
  self:onCreate()
end

function handles:showPokemonInteractiveDialog(packet)
  if packet.dialogueId ~= -1 then
    UI:getWnd("pokemonInteractiveDialog"):onShow(packet.npcId, packet.actionId, packet.dialogueId, packet.reasonId, packet.objID)
  end
end

function handles:showSelectPokemon(packet)
  local pokemonId = tonumber(packet.pokemonId)
  UI:getWnd("pokemonGuide"):onShow(false)
  UI:getWnd("pokemonSelect"):onShow(pokemonId)
end

function handles:RunawayEnemy(packet)
  local nameText = string.format(Lang:toText("runaway_enemy_info"), Lang:toText(packet.name))
  UI:getWnd("battle_dialog"):showDialogText({
    text = nameText,
    autoCloseTime = 2000,
    closeFunc = function()
      Me:notifyStateReady()
    end
  })
  PokemonManager:getPokemon(tonumber(packet.pkmObjId), function(pokemon)
    if not pokemon then
      Lib.logError("handles PokemonValue not pokemon", packet.pkmObjId)
      return
    end
    pokemon:setRunaway(true)
  end)
  Lib.emitEvent(Event.EVENT_BATTLE_ENEMY_RUN_AWAY, packet.pkmObjId)
end

function handles:SetMapPlayerIcon(packet)
  for _, objID in ipairs(packet.list) do
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() and entity.isPlayer then
      entity:setMiniMapIcon()
    end
  end
end

function handles:BattleStateFeatureStart(packet)
  Lib.logDebug("BattleStateFeatureStart")
  self.featureStartHideFunc = UI:hideOpenedWnd()
end

function handles:BattleStateFeatureLeave(packet)
  Lib.logDebug("BattleStateFeatureLeave")
  if self.featureStartHideFunc then
    self.featureStartHideFunc()
  end
end

function handles:CheckRankReward(packet)
  Lib.emitEvent(Event.EVENT_CHECK_RANK_REWARD, packet.subId, packet.rank)
end

function handles:RequestPlayerRank(packet)
  Lib.emitEvent(Event.EVENT_RECEIVE_PLAYER_RANK, packet.rankType, packet.subId, packet.rankIndex, packet.rank, packet.score)
end

local NameColor = {
  [Define.POKEMON_QUALITY.EPIC] = "\226\150\162FF3992FB",
  [Define.POKEMON_QUALITY.LEGENDARY] = "\226\150\162FFC100FA",
  [Define.POKEMON_QUALITY.MYTHICAL] = "\226\150\162FFFF7C26"
}

local function createOneContentTxt(packet)
  Lib.logInfo("createOneContentTxt packet = ", Lib.v2s(packet))
  local tipText = ""
  if packet.normalMsg ~= "" then
    local tipDesc = Lang:toText("world_tip_desc0")
    tipText = string.format(tipDesc, packet.normalMsg)
    return tipText
  else
    local WorldCommonTipsConfig = T(Config, "WorldCommonTipsConfig")
    local tipsInfo = packet.tipsInfo
    local tipDesc = Lang:toText(WorldCommonTipsConfig:getConfigById(tipsInfo.id).tip_desc)
    Lib.logInfo("tipDesc = ", tipDesc)
    if packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.CATCH then
      tipText = string.format(tipDesc, tipsInfo.playerName, Lang:toText(tipsInfo.mapIdName), NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.INCUBATE then
      tipText = string.format(tipDesc, tipsInfo.playerName, NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.MUTATED then
      tipText = string.format(tipDesc, tipsInfo.playerName, NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.WINPVP then
      local challengeName = ""
      if tipsInfo.challengeId == 0 then
        Lib.logInfo("use npc name")
        challengeName = Lang:toText(tipsInfo.challengeName)
      else
        Lib.logInfo("use user name")
        challengeName = tipsInfo.challengeName
      end
      tipText = string.format(tipDesc, tipsInfo.playerName, challengeName, Lang:toText(Lib.getGymKey(tipsInfo.gym_type)), tipsInfo.rank)
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.WAKEUP then
      tipText = string.format(tipDesc, tipsInfo.playerName, tipsInfo.syntheticNum, NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.UPGRADESTAT then
      tipText = string.format(tipDesc, tipsInfo.playerName, tipsInfo.starLevel, NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    elseif packet.tipsInfo.tipType == Define.WORLD_TIP_TYPE.EVOLVE then
      tipText = string.format(tipDesc, tipsInfo.playerName, NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.oldName), NameColor[tipsInfo.quality] .. Lang:toText(tipsInfo.pkmName))
    end
    return tipText
  end
end

function handles:radioTopWorldCommonTips(packet)
  local curMsg = createOneContentTxt(packet)
  self:playerOneTopWorldTips(curMsg, 1)
end

function handles:radioChatWorldCommonTips(packet)
  local curMsg = createOneContentTxt(packet)
  self:playerOneChatWorldTips(curMsg)
end

function handles:getPokemonCollect(packet)
  Lib.emitEvent(Event.EVENT_GET_PET_COLLECT, packet.collectPetList)
end

function handles:GetPVPGymPokemons(packet)
  Lib.emitEvent(Event.EVENT_GET_PVP_NPC_POKEMONS, packet.isnpc, packet.npcId, packet.userId, packet.power, packet.name, packet.pokemons)
end

function handles:ShowPVPPrompt(packet)
  Lib.emitEvent(Event.EVENT_SHOW_PVP_PROMPT, packet.playerName, packet.rank)
end

function handles:battleRoundChange(packet)
  Lib.emitEvent(Event.EVENT_BATTLE_ROUND_CHANGE)
end

function handles:triggerSkillEffect(packet)
  local target = World.CurWorld:getEntity(packet.targetId)
  if target and target:isValid() then
    Lib.logInfo("_____________triggerSkillEffect:", target:cfg().fullName, Lib.v2s(packet.buffCfg))
    local round = packet.round
    local effectValue = packet.buffCfg and packet.buffCfg.effect
    if packet.buffCfg.triggerData and packet.buffCfg.triggerData.effect then
      effectValue = packet.buffCfg.triggerData.effect
    end
    if effectValue then
      target:skillEffecttrigger(effectValue, packet.buffCfg, packet.effectId, true)
    end
    local soundValue = packet.buffCfg and packet.buffCfg.sound
    if packet.buffCfg.triggerData and packet.buffCfg.triggerData.sound then
      soundValue = packet.buffCfg.triggerData.sound
    end
    if soundValue then
      target:skillEffecttrigger(soundValue, packet.buffCfg, packet.effectId, false)
    end
    local effectCfg = skillEffectCfg:getConfigById(packet.effectId)
    local showId = 2
    local masterId = target:getValue("masterId")
    if masterId == self.objID then
      showId = 1
    end
    local effect_trigger_desc = string.gsub(effectCfg.effect_trigger_desc, "^%s+", "")
    if effect_trigger_desc and 0 < #effect_trigger_desc then
      local dec = Lang:toText(effectCfg.effect_trigger_desc)
      local tbPacket = {
        showId = showId,
        txtTitle = effectCfg.effect_type,
        txtContent = dec,
        pkmObjID = target.objID,
        playerObjID = self.objID
      }
      UI:getWnd("battle_effect_tip"):onShow(true)
      UI:getWnd("battle_effect_tip"):showCanvasCharacteristic(tbPacket)
    end
  end
end

function handles:ItemShopBuyResult(packet)
  UI:getWnd("pokemon_Shop"):itemShopBuyResult(packet.params)
end

function handles:informDailyReward(packet)
  if not World.cfg.useFDiamonds then
    return
  end
  local day = Me:getActiveDay()
  if World.cfg.dailyFDiamondsReward[day] then
    UI:getWnd("pokemonMain").btnPokemonMainReward:SetVisible(true)
  end
end

function handles:CatchGlory(packet)
  if Me:isInBattle() then
    Me.waitShowGlory = packet.id
  end
end

function handles:AddBuff(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  local from = World.CurWorld:getEntity(packet.fromID)
  if entity and entity:isValid() then
    entity:addClientBuff(packet.name, packet.id, packet.time, from, packet.effectId)
  end
end

function handles:ClientAutoShowGiftWnd(packet)
  if packet.showType == "login" then
    self:checkLoginAutoShowGiftWnd()
  elseif packet.showType == "dead" then
    self:checkDeadAutoShowGiftWnd()
  end
end

function handles:showCommonTips(packet)
  local message = Lang:toText(packet.message)
  Me:showCommonTip(1, message, packet.time or 40)
end

function handles:PVPGYM(packet)
  local curMsg = createOneContentTxt(packet)
  Lib.logInfo("PVPGYM curMsg = ", curMsg)
  self:playerOneTopWorldTips(curMsg, 2)
end

function handles:showNewTriggerGift(packet)
  local pokemonGiftBag = UI:getWnd("pokemonGiftBag")
  local curShowId = pokemonGiftBag.showByGiftId
  local curGift = TriggerGiftConfig:getGiftById(curShowId)
  local newGift = TriggerGiftConfig:getGiftById(packet.giftId)
  local showGiftId = packet.giftId
  if newGift.battleShow then
    pokemonGiftBag:onShowByGiftId(showGiftId)
    return
  end
  if not curGift then
    pokemonGiftBag.showByGiftId = packet.giftId
    if not self:isInBattle() then
      pokemonGiftBag:pushGiftPackage()
    end
    return
  end
  if not newGift then
    return
  end
  if curGift.quality > newGift.quality then
    showGiftId = curShowId
  elseif curGift.quality == newGift.quality and curGift.id < newGift.id then
    showGiftId = curShowId
  end
  pokemonGiftBag.showByGiftId = showGiftId
  if not self:isInBattle() then
    pokemonGiftBag:pushGiftPackage()
  end
end

function handles:sendBuyRegularResult(packet)
  local message = Lang:toText(packet.message)
  local giftItemInfo = {}
  if packet.result then
    local item = RegularGiftConfig:getConfigById(packet.itemId)
    if item then
      for key, val in pairs(item.giftContent) do
        local itemData = {}
        local goodInfo = RegularGiftItemConfig:getConfigById(val)
        if goodInfo.itemType == 1 then
          itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.ITEM
          itemData.item = goodInfo.itemName
          itemData.count = goodInfo.itemCount
          itemData.highlight = false
        elseif goodInfo.itemType == 2 then
          itemData.giftType = Define.TRIGGER_GIFT_ITEM_TYPE.GOLD
          itemData.item = "item"
          itemData.count = goodInfo.itemCount
          itemData.highlight = false
        end
        table.insert(giftItemInfo, itemData)
      end
    end
    UI:getWnd("buyGiftTip"):onShow(true, giftItemInfo)
  else
    Me:showCommonTip(1, message, packet.time or 40)
  end
  Lib.emitEvent(Event.EVENT_UPDATE_REGULAR_BUY_TIME)
end

function handles:TriggerGiftBuyResult(packet)
  local giftInfo = TriggerGiftConfig:getGiftById(packet.giftId)
  local giftType = "LimitedGift_"
  if giftInfo and giftInfo.type == Define.TRIGGER_GIFT_TYPE.GROW then
    giftType = "GrowthGift_"
  end
  local resultType = giftType .. "click"
  local behaviorKey = giftType .. resultType
  Me:gameBehaviorReport(behaviorKey, packet.giftId)
  if packet.result == Define.BuyingTips.buy_finish then
    resultType = "success"
    behaviorKey = giftType .. resultType
    Me:gameBehaviorReport(behaviorKey, packet.giftId)
  end
  local tGiftWnd = UI:getWnd("pokemonGiftBag")
  tGiftWnd.onBuy = false
  tGiftWnd:onHide()
  if packet.result == Define.BuyingTips.buy_finish then
    local giftItemInfo = TriggerGiftConfig:getGiftItemsInfoById(packet.giftId)
    if giftItemInfo then
      UI:getWnd("buyGiftTip"):onShow(true, giftItemInfo)
    end
  else
    UI:getWnd("pokemonCommonDialog"):onShow("ui_buy_gift_Result", "ui_buy_gift_Result_" .. packet.result, function(ret)
      if not ret then
        return
      end
      if packet.result == Define.BuyingTips.buy_fail then
        Interface.onRecharge(1)
      end
    end)
  end
end

function handles:sendRegularServerTime(packet)
  Lib.emitEvent(Event.EVENT_UPDATE_REGULAR_SERVER_TIME, packet.curServerTime)
end

function handles:getOtherPlayerPower(packet)
  Lib.emitEvent(Event.EVENT_UPDATE_OTHERS_POWER, packet)
end

function handles:syncRequestJoinTeam(packet)
  teamMgr:syncRequestJoinTeam(packet.fromID, packet.fromName)
end

function handles:syncAgreeJoinTeam(packet)
  local from = World.CurWorld:getEntity(packet.fromID)
  local target = World.CurWorld:getEntity(packet.targetID)
  teamMgr:syncAgreeJoinTeam(from, target)
end

function handles:syncRefuseJoinTeam(packet)
  local from = World.CurWorld:getEntity(packet.fromID)
  local target = World.CurWorld:getEntity(packet.targetID)
  teamMgr:syncRefuseJoinTeam(from, target)
end

function handles:syncLeaveTeam(packet)
  Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui_leave_team"), 60)
  Lib.emitEvent(Event.EVENT_UPDATE_TEAM_PLAYER_INFO)
  local status = packet.status
  if status == 0 then
    Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.leaveteam.returnhome"), 60)
  end
end

function handles:syncFollowForceMove(packet)
  local entity = World.CurWorld:getEntity(packet.targetID)
  if entity and entity:isValid() then
    entity:setForceMove(packet.pos, packet.time)
  end
end

function handles:syncRequestPKPlayer(packet)
  playerPkMgr:syncRequestPKPlayer(packet.fromID)
end

function handles:syncPkRequestRefused(packet)
  playerPkMgr:syncPkRequestRefused(packet.targetID)
end

function handles:syncPkRequestAgreed(packet)
  playerPkMgr:syncPkRequestAgreed(packet.targetID)
end

function handles:OpenPlayerActionDialog(packet)
  UI:getWnd("pokemon_base_interactionUI"):onShow(true, packet.objID)
end

function handles:HideBlockInputEvents(packet)
  UI:getWnd("pokemonBlockInputEvents"):onHide()
end

function handles:ShowBlockInputEvents(packet)
  UI:getWnd("pokemonBlockInputEvents"):onShow()
end

function handles:CloseResult(packet)
  UI:closeWnd("battle_results")
  UI:closeWnd("battle_dialog")
  self:setReadyCloseResult(false)
end

function handles:startAutoSkipResult(packet)
  if UI:isOpen("battle_results") then
    UI:getWnd("battle_results"):starCountDown()
  end
end

function handles:pushLuckyEggResult(packet)
  Lib.emitEvent(Event.EVENT_UPDATE_LUCKY_EGG_INFO, packet.luckyResult)
end

function handles:pushLuckyEggFail(packet)
  Lib.emitEvent(Event.EVENT_UPDATE_LUCKY_EGG_FAIL)
  local message = Lang:toText(packet.message)
  Me:showCommonTip(1, message, 40)
end

function handles:receiveLuckyExtraSuccess(packet)
  Lib.emitEvent(Event.EVENT_RECEIVE_LUCKY_EGG_EXTRA, packet.extraId)
  local message = Lang:toText("gui_receive_success_text")
  Me:showCommonTip(1, message, 40)
end

function handles:showEvolution(packet)
  UI:getWnd("pokemonEvolution"):onShow(packet.cfgId)
end

function handles:responeDoDailyLottery(packet)
  local player = World.CurWorld:getObject(packet.objID)
  if not player or not player:isValid() then
    return
  end
  Lib.emitEvent(Event.EVENT_DAILY_LOTTERY_RESPONE, packet.itemIndex, packet.curCrlcle, packet.curPickList)
end

function handles:ThreeSelOne(packet)
  UI:getWnd("pokemon_three_select_one"):onShow(packet.giftId)
end

function handles:BuyFollowPetPrivilegeSuccess(packet)
  Lib.emitEvent(Event.EVENT_SHOW_FOLLOW_PET)
  UI:getWnd("battle_dialog"):showDialogText({
    text = Lang:toText("buy_follow_pet_privilege_success"),
    maskEquateYes = true,
    yesCb = function()
    end
  })
end

function handles:GetDailyTaskAcitveStatus(packet)
  Lib.emitEvent(Event.EVENT_GET_DAILY_TASK_ACTIVE_STATUS, packet.activeIndex, packet.activePoint)
end

function handles:GetDailyTaskStatusList(packet)
  Lib.emitEvent(Event.EVENT_GET_DAILY_TASK_STATUS_LIST, packet.task_status_list)
end

function handles:useItemMessage(packet)
  local str = packet.userName .. Lang:toText("ui_ues") .. Lang:toText(packet.itemName)
  UI:getWnd("battle_dialog"):showDialogText({text = str, autoCloseTime = 1000})
end

function handles:canEnterBattle(packet)
  Me:canEnterBattle(packet.npcId, packet.reason_id)
end

local function setBattlePetsValue(indexList, key, checkFalse)
  local battlePokemonList = {}
  Me:getBattlePokemon(function(pokemonList)
    battlePokemonList = pokemonList
  end)
  local key2Func = {
    levelUp = function(pokemon, value)
      pokemon:setCanLevelUpRedPointShow(value)
    end,
    wakeUp = function(pokemon, value)
      pokemon:setCanWakeRedPointShow(value)
    end,
    starUp = function(pokemon, value)
      pokemon:setCanStarUpRedShow(value)
    end,
    bless = function(pokemon, value)
      pokemon:setCanBlessRedPointShow(value)
    end
  }
  if checkFalse then
    for battlePokemonIndex, _ in pairs(battlePokemonList) do
      local needSetFalse = true
      for _, index in pairs(indexList) do
        if battlePokemonIndex == index then
          needSetFalse = false
        end
      end
      if needSetFalse then
        key2Func[key](battlePokemonList[battlePokemonIndex], false)
      end
    end
    return
  end
  for _, index in pairs(indexList) do
    if battlePokemonList[index] then
      key2Func[key](battlePokemonList[index], true)
    end
  end
end

function handles:updatePokemonListDo(packet)
  setBattlePetsValue(packet.wakeRedShowIndexList, "wakeUp", packet.checkFalse)
  setBattlePetsValue(packet.starUpShowIndexList, "starUp", packet.checkFalse)
  Lib.emitEvent(Event.EVENT_GAIN_POKEMON, packet.wakeRedShowIndexList, packet.starUpShowIndexList)
end

function handles:updateExpItemDo(packet)
  setBattlePetsValue(packet.indexList, "levelUp", packet.checkFalse)
  Lib.emitEvent(Event.EVENT_GAIN_EXP_ITEM, packet.indexList)
end

function handles:showCheating(packet)
  Lib.emitEvent(Event.EVENT_SHOW_CHEATING, packet.name, packet.time, packet.pay)
end

function handles:gainBlessItemDo(packet)
  setBattlePetsValue(packet.canBlessPokemonIndexList, "bless")
  Lib.emitEvent(Event.EVENT_GAIN_BLESS_ITEM, packet.canBlessPokemonIndexList)
end

function handles:SyncGloryHallRemainRT(packet)
  local gloryDoorRefreshTimer = self:data("main").gloryDoorRefreshTimer or {}
  if gloryDoorRefreshTimer then
    LuaTimer:cancel(gloryDoorRefreshTimer)
  end
  local curWeekDay = os.date("%w", packet.curServerTime)
  local data = PokemonGloryHallConfig:getCfgByOpenDay(curWeekDay)
  local openedDoor = {}
  local remainTime = packet.timeList
  for _, cfg in pairs(data) do
    openedDoor[cfg.id] = true
  end
  gloryDoorRefreshTimer = LuaTimer:scheduleTimer(function()
    for gymId, objId in pairs(packet.doorNameTxtList) do
      remainTime[gymId] = remainTime[gymId] - 1
      if remainTime[gymId] < 0 then
        remainTime[gymId] = 0
      end
      local seconds = math.floor(remainTime[gymId] % 60)
      local min = math.floor(remainTime[gymId] / 60 % 60)
      local hour = math.floor(remainTime[gymId] / 3600)
      local decTime = string.format("%02d:%02d:%02d", hour, min, seconds)
      local doorNameEntity = World.CurWorld:getEntity(objId)
      local gymName = Lang:toText("gui_glory_hall_gym_name" .. gymId)
      local headText = ""
      if openedDoor[gymId] then
        headText = string.format(Lang:toText("gui_glory_hall_close_tips"), gymName, decTime)
      else
        headText = string.format(Lang:toText("gui_glory_hall_open_tips"), gymName, decTime)
      end
      if doorNameEntity then
        doorNameEntity.name = headText
        doorNameEntity:updateShowName()
      end
    end
    if not Me.gloryDoorEntityNum or 0 >= Me.gloryDoorEntityNum then
      for gymId, objId in pairs(packet.doorEntityList) do
        local doorNameEntity = World.CurWorld:getEntity(objId)
        if doorNameEntity then
          Me.gloryDoorEntityNum = Me.gloryDoorEntityNum + 1
          if 0 < Me.gloryDoorEntityNum then
            Me.disableControl = false
          end
        end
      end
    end
  end, 1000, -1)
  self:data("main").gloryDoorRefreshTimer = gloryDoorRefreshTimer
end

function handles:pushGloryHallRefresh(packet)
  Me:showChatShopDialog({
    titleText = "gui.tip.title",
    msgText = "gui_glory_hall_refresh_tips"
  }, function()
  end)
end

function handles:pushCurServerTime(packet)
  Lib.emitEvent(Event.EVENT_PUSH_CUR_SERVER_TIME, packet.curServerTime)
end

function handles:gameCfgVersionChange(packet)
  local oldVersion = packet.oldVersion
  local newVersion = packet.newVersion
  if not Me:isWatch() and newVersion == World.cfg.gameCfgVersion and oldVersion ~= newVersion then
    UI:getWnd("pokemonCommonDialog"):onShow("s_announcement_title", "s_announcement_detail", nil, nil, 0)
  end
end

function handles:ChangeMap(packet)
  local oldMap = World.CurMap
  local world = World.CurWorld
  world:loadCurMap(packet, packet.pos)
  local map = World.CurMap
  if map == oldMap then
    Lib.emitEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, map.name)
    return
  end
  for _, obj in ipairs(world:getAllObject()) do
    if obj.waitMapId == map.id then
      obj:setMap(map)
      obj.waitMapId = nil
    end
  end
  if oldMap then
    oldMap:leaveAllEntity()
    oldMap:close()
  end
  Lib.emitEvent(Event.EVENT_CLIENT_CHANGE_SCENE_MAP, map.name)
end

function handles:pushRotaryTableResult(packet)
  if packet.state then
    Lib.emitEvent(Event.EVENT_PUSH_ROTARY_RESULT, true, packet.resultID)
  else
    local message = Lang:toText(packet.message)
    Me:showCommonTip(Define.CommonTipType.TOP, message, packet.time or 40)
    Lib.emitEvent(Event.EVENT_PUSH_ROTARY_RESULT, false)
  end
end

function handles:showDialog(packet)
  Lib.logInfo("g2038 showDialog packet = ", Lib.v2s(packet))
  Me:showDialog(packet)
end

function handles:ShowSumRecharge(packet)
end

function handles:SumRechargeGCube(packet)
end

function handles:SumRechargeResult(packet)
end

function handles:SCWatchCarAdResult(packet)
  local type = packet.type
  local code = packet.code
  local params = packet.params
  if code == 1 then
    Me.lastWatchAdTime = os.time()
    if type == Define.AdvertisingType.Battle and UI:isOpen("battle_results") then
      UI:getWnd("battle_results"):onAdFinish()
    end
  else
    Me.lastWatchAdTime = 0
  end
end
