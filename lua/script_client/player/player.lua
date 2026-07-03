local PokemonManager = require("script_client.pokemon.pokemon_manager")
local setting = require("common.setting")
local MovieManager = require("script_client.movie.movie_manager")
local Player = _ENV.Player
local cfgs = setting:modCfgs("item")
local engine_initPlayer = Player.initPlayer

function Player:initPlayer()
  engine_initPlayer(self)
  self:initDialogEvent()
end

function Player:notifyStateReady(type)
  self:sendPacket({
    pid = "notifyStateReady",
    type = type
  })
  if self.debugStateReady then
    Lib.logInfo("notifyStateReady", debug.traceback())
  end
end

function Player:getPokemon(objId, callBack)
  PokemonManager:getPokemon(objId, callBack)
end

function Player:getPokemonList(objIds, callBack)
  PokemonManager:getPokemonList(objIds, callBack)
end

function Player:getPacketPokemon(callBack)
  local packetPetList = self:getValue("packetPetList")
  PokemonManager:getPokemonList(packetPetList, callBack)
end

function Player:getBattlePokemon(callBack)
  local battlePetList = self:getValue("battlePetList")
  PokemonManager:getPokemonList(battlePetList, callBack)
end

function Player:copyPokemon(pokemon)
  return PokemonManager:copyPokemon(pokemon)
end

function Player:createTempPokemon(pokemonId, level)
  return PokemonManager:createPokemon(pokemonId, level)
end

function Player:clearPokemonList(objIds)
  self:sendPacket({
    pid = "clearPokemonList",
    objIds = objIds or {}
  })
end

function Player:selectInitPokemon(id)
  self:sendPacket({
    pid = "selectInitPokemon",
    pokemonId = id
  })
end

function Player:gotoNextGuide()
  Lib.emitEvent(Event.EVENT_OPEN_BLOCK_INPUT)
  Me:sendPacket({
    pid = "gotoNextGuide"
  })
end

function Player:gotoSpecificGuide(index)
  Lib.emitEvent(Event.EVENT_OPEN_BLOCK_INPUT)
  Me:sendPacket({
    pid = "gotoSpecificGuide",
    index = index
  })
end

function Player:pokemonStudySkill(objId, skillId, pos, callBack)
  self:sendPacket({
    pid = "pokemonStudySkillFromClient",
    objId = objId,
    skillId = skillId,
    pos = pos
  }, function()
    if callBack then
      callBack()
    end
  end)
end

function Player:pokemonGiveUpSkill(objId, skillId, callBack)
  self:sendPacket({
    pid = "pokemonGiveUpSkillFromClient",
    objId = objId,
    skillId = skillId
  }, function()
    if callBack then
      callBack()
    end
  end)
end

function Player:useExpItem(params, callBack)
  self:sendPacket({pid = "UseExpItem", params = params}, callBack)
end

function Player:MutatePokemon(params, callback)
  self:sendPacket({
    pid = "mutatePokemon",
    objId = params.objId
  }, callback)
end

function Player:resetBattleCameraView()
  local timeLine = self.timeLine
  if not timeLine then
    Lib.logError("resetBattleCameraView not timeLine")
    return
  end
  local cameraTrack = timeLine:getTrackByName("camera_track")
  if not cameraTrack then
    Lib.logError("getTrackByName camera_track not cameraTrack")
    return
  end
  Lib.logInfo("resetBattleCameraView", Lib.v2s(cameraTrack.cfg))
  local pos
  if cameraTrack.cfg.pos then
    local result = Lib.splitString(cameraTrack.cfg.pos, ",")
    pos = Lib.v3(tonumber(result[1]), tonumber(result[2]), tonumber(result[3]))
  end
  local isReverse = Me.battleFieldInfo and Me:getBpIndex() > 6 or false
  if isReverse then
    pos = Lib.v3(-pos.x, pos.y, -pos.z)
  end
  Me:changeCameraView(pos, isReverse and cameraTrack.cfg.yaw + 180 or cameraTrack.cfg.yaw or 0, cameraTrack.cfg.pitch or 0, 0, 0)
