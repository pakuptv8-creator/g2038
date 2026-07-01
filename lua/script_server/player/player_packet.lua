local handles = T(Player, "PackageHandlers")
local VoiceShopConfig = T(Config, "VoiceShopConfig")
local MapConfig = T(Config, "MapConfig")
local RegionConfig = T(Config, "RegionConfig")
local WashCostConfig = T(Config, "WashCostConfig")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
local ActiveRewardConfig = T(Config, "ActiveRewardConfig")
local BlessItemConfig = T(Config, "BlessItemConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
local NPCConfig = T(Config, "NPCConfig")
local GymConfig = T(Config, "GymConfig")
local DBHandler = require("dbhandler")
local SkillConfig = T(Config, "SkillConfig")
local skillEffectCfg = T(Config, "SkillEffectConfig")

function handles:BattleAction(packet)
  if not self.battleField then
    return
  end
  self.battleField:onBattleAction(self, packet)
end

function handles:finishBattleResult()
  self.isInBattleResult = false
end

function handles:notifyStateReady(packet)
  self:notifyStateReady(packet)
end

function handles:getPokemonList(packet)
  local objId_list = Lib.splitString(packet.objIds or "", ":")
  return PokemonManager:subscribePokemonList(objId_list, self)
end

function handles:clearPokemonList(packet)
  for _, objId in pairs(packet.objIds) do
    local pokemon = PokemonManager:getPokemon(objId)
    if pokemon then
      pokemon:removePlayer(self.platformUserId)
    end
  end
end

function handles:selectInitPokemon(packet)
  Lib.logDebug("selectInitPokemon packet = ", Lib.v2s(packet))
  if not packet or not packet.pokemonId then
    return
  end
  local pokemonId = packet.pokemonId
  self:setInitPokemonId(pokemonId)
  local pokemon1 = self:randomPokemon(pokemonId)
  pokemon1:recoveryHp()
  self:setBattleList({
    pokemon1.objId
  })
  Lib.reportPokemonSelect(self, packet.pokemonId)
  local guide_index = Define.GUIDE_INDEX.FINISH_SELECT_POKEMON
  local guide_data = PokemonGuideConfig:getGuideData(guide_index)
  self:getGuideReward(guide_data)
  local pkmInfo = {
    cfgId = pokemonId,
    pkmObjId = pokemon1.objId,
    isNew = true
  }
  self:sendPacket({
    pid = "finishSelectInitPokemon",
    pkmInfo = pkmInfo
  })
end

function handles:setBattleListFromClient(packet)
  if self:isEnterBattle() then
    return {success = false}
  end
  local objId_list = Lib.splitString(packet.objIds or "", ":")
  local result = {
    success = self:setBattleList(objId_list)
  }
  if result.success and not self:isGuideFinish() and self:getCurGuideIndex() == Define.GUIDE_INDEX.FILL_POKEMON_CLOSE_PACKET then
    local guide_data = PokemonGuideConfig:getGuideData(Define.GUIDE_INDEX.FINISH_FILL_POKEMON)
    if guide_data then
      self:getGuideReward(guide_data)
    end
  end
  return result
end

function handles:pokemonRename(packet)
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon and packet.newName and #packet.newName <= 18 and #packet.newName > 0 then
    pokemon:setName(World.CurWorld:filterWord(packet.newName))
  end
end

function handles:pokemonStudySkillFromClient(packet)
  self:pokemonStudySkill(packet.objId, packet.skillId, packet.pos)
end

function handles:pokemonGiveUpSkillFromClient(packet)
  self:pokemonGiveUpSkill(packet.objId, packet.skillId)
end

function handles:pokemonReleaseFromClient(packet)
  local objId_list = Lib.splitString(packet.objIds or "", ":")
  local success = self:pokemonRelease(objId_list)
  local result = {success = success}
  return result
end

function handles:sellPokemon(packet)
  local objId_list = Lib.splitString(packet.objIds or "", ":")
  local success, gain = self:pokemonRelease(objId_list)
  if success then
    self:sortPokemonList()
  end
  local result = {}
  result.success = success
  result.gain = gain
  if result.success then
    self:addCurrency("gold_coin", result.gain, "sell_pets")
  end
  return result
end

function handles:UseExpItem(packet)
  return self:useExpItem(packet.params)
end

function handles:mutatePokemon(params)
  if not params or not params.objId then
    return
  end
  local pokemon = self:getSelfPokemon(params.objId)
  if not pokemon then
    return
  end
  if pokemon:isMutated() then
    return
  end
  local mutateItem = pokemon:getMutateItem()
  local itemFullName = self:inspectBagItemByItemId(tonumber(mutateItem[1])):full_name()
  local costNum = tonumber(mutateItem[2])
  local itemCount = self:getTrayItemCountByFullName(params.fullName)
  if costNum > itemCount then
    return
  end
  self:useBagItemByFullName(itemFullName, costNum, false, nil, nil, "use_mutate_item")
  pokemon:mutate()
  pokemon:lock(true)
  self:sortPokemonList()
  self:updateAllPokemonPower()
  local curFollowPetId = tostring(self:getCurFollowPetId())
  if curFollowPetId ~= "0" and curFollowPetId == pokemon:getObjId() then
    self:removeFollowPetEntity(true, curFollowPetId)
    self:createFollowPetEntity(pokemon:getCfgFullName(), pokemon:getObjId())
    self:setCurFollowPetId(pokemon:getObjId())
  end
  local skillList = pokemon:getPassiveSkillList()
  local tipsInfo = {
    tipType = Define.WORLD_TIP_TYPE.MUTATED,
    playerName = self.name,
    mapIdName = "",
    quality = pokemon:getQuality(),
    pkmName = pokemon:getCfg().name,
    oldName = "",
    skillName = "",
    ownerName = "",
    starLevel = pokemon:getStarLevel(),
    syntheticNum = skillList and #skillList or 0
  }
  self:sendSpecialWorldCommonTips(tipsInfo)
  return true
end

function handles:recoveryAllByDoctor(packet)
  if not packet then
    return
  end
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:recoveryBattlePokemon()
      teamMate:sendPacket({
        pid = "showPokemonRecovery"
      })
    end
  end
  self:recoveryBattlePokemon()
  self:sendPacket({
    pid = "showPokemonRecovery"
  })
end

function handles:canEnterBattle(packet)
  if not packet or not packet.npcId then
    return
  end
  self:canEnterBattle(packet.npcId)
end

function handles:npcEnterBattle(packet)
  Lib.logDebug("server npcEnterBattlle packet = ", Lib.v2s(packet))
  if not (packet and packet.npcId) or not packet.objId then
    return
  end
  local npc_config = NPCConfig:getNPCById(packet.npcId)
  if not npc_config then
    Lib.logError("can not find npc_config, npcId =", packet.npcId)
    return
  end
  if npc_config.team_id == 0 and self:isJoinTeam() then
    self:sendPacket({
      pid = "canEnterBattle",
      npcId = packet.npcId,
      reason_id = Define.DIALOG_REASON.TEAM
    })
    return
  end
  if npc_config.challenge_race ~= 0 and not self:isPokemonRaceMatch(npc_config.challenge_race) then
    self:sendPacket({
      pid = "canEnterBattle",
      npcId = packet.npcId,
      reason_id = Define.DIALOG_REASON.RACENOTMATCH
    })
    return
  end
  self.kickPos = nil
  self:npcEnterBattle(packet.npcId, packet.objId)
end

function handles:OnPetTargetUseItem(packet)
  return self:onPetTargetUseItem(packet)
end

function handles:OnSellItem(packet)
  return self:onSellItem(packet)
end

function handles:InteractWithEntity(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if not entity then
    return
  end
  local cfgKey, cfgIndex, btnType, btnIndex = packet.cfgKey, packet.cfgIndex, packet.btnType, packet.btnIndex
  local cfg = entity:cfg()[cfgKey]
  if cfgIndex then
    cfg = cfg[cfgIndex]
  end
  local btnCfg = cfg[btnType][btnIndex]
  if btnCfg.event and entity[btnCfg.event] and type(entity[btnCfg.event]) == "function" then
    entity[btnCfg.event](entity, self, cfg)
  end
end

function handles:ShowViewMapTip(packet)
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:sendPacket({
        pid = "ShowViewMapTip"
      })
    end
  end
end

function handles:HideViewMapTip(packet)
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:sendPacket({
        pid = "HideViewMapTip"
      })
    end
  end
end

function handles:CheckTeamateTelegraph(packet)
  local mapId = packet.mapId
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      local status = teamMate:getMapUnlock(mapId)
      Lib.logDebug("status = ", status)
      self:sendPacket({
        pid = "CheckTeamateTelegraph",
        mapId = mapId,
        status = status
      })
    end
  end
end

function handles:PrepareTelegraph(packet)
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:sendPacket({
        pid = "PrepareTelegraph"
      })
    end
  end
end

function handles:TelegraphToMap(packet)
  local mapId = packet.mapId
  self:telegraphToMap(mapId)
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:telegraphToMap(mapId)
    end
  end
end

function handles:TelegraphToRegion(packet)
  local gymId = packet.gymId
  Lib.logDebug("TelegraphToRegion gymId = ", gymId)
  local regionId = packet.regionId
  Lib.logDebug("TelegraphToRegion regionId = ", regionId)
  self.kickPos = nil
  if self:isJoinTeam() and not self:isTeamCaptain() then
    return
  end
  local region_config
  if regionId == 0 then
    region_config = RegionConfig:getRegionById(2)
  else
    region_config = RegionConfig:getRegionById(regionId)
  end
  local map = World.CurWorld:getMap(region_config.map)
  self:telegraphTo(map, Lib.v3(region_config.born[1], region_config.born[2], region_config.born[3]), gymId)
  self:setCurGym(gymId)
  self:changePVPEntities()
  self:setInNpc(0)
  self:setCanPK(1)
end

function handles:GetPVPGymPokemons(packet)
  local npcId = packet.npcId
  local npc_config = NPCConfig:getNPCById(npcId)
  if not npc_config then
    Lib.logError("GetPVPGymPokemons can not find npc_config, npcId =", npcId)
    return
  end
  local gym_index = npc_config.gym_index
  local gym_id = npc_config.gym_id
  local gym_config = GymConfig:getGymById(gym_id)
  local gym_type = gym_config.type
  local rank = 8 - gym_index
  local rankType = self:getLangType()
  local rankIndex = self:getRankIndex()
  local userId = self.platformUserId
  Rank.GetSubRankData(rankType, gym_type, rankIndex, function(rankDatas)
    local player = Game.GetPlayerByUserId(userId)
    if player and player:isValid() then
      if rankDatas and rankDatas[rank] then
        local rankData = rankDatas[rank]
        Lib.logInfo("GetPVPGymPokemons rankData = ", Lib.v2s(rankData))
        if rankData.isnpc == false then
          Lib.logInfo("get data from db userId = ", rankData.userId)
          DBHandler:getDataByUserId(rankData.userId, 1, function(userId, txt)
            local seri = require("seri")
            local misc = require("misc")
            local data
            if txt and txt ~= "" then
              data = seri.deseristring_string(misc.base64_decode(txt))
            end
            local pvpBattlePetAttrs = data.values.pvpBattlePetAttrs or {}
            Lib.logInfo("pvpBattlePetAttrs = ", Lib.v2s(pvpBattlePetAttrs))
            if pvpBattlePetAttrs[gym_type] and 0 < #pvpBattlePetAttrs[gym_type] then
              local npc_battle_pokemons = {}
              for _, info in pairs(pvpBattlePetAttrs[gym_type]) do
                if PokemonConfig:getConfigById(info.cfgId) then
                  local pokemon = PokemonManager:initPokemon(info)
                  table.insert(npc_battle_pokemons, pokemon)
                end
              end
              local pokemon_infos = {}
              local power = 0
              for _, pokemon in pairs(npc_battle_pokemons) do
                power = power + pokemon:getFightPower()
                local info = {
                  cfgId = pokemon.attr.cfgId,
                  level = pokemon.attr.level,
                  star = pokemon.attr.star
                }
                table.insert(pokemon_infos, info)
              end
              local packet = {
                isnpc = false,
                pid = "GetPVPGymPokemons",
                npcId = npcId,
                userId = userId,
                power = power,
                name = rankData.name,
                pokemons = pokemon_infos
              }
              Lib.logDebug("GetPVPGymPokemons packet = ", Lib.v2s(packet))
              player:sendPacket(packet)
              for _, pokemon in pairs(npc_battle_pokemons) do
                pokemon:onDestroy()
              end
            else
              Lib.logInfo("cannot get pvp player pvpBattlePetAttrs")
              player:GetPVEGymPokemons(npcId)
            end
          end)
        else
          player:GetPVEGymPokemons(npcId)
        end
      else
        player:GetPVEGymPokemons(npcId)
      end
    end
  end)
end

function handles:ChangePVPEntityByObj(packet)
  local objID = packet.objID
  local curGym = self:getCurGym()
  if curGym ~= 0 then
    local gym_config = GymConfig:getGymById(curGym)
    if gym_config and gym_config.is_pvp == 1 then
      do
        local rankType = self:getLangType()
        local rankIndex = self:getRankIndex()
        local userId = self.platformUserId
        Rank.GetSubRankData(rankType, gym_config.type, rankIndex, function(rankDatas)
          local player = Game.GetPlayerByUserId(userId)
          if player and player:isValid() then
            local map = World.CurWorld:getMap(gym_config.map)
            player:loadPVPGymEntity(rankDatas, map, gym_config.type, curGym, objID)
          end
        end)
      end
    end
  end
end

function handles:ChangePVPEntities(packet)
  self:changePVPEntities()
end

function handles:TelegraphToTask(packet)
  Lib.logDebug("TelegraphToTask packet = ", Lib.v2s(packet))
  local map = World.CurWorld:getMap(packet.map)
  self:setMapPos(map, Lib.v3(packet.pos[1], packet.pos[2], packet.pos[3]))
end

function handles:GetDailyTaskStatusList(packet)
  local task_status_list = self:getDailyTaskStatusList()
  self:sendPacket({
    pid = "GetDailyTaskStatusList",
    task_status_list = task_status_list
  })
end

function handles:GetDailyTaskAcitveStatus(packet)
  local activePoint = self:getActivePoint()
  local activeIndex = self:getCurActiveIndex()
  Lib.logDebug("GetDailyTaskAcitveStatus activePoint and activeIndex = ", activePoint, activeIndex)
  self:sendPacket({
    pid = "GetDailyTaskAcitveStatus",
    activeIndex = activeIndex,
    activePoint = activePoint
  })
end

function handles:GetDailyTaskStatus(packet)
  local task_id = packet.id
  local task_status = self:getDailyTaskStatus(task_id)
  Lib.logDebug("task_status = ", Lib.v2s(task_status))
  self:sendPacket({
    pid = "GetDailyTaskStatus",
    task_status = task_status
  })
end

function handles:GetTaskReward(packet)
  local taskid = packet.taskid
  Lib.logDebug("GetTaskReward taskid = ", taskid)
  local task_data = PokemonTaskConfig:getTaskById(taskid)
  local exp_reward = task_data.exp_reward
  Lib.logDebug("GetTaskReward exp_reward = ", exp_reward)
  if exp_reward ~= 0 then
    self:addPlayerExp(exp_reward)
  end
  local active_reward = task_data.active_reward
  self:setActivePoint(self:getActivePoint() + active_reward)
  Lib.logDebug("GetTaskReward active point = ", self:getActivePoint())
  local active_item_rewards = ActiveRewardConfig:getSpeicifcRewards(self:getPlayerLevel(), self:getActivePoint(), self:getCurActiveIndex())
  Lib.logDebug("active_item_rewards = ", Lib.v2s(active_item_rewards))
  for i = 1, #active_item_rewards do
    local item = active_item_rewards[i]
    local reward = item.reward
    local item_fullname = reward[1]
    Lib.logDebug("GetTaskReward get item item_fullname = ", item_fullname)
    local item_count = reward[2]
    Lib.logDebug("GetTaskReward get item item_count = ", item_count)
    for j = 1, item_count do
      Lib.logDebug("GetTaskReward get item")
      self:obtainItemsByFullName(item_fullname, 1, "getactivereward")
    end
  end
  self:setCurActiveIndex(math.modf(self:getActivePoint() / 20))
  local item_reward = task_data.item_reward
  Lib.logDebug("GetTaskReward item_reward = ", Lib.v2s(item_reward))
  local item_fullname = item_reward[1]
  local item_count = item_reward[2]
  for i = 1, item_count do
    self:obtainItemsByFullName(item_fullname, 1, "gettaskreward_" .. taskid)
  end
  self:setTaskIsRewarded(taskid)
end

function handles:resetInNpc(packet)
  local value = packet.value
  self:resetInNpc(value)
end

function handles:OnUseItem(packet)
  self:onUseItem(packet)
end

function handles:TelegraphToPos(packet)
  local x = tonumber(packet.x)
  local y = tonumber(packet.y)
  local z = tonumber(packet.z)
  self:setMapPos(self.map, Lib.v3(x, y, z))
end

function handles:OnBuyTriggerGift(packet)
  self:onBuyTriggerGift(packet)
end

function handles:pokemonBless(packet)
  local costFullName = packet.fullName
  local pokemon = self:getSelfPokemon(packet.objId)
  local bless_config = BlessItemConfig:getConfigByFullName(costFullName)
  if pokemon and bless_config then
    if pokemon:getBlessTimes(bless_config.bless_type) >= pokemon:getBlessLimit(bless_config.bless_type) then
      return {success = false}
    end
    if self:getTrayItemCountByFullName(costFullName) < 1 then
      return {success = false}
    end
    self:useBagItemByFullName(costFullName, 1, false, nil, nil, "use_bless_item")
    pokemon:addBless(bless_config.bless_type, bless_config.bless_level)
    self:useBlessingNewDesign(pokemon, bless_config.bless_type, bless_config.bless_level)
    local firstTriggerGift = self:getValue("firstTriggerGift")
    if not firstTriggerGift[Define.GIFT_TRIGGER_CONDITION.PET_LIFT .. "2"] then
      self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.PET_LIFT, 2)
      firstTriggerGift[Define.GIFT_TRIGGER_CONDITION.PET_LIFT .. "2"] = true
      self:setValue("firstTriggerGift", firstTriggerGift)
    end
    self:updateAllPokemonPower()
    return {success = true}
  end
  return {success = false}
end

function handles:pokemonBlessRemove(packet)
  local removeList = packet.removeList
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    for _, remove_table in pairs(removeList) do
      local bless_config = BlessItemConfig:getConfigByFullName(remove_table.fullName)
      pokemon:removeBless(bless_config.bless_type, bless_config.bless_level, remove_table.removeNum)
    end
    self:updateAllPokemonPower()
    return {success = true}
  end
  return {success = false}
end

function handles:setPokemonFreeFromClient(packet)
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    self:setPokemonFree(pokemon)
  end
end

function handles:gainPokemonFromClient(packet)
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    local capturePetList = self:getValue("capturePetList")
    for index, objId in pairs(capturePetList) do
      if tostring(objId) == tostring(pokemon:getObjId()) then
        table.remove(capturePetList, index)
        self:setValue("capturePetList", capturePetList)
        self:gainPokemon(pokemon)
        if not self:isGuideFinish() and self:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
          local guide_data = PokemonGuideConfig:getGuideData(Define.GUIDE_INDEX.FINISH_CAPTURE_POKEMON)
          if guide_data then
            self:getGuideReward(guide_data)
          end
        end
        break
      end
    end
  end
end

function handles:putCaptureInPacket(packet)
  local releaseObjId = packet.releaseObjId
  local releasePokemon = self:getSelfPokemon(releaseObjId)
  if releasePokemon then
    self:setPokemonFree(releasePokemon)
    handles.gainPokemonFromClient(self, {
      objId = packet.gainObjId
    })
    self:sortPokemonList()
    return Define.PUT_CAPTURE_IN_PACKET_CODE.SUCCESS
  end
  return Define.PUT_CAPTURE_IN_PACKET_CODE.FAIL
end

function handles:SwitchCurSelGlory(packet)
  self:switchCurSelGlory(packet.id)
end

function handles:leaveBattleField(packet)
  self:leaveBattleField()
end

function handles:getPkmSkillBuffTipEnd(packet)
end

function handles:RequestPlayerRank(packet)
  if not (packet and packet.rankType) or not packet.subId then
    return
  end
  local userId = self.platformUserId
  local rankIndex = self:getRankIndex()
  local rankType = packet.rankType
  local subId = packet.subId
  Rank.RequestUserRankInfo(userId, rankType, subId, rankIndex)
end

function handles:CheckRankReward(packet)
  if not packet then
    return
  end
  Lib.logInfo("CheckRankReward = ", self:getLastRankReward())
  if self:getLastRankReward() == false then
    self:setLastRankReward(true)
    local lastLangType = self:getLastLangType()
    local lastRankIndex = self:getLastRankIndex()
    local cfgs = Rank.GetSubRankCfgs(lastLangType)
    if not cfgs then
      return nil
    end
    local curTime = os.time()
    Lib.logInfo("CheckRankReward curTime = ", curTime)
    local lastWeekEndTime = Lib.getWeekEndTime(curTime - 604800)
    Lib.logInfo("CheckRankReward lastWeekEndTime = ", lastWeekEndTime)
    for subId, cfg in pairs(cfgs) do
      local status = self:getRankRewardStatus(subId)
      Lib.logInfo("CheckRankReward status = ", status)
      local expireTime = Rank.getRankExpireTime(curTime - 604800, lastLangType, subId)
      Lib.logInfo("CheckRankReward expireTime = ", expireTime)
      if status == 0 then
        if curTime > lastWeekEndTime and curTime < expireTime then
          Lib.logInfo("can get rank reward subId = ", subId)
          Rank.RequestLastWeekUserRankInfo(self.platformUserId, lastLangType, subId, lastRankIndex)
        end
      else
        Lib.logInfo("can not get rank reward subId = ", subId)
      end
    end
  end
end

function handles:SyncShopOperation(packet)
  Store.Shop:operationByType(self, packet.params)
end

function handles:GetGoldByExchanging(packet)
  self:getGoldByExchanging(packet.grade)
end

function handles:GetDailyFDiamondsReward(packet)
  self:getDailyFDiamondsReward(packet.count)
end

function handles:getRechargeAward(packet)
  local recharge_award = require("script_server.reward.recharge_award")
  recharge_award:rechargeAwardOperation(self, tonumber(packet.awardType), tonumber(packet.awardStatus))
end

function handles:SyncCasktMainSkillReady(packet)
  Lib.logInfo("______SyncCasktMainSkillReady:", packet.uid or "not uid", packet.skillId, packet.isEffectTrigger)
  local from = World.CurWorld:getEntity(packet.fromID)
  local target = World.CurWorld:getEntity(packet.targetID)
  if not from or not from:isValid() then
    if self.battleField then
      self.battleField:setAllStateReady(true)
    end
    Lib.logError("error:not from or not from:isValid() when SyncCasktMainSkillReady!!")
    return
  end
  if from:data("main").skillPacket then
    if from:data("main").skillPacket[packet.uid] then
      Lib.logWarning("warning:skill packet[" .. packet.uid .. "] have been dealt with!!", self.name, self.objID, packet.skillId, from.name, from.objID)
      return
    end
  else
    from:data("main").skillPacket = {}
  end
  from:data("main").skillPacket[packet.uid] = true
  Lib.logInfo("______Finish Cast skill:", packet.uid or "not uid", from.objID, packet.skillId, packet.isEffectTrigger)
  from:data("main").isEffectTriggerState = false
  local skill_config = SkillConfig:getConfigById(packet.skillId)
  if skill_config.isEffectTriiger == 1 then
    from.battleField:setAllStateReady(true)
    return
  end
  if from.curSkillBaseInfo and not from.curSkillBaseInfo.isAccuracy then
    from.battleField:setAllStateReady(true)
    return
  end
  local damage = from:data("main").skillDamage and from:data("main").skillDamage[tonumber(packet.skillId)] or 0
  local roundSkillEffcts = from.pokemon and from.pokemon:getLongRoundEffectbuffList() or {}
  local addSkillEffect = from:getAddSkillEffects() or {}
  for key, v in pairs(roundSkillEffcts) do
    local effectCfg = skillEffectCfg:getConfigById(v.skilleffectId)
    if effectCfg and effectCfg.effectSkillType < Define.EffectSkillType.fanji then
      local effectIntger = effectCfg and effectCfg.intger and effectCfg.intger or 0
      SkillEffectMgr:triggerFinishCastSkillEffect(from, v.buffCfg, v.skilleffectId, {
        key = key,
        round = v.round,
        damage = damage,
        intger = effectIntger
      })
    end
  end
  for key, v in pairs(addSkillEffect) do
    local effectCfg = skillEffectCfg:getConfigById(v.skilleffectId)
    if effectCfg and effectCfg.effectSkillType < Define.EffectSkillType.fanji then
      local effectIntger = effectCfg and effectCfg.intger and effectCfg.intger or 0
      SkillEffectMgr:triggerFinishCastSkillEffect(from, v.buffCfg, v.skilleffectId, {
        key = key,
        round = v.round,
        damage = damage,
        intger = effectIntger
      })
    end
  end
  SkillEffectMgr:addPassiveSkillEffect(Define.SkillEffectTiming.finshSkillCast, from, target)
  local skillEffect = skill_config.skill_effect
  local tbSkillCastEffect = SkillEffectMgr:getTriggerSkillCastEffect(from, target)
  if skillEffect and type(skillEffect) == "table" and 0 < #skillEffect then
    SkillEffectMgr:addInitiativeSkillEffect(packet.skillId, Define.SkillEffectTiming.finshSkillCast, from, target, skillEffect, true)
  elseif 0 < #tbSkillCastEffect then
    local skillId = from.curSkillBaseInfo and from.curSkillBaseInfo.id or nil
    if skillId then
      local realDamage = from:data("main").skillDamage and from:data("main").skillDamage[tonumber(skillId)] or 0
      SkillEffectMgr:processTriggerSkillCastEffect(from, tbSkillCastEffect, realDamage)
    else
      from.battleField:setAllStateReady(true)
    end
  else
    from.battleField:setAllStateReady(true)
  end
end

function handles:sendCaptureWorldTips(packet)
  if not self._lastMap then
    return
  end
  local mapId = Lib.getCurMapIndex(self._lastPos, self._lastMap.name)
  local map_config = MapConfig:getMapById(mapId) or {}
  local tipsInfo = {
    tipType = Define.WORLD_TIP_TYPE.CATCH,
    playerName = self.name,
    mapIdName = map_config.title or "",
    quality = packet.quality,
    pkmName = packet.pkmName,
    oldName = "",
    skillName = "",
    ownerName = "",
    starLevel = packet.starLevel or 1,
    syntheticNum = packet.skillList and #packet.skillList or 0
  }
  self:sendSpecialWorldCommonTips(tipsInfo)
end

function handles:getOtherPlayerPower(packet)
  local player = World.CurWorld:getObject(packet.targetID)
  if not player or not player:isValid() then
    return
  end
  local battlePetList = player:getBattlePokemon()
  local ret = 0
  local battleIconList = {}
  local k = 0
  for _, pet in pairs(battlePetList) do
    ret = ret + pet:getFightPower()
    k = k + 1
    battleIconList[k] = {}
    battleIconList[k].race = pet:getRace()
    battleIconList[k].icon = pet:getIcon()
    battleIconList[k].level = pet:getLevel()
  end
  local packet = {
    pid = "getOtherPlayerPower",
    battleIconList = battleIconList,
    power = ret
  }
  self:sendPacket(packet)
end

function handles:requestBugRegularGift(packet)
  return Store.RegularGiftShop:operationBuy(self, packet.itemId, packet.buyCount)
end

local function sendShowApplySwap(self, targetId)
  self:sendPacket({
    pid = "showApplySwap",
    targetId = targetId
  })
end

function handles:requestPlayerAction(packet)
  local target = World.CurWorld:getObject(packet.targetID)
  if not target or not target:isValid() then
    return Define.ERROR_CODE.TARGET_NIL
  end
  if target.isActing then
    return Define.ERROR_CODE.TARGET_BUSY
  end
  if packet.actionType == Define.PLAYER_ACTION.PK then
    if not self:isCanPkCurTarget(packet.targetID) then
      return Define.ERROR_CODE.FORBID
    end
    local packet = {
      pid = "syncRequestPKPlayer",
      fromID = self.objID
    }
    target:sendPacket(packet)
  elseif packet.actionType == Define.PLAYER_ACTION.SWAP then
    local swapCode = self:checkSwapCode(target)
    if swapCode ~= 0 then
      return swapCode
    end
    if target:isBanSwap() then
      return Define.ERROR_CODE.SWAP_BIND
    end
    if self:getSwapTargetId() == target.objID then
      handles.playerSwap(self, packet)
      target.isActing = true
      return Define.ERROR_CODE.SUCCESS
    end
    self:setSwapTargetId(target.objID)
    if target:getSwapTargetId() == 0 then
      target:setSwapTargetId(self.objID)
      sendShowApplySwap(target, self.objID)
      target.isActing = true
      self.isActing = true
      return Define.ERROR_CODE.SUCCESS
    else
      self:setSwapTargetId(0)
      return Define.ERROR_CODE.SWAPING
    end
  elseif packet.actionType == Define.PLAYER_ACTION.JOIN_TEAM then
  elseif packet.actionType == Define.PLAYER_ACTION.LEAVEL_TEAM then
  end
  target.isActing = true
  return Define.ERROR_CODE.SUCCESS
end

function handles:finishPlayerAction(packet)
  self.isActing = false
end

function handles:forbidPlayerAction(packet)
  self.isActing = true
end

function handles:refuseOthersPkRequest(packet)
  local from = World.CurWorld:getObject(packet.fromID)
  if not from or not from:isValid() then
    return
  end
  local packet = {
    pid = "syncPkRequestRefused",
    targetID = self.objID
  }
  from:sendPacket(packet)
end

function handles:agreeOthersPkRequest(packet)
  local fromID = packet.fromID
  local from = World.CurWorld:getObject(fromID)
  if not from or not from:isValid() then
    self:sendPacket({
      pid = "showCommonTips",
      message = "gui_player_offline",
      time = 40
    })
    return
  end
  if not self:isCanStartNewBattle(true) then
    Lib.logDebug("gui_tip_can_not_invitate self isCanStartNewBattle")
    from:sendPacket({
      pid = "showCommonTips",
      message = "gui_tip_can_not_invitate",
      time = 40
    })
    return
  end
  if not from:isCanStartNewBattle(true) then
    Lib.logDebug("gui_tip_can_not_invitate from isCanStartNewBattle")
    self:sendPacket({
      pid = "showCommonTips",
      message = "gui_tip_can_not_invitate",
      time = 40
    })
    return
  end
  if not self:isCanPkCurTarget(packet.fromID) then
    self:sendPacket({
      pid = "showCommonTips",
      message = "gui_tip_can_not_PK",
      time = 40
    })
    from:sendPacket({
      pid = "showCommonTips",
      message = "gui_tip_can_not_PK",
      time = 40
    })
    return
  end
  local objIDList = {}
  local packet = {
    pid = "syncPkRequestAgreed",
    targetID = self.objID
  }
  from:sendPacket(packet)
  table.insert(objIDList, self.objID)
  table.insert(objIDList, fromID)
  self:setBattlePreType(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
  self:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
  local myTeamMate = self:getMyTeamMate()
  if myTeamMate then
    myTeamMate:setBattlePreType(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
    myTeamMate:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
    table.insert(objIDList, self:getMyTeamMateId())
  end
  from:setBattlePreType(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
  from:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
  local fromTeamMate = from:getMyTeamMate()
  if fromTeamMate then
    fromTeamMate:setBattlePreType(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
    fromTeamMate:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.INTERACTION_PVP_PLAYER)
    table.insert(objIDList, from:getMyTeamMateId())
  end
  World.Timer(40, function()
    local isOffline = false
    for key, val in pairs(objIDList) do
      local playerEntity = World.CurWorld:getObject(val)
      if not playerEntity or not playerEntity:isValid() then
        isOffline = true
      end
    end
    if isOffline then
      for key, val in pairs(objIDList) do
        local playerEntity = World.CurWorld:getObject(val)
        if playerEntity and playerEntity:isValid() then
          playerEntity:sendPacket({
            pid = "showCommonTips",
            message = "gui_player_offline",
            time = 40
          })
          playerEntity:setBattlePreType(Define.MEET_PKM_TYPE.NO_MEET_PKM)
          playerEntity:sendStartPlayPreAnimation(Define.MEET_PKM_TYPE.NO_MEET_PKM)
        end
      end
    else
      from:onEnterPVP(self)
    end
  end)
end

function handles:requestInteractionFailed(packet)
  local from = World.CurWorld:getObject(packet.fromID)
  if not from or not from:isValid() then
    return
  end
  from:sendPacket({
    pid = "showCommonTips",
    message = "gui_tip_can_not_invitate",
    time = 40
  })
end

function handles:requestJoinTeam(packet)
  local target = World.CurWorld:getObject(packet.targetID)
  local from = World.CurWorld:getObject(packet.fromID)
  TeamMgr:requestJoinTeam(from, target)
end

function handles:agreeJoinTeam(packet)
  local target = World.CurWorld:getObject(packet.targetID)
  local from = World.CurWorld:getObject(packet.fromID)
  if not from or not from:isValid() then
    return
  end
  if not target or not target:isValid() then
    return
  end
  if not from:isCanTeamCurTarget(packet.targetID) then
    return
  end
  TeamMgr:agreeJoinTeam(from, target)
end

function handles:refuseJoinTeam(packet)
  local target = World.CurWorld:getObject(packet.targetID)
  local from = World.CurWorld:getObject(packet.fromID)
  TeamMgr:refuseJoinTeam(from, target)
end

function handles:requestLeaveTeam(packet)
  local player = World.CurWorld:getObject(packet.playerID)
  TeamMgr:leaveTeam(player)
end

function handles:kickForceObstacle(packet)
  self:kickForceObstacle()
end

function handles:ShowFollowPet(packet)
  local fullName = packet.fullName
  local objId = packet.objId
  return self:showFollowPet(fullName, objId)
end

function handles:pokemonStarUp(packet)
  if self.pokemonStarUpCd and self.pokemonStarUpCd > os.time() then
    return
  end
  self.pokemonStarUpCd = os.time() + 1
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    local materialList = PokemonManager:getPokemonList(packet.selectObjIds)
    local costMap = PokemonConfig:getStarConfig(pokemon:getStar()).starUpCost
    if #materialList ~= tonumber(costMap[1]) then
      return
    end
    for _, materialPokemon in pairs(materialList) do
      if not self:checkMyPokemon(materialPokemon) then
        return
      end
      if not PokemonConfig:checkMaterial(pokemon, materialPokemon) then
        return
      end
    end
    self:pokemonRelease(packet.selectObjIds)
    pokemon:starUp()
    self:pokemonNewDesign(pokemon, Define.newDesignEventKey.STAR_UP, "star", pokemon:getStar() - 1, pokemon:getStar())
    self:sortPokemonList()
    self:updateAllPokemonPower()
    self:updateTaskStatus(Define.TASK_TYPE.POKEMON_UPGRADE_STAR, 1, pokemon:getCfgId(), 1)
    local skillList = pokemon:getPassiveSkillList()
    local tipsInfo = {
      tipType = Define.WORLD_TIP_TYPE.UPGRADESTAT,
      playerName = self.name,
      mapIdName = "",
      quality = pokemon:getQuality(),
      pkmName = pokemon:getCfg().name,
      oldName = "",
      skillName = "",
      ownerName = "",
      starLevel = pokemon:getStarLevel(),
      syntheticNum = skillList and #skillList or 0
    }
    self:sendSpecialWorldCommonTips(tipsInfo)
  end
end

function handles:pokemonCanWakeUp(packet)
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    local wake_config = PokemonConfig:getWakeConfig(pokemon:getWake())
    local costNum = wake_config.wakeUpCost
    local costPokemonList = PokemonManager:getPokemonList(packet.costIds)
    if costNum > #costPokemonList then
      return 1
    end
    for _, costPokemon in pairs(costPokemonList) do
      if not self:checkMyPokemon(costPokemon) then
        return 2
      end
      if pokemon == costPokemon then
        return 2
      end
      if not PokemonConfig:isSamePokemon(pokemon:getCfgId(), costPokemon:getCfgId()) then
        return 2
      end
    end
    return 0
  end
  return 100
end

function handles:pokemonWakeUp(packet)
  local code = handles.pokemonCanWakeUp(self, packet)
  if code ~= 0 then
    return
  end
  local pokemon = self:getSelfPokemon(packet.objId)
  if pokemon then
    self:pokemonRelease(packet.costIds)
    pokemon:wakeUp()
    self:pokemonNewDesign(pokemon, Define.newDesignEventKey.WAKE_UP, "wake", pokemon:getWake() - 1, pokemon:getWake())
    pokemon:lock(true)
    self:sortPokemonList()
    local skillList = pokemon:getPassiveSkillList()
    local tipsInfo = {
      tipType = Define.WORLD_TIP_TYPE.WAKEUP,
      playerName = self.name,
      mapIdName = "",
      quality = pokemon:getQuality(),
      pkmName = pokemon:getCfg().name,
      oldName = "",
      skillName = "",
      ownerName = "",
      starLevel = pokemon:getStarLevel(),
      syntheticNum = skillList and #skillList or 0
    }
    self:sendSpecialWorldCommonTips(tipsInfo)
    if not self:isGuideFinish() and self:getCurGuideIndex() == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_PACKET then
      local guide_data = PokemonGuideConfig:getGuideData(Define.GUIDE_INDEX.FINISH_WAKE_POKEMON)
      self:getGuideReward(guide_data)
    end
  end
end

function handles:lockPokemon(packet)
  local objId = packet.objId
  local value = packet.value
  if not objId or value == nil then
    return
  end
  local pokemon = PokemonManager:getPokemon(objId, self.platformUserId)
  if not pokemon then
    return
  end
  pokemon:lock(value)
  self:sortPokemonList()
  return true
end

function handles:SendFinishGuide(packet)
  self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.TASK_FINISH, packet.index)
  self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.TASK_IN, packet.index + 1)
end

function handles:autoSkipResult(packet)
  for _, pokemon in pairs(self:getBattlePokemon()) do
    pokemon:evolution()
  end
  if self.battleField then
    self.battleField:leave(self)
    self:setFollowPetTargetWhenLeaveBattle()
    self:removePlayerMirror()
  end
  self:setReadyCloseResult(true)
  self:updateAllPokemonPower()
end

function handles:takeLuckyEggAward(packet)
  Store.LuckyEggAward:operationTakeLucky(self, packet.tabType, packet.takeType)
end

function handles:receiveLuckyEggExtraAward(packet)
  Store.LuckyEggAward:operationReceiveLuckyExtra(self, packet.extraId)
end

function handles:requestCurServerTime()
  self:sendPacket({
    pid = "pushCurServerTime",
    curServerTime = os.time()
  })
end

function handles:takeRotaryTableAward(packet)
  Store.RotaryTableAward:operationTakeRotary(self, packet.tabType)
end

function handles:tryDoDailyLottery(packet)
  local player = World.CurWorld:getObject(packet.objID)
  if player and player:isValid() then
    DailyLotteryMgr:doDailyLottery(player)
  end
end

function handles:SelectThreeSelOne(packet)
  if self:getThreeSelCache() == 0 or type(self:getThreeSelCache()) == "table" and not next(self:getThreeSelCache()) then
    return
  end
  self:petChooseThreeSuccess(packet.petId)
end

function handles:buyFollowPetPrivilege(packet)
  if self:getFollowPetPrivilege() then
    return
  end
  self:setFollowPetPrivilege(true)
  self:sendPacket({
    pid = "BuyFollowPetPrivilegeSuccess"
  })
  GameAnalytics.Design(self.platformUserId, 1, {
    "Follow_success"
  })
end

function handles:gotoNextGuide()
  self:gotoNextGuide()
end

function handles:gotoSpecificGuide(packet)
  local index = packet.index
  self:setCurGuideIndex(index)
end

function handles:sendEggResultTip(packet)
  if not packet.luckyResult then
    return
  end
  local pokemon = PokemonManager:getPokemon(packet.luckyResult.pkmObjId)
  if pokemon then
    local skillList = pokemon:getPassiveSkillList()
    local tipsInfo = {
      tipType = Define.WORLD_TIP_TYPE.INCUBATE,
      playerName = self.name,
      mapIdName = "",
      quality = pokemon:getQuality(),
      pkmName = pokemon:getCfg().name,
      oldName = "",
      skillName = "",
      growthSCount = 0,
      ownerName = "",
      starLevel = pokemon:getStarLevel(),
      syntheticNum = skillList and #skillList or 0
    }
    self:sendSpecialWorldCommonTips(tipsInfo)
  end
end

function handles:SetUIAvoidBattle(packet)
  self:setUIAvoidBattle(packet.isAvoid)
end

function handles:OnWatchAdResult(packet)
  local code = packet.code
  local context = {
    obj1 = self,
    type = packet.type,
    params = packet.params
  }
  local type = packet.type
  local params = packet.params
  if code == 1 then
    self:grantAdReward(type, params)
    Trigger.CheckTriggers(self:cfg(), "WATCH_AD_FINISHED", context)
  elseif code == 2 then
    Trigger.CheckTriggers(self:cfg(), "WATCH_AD_FAILED", context)
  elseif code == 3 then
    Trigger.CheckTriggers(self:cfg(), "CLOSE_WATCH_AD", context)
  end
  local packet = {
    pid = "SCWatchCarAdResult",
    type = type,
    code = code,
    params = params
  }
  self:sendChatMsg(packet)
end