end

function Player:getThrowBallAnimName(isEnemy, isReplace)
  local info = Me.battleFieldInfo
  if not info then
    return "throw_ball"
  end
  if info.mode == Define.BATTLE_MODE.PVP and info.maxPlayerNum == 4 or self:isJoinTeam() or info.enemyQueueCount == 2 then
    return isEnemy and "throw_ball_4" or "throw_ball_3"
  end
  return isEnemy and "throw_ball_2" or "throw_ball"
end

function Player:getFightShowAnimName()
  local info = Me.battleFieldInfo
  if not info then
    return "fight_show_01"
  end
  if info.mode == Define.BATTLE_MODE.PVP then
    if info.maxPlayerNum == 2 then
      return "fight_show_02"
    else
      return "fight_show_04"
    end
  end
  return "fight_show_01"
end

function Player:getBattleResultAnimName(win)
  local info = Me.battleFieldInfo
  if not info then
    return "fail"
  end
  if info.mode == Define.BATTLE_MODE.PVP and info.maxPlayerNum == 4 then
    return win and "victory_2" or "fail_2"
  end
  return win and "victory" or "fail"
end

function Player:startPlayBattleMove()
  Lib.setPlayableScriptParam("ThrowBallObjId", -1)
  Lib.setPlayableScriptParam("ThrowBallObjId2", self:getMyTeamMateId() or -1)
  if Me.battleFieldInfo and Me.battleFieldInfo.mode == Define.BATTLE_MODE.PVP then
    self:doPVPThrowBallAnim()
  else
    MovieManager.playSequence({
      self:getFightShowAnimName(),
      self:getThrowBallAnimName()
    }, function()
      Me:notifyStateReady()
    end)
  end
end

function Player:doPVPThrowBallAnim()
  Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, self:getFightShowAnimName(), function()
    if Me.battleFieldInfo and Me.battleFieldInfo.curEnemyIdList then
      Lib.setPlayableScriptParam("ThrowBallObjId", Me.battleFieldInfo.curEnemyIdList[1])
      Lib.setPlayableScriptParam("ThrowBallObjId2", Me.battleFieldInfo.curEnemyIdList[2] or -1)
    end
    Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, self:getThrowBallAnimName(true), function()
      Lib.setPlayableScriptParam("ThrowBallObjId", -1)
      Lib.setPlayableScriptParam("ThrowBallObjId2", self:getMyTeamMateId() or -1)
      Lib.emitEvent(Event.EVENT_PLAY_CUTSCENE, self:getThrowBallAnimName(), function()
        Me:notifyStateReady()
      end)
    end)
  end)
end

function Player:initBattleCameraView(cameraCfg, reverse)
  if cameraCfg then
    if cameraCfg.viewMode then
      Blockman.instance:setPersonView(cameraCfg.viewMode)
    end
    local cameraView = cameraCfg.cameraView
    if cameraView then
      local pos = cameraView.pos
      if reverse then
        pos = Lib.v3(-cameraView.pos.x, cameraView.pos.y, -cameraView.pos.z)
      end
      self:changeCameraView(pos, tonumber(reverse and cameraView.yaw + 180 or cameraView.yaw), tonumber(cameraView.pitch), tonumber(cameraView.distance), tonumber(cameraView.smooth))
    end
  end
end

function Player:isReverseCamera()
  if not self.battleFieldInfo then
    return false
  end
  return self:getBpIndex() > 6
end

function Player:leaveBattleField()
  self:sendPacket({
    pid = "leaveBattleField"
  })
  self:sendPacket({
    pid = "finishBattleResult"
  })
end

function Player:playPreHideBlackAnimation()
  UI:getWnd("battle_pre_animation"):showCloseAnimation()
end

function Player:showChatShopDialog(params, callback)
  UI:getWnd("pokemonCommonDialog"):onShow(params.titleText, params.msgText, callback)
end

function Player:showSpecialChatDialog(params, callback)
  UI:getWnd("pokemonSpecialDialog"):onShow(params.titleText, params.msgText, params.popupKey, callback)
end

function Player:getTrayItemCountByFullName(fullName)
  local trayArray = self:tray():query_trays(Define.TRAY_TYPE.BAG)
  local count = 0
  for _, element in pairs(trayArray) do
    local tray = element.tray
    count = tray:count_item_num_by_fullname(fullName) + count
  end
  return count
end

function Player:getItemsCfgByItemType(itemType)
  local items = {}
  for fullName, cfg in pairs(cfgs) do
    if cfg.itemType == itemType then
      items[fullName] = cfg
    end
  end
  return items
end

function Player:getItemFullNameByItemId(itemId)
  local fullName
  for _fullName, cfg in pairs(cfgs) do
    if tonumber(cfg.itemId) == tonumber(itemId) then
      fullName = _fullName
      break
    end
  end
  return fullName
end

function Player:pagingItemsByBagType()
  local trayArray = Me:tray():query_trays(Define.TRAY_TYPE.BAG)
  local items = {}
  for _, element in pairs(trayArray) do
    local _, tray = element.tid, element.tray
    for _, _type in pairs(Define.BAG_TYPE) do
      items[_type] = tray:query_items(function(item)
        local _tray = item:tray_type()
        if _tray[_type] then
          return true
        end
        return false
      end)
    end
  end
  self.bagItems = items
  Lib.emitEvent(Event.EVENT_REFRESH_PLAYER_BAG)
end

function Player:getBagItemsByBagType(bag_type)
  if not self.bagItems then
    self:pagingItemsByBagType()
  end
  return self.bagItems[bag_type]
end

function Player:getBagItems()
  if not self.bagItems then
    self:pagingItemsByBagType()
  end
  return self.bagItems
end

function Player:getPlayerPower(cb)
  self:getBattlePokemon(function(list)
    local ret = 0
    for _, pet in pairs(list) do
      ret = ret + pet:getFightPower()
    end
    cb(ret)
  end)
end

function Player:CheckRankReward()
  local packet = {
    pid = "CheckRankReward"
  }
  self:sendPacket(packet)
end

function Player:playerOneTopWorldTips(curMsg, type)
  UI:getWnd("pokemonWorldTips"):onShow(true, type)
  UI:getWnd("pokemonWorldTips"):pushWorldCommonTips(curMsg, type)
end

function Player:playerOneChatWorldTips(curMsg)
  local packet = {
    fromname = "",
    args = {
      [1] = -1,
      [2] = 1,
      [3] = -1,
      n = 3
    },
    voiceTime = false,
    msg = curMsg,
    isWorldMsg = true
  }
  Lib.emitEvent(Event.EVENT_CHAT_MESSAGE, packet.msg, packet.fromname, packet.voiceTime, packet.args, nil, packet.msgPack, packet.isWorldMsg)
end

function Player:battleAction(type, param)
  Lib.logDebug("Player:battleAction", type)
  local isFulfill = false
  if type == Define.BATTLE_ACTION.SKILL then
    if param.pet:useSkill(param.skillId) then
      Me:sendPacket({
        pid = "BattleAction",
        type = Define.BATTLE_ACTION.SKILL,
        param = param.skillId,
        targetId = param.targetId
      })
      isFulfill = true
    end
  elseif type == Define.BATTLE_ACTION.RUNAWAY then
    Me:sendPacket({
      pid = "BattleAction",
      type = Define.BATTLE_ACTION.RUNAWAY
    })
    isFulfill = true
  elseif type == Define.BATTLE_ACTION.BALL then
    Me:sendPacket({
      pid = "BattleAction",
      type = Define.BATTLE_ACTION.BALL,
      param = param.itemId,
      targetId = param.targetId
    })
    isFulfill = true
  elseif type == Define.BATTLE_ACTION.REPLACE then
    Me:sendPacket({
      pid = "BattleAction",
      type = Define.BATTLE_ACTION.REPLACE,
      param = param
    })
    isFulfill = true
  elseif type == Define.BATTLE_ACTION.ITEM then
    Me:sendPacket({
      pid = "BattleAction",
      type = Define.BATTLE_ACTION.ITEM
    })
    isFulfill = true
  end
  if isFulfill then
    UI:getWnd("battle_main").canCommand = false
  end
  return isFulfill
end

function Player:playSoundByKey(key, time)
  Lib.logDebug(key)
  local sid = 0
  if key then
    local SoundConfig = T(Config, "SoundConfig")
    sid = Me:playSound(SoundConfig:getSound(key))
  end
  if time then
    World.Timer(time, function()
      Me:stopSound(sid)
    end)
  end
  return sid
end

function Player:getVoiceCardTime()
  self:sendPacket({
    pid = "GetVoiceCardTime"
  })
end

function Player:isFriendShip(platformUserId)
  print("-------------isFriendShip-----" .. platformUserId .. " -----------------", Lib.v2s(FriendManager.friendsMap))
  print("-------------isFriendShip-----" .. platformUserId .. " -----------------", Lib.v2s(FriendManager.friendsMap))
  return FriendManager.friendsMap[platformUserId]
end

function Player:processClickEntity(hit, packet)
  local target = World.CurWorld:getEntity(packet.targetID)
  if target.isPlayer and target.platformUserId ~= self.platformUserId then
    if target:getIsReturnHome() == false then
      UI:getWnd("pokemon_base_interactionUI"):onShow(true, packet.targetID)
    end
  else
    Skill.ClickCast(packet)
  end
end

function Player:showCommonTip(type, text, tickTimes)
  if UI:isOpen("pokemonCommonTip") then
    UI:closeWnd("pokemonCommonTip")
  end
  UI:openWnd("pokemonCommonTip", type or Define.CommonTipType.TOP, text or "", tickTimes or 20)
end

function Player:isCanShowOneInteractionWnd(wndName, fromID)
  if self:getValue("battlePreType") ~= 0 then
    Me:sendPacket({
      pid = "requestInteractionFailed",
      fromID = fromID
    })
    return false
  end
  if Me:isInBattle() then
    Me:sendPacket({
      pid = "requestInteractionFailed",
      fromID = fromID
    })
    return false
  end
  if Me:getInNpc() ~= 0 then
    Me:sendPacket({
      pid = "requestInteractionFailed",
      fromID = fromID
    })
    return false
  end
  if wndName == "pokemonSwap" then
    if UI:isOpen("pokemonRequestPkDialog") then
      Me:sendPacket({
        pid = "requestInteractionFailed",
        fromID = fromID
      })
      return false
    end
  elseif wndName == "pokemonRequestPkDialog" then
    if UI:isOpen("pokemonRequestPkDialog") then
      Me:sendPacket({
        pid = "requestInteractionFailed",
        fromID = fromID
      })
      return false
    end
    if UI:isOpen("pokemonSwap") then
      Me:sendPacket({
        pid = "requestInteractionFailed",
        fromID = fromID
      })
      return false
    end
  elseif wndName == "pokemonRequestTeamDialog" then
    local map = World.CurMap
    if map.name == World.cfg.gloryHallMap then
      Me:sendPacket({
        pid = "requestInteractionFailed",
        fromID = fromID
      })
      return false
    end
  end
  return true
end

function Player:inPreBattleCloseInteractionWnd()
  if UI:isOpen("pokemonRequestPkDialog") then
    UI:closeWnd("pokemonRequestPkDialog")
  end
  if UI:isOpen("pokemonSwap") then
    UI:closeWnd("pokemonSwap")
  end
  if UI:isOpen("pokemonRequestTeamDialog") then
    UI:closeWnd("pokemonRequestTeamDialog")
  end
end

function Player:sendFinishAction()
  Me:sendPacket({
    pid = "finishPlayerAction"
  })
end

function Player:sendPlayerAction(actionType, targetId, succCb)
  Me:sendPacket({
    pid = "requestPlayerAction",
    actionType = actionType,
    targetID = targetId
  }, function(code)
    if code == Define.ERROR_CODE.SUCCESS then
      if succCb then
        succCb()
      end
    elseif code == Define.ERROR_CODE.TARGET_NIL then
      Me:showCommonTip(1, Lang:toText("gui_player_offline"), 40)
    elseif code == Define.ERROR_CODE.TARGET_BUSY then
      Me:showCommonTip(1, Lang:toText("gui_tip_busy"), 40)
    elseif code == Define.ERROR_CODE.FORBID then
      Me:showCommonTip(1, Lang:toText("gui_tip_can_not_invitate"), 40)
    elseif code == Define.ERROR_CODE.SWAP_BIND then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.player.ban.swap"), 60)
    elseif code == Define.ERROR_CODE.SWAPING then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.player.is.swapping"), 60)
    elseif code == Define.ERROR_CODE.IN_TEAM then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.swap.not.other.teammate"), 60)
    elseif code == Define.ERROR_CODE.ONLY_CAP then
      Me:showCommonTip(Define.CommonTipType.TOP, Lang:toText("gui.swap.only.captain"), 60)
    end
  end)
end

function Player:sendSelectThreeSelOne(petId)
  Me:sendPacket({
    pid = "SelectThreeSelOne",
    petId = petId
  })
end

function Player:checkItemMoney(currencyType, prices)
  if currencyType == 0 then
    local wallet = Me:data("wallet")
    if wallet.gDiamonds then
      local asset = wallet.gDiamonds.count + (wallet.gameCashCoupon and wallet.gameCashCoupon.count or 0)
      if prices <= asset then
        return true
      else
      end
    end
  else
    if prices <= Coin:countByCoinName(Me, Coin:coinNameByCoinId(currencyType)) then
      return true
    else
    end
  end
  return false
end

function Player:setUIAvoidBattle(isAvoid)
  self:sendPacket({
    pid = "SetUIAvoidBattle",
    isAvoid = isAvoid
  })
end

function Player:isInPreBattleOrBattle()
  if Me:isInBattle() or UI:isOpen("battle_pre_animation") then
    return true
  end
  return false
end

function Player:filterLockPokemonToEnd(packetPetList)
  local tempList = {}
  local lockPetList = {}
  for _, objId in pairs(packetPetList) do
    PokemonManager:getPokemon(objId, function(pokemon)
      table.insert(pokemon:isLocked() and lockPetList or tempList, pokemon:getObjId())
    end)
  end
  for _, objId in pairs(lockPetList) do
    table.insert(tempList, objId)
  end
  return tempList
end

function Player:isTodayFirstLoginGame()
  local todayFirstLoginTime = Me:getTodayFirstLoginTime()
  local curLoginTime = Me:getCurLoginTime()
  if todayFirstLoginTime == curLoginTime and todayFirstLoginTime ~= 0 then
    return true
  end
  return false
end

function Player:isInTeam(objId)
  for _, battleObjId in pairs(self:getValue("battlePetList")) do
    if battleObjId == objId then
      return true
    end
  end
end

function Player:getSkillSuitablePokemon(skillCfg)
  local packetPetList = self:getValue("packetPetList")
  for _, objId in pairs(self:getValue("battlePetList")) do
    table.insert(packetPetList, objId)
  end
  local suitablePokemonList = {}
  PokemonManager:getPokemonList(packetPetList, function(pokemonList)
    -- ULTRA HACK: Any pet can learn any skill
    for _, pokemon in pairs(pokemonList) do
        table.insert(suitablePokemonList, pokemon)
    end
  end)
  return suitablePokemonList
end

function Player:checkIsInWatchCD(watchType)
  if Me.lastWatchAdTime then
    local remainTime = 3 - (os.time() - Me.lastWatchAdTime)
    if 0 < remainTime then
      return true
    end
  end
  Me.lastWatchAdTime = os.time()
  return false
end

function Player:requestWatchAd(watchType)
  -- ULTRA HACK: Instant Ad Complete
  Me:sendPacket({
    pid = "CSWatchCarAd",
    watchType = watchType
  })
end
