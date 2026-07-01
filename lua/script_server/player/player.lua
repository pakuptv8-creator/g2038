local BattleFieldManager = require("script_server.battle.battle_field_manager")
local PokemonManager = require("script_server.pokemon.pokemon_manager")
local PlayerDBMgr = T(Lib, "PlayerDBMgr")
local setting = require("common.setting")
local MainBattleRewardConfig = T(Config, "MainBattleRewardConfig")
local NormalBattleRewardConfig = T(Config, "NormalBattleRewardConfig")
local NPCConfig = T(Config, "NPCConfig")
local GloryConfig = T(Config, "GloryConfig")
local LuaTimer = T(Lib, "LuaTimer")
local PokemonTaskConfig = T(Config, "PokemonTaskConfig")
local PokemonConfig = T(Config, "PokemonConfig")
local MapConfig = T(Config, "MapConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local DBHandler = require("dbhandler")
local GymConfig = T(Config, "GymConfig")
local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
local CheatConfig = T(Config, "CheatConfig")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local Player = _ENV.Player
local engine_initPlayer = Player.initPlayer

local function checkTableSame(array)
  local map = {}
  local newArray = {}
  for index, value in pairs(array) do
    if not map[value] then
      map[value] = index
      table.insert(newArray, value)
    end
  end
  return newArray
end

function Player:initPlayer(attrInfo)
  engine_initPlayer(self, attrInfo)
  self.catchFailCount = 0
  self.onlineTime = 0
  self:setBpIndex(1)
  self.enemyList = {}
  self.lockEnterPVP = false
  self.isHosting = false
  self:resetBattleState()
  self:setCampId(0)
  self.isInBattleResult = false
  self:playMainBGM()
end

function Player:initDBData()
  local noConfigPetAttr = {}
  local battlePetList = {}
  local packetPetList = {}
  local uuidMap = {}
  for _, info in pairs(self:getValue("battlePetAttr")) do
    if PokemonConfig:getConfigById(info.cfgId) then
      if not info.uid or not uuidMap[tostring(info.uid)] then
        uuidMap[tostring(info.uid)] = true
        local pokemon = PokemonManager:initPokemon(info)
        pokemon:setMasterId(self.platformUserId)
        table.insert(battlePetList, pokemon:getObjId())
      end
    else
      table.insert(noConfigPetAttr, info)
    end
  end
  self:setValue("battlePetList", battlePetList)
  for _, info in pairs(self:getValue("packetPetAttr")) do
    if PokemonConfig:getConfigById(info.cfgId) then
      if not info.uid or not uuidMap[tostring(info.uid)] then
        uuidMap[tostring(info.uid)] = true
        local pokemon = PokemonManager:initPokemon(info)
        pokemon:setMasterId(self.platformUserId)
        table.insert(packetPetList, pokemon:getObjId())
      end
    else
      table.insert(noConfigPetAttr, info)
    end
  end
  self:setValue("packetPetList", packetPetList)
  self:setValue("noConfigPetAttr", noConfigPetAttr)
end

PlayerDBMgr.registerLoginDBDataRequestFunc(Define.DBSubKey.PlayerData, nil, function(player)
  local battleInfoList = {}
  for _, pokemon in pairs(player:getBattlePokemon()) do
    table.insert(battleInfoList, pokemon:getDBInfo())
  end
  local packetInfoList = {}
  for _, pokemon in pairs(player:getPacketPokemon()) do
    table.insert(packetInfoList, pokemon:getDBInfo())
  end
  local noConfigPetAttr = player:getValue("noConfigPetAttr")
  for _, info in pairs(noConfigPetAttr) do
    table.insert(packetInfoList, info)
  end
  if #player:getValue("battlePetList") == #battleInfoList then
    player:setValue("battlePetAttr", battleInfoList)
  end
  if #player:getValue("packetPetList") + #noConfigPetAttr == #packetInfoList then
    player:setValue("packetPetAttr", packetInfoList)
  end
  return player:saveDBData()
end)

function Player:playMainBGM()
  self:addBuff("myplugin/bgm_buff_main")
end

function Player:playBattleBGM(type)
  self:removeTypeBuff("fullName", "myplugin/bgm_buff_field")
  self:removeTypeBuff("fullName", "myplugin/bgm_buff_gym_01")
  World.Timer(1, function()
    self:removeTypeBuff("fullName", "myplugin/bgm_buff_main")
  end)
  if type == Define.BATTLE_MODE.PVE then
    self:addBuff("myplugin/bgm_buff_battle_normal")
  elseif type == Define.BATTLE_MODE.NPC then
    self:addBuff("myplugin/bgm_buff_battle_npc")
  elseif type == Define.BATTLE_MODE.PVP then
    self:addBuff("myplugin/bgm_buff_battle_dao")
  end
end

function Player:playResultBGM(isWin)
  if isWin then
    self:addBuff("myplugin/bgm_buff_battle_win")
  else
    self:addBuff("myplugin/bgm_buff_battle_lost")
  end
end

function Player:stopBattleBGM(type)
  if type == Define.BATTLE_MODE.PVE then
    self:removeTypeBuff("fullName", "myplugin/bgm_buff_battle_normal")
  elseif type == Define.BATTLE_MODE.NPC then
    self:removeTypeBuff("fullName", "myplugin/bgm_buff_battle_npc")
  elseif type == Define.BATTLE_MODE.PVP then
    self:removeTypeBuff("fullName", "myplugin/bgm_buff_battle_dao")
  end
  self:removeTypeBuff("fullName", "myplugin/bgm_buff_battle_win")
  self:removeTypeBuff("fullName", "myplugin/bgm_buff_battle_lost")
end

function Player:setCatchTarget(target)
  self.catchTarget = target
end

function Player:getCatchTarget()
  return self.catchTarget
end

function Player:setCmdReady(value)
  self.cmdReady = value
  Lib.logInfo("setCmdReady", value, self.objID, self:isValid() and tostring(self.platformUserId))
end

function Player:setStateReady(state)
  self.stateReady = state
  self.curCmdType = ""
  self.cmdResult = false
  if self.debugStateReady then
    local trace = debug.traceback()
    Lib.logInfo("setStateReady", self.name, state, state and trace)
  end
end

function Player:deltaCurrency(type, val, reason, canOverdraft, related)
  if not type then
    perror("change currency mush have a type!")
    return
  end
  if not val or val == 0 then
    return
  end
  if not reason then
    perror("change currency mush have a reason!")
    return
  end
  val = math.floor(val)
  if 0 < val then
    self:addCurrency(type, val, reason, related)
  else
    self:payCurrency(type, -val, not canOverdraft, false, reason)
    self:sendPacket({
      pid = "ShowPayCurrencyTip",
      countDif = val,
      reason = reason
    })
  end
end

function Player:resetBattleState()
  self:setStateReady(false)
  self:setCmdReady(false)
end

function Player:recoveryInGuidance()
  if not self:isGuideFinish() and self:getCurGuideIndex() <= Define.GUIDE_INDEX.FINISH_CAPTURE_POKEMON then
    self:recoveryBattlePokemon()
  end
end

function Player:getFightPower()
  local power = 0
  local battlePetList = self:getBattlePokemon()
  for _, pet in pairs(battlePetList) do
    power = power + pet:getFightPower()
  end
  return power
end

function Player:savePVPGymBattle(gym_type, gym_index, gym_progress)
  local battlePetList = self:getBattlePokemon()
  local infos = {}
  for _, pet in pairs(battlePetList) do
    local info = pet:getDBInfo()
    local pokemon = PokemonManager:initPokemon(info)
    pokemon:recoveryAll()
    info = pokemon:getDBInfo()
    table.insert(infos, info)
    pokemon:onDestroy()
  end
  self:setPVPBattlePetAttr(gym_type, infos)
  self:setPVPActorName(gym_type, self:data("main").actorName)
  self:setPVPSkin(gym_type, self:data("skin"))
  PlayerDBMgr.onSaveLoginDBData(self)
end

function Player:isPokemonRaceMatch(race)
  local isMatch = true
  local battlePetList = self:getBattlePokemon()
  for _, pet in pairs(battlePetList) do
    if pet:getRace() ~= race then
      Lib.logDebug("isPokemonRaceMatch not match")
      isMatch = false
      break
    end
  end
  return isMatch
end

function Player:reportBattlePower()
  local unlockLevel = PlayerExpConfig:getLvByUnlockMod(Define.MODULE_TYPE.MAIN_LEADERBOARD)
  Lib.logDebug("reportBattlePower unlockLevel = ", unlockLevel)
  if unlockLevel ~= -1 and unlockLevel <= self:getPlayerLevel() then
    local power = self:getFightPower()
    local rankType = self:getLangType()
    local rankIndex = self:getRankIndex()
    if rankIndex ~= -1 and rankType ~= 0 then
      self:updateRankScore(rankType, Define.RANK_SUB_TYPE.POWER, rankIndex, power)
    end
  end
end

function Player:reportedRankData()
  self:reportBattlePower()
end

function Player:resetRank()
  Lib.logDebug("resetRank init rank index")
  self:setLastRankReward(false)
  self:resetPVPRankList()
  local power = 0
  local battlePetList = self:getBattlePokemon()
  for _, pet in pairs(battlePetList) do
    power = power + pet:getFightPower()
  end
  if self:getLastLangType() ~= 0 and self:getLastRankIndex() ~= -1 then
    local curTime = os.time()
    local lastWeekRankExpireTime = Rank.getRankExpireTime(curTime - 1209600, self:getLastLangType(), 1)
    if curTime >= lastWeekRankExpireTime then
      Lib.logDebug("resetRankRewardStatus")
      self:resetRankRewardStatus()
    end
  end
  self:setLastLangType(self:getLangType())
  self:setLastRankIndex(self:getRankIndex())
  local cache = UserInfoCache.GetCache(self.platformUserId)
  Lib.logDebug("resetRank cache = ", Lib.v2s(cache))
  local lang = Define.RANK_LANG_TYPE.EN
  if cache and cache.language then
    lang = cache.language
  end
  self:setLangType(Lib.getLangType(lang))
  if power <= World.cfg.rankThreshold then
    Lib.logDebug("power less than rankThreshold goto rankindex 0")
    self:setRankIndex(0)
  else
    local rank_counter_key = Lib.getRankCounterKey(lang)
    Rank.RequestRankCounter(self.platformUserId, rank_counter_key)
  end
end

function Player:startGuidance()
  local cur_guide_index = self:getCurGuideIndex()
  Lib.logDebug("startGuidance cur_guide_index= ", cur_guide_index)
  if cur_guide_index == 0 then
    cur_guide_index = Define.GUIDE_INDEX.SELECT_INIT_POKEMON
  end
  local guide_data = PokemonGuideConfig:getGuideData(cur_guide_index)
  if guide_data.next_guide_index == -1 or self:getPlayerLevel() > 30 and not Define.WEAK_GUIDA[cur_guide_index] then
    self:setGuideFinish(true)
  else
    self:setGuideFinish(false)
  end
  if not self:isGuideFinish() then
    local packet = {
      pid = "ShowBlockInputEvents"
    }
    self:sendPacket(packet)
    if cur_guide_index == Define.GUIDE_INDEX.SELECT_INIT_POKEMON then
      if self:getInitPokemonId() ~= 0 then
        self:setNpcChallenge(10109, 0)
        self:setNpcChallenge(10110, 0)
        self:setNpcChallenge(10111, 0)
        self:setValue("curGuideIndex", Define.GUIDE_INDEX.FINISH_SELECT_POKEMON)
      else
        self:setValue("curGuideIndex", cur_guide_index)
      end
    elseif cur_guide_index == Define.GUIDE_INDEX.TAKE_TEN_CONFIRM then
      if self:getFirstLuckyEgg() == true then
        self:setValue("curGuideIndex", guide_data.continue_guide_index)
      else
        self:setValue("curGuideIndex", Define.GUIDE_INDEX.TAKE_TEN_OPEN_LUCKY)
      end
    elseif cur_guide_index == Define.GUIDE_INDEX.TAKE_TEN_CLOSE or cur_guide_index == Define.GUIDE_INDEX.TAKE_TEN_CLOSE_LUCKY then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.GOTO_FIRST_NPC or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_1_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_2_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_3_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_4_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_5_BOSS then
      local challenge = self:getNpcChallenge(tonumber(guide_data.npc_id))
      if challenge == nil or 0 < challenge then
        self:setValue("curGuideIndex", cur_guide_index)
      else
        self:setValue("curGuideIndex", guide_data.next_guide_index)
      end
    elseif cur_guide_index == Define.GUIDE_INDEX.CAPTURE_POKEMON_USE_BALL or cur_guide_index == Define.GUIDE_INDEX.CAPTURE_POKEMON_CONFIRM_BALL or cur_guide_index == Define.GUIDE_INDEX.CAPTURE_POKEMON_PUT_BALL then
      if self:isThrowBall() == true then
        self:obtainItemsByFullName("myplugin/pokeball_01", 1, "getguidereward")
      end
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_POKEMON or cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_SELECT_UPGRADE or cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CONFIRM_UPGRADE or cur_guide_index == Define.GUIDE_INDEX.OPEN_FOLLOW_PET or cur_guide_index == Define.GUIDE_INDEX.CONFIRM_FOLLOW_PET then
      Lib.logDebug("continue_guide_index = ", guide_data.continue_guide_index)
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_UPGRADE or cur_guide_index == Define.GUIDE_INDEX.UPGRADE_POKEMON_CLOSE_PACKET then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_EMPTY or cur_guide_index == Define.GUIDE_INDEX.FILL_POKEMON_SELECT_POKEMON or cur_guide_index == Define.GUIDE_INDEX.FILL_POKEMON_SAVE_QUEUE then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.FILL_POKEMON_CLOSE_PACKET then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_TAB or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_OPEN_WND or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_ADD_MATERIAL or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_SELECT_MATERIAL or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_MATERIAL or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_CONFIRM_WAKE or cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_WND then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    elseif cur_guide_index == Define.GUIDE_INDEX.WAKE_POKEMON_CLOSE_PACKET then
      self:setValue("curGuideIndex", guide_data.continue_guide_index)
    else
      self:setValue("curGuideIndex", cur_guide_index)
    end
  end
end

function Player:isCheating()
  Lib.logDebug("isCheating self.platformUserId = ", self.platformUserId)
  local cheat_datas = CheatConfig:getUser(self.platformUserId)
  Lib.logDebug("cheat_datas = ", Lib.v2s(cheat_datas))
  for _, cheat_data in pairs(cheat_datas) do
    Lib.logDebug("cheat_data = ", Lib.v2s(cheat_data))
    local status = self:getCheating(cheat_data.time)
    Lib.logDebug("isCheating status = ", status)
    if status == nil then
      self:setCheating(cheat_data.time, 1)
      local packet = {
        pid = "showCheating",
        name = self.name,
        time = cheat_data.time,
        pay = cheat_data.pay
      }
      self:sendPacket(packet)
    end
  end
end

function Player:changePVPEntities()
  local curGym = self:getCurGym()
  if curGym ~= 0 then
    local gym_config = GymConfig:getGymById(curGym)
    if gym_config and gym_config.is_pvp == 1 then
      self:loadPVPGymEntities(gym_config.map, gym_config.type, curGym)
    end
  end
end

function Player:loadPVPGymEntities(mapName, gymType, gymId)
  local rankType = self:getLangType()
  local rankIndex = self:getRankIndex()
  local userId = self.platformUserId
  Rank.GetSubRankData(rankType, gymType, rankIndex, function(rankDatas)
    local player = Game.GetPlayerByUserId(userId)
    if player and player:isValid() then
      local map = World.CurWorld:getMap(mapName)
      for objID, npcId in pairs(map.npcEntities) do
        player:loadPVPGymEntity(rankDatas, map, gymType, gymId, objID)
      end
    end
  end)
end

function Player:loadPVPGymEntity(rankDatas, map, gymType, gymId, objID)
  local npcId = map.npcEntities[objID]
  local npc_config = NPCConfig:getNPCById(npcId)
  if npc_config and npc_config.gym_id == gymId and npc_config.is_pvp == 1 then
    local gym_index = npc_config.gym_index
    local rank = 8 - gym_index
    local rankData = rankDatas[rank]
    if rankData then
      do
        local playerId = self.platformUserId
        local userId = rankData.userId
        if rankData.isnpc == false then
          DBHandler:getDataByUserId(userId, 1, function(userId, txt)
            local seri = require("seri")
            local misc = require("misc")
            local data
            if txt and txt ~= "" then
              data = seri.deseristring_string(misc.base64_decode(txt))
            end
            local npcEntity = World.CurWorld:getEntity(objID)
            if npcEntity then
              local player = Game.GetPlayerByUserId(playerId)
              if player and player:isValid() then
                local actorName = data.values.pvpActorNames[gymType]
                if actorName then
                  player:sendPacketToTracking({
                    pid = "ChangeActor",
                    objID = objID,
                    name = actorName,
                    clearSkin = true
                  }, true)
                end
                local skin = data.values.pvpSkins[gymType]
                if skin then
                  player:sendPacketToTracking({
                    pid = "SkinChange",
                    objID = objID,
                    skinData = skin
                  }, true)
                end
                player:sendPacketToTracking({
                  pid = "SetEntityName",
                  objID = objID,
                  name = rankData.name
                }, true)
              end
            end
          end, function(userId)
            Lib.logInfo("get db data failed userId = ", userId)
          end)
        end
      end
    end
  end
end

function Player:doDataExpire()
  local lastLoginTime = self:getLastLoginTime()
  local nowTime = os.time()
  Lib.logDebug("doDataExpire userId = ", self.platformUserId)
  if lastLoginTime then
    Lib.logInfo("getFollowPetPrivilege = ", self:getFollowPetPrivilege())
    if self:isGuideFinish() and self:getFollowPetPrivilege() == false then
      Lib.logInfo("setFollowPetPrivilege")
      self:setFollowPetPrivilege(true)
      for _, pet in pairs(self:getBattlePokemon()) do
        Lib.logInfo("showFollowPet fullName = ", pet:getCfgFullName())
        Lib.logInfo("showFollowPet objId = ", pet:getObjId())
        self:showFollowPet(pet:getCfgFullName(), pet:getObjId())
        break
      end
    end
    if self:isGuideFinish() then
      self:setNpcChallenge(10109, 0)
      self:setNpcChallenge(10110, 0)
      self:setNpcChallenge(10111, 0)
    end
    local gymProgressList = self:getValue("gymProgressList")
    Lib.logDebug("gymProgressList = ", Lib.v2s(gymProgressList))
    for gym_id, gym_progress in pairs(gymProgressList) do
      local gym_config = GymConfig:getGymById(gym_id)
      if gym_config and gym_config.is_pvp == 0 then
        Lib.logDebug("set gym_id and gym_progress = ", gym_id, gym_progress)
        if gym_progress == 7 then
          self:setGymFinish(gym_id, 1)
        end
        local gloryId = GloryConfig:getGloryIdByGymIdAndGymProgress(gym_id, gym_progress)
        if gloryId and self:getGloryStatus(gloryId) == Define.GLORY_STATUS.INIT then
          self:catchGlory(gloryId)
        end
      end
    end
    if Lib.confirmDateChanged(lastLoginTime, nowTime, World.cfg.offsetTime) then
      self:setActiveDay(self:getActiveDay() + 1)
      self:setValue("dailyFDiamond", true)
      self:resetNpcChallengeState()
      self:resetHonorGymState()
      self:sendDailyFDiamondsReward()
      self:initDailyTask()
      self:setValue("onlineGiftBagStatus", true)
      if not self:getSoundMoonCardEnable() then
        self:initFreeSoundTimes()
      end
      if not Lib.isSameWeek(lastLoginTime, nowTime) then
        self:resetRank()
      end
    elseif self:getValue("dailyFDiamond") then
      self:sendDailyFDiamondsReward()
    end
  else
    self:setActiveDay(self:getActiveDay() + 1)
    self:setCurGuideIndex(Define.GUIDE_INDEX.SELECT_INIT_POKEMON)
    self:setValue("dailyFDiamond", true)
    self:sendDailyFDiamondsReward()
    local cache = UserInfoCache.GetCache(self.platformUserId)
    Lib.logDebug("first login cache = ", Lib.v2s(cache))
    local langType = Define.RANK_LANG_TYPE.EN
    if cache and cache.language then
      Lib.logDebug("first login cache.language = ", cache.language)
      langType = Lib.getLangType(cache.language)
    end
    self:setLangType(langType)
    self:setRankIndex(0)
  end
  self:updateLastLoginTime()
  Store.Shop:initShopInfo(self)
  Store.RegularGiftShop:updateRegularGiftTime(self)
end

function Player:sendDailyFDiamondsReward()
  if not World.cfg.useFDiamonds then
    return
  end
  local packet = {
    pid = "informDailyReward"
  }
  self:sendPacket(packet)
end

function Player:resetDailyTask()
  local task_status_list = self:getDailyTaskStatusList()
  if 8 < #task_status_list then
    self:initDailyTask()
  end
end

function Player:initDailyTask()
  self:setActivePoint(0)
  self:setCurActiveIndex(0)
  local level = self:getPlayerLevel()
  local activeDday = self:getActiveDay()
  local gym = self:getGymFinishCount()
  local task_list = PokemonTaskConfig:getTask(level, gym, activeDday)
  self:setDailyTaskList(task_list)
  local task_status_list = {}
  for i = 1, #task_list do
    local task_status = {}
    local id = task_list[i]
    local data = PokemonTaskConfig:getTaskById(id)
    task_status.id = id
    task_status.type = data.type
    task_status.condition = data.condition
    task_status.finished = 0
    task_status.rewarded = 0
    local targets = {}
    for j = 1, #data.targets do
      local target = data.targets[j]
      table.insert(targets, {
        target[1],
        0,
        0
      })
    end
    task_status.targets = targets
    task_status_list[id] = task_status
  end
  self:initDailyTaskStatusList(task_status_list)
end

function Player:resetHonorGymState()
  local gym_datas = GymConfig:getHonorGyms()
  for _, gym_data in pairs(gym_datas) do
    local gym_id = gym_data.id
    self:setGymProgress(gym_id, 0)
    self:setGymFinish(gym_id, 0)
  end
end

function Player:resetNpcChallengeState()
  local datas = self:getValue("npcChallengeList")
  Lib.logDebug("npcChallengeList datas = ", Lib.v2s(datas))
  for id, data in pairs(datas) do
    Lib.logDebug("resetNpcChallengeState id and data = ", id, data)
    if data ~= nil then
      local npc_config = NPCConfig:getNPCById(id)
      if npc_config and npc_config.free_challenge_per_day ~= 0 then
        datas[id] = nil
      end
    end
  end
  Lib.logDebug("resetNpcChallengeState datas = ", Lib.v2s(datas))
  self:setValue("npcChallengeList", datas)
end

function Player:notifyStateReady(packet)
  if self.battleField then
    self.battleField:notifyStateReady(self, packet)
    EncounterMgr:resetPlayerThey(self)
  end
end

function Player:isCanStartNewBattle(isPVP)
  if not self:isValid() then
    return false
  end
  if self:isJoinTeam() and not self:isTeamCaptain() then
    return
  end
  if not self:getFirstBattlePokemon() then
    return false
  end
  if self:isInBattle() then
    return false
  end
  if self:getValue("battlePreType") ~= 0 then
    return false
  end
  if self:getInNpc() ~= 0 then
    return false
  end
  if self:isUIAvoidBattle() then
    return false
  end
  if isPVP then
    if self:isAvoidPVPBattle() then
      return false
    end
  elseif self:isAvoidBattle() then
    return false
  end
  if self:getSwapTargetId() ~= 0 then
    return false
  end
  return true
end

function Player:triggerMonster(entity)
  if self.isInBattleResult then
    return
  end
  if entity:isInBattle() or entity.isPreBattleState then
    return
  end
  if not self:isCanStartNewBattle() then
    return
  end
  entity.isPreBattleState = true
  EncounterMgr:startBrightPkmBattle(entity.objID, self)
end

function Player:copyPlayerMirror()
  if not self.mirrorPlayer then
    local mainData = self:data("main")
    local sex = mainData.sex
    self.mirrorPlayer = EntityServer.Create({
      map = self.map,
      name = "",
      cfgName = sex == 1 and "myplugin/player_npc" or "myplugin/player_npc_girl",
      pos = self:getPosition(),
      ry = self:getRotationYaw(),
      rp = self:getRotationPitch()
    })
    self.mirrorPlayer:changeSkin(self:data("skin"))
  else
    self.mirrorPlayer:setPos(self:getPosition())
  end
end

function Player:removePlayerMirror()
  if self.mirrorPlayer then
    self.mirrorPlayer:destroy()
    self.mirrorPlayer = nil
  end
end

function Player:enterBattleField(battleField, index, campId, enemyList)
  if battleField and self:getFirstBattlePokemon() then
    self:copyPlayerMirror()
    self:playBattleBGM(battleField:getBattleMode())
    local followPet = self:getFollowPetEntity()
    if followPet then
      local aiControl = followPet:getAIControl()
      aiControl:setFollowTarget(self.mirrorPlayer)
    end
    local npcId = battleField:getNPCId()
    if npcId then
      Lib.reportChallengeNpc(self, npcId, battleField:is2V2Mode())
      if npcId == 20301 or npcId == 20307 then
        Lib.reportChallengePetNumber(self, npcId)
      end
    end
    battleField:enter(self, index, campId, enemyList)
  end
end

function Player:leaveBattleField()
  if self.battleField then
    self:stopBattleBGM(self.battleField:getBattleMode())
    self.battleField:leave(self)
  end
  self:resetBattleState()
  self:setCampId(0)
  EncounterMgr:resetPlayerThey(self)
  self:setFollowPetTargetWhenLeaveBattle()
  self:removePlayerMirror()
end

function Player:checkHasLifePet()
  for _, pet in pairs(self:getBattlePokemon()) do
    if pet:getCurHp() > 0 then
      return true
    end
  end
  return false
end

function Player:onEnterPVP(target)
  if self.lockEnterPVP or target.lockEnterPVP then
    Lib.logError("onEnterPVP lockEnterPVP", self.name, target.name)
    return
  end
  if not self:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon", self.name)
    return
  end
  if not target:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon", target.name)
    return
  end
  self.isChallenger = true
  target.isChallenger = false
  if not self:isJoinTeam() and not target:isJoinTeam() then
    self:onEnterPVP1V1(target)
    return
  end
  if self:isTeamCaptain() and target:isTeamCaptain() then
    self:onEnterPVP2V2(target)
    return
  end
end

function Player:onEnterPVP1V1(target)
  local battleField = BattleFieldManager:create({
    map = Lib.getPVPMapName(self:getPosition()),
    playerNum = 2,
    mode = Define.BATTLE_MODE.PVP
  })
  if battleField then
    self:enterBattleField(battleField, 1, Define.CAMP.CAMP_A, {target})
    target:enterBattleField(battleField, 7, Define.CAMP.CAMP_B, {self})
  end
end

function Player:onEnterPVP2V2(target)
  local playerA = self
  local playerB = self:getMyTeamMate()
  playerB.isChallenger = true
  local playerC = target
  local playerD = target:getMyTeamMate()
  playerD.isChallenger = false
  if not (playerB and playerB:isValid() and playerD) or not playerD:isValid() then
    return
  end
  if not playerB:getFirstBattlePokemon() or not playerD:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon")
    return
  end
  local battleField = BattleFieldManager:create({
    map = Lib.getPVPMapName(self:getPosition()),
    playerNum = 4,
    mode = Define.BATTLE_MODE.PVP
  })
  if battleField then
    TeamMgr:enterBattleField(playerA, battleField, 2, Define.CAMP.CAMP_A, {playerC, playerD})
    TeamMgr:enterBattleField(playerC, battleField, 8, Define.CAMP.CAMP_B, {playerA, playerB})
  end
end

function Player:getRandomBattlePokemon()
  local battlePetList = self:getValue("battlePetList")
  for _, battlePetId in pairs(battlePetList or {}) do
    local battlePet = PokemonManager:getPokemon(battlePetId)
    if battlePet and battlePet:getCurHp() > 0 then
      return battlePet
    end
  end
  return nil
end

function Player:capturePokemon(pokemon, ballId)
  ballId = ballId or 1
  if not pokemon then
    return
  end
  local newPokemon = PokemonManager:createPokemon(pokemon:getCfgId(), 1)
  newPokemon:setBallId(ballId)
  newPokemon:setStar(pokemon:getStar())
  self:putCaptureList(newPokemon)
end

function Player:putCaptureList(pokemon)
  pokemon:setMasterId(self.platformUserId)
  local odjIds = self:getValue("capturePetList")
  table.insert(odjIds, tostring(pokemon.objId))
  Lib.logDebug("putCaptureList pokemon.objId = ", pokemon.objId)
  self:setValue("capturePetList", odjIds)
end

function Player:gainPokemon(pokemon)
  if not pokemon then
    return
  end
  local packetPetList = self:getValue("packetPetList")
  if #packetPetList >= World.cfg.maxBoxPetsCnt then
    self:putCaptureList(pokemon)
    return
  end
  table.insert(packetPetList, tostring(pokemon.objId))
  self:setPacketPetList(packetPetList)
  pokemon:setMasterId(self.platformUserId)
  pokemon:setCaptured(false)
  local cfgID = pokemon:getCfgId()
  self:addPokemonBook(cfgID)
  local quality = pokemon:getQuality()
  if quality == Define.POKEMON_QUALITY.MYTHICAL and self:getGainFirstOrangePet() == 0 then
    self:setGainFirstOrangePet(1)
    self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.ORANGE_PET, cfgID, true)
  end
  self:pokemonNewDesign(pokemon, Define.newDesignEventKey.QUALITY_GAIN, "quality", 0, quality)
  self.newPokemonList = self.newPokemonList or {}
  table.insert(self.newPokemonList, pokemon)
  local starUpRedShowIndexList, wakeRedShowIndexList = self:getStarAndWakeRedPointList()
  if self.sendGainCancel then
    self.sendGainPokemonCancel()
  end
  self.sendGainPokemonCancel = World.Timer(0, function()
    if self.newPokemonList == nil then
      return
    end
    self:sendPacket({
      pid = "updatePokemonListDo",
      wakeRedShowIndexList = wakeRedShowIndexList,
      starUpShowIndexList = starUpRedShowIndexList
    })
    for _, newPokemon in pairs(self.newPokemonList) do
      newPokemon:setIsNewRedPointShow(true)
      newPokemon:setIsNewRedPointShow(true, true)
    end
    self.newPokemonList = nil
  end)
  return pokemon
end

function Player:addPokemonBook(cfgId)
  local bookRecord = self:getValue("bookRecord")
  if not bookRecord[tostring(cfgId)] then
    bookRecord[tostring(cfgId)] = os.time()
    self:setValue("bookRecord", bookRecord)
    self:updateAllPokemonFlag()
  end
end

function Player:isHaveCurCfgId(curCfgId)
  local bookRecord = self:getValue("bookRecord")
  for cfgId, time in pairs(bookRecord) do
    if tostring(cfgId) == tostring(curCfgId) then
      return true
    end
  end
  return false
end

function Player:randomPokemon(pokemonId, star)
  local pokemon = PokemonManager:createPokemon(pokemonId, nil, star or 0)
  self:gainPokemon(pokemon)
  return pokemon
end

function Player:checkMyPokemon(pokemon)
  for _, objId in pairs(self:getValue("battlePetList")) do
    if objId == pokemon:getObjId() then
      return true
    end
  end
  for _, objId in pairs(self:getValue("packetPetList")) do
    if objId == pokemon:getObjId() then
      return true
    end
  end
  return false
end

function Player:setPokemonFree(pokemon)
  local freeObjId = pokemon:getObjId()
  
  local function removeFromList(listKey, freeObjId)
    local list = self:getValue(listKey)
    for index, objId in pairs(list) do
      if tostring(objId) == tostring(freeObjId) then
        table.remove(list, index)
        self:setValue(listKey, list)
        return true
      end
    end
    return false
  end
  
  if removeFromList("battlePetList", freeObjId) or removeFromList("packetPetList", freeObjId) or removeFromList("capturePetList", freeObjId) then
    pokemon:onDestroy()
    return true
  end
  return false
end

function Player:getFirstBattlePokemon()
  local battleList = self:getBattlePokemon()
  for _, pokemon in pairs(battleList) do
    if pokemon:getCurHp() > 0 then
      return pokemon
    end
  end
  self:recoveryBattlePokemon()
  local pokemon = battleList[1]
  if pokemon then
    return pokemon
  end
end

function Player:recoveryBattlePokemon()
  local packet = self:getBattlePokemon()
  for _, pokemon in pairs(packet) do
    if pokemon then
      pokemon:recoveryAll()
    end
  end
end

function Player:cleanSkillAttributeBuff()
  for _, pet in pairs(self:getBattlePokemon()) do
    if pet:getCurHp() > 0 then
      pet:cleanSkillAttributeBuff()
    end
  end
end

function Player:getRestraintPokemonId(status)
  local id = -1
  local pokemon = self:getFirstBattlePokemon()
  if pokemon then
    local race = pokemon:getRace()
    if status == 0 then
      if race == 2 then
        id = 101002
      elseif race == 3 then
        id = 101003
      elseif race == 4 then
        id = 101001
      end
    elseif status == 1 then
      if race == 2 then
        id = 101003
      elseif race == 3 then
        id = 101001
      elseif race == 4 then
        id = 101002
      end
    end
  end
  return id
end

function Player:resetInNpc(value)
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      teamMate:setInNpc(value)
      self:setCanPK(1)
    end
  end
  self:setInNpc(value)
  self:setCanPK(1)
end

function Player:kickForceObstacle()
  if self.kickPos then
    self:setMapPos(self.map, self.kickPos)
    if self:isJoinTeam() and self:isTeamCaptain() then
      local teamMateId = self:getMyTeamMateId()
      local teamMate = World.CurWorld:getEntity(teamMateId)
      if teamMate and teamMate:isValid() then
        teamMate:setMapPos(self.map, self.kickPos)
      end
    end
    self.kickPos = nil
    self:setInNpc(0)
    self:setCanPK(1)
  end
end

function Player:initNpcChallenge(npcId, count)
  local challenge = self:getNpcChallenge(npcId)
  if challenge == nil then
    if count ~= 0 then
      challenge = count
    else
      challenge = 1
    end
    self:setNpcChallenge(npcId, challenge)
  end
  return challenge
end

function Player:initGymProgress(gym_id)
  local progress = self:getGymProgress(gym_id)
  if not progress then
    progress = 0
    self:setGymProgress(gym_id, progress)
  end
  return progress
end

function Player:checkTeamEnterBattle(npcId)
  Lib.logDebug("checkTeamEnterBattle npcId = ", npcId)
  local action_id = Define.NPC_ACTION_TYPE.ENTERBATTLE
  local reason_id = Define.DIALOG_REASON.NORMAL
  local npc_config = NPCConfig:getNPCById(npcId)
  local captain_challenge = self:initNpcChallenge(npcId, npc_config.free_challenge_per_day)
  local mate_challenge
  local teamMateId = self:getMyTeamMateId()
  local teamMate = World.CurWorld:getEntity(teamMateId)
  if teamMate and teamMate:isValid() then
    mate_challenge = teamMate:initNpcChallenge(npcId, npc_config.free_challenge_per_day)
  end
  if npc_config.gym_id ~= 0 then
    if captain_challenge <= 0 and mate_challenge <= 0 then
      action_id = Define.NPC_ACTION_TYPE.DONOTHING
      reason_id = Define.DIALOG_REASON.CHALLENGED
    elseif npc_config.team_id == 0 then
      Lib.logDebug("cannot challenge by team")
      action_id = Define.NPC_ACTION_TYPE.DONOTHING
      reason_id = Define.DIALOG_REASON.TEAM
    else
      local min_progress = self:initGymProgress(npc_config.gym_id)
      local mate_progress = teamMate:initGymProgress(npc_config.gym_id)
      if min_progress > mate_progress then
        min_progress = mate_progress
      end
      if min_progress >= npc_config.gym_progress then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
        reason_id = Define.DIALOG_REASON.WRONGPOSTORDER
      elseif min_progress < npc_config.gym_progress then
        if min_progress + 1 ~= npc_config.gym_progress then
          action_id = Define.NPC_ACTION_TYPE.DONOTHING
          reason_id = Define.DIALOG_REASON.WRONGPREORDER
        else
          action_id = Define.NPC_ACTION_TYPE.ENTERBATTLE
          reason_id = Define.DIALOG_REASON.TEAM
        end
      end
    end
  elseif captain_challenge <= 0 and mate_challenge <= 0 then
    action_id = Define.NPC_ACTION_TYPE.DONOTHING
    reason_id = Define.DIALOG_REASON.CHALLENGED
  elseif npc_config.team_id == 0 then
    action_id = Define.NPC_ACTION_TYPE.DONOTHING
    reason_id = Define.DIALOG_REASON.TEAM
  else
    action_id = Define.NPC_ACTION_TYPE.ENTERBATTLE
    reason_id = Define.DIALOG_REASON.TEAM
  end
  return action_id, reason_id
end

function Player:checkSingleEnterBattle(npcId)
  Lib.logDebug("checkSingleEnterBattle npcId = ", npcId)
  local action_id = Define.NPC_ACTION_TYPE.ENTERBATTLE
  local reason_id = Define.DIALOG_REASON.NORMAL
  local npc_config = NPCConfig:getNPCById(npcId)
  local challenge = self:initNpcChallenge(npcId, npc_config.free_challenge_per_day)
  if npc_config.gym_id ~= 0 then
    if challenge <= 0 then
      action_id = Define.NPC_ACTION_TYPE.DONOTHING
      reason_id = Define.DIALOG_REASON.CHALLENGED
    else
      local cur_progress = self:initGymProgress(npc_config.gym_id)
      if cur_progress >= npc_config.gym_progress then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
        reason_id = Define.DIALOG_REASON.WRONGPOSTORDER
      elseif cur_progress < npc_config.gym_progress and cur_progress + 1 ~= npc_config.gym_progress then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
        reason_id = Define.DIALOG_REASON.WRONGPREORDER
      end
      if npc_config.challenge_race ~= 0 and not self:isPokemonRaceMatch(npc_config.challenge_race) then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
        reason_id = Define.DIALOG_REASON.RACENOTMATCH
      end
      if npc_config.is_pvp == 1 and self:getFightPower() < npc_config.min_challenge_power then
        action_id = Define.NPC_ACTION_TYPE.DONOTHING
        reason_id = Define.DIALOG_REASON.LACKOFPOWER
      end
    end
  elseif challenge <= 0 then
    action_id = Define.NPC_ACTION_TYPE.DONOTHING
    reason_id = Define.DIALOG_REASON.CHALLENGED
  end
  return action_id, reason_id
end

function Player:checkEnterBattle(npcId)
  if self:isJoinTeam() then
    Lib.logDebug("checkTeamEnterBattle npcId = ", npcId)
    return self:checkTeamEnterBattle(npcId)
  else
    Lib.logDebug("checkSingleEnterBattle npcId = ", npcId)
    return self:checkSingleEnterBattle(npcId)
  end
end

function Player:canEnterBattle(npcId)
  local npc_config = NPCConfig:getNPCById(npcId)
  if not npc_config then
    Lib.logError("can not find npc_config, npcId =", npcId)
    return
  end
  local reason_id = Define.DIALOG_REASON.NORMAL
  local team_id = npc_config.team_id
  if team_id == 0 and self:isJoinTeam() and self:isTeamCaptain() then
    reason_id = Define.DIALOG_REASON.TEAM
  end
  self:sendPacket({
    pid = "canEnterBattle",
    npcId = npcId,
    reason_id = reason_id
  })
end

function Player:npcEnterBattle(npcId, objId)
  Lib.logDebug("player npcEnterBattle npcId = ", npcId)
  Lib.logDebug("player npcEnterBattle objId = ", objId)
  if not self:getFirstBattlePokemon() then
    Lib.logError("not getFirstBattlePokemon", self.name)
    return
  end
  if self:isInBattle() then
    return
  end
  local npc_config = NPCConfig:getNPCById(npcId)
  if not npc_config then
    Lib.logError("can not find npc_config, npcId =", npcId)
    return
  end
  if npc_config.gym_id ~= 0 and npc_config.is_pvp == 1 then
    self:npcEnterPVPBattle(npcId, objId, npc_config)
  else
    self:npcEnterPVEBattle(npcId, objId, npc_config)
  end
end

function Player:npcEnterPVPBattle(npcId, objId, npc_config)
  if npc_config.challenge_race ~= 0 and not self:isPokemonRaceMatch(npc_config.challenge_race) then
    return
  end
  self:setEnterBattle(true)
  local mapName = npc_config.map
  local battle_enemies = {}
  local destroy_enemies = {}
  local npc_cfgs = {}
  local gym_config = GymConfig:getGymById(npc_config.gym_id)
  local gym_type = gym_config.type
  local gym_index = npc_config.gym_index
  local rank = 8 - gym_index
  local rankType = self:getLangType()
  local rankIndex = self:getRankIndex()
  local playerUserId = self.platformUserId
  Rank.RequestRankData(rankType, gym_type, rankIndex, function()
    local player = Game.GetPlayerByUserId(playerUserId)
    if player and player:isValid() then
      local rankDatas = Rank.GetSpecificRankData(rankType, gym_type, rankIndex)
      if rankDatas and rankDatas[rank] then
        local rankData = rankDatas[rank]
        local userId = rankData.userId
        player:setGymChallengeRank(rank)
        player:setGymChallengeName(rankData.name)
        if rankData.isnpc == true then
          player:setGymChallengeId(0)
          player:npcEnterPVEBattle(npcId, objId, npc_config)
        else
          DBHandler:getDataByUserId(userId, 1, function(userId, txt)
            local seri = require("seri")
            local misc = require("misc")
            local data
            if txt and txt ~= "" then
              data = seri.deseristring_string(misc.base64_decode(txt))
            end
            local pvpBattlePetAttrs = data.values.pvpBattlePetAttrs or {}
            if pvpBattlePetAttrs[gym_type] and 0 < #pvpBattlePetAttrs[gym_type] then
              local npc_battle_pokemons = {}
              local npc_destroy_pokemons = {}
              for _, info in pairs(pvpBattlePetAttrs[gym_type]) do
                if PokemonConfig:getConfigById(info.cfgId) then
                  local pokemon = PokemonManager:initPokemon(info)
                  table.insert(npc_battle_pokemons, pokemon)
                  table.insert(npc_destroy_pokemons, pokemon)
                end
              end
              table.insert(battle_enemies, npc_battle_pokemons)
              table.insert(destroy_enemies, npc_destroy_pokemons)
              local npcEntity = World.CurWorld:getEntity(objId)
              local npcCfgName = npcEntity:cfg().fullName
              table.insert(npc_cfgs, npcCfgName)
              local pvpActorName = data.values.pvpActorNames[gym_type]
              local pvpSkin = data.values.pvpSkins[gym_type]
              local playerNum = 1
              local battleField = BattleFieldManager:create({
                map = mapName,
                playerNum = playerNum,
                enemy = battle_enemies,
                mode = Define.BATTLE_MODE.NPC,
                npcId = npcId,
                npcCfg = npc_cfgs,
                actorName = pvpActorName,
                npcName = rankData.name,
                skin = pvpSkin,
                hostCfg = {},
                endCallBack = function()
                  for _, pokemons in pairs(destroy_enemies) do
                    for _, pokemon in pairs(pokemons) do
                      if pokemon:getMasterId() == 0 then
                        pokemon:onDestroy()
                      end
                    end
                  end
                end
              })
              player:setGymChallengeId(userId)
              player:enterBattleField(battleField)
            else
              Lib.logInfo("get pvpBattlePetAttrs userId = ", userId)
              player:setGymChallengeId(userId)
              player:npcEnterPVEBattle(npcId, objId, npc_config)
            end
          end, function(userId)
            Lib.logInfo("get db data failed userId = ", userId)
            player:setGymChallengeId(userId)
            player:npcEnterPVEBattle(npcId, objId, npc_config)
          end)
        end
      else
        player:setGymChallengeId(0)
        player:npcEnterPVEBattle(npcId, objId, npc_config)
      end
    end
  end)
end

function Player:npcEnterPVEBattle(npcId, objId, npc_config)
  local mapName = npc_config.map
  local battle_enemies = {}
  local destroy_enemies = {}
  local npc_cfgs = {}
  local npc_battle_pokemons, npc_destroy_pokemons = self:getNpcPokemons(npc_config)
  table.insert(battle_enemies, npc_battle_pokemons)
  table.insert(destroy_enemies, npc_destroy_pokemons)
  local npcEntity = World.CurWorld:getEntity(objId)
  local npcCfgName = npcEntity:cfg().fullName
  Lib.logDebug("npcCfgName = ", npcCfgName)
  table.insert(npc_cfgs, npcCfgName)
  local mate_infos = {}
  local team_id = npc_config.team_id
  if team_id ~= 0 then
    local mate = NPCConfig:getMate(npcId, team_id)
    if mate ~= nil then
      local mate_npc_info = {}
      mate_npc_info.npc_id = mate.id
      mate_npc_info.npc_cfg = mate.cfg
      table.insert(mate_infos, mate_npc_info)
    end
  end
  if 0 < #mate_infos then
    local mate_id = mate_infos[1].npc_id
    local mate_cfg = mate_infos[1].npc_cfg
    local mate_config = NPCConfig:getNPCById(mate_id)
    if mate_config then
      local mateCfgName = "myplugin/" .. mate_infos[1].npc_cfg
      table.insert(npc_cfgs, mateCfgName)
      local mate_battle_pokemons, mate_destroy_pokemons = self:getNpcPokemons(mate_config)
      table.insert(battle_enemies, mate_battle_pokemons)
      table.insert(destroy_enemies, mate_destroy_pokemons)
    end
  end
  local playerNum = self:getMyTeamMateId() and 2 or 1
  local host_battle_pokemons = {}
  local host_destroy_pokemons = {}
  if npc_config.host_pokemon_list and 0 < #npc_config.host_pokemon_list then
    host_battle_pokemons, host_destroy_pokemons = self:getHostPokemons(npc_config.host_pokemon_list)
  end
  local battleField = BattleFieldManager:create({
    map = mapName,
    playerNum = playerNum,
    enemy = battle_enemies,
    mode = Define.BATTLE_MODE.NPC,
    npcId = npcId,
    npcCfg = npc_cfgs,
    actorName = nil,
    skin = nil,
    hostCfg = World.cfg.enableNpcHost and {
      cfgName = "myplugin/" .. npc_config.host_cfg,
      pokemonList = host_battle_pokemons
    } or {},
    endCallBack = function()
      for _, pokemons in pairs(destroy_enemies) do
        for _, pokemon in pairs(pokemons) do
          if pokemon:getMasterId() == 0 then
            pokemon:onDestroy()
          end
        end
      end
      for _, pokemon in pairs(host_destroy_pokemons) do
        if pokemon:getMasterId() == 0 then
          pokemon:onDestroy()
        end
      end
    end
  })
  if self:isTeamCaptain() then
    TeamMgr:enterBattleField(self, battleField)
  else
    self:enterBattleField(battleField)
  end
end

function Player:GetPVEGymPokemons(npcId)
  local npc_config = NPCConfig:getNPCById(npcId)
  local pokemon_infos = {}
  local npc_battle_pokemons = self:getNpcPokemons(npc_config)
  local power = 0
  for _, pokemon in pairs(npc_battle_pokemons) do
    power = power + pokemon:getFightPower()
    local info = {
      cfgId = pokemon.attr.cfgId,
      npcCfgId = pokemon:getValue("npcCfgId"),
      level = pokemon.attr.level,
      star = pokemon.attr.star
    }
    table.insert(pokemon_infos, info)
  end
  local packet = {
    pid = "GetPVPGymPokemons",
    isnpc = true,
    npcId = npcId,
    power = power,
    pokemons = pokemon_infos
  }
  Lib.logDebug("GetPVPGymPokemons packet = ", Lib.v2s(packet))
  self:sendPacket(packet)
  for _, pokemon in pairs(npc_battle_pokemons) do
    pokemon:onDestroy()
  end
end

function Player:getHostPokemons(pokemon_list)
  local host_battle_pokemons = {}
  local host_destroy_pokemons = {}
  for i = 1, #pokemon_list do
    local id = pokemon_list[i]
    local pokemon
    local strength = -1
    pokemon = PokemonManager:createNPCPokemon(id, -1, self:getPlayerLevel())
    if pokemon then
      table.insert(host_battle_pokemons, pokemon)
      table.insert(host_destroy_pokemons, pokemon)
    end
  end
  return host_battle_pokemons, host_destroy_pokemons
end

function Player:getNpcPokemons(npc_config)
  local npc_battle_pokemons = {}
  local npc_destroy_pokemons = {}
  Lib.logDebug("not gym pvp npc get config data")
  for i = 1, #npc_config.pokemon_list do
    local id = npc_config.pokemon_list[i]
    Lib.logDebug("npcEnterBattle id = ", id)
    local pokemon
    local strength = -1
    if id == 0 or id == 1 then
      id = self:getRestraintPokemonId(id)
      Lib.logDebug("getRestraintPokemonId = ", id)
      if id ~= -1 then
        pokemon = PokemonManager:createNPCPokemon(id, strength, self:getPlayerLevel())
      end
    else
      strength = 0 < #npc_config.dynamic_strength and npc_config.dynamic_strength[i] or -1
      pokemon = PokemonManager:createNPCPokemon(id, strength, self:getPlayerLevel())
    end
    if pokemon then
      table.insert(npc_battle_pokemons, pokemon)
      table.insert(npc_destroy_pokemons, pokemon)
    end
  end
  return npc_battle_pokemons, npc_destroy_pokemons
end

function Player:getPacketPokemon()
  local packetPetList = self:getValue("packetPetList")
  return PokemonManager:getPokemonList(packetPetList)
end

function Player:getBattlePokemon()
  if not self or not self:isValid() then
    return
  end
  local battlePetList = self:getValue("battlePetList")
  return PokemonManager:getPokemonList(battlePetList)
end

function Player:getCapturePokemon()
  local capturePetList = self:getValue("capturePetList")
  return PokemonManager:getPokemonList(capturePetList)
end

function Player:getPokemon(objId)
  return PokemonManager:getPokemon(objId)
end

function Player:getSelfPokemon(objId)
  return PokemonManager:getPokemon(objId, self.platformUserId)
end

function Player:setBattleList(newBattleList)
  if #newBattleList > World.cfg.maxHandPetsCnt then
    return false
  end
  newBattleList = checkTableSame(newBattleList)
  local oldPacketList = self:getValue("packetPetList")
  local oldBattleList = self:getValue("battlePetList")
  local allPokemonList = {}
  for _, objId in pairs(oldPacketList) do
    table.insert(allPokemonList, tostring(objId))
  end
  local showPet = false
  for _, objId in pairs(newBattleList) do
    if objId == tostring(self:getCurFollowPetId()) then
      showPet = true
      break
    end
  end
  for _, objId in pairs(oldBattleList) do
    table.insert(allPokemonList, tostring(objId))
  end
  for _, objId in pairs(newBattleList) do
    local pokemon = self:getPokemon(objId)
    if pokemon:getLevel() > self:getPlayerLevel() or not Lib.tableContain(allPokemonList, tostring(objId)) then
      return false
    end
  end
  local newPacketList = {}
  for _, objId in pairs(allPokemonList) do
    if not Lib.tableContain(newBattleList, tostring(objId)) then
      table.insert(newPacketList, objId)
    end
  end
  self:setValue("battlePetList", newBattleList)
  self:setPacketPetList(newPacketList)
  self:updateAllPokemonPower()
  return true
end

function Player:grantAdReward(type, params)
  if type == Define.AdvertisingType.Battle and self.combatRewardCache then
    local exp = self.combatRewardCache.exp or 0
    local coin = self.combatRewardCache.coin or 0
    self:addPlayerExp(exp)
    self:deltaCurrency("gold_coin", coin, Define.AdvertisingAdsId.Battle)
    self.combatRewardCache = nil
  end
end

function Player:calcBattleReward(battleField)
  local exp, coin, reward, pokemons
  local petExpList = {}
  local pokemonList = {}
  local p_exp_cnt = 0
  if battleField:getBattleMode() == Define.BATTLE_MODE.PVP or not battleField:isWin(self) then
    return 0, 0, {}, {}, {}
  end
  local npcId = battleField:getNPCId()
  if npcId then
    local count = self:getNpcChallenge(npcId)
    if count and count <= 0 then
      return 0, 0, {}, {}, {}
    end
  end
  exp, coin, reward, pokemons = MainBattleRewardConfig:getRewardById(battleField:getNPCId() or 0)
  for _, pokemon in pairs(pokemons) do
    Lib.logDebug("calcBattleReward pokemon = ", Lib.v2s(pokemon))
    local pokemon_id = tonumber(pokemon[1])
    local pokemon_count = tonumber(pokemon[2])
    for i = 1, pokemon_count do
      Lib.logDebug("reward pokemon_id = ", pokemon_id)
      local pokemon = PokemonManager:createPokemon(pokemon_id)
      Lib.logDebug("reward pokemon = ", Lib.v2s(pokemon))
      self:putCaptureList(pokemon)
    end
  end
  for _, pokemon in pairs(battleField:getEnemyPokemonList()) do
    if not pokemon.runaway then
      local pkm_exp, pkm_coin, pkm_reward = NormalBattleRewardConfig:getRewardById(pokemon:getCfgId())
      coin = coin + pkm_coin * pokemon:getLevel()
      p_exp_cnt = p_exp_cnt + pkm_exp * pokemon:getLevel()
      for _, item in pairs(pkm_reward) do
        table.insert(reward, item)
      end
    end
  end
  local subscribe_vipSetting = World.cfg.subscribe_vipSetting
  if self:getSubscribeGameState() then
    coin = math.floor(coin * (100 + subscribe_vipSetting.coinAddition) / 100)
    p_exp_cnt = math.floor(p_exp_cnt * (100 + subscribe_vipSetting.petExpAddition) / 100)
  end
  self.combatRewardCache = {exp = exp, coin = coin}
  self:addPlayerExp(exp)
  self:deltaCurrency("gold_coin", coin, "battle_reward")
  local updatePower = false
  for _, pet in pairs(self:getBattlePokemon()) do
    if 0 < pet:getCurHp() then
      local _exp = pet:isFought() and p_exp_cnt or math.floor(p_exp_cnt / 2 + 0.5)
      local extraExp = pet:addExp(_exp, self)
      table.insert(petExpList, {
        objId = pet:getObjId(),
        exp = _exp - extraExp
      })
      updatePower = true
    else
      table.insert(petExpList, {
        objId = pet:getObjId(),
        exp = 0
      })
    end
  end
  if updatePower then
    self:updateAllPokemonPower()
  end
  for i = #reward, 1, -1 do
    local rand = math.random()
    local item = reward[i]
    if rand < tonumber(item[3]) then
      print("get item :", item[1], " cnt:", item[2])
      self:obtainItemsByFullName(item[1], tonumber(item[2]), "battle_reward")
    else
      table.remove(reward, i)
    end
  end
  return exp, coin, reward, petExpList, pokemons
end

function Player:enterBattleResult(battleField)
  self.isInBattleResult = true
  local isMult = battleField:is2V2Mode()
  local exp, coin, reward, petExpList, pokemonList = self:calcBattleReward(battleField)
  local battleResult
  if battleField.isMaxRound then
    battleResult = battleField:isMaxRoundWin(self) or false
  else
    battleResult = battleField:isWin(self) or false
  end
  self:setBattleResult(battleResult)
  local npcId = battleField:getNPCId()
  Lib.logDebug("enterBattleResult npcId = ", npcId)
  if npcId then
    self:updateTaskStatus(Define.TASK_TYPE.NPC_BATTLE, 0, npcId, 1)
    local npc_config = NPCConfig:getNPCById(npcId)
    local gym_id = npc_config.gym_id
    local gym_progress = npc_config.gym_progress
    local is_pvp = npc_config.is_pvp
    local is_gym_boss = npc_config.is_gym_boss
    local gym_index = npc_config.gym_index
    if battleResult == true then
      if gym_id ~= 0 and gym_progress ~= 0 and is_pvp == 1 then
        local gym_config = GymConfig:getGymById(gym_id)
        if gym_config then
          local gym_type = gym_config.type
          local rankType = self:getLangType()
          local rankIndex = self:getRankIndex()
          local userId = self.platformUserId
          Rank.UserUpdateGym(rankType, gym_type, rankIndex, self:getGymChallengeId(), userId, 8 - gym_index, self:getFightPower(), function(isSucceed)
            local player = Game.GetPlayerByUserId(userId)
            if player and player:isValid() then
              if isSucceed then
                Lib.logInfo("UserUpdateGym isSucceed")
                player:updateTaskStatus(Define.TASK_TYPE.PVP_GYM, 1, npcId, 1)
                local count = player:getNpcChallenge(npcId)
                if count and 0 < count then
                  player:setNpcChallenge(npcId, count - 1)
                end
                local cur_gym_progress = player:getGymProgress(gym_id)
                if cur_gym_progress then
                  if cur_gym_progress < gym_progress then
                    player:setGymProgress(gym_id, gym_progress)
                  end
                else
                  player:setGymProgress(gym_id, gym_progress)
                end
                if is_gym_boss == 1 then
                  player:setGymFinish(gym_id, 1)
                end
                player:setPVPRank(gym_id, 8 - gym_index)
                local gloryId = GloryConfig:getGloryIdByGymIdAndGymProgress(gym_id, gym_progress)
                if gloryId then
                  player:catchGlory(gloryId)
                end
                player:savePVPGymBattle(gym_type, gym_index, gym_progress)
                player:changePVPEntities()
                player:broadcastPVPGYMMessage(userId, rankType, rankIndex, gym_id, gym_type, gym_index)
              else
                Lib.logDebug("UserUpdateGym failed")
                player:updatePVPGymStatus(gym_id)
              end
            end
          end)
        end
      else
        local count = self:getNpcChallenge(npcId)
        if count and 0 < count then
          self:setNpcChallenge(npcId, count - 1)
        end
        if gym_id ~= 0 and gym_progress ~= 0 then
          local cur_gym_progress = self:getGymProgress(gym_id)
          if cur_gym_progress then
            if gym_progress > cur_gym_progress then
              self:setGymProgress(gym_id, gym_progress)
            end
          else
            self:setGymProgress(gym_id, gym_progress)
          end
          if is_gym_boss == 1 then
            self:setGymFinish(gym_id, 1)
          end
          Lib.logDebug("getGloryIdByGymIdAndGymProgress gym_id and gym_progress  = ", gym_id, gym_progress)
          local gloryId = GloryConfig:getGloryIdByGymIdAndGymProgress(gym_id, gym_progress)
          Lib.logDebug("gloryId = ", gloryId)
          if gloryId then
            self:catchGlory(gloryId)
          end
        end
      end
      self:updateTaskStatus(Define.TASK_TYPE.NPC_BATTLE, 1, npcId, 1)
      local mapId = MapConfig:getMapIdByNpc(npcId)
      if mapId ~= 0 then
        self:setMapUnlock(mapId, 1)
      end
      if not self:isGuideFinish() then
        local cur_guide_index = self:getCurGuideIndex()
        if cur_guide_index == Define.GUIDE_INDEX.GOTO_FIRST_NPC or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_1_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_2_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_3_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_4_BOSS or cur_guide_index == Define.GUIDE_INDEX.GOTO_GYM_5_BOSS then
          local cur_guide_data = PokemonGuideConfig:getGuideData(cur_guide_index)
          local next_guide_data = PokemonGuideConfig:getGuideData(cur_guide_data.next_guide_index)
          if next_guide_data and tostring(next_guide_data.npc_id) == tostring(npcId) then
            self:getGuideReward(next_guide_data)
          end
        end
      end
      self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.NPC_FINISH, npcId)
      Lib.reportResultNpc(self, npcId, isMult)
      if npcId == 20301 or npcId == 20307 then
        Lib.reportSuccessPetNumber(self, npcId)
      end
    else
      self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.NPC_FAIL, npcId)
      if gym_id ~= 0 and is_pvp == 1 then
        self:updateTaskStatus(Define.TASK_TYPE.PVP_GYM, 0, npcId, 1)
        self:updatePVPGymStatus(gym_id)
      end
    end
    Lib.reportUseItemNpc(self, npcId, isMult)
  elseif battleField:getBattleMode() == Define.BATTLE_MODE.PVP then
    self:updateTaskStatus(Define.TASK_TYPE.PVP_BATTLE, 0, 0, 1)
    Lib.reportUseItem1V1(self, isMult)
    if self.isChallenger then
      Lib.reportChanllgePK(self, isMult)
      if battleResult then
        Lib.reportChanllgerWin(self, isMult)
        self:updateTaskStatus(Define.TASK_TYPE.PVP_BATTLE, 1, 0, 1)
      end
    end
  else
    Lib.reportResultMonster(self, battleField:getBattleFieldLevel(), battleResult, isMult)
  end
  self:playResultBGM(battleResult)
  self:sendPacket({
    pid = "BattleResult",
    result = battleResult,
    mode = battleField:getBattleMode() or Define.BATTLE_MODE.PVE,
    reward = reward,
    coin = coin,
    exp = exp,
    petExpList = petExpList,
    pokemonList = pokemonList
  })
  Lib.logDebug("sendPacket BattleResult", battleResult)
end

function Player:broadcastPVPGYMMessage(userId, rankType, rankIndex, gym_id, gym_type, gym_index)
  local content = {
    key = "GYMPVP",
    rankType = rankType,
    rankIndex = rankIndex,
    gym_id = gym_id,
    gym_type = gym_type,
    rank = 8 - gym_index,
    playerId = userId,
    name = self.name,
    challengeId = self:getGymChallengeId(),
    challengeName = self:getGymChallengeName()
  }
  AsyncProcess.SendBroadcastMessageMsgSend(nil, content, Define.BROADCAST_SEND_MSG, "game")
end

function Player:updateTaskStatus(type, condition, targetId, count)
  if self:getPlayerLevel() < 20 then
    return
  end
  local targetid = ""
  if type == Define.TASK_TYPE.ITEM_USE then
    targetid = Lib.split(targetId, "/")[2]
  else
    targetid = targetId
  end
  local task_status_list = self:getDailyTaskStatusList()
  for _, task_status in pairs(task_status_list) do
    local task_id = task_status.id
    if task_status.type == type and condition >= task_status.condition and task_status.finished == 0 then
      for _, target in pairs(task_status.targets) do
        if tostring(target[1]) == "0" or tostring(target[1]) == tostring(targetid) then
          target[2] = target[2] + count
          self:checkTaskIsFinished(task_id, task_status)
        end
      end
    end
  end
end

function Player:checkTaskIsFinished(task_id, task_status)
  local isFinished = 1
  local task_data = PokemonTaskConfig:getTaskById(task_id)
  for _, source_target in pairs(task_status.targets) do
    for _, dest_target in pairs(task_data.targets) do
      if tostring(source_target[1]) == tostring(dest_target[1]) then
        if tonumber(source_target[2]) < tonumber(dest_target[2]) then
          isFinished = 0
          break
        else
          source_target[3] = 1
        end
      end
    end
  end
  if isFinished == 1 then
    task_status.finished = isFinished
  end
  self:setDailyTaskStatus(task_id, task_status)
end

function Player:setTaskIsRewarded(task_id)
  local task_status = self:getDailyTaskStatus(task_id)
  Lib.logDebug("setTaskIsRewarded before task_status = ", Lib.v2s(task_status))
  if task_status then
    task_status.rewarded = 1
    Lib.logDebug("setTaskIsRewarded after task_status = ", Lib.v2s(task_status))
    self:setDailyTaskStatus(task_id, task_status)
  end
end

function Player:sendStartPlayPreAnimation(meetType, rareID)
  local packet = {
    pid = "startPlayPreBattleAnimation",
    meetType = meetType,
    rareID = rareID
  }
  self:sendPacket(packet)
end

function Player:sendPkmSkillBuffTipWnd(effectTemp)
  local packet = {
    pid = "showPkmSkillBuffTipWnd",
    showId = effectTemp.showId,
    txtTitle = effectTemp.txtTitle,
    txtContent = effectTemp.txtContent,
    pkmObjID = effectTemp.pkmObjID,
    playerObjID = effectTemp.playerObjID
  }
  self:sendPacket(packet)
end

function Player:pokemonStudySkill(objId, skillId, pos)
  local pokemon = self:getSelfPokemon(objId)
  if pokemon and skillId then
    pokemon:studySkill(skillId, pos)
    self:updateAllPokemonPower()
  end
end

function Player:pokemonGiveUpSkill(objId, skillId)
  local pokemon = self:getSelfPokemon(objId)
  if pokemon and skillId then
    pokemon:removeStudySkill(skillId)
  end
end

function Player:pokemonRelease(objIds)
  local pokemon_list = PokemonManager:getPokemonList(objIds)
  local gain = 0
  local success = true
  for _, pokemon in pairs(pokemon_list) do
    if not self:setPokemonFree(pokemon) then
      success = false
    else
      gain = gain + pokemon:getCfg().price
      local starUpRedShowIndexList, wakeRedShowIndexList = self:getStarAndWakeRedPointList()
      self:sendPacket({
        pid = "updatePokemonListDo",
        wakeRedShowIndexList = wakeRedShowIndexList,
        starUpShowIndexList = starUpRedShowIndexList,
        checkFalse = true
      })
    end
  end
  return success, gain
end

function Player:sendSpecialWorldCommonTips(tipsInfo)
  local WorldCommonTipsConfig = T(Config, "WorldCommonTipsConfig")
  local tipConfigs = WorldCommonTipsConfig:getConfigByTipTypeAndLimit(tipsInfo)
  if tipConfigs then
    for i, id in pairs(tipConfigs) do
      local tipConfig = WorldCommonTipsConfig:getConfigById(id)
      if tipConfig then
        for key, val in pairs(tipConfig.show_type) do
          if tonumber(val) == 1 then
            tipsInfo.id = tipConfig.id
            self:sendTopWorldCommonTips("", tipsInfo)
          elseif tonumber(val) == 2 then
            tipsInfo.id = tipConfig.id
            self:sendChatWorldCommonTips("", tipsInfo)
          end
        end
      end
    end
  end
end

function Player:sendTopWorldCommonTips(normalMsg, tipsInfo)
  local packet = {
    pid = "radioTopWorldCommonTips",
    normalMsg = normalMsg,
    tipsInfo = tipsInfo
  }
  WorldServer.BroadcastPacket(packet)
end

function Player:sendChatWorldCommonTips(normalMsg, tipsInfo)
  local packet = {
    pid = "radioChatWorldCommonTips",
    normalMsg = normalMsg,
    tipsInfo = tipsInfo
  }
  WorldServer.BroadcastPacket(packet)
end

function Player:getGoldByExchanging(grade)
  local amount = World.cfg.goldCoinExchangeContent[grade]
  if not amount then
    return
  end
  if not World.cfg.useFDiamonds then
    local uniqueId = 77700 + grade
    self:doConsumeDiamonds("gDiamonds", amount.cube, function(ret)
      if ret then
        self:addCurrency("gold_coin", amount.gold, "exchanging")
        local costParts = {
          unit_price = amount.cube,
          total_price = amount.cube,
          counts = 1,
          change_key = "diamond_exchange_gold_" .. amount.cube
        }
        self:diamondCostNewDesign(Define.newDesignEventKey.GOLD_EXCHANGE_COST, costParts)
        self:bhvLog("diamond_exchange_gold", string.format("diamond exchange gold_coin:diamond:%s,gold:%s", amount.cube, amount.gold))
        return true
      else
      end
    end, uniqueId)
  else
    local checkMoney = self:payCurrency(Coin:coinNameByCoinId(4), amount.cube, false, false, "exchanging")
    if checkMoney then
      self:addCurrency("gold_coin", amount.gold, "exchanging")
    end
  end
end

function Player:getDailyFDiamondsReward()
  local day = self:getActiveDay()
  if World.cfg.dailyFDiamondsReward[day] and self:getValue("dailyFDiamond") then
    self:setValue("dailyFDiamond", false)
    self:addCurrency("fDiamonds", World.cfg.dailyFDiamondsReward[day], "daily_reward")
  end
end

function Player:setAvoidBattle(isAvoid)
  self.avoidBattle = isAvoid
end

function Player:setUIAvoidBattle(isAvoid)
  self.UIavoidBattle = isAvoid
end

function Player:isUIAvoidBattle()
  return self.UIavoidBattle or false
end

function Player:isAvoidBattle()
  return self.avoidBattle or false
end

function Player:setAvoidPVPBattle()
  self.avoidPVPBattle = os.time()
end

function Player:isAvoidPVPBattle()
  if self.avoidPVPBattle then
    return os.time() - self.avoidPVPBattle < World.cfg.avoidPVPBattleTime / 20
  else
    return false
  end
end

function Player:pushShowLoginGiftWnd()
  self:sendPacket({
    pid = "ClientAutoShowGiftWnd",
    showType = "login"
  })
end

function Player:cacheBattleItemUse(cureType)
  if not self.useItemCache then
    self.useItemCache = {}
  end
  if cureType and 0 < #cureType then
    for _, type in pairs(cureType) do
      if type then
        self.useItemCache[type] = true
      end
    end
  end
end

function Player:cacheAction(actionType)
  if not self.actionCache then
    self.actionCache = {}
  end
  if actionType then
    self.actionCache[actionType] = true
  end
end

function Player:isCanPkCurTarget(targetID)
  local target = World.CurWorld:getObject(targetID)
  if target:isAvoidPVPBattle() then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget target:isAvoidPVPBattle")
    return false
  end
  if self:isAvoidPVPBattle() then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget self:isAvoidPVPBattle")
    return false
  end
  if self:getValue("battlePreType") ~= 0 then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  self:getValue battlePreType", self:getValue("battlePreType"))
    return false
  end
  if target:getValue("battlePreType") ~= 0 then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  target:getValue battlePreType", target:getValue("battlePreType"))
    return false
  end
  if target:isInBattle() then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  target:isInBattle")
    return false
  end
  if self:isInBattle() then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  self:isInBattle")
    return false
  end
  if not target:isJoinTeam() and not self:isJoinTeam() then
    return true
  end
  if target:isJoinTeam() and self:isJoinTeam() then
    Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  target:isJoinTeam() and self:isJoinTeam()")
    if target:isTeamCaptain() and self:isTeamCaptain() then
      return true
    else
      Lib.logDebug("gui_tip_can_not_invitate isCanPkCurTarget  target:isTeamCaptain() and self:isTeamCaptain()", target:isTeamCaptain(), self:isTeamCaptain())
      return false
    end
  end
  Lib.logDebug(" gui_tip_can_not_invitate isCanPkCurTarget")
  return false
end

function Player:isCanTeamCurTarget(targetID)
  local target = World.CurWorld:getObject(targetID)
  if self:getValue("battlePreType") ~= 0 then
    return false
  end
  if target:getValue("battlePreType") ~= 0 then
    return false
  end
  if target:isInBattle() then
    return false
  end
  if self:isInBattle() then
    return false
  end
  if self:isJoinTeam() then
    return false
  end
  if target:isJoinTeam() then
    return false
  end
  if target:getInNpc() ~= 0 then
    self:sendPacket({
      pid = "showCommonTips",
      message = "gui_tip_can_not_invitate",
      time = 40
    })
    return false
  end
  if self:getInNpc() ~= 0 then
    return false
  end
  return true
end

function Player:createFollowPetEntity(fullName, pokemonId)
  local pos = self:getFrontPos(-1, true, false)
  local map = self.map
  local cfgName = "myplugin/pet_follow_base"
  local entity = EntityServer.Create({
    cfgName = cfgName,
    map = map,
    pos = pos,
    ry = self:getRotationYaw()
  })
  entity:startAI()
  if entity:cfg() and entity:cfg().wakeEffect then
    local tbWakeEffect = entity:cfg().wakeEffect
    local pokemon = PokemonManager:getPokemon(pokemonId)
    local nAwake = pokemon and pokemon:getWake() or 0
    if tbWakeEffect[nAwake] then
      entity:addBuff(tbWakeEffect[nAwake])
    end
  end
  local aiControl = entity:getAIControl()
  aiControl:setFollowTarget(self)
  local cfg = setting:fetch("entity", fullName)
  if cfg then
    if cfg.actorName then
      entity:changeActor(cfg.actorName, true)
    end
    if cfg.skin then
      entity:changeSkin(cfg.skin)
    end
  end
  self.followPetObjID = entity.objID
end

function Player:removeFollowPetEntity(reset, followPetId)
  if reset then
    self:setCurFollowPetId(0)
    self:removeFollowPokemon(followPetId)
  end
  if not self.followPetObjID then
    self.followPetObjID = 0
    return
  end
  local entity = World.CurWorld:getEntity(self.followPetObjID)
  if entity then
    local aiControl = entity:getAIControl()
    aiControl:setFollowTarget(nil)
    entity:destroy()
  end
  self.followPetObjID = 0
end

function Player:getFollowPetEntity()
  return World.CurWorld:getEntity(self.followPetObjID)
end

function Player:removeFollowPokemon(followPetId)
  for _, pokemon in pairs(self:getBattlePokemon()) do
    if pokemon:getObjId() == followPetId then
      pokemon:setFollowPet(false)
      return
    end
  end
  for _, pokemon in pairs(self:getPacketPokemon()) do
    if pokemon:getObjId() == followPetId then
      pokemon:setFollowPet(false)
      return
    end
  end
end

function Player:setFollowPokemon(objId)
  for _, pokemon in pairs(self:getBattlePokemon()) do
    if pokemon:getObjId() == objId then
      pokemon:setFollowPet(true)
      return
    end
  end
  for _, pokemon in pairs(self:getPacketPokemon()) do
    if pokemon:getObjId() == objId then
      pokemon:setFollowPet(true)
      return
    end
  end
end

function Player:getFollowPokemon()
  for _, pokemon in pairs(self:getBattlePokemon()) do
    if pokemon:isFollowPet() then
      return pokemon
    end
  end
  for _, pokemon in pairs(self:getPacketPokemon()) do
    if pokemon:isFollowPet() then
      return pokemon
    end
  end
  return nil
end

function Player:getMapUnlockByPos()
  local playerPosition = self:getPosition()
  Lib.logDebug("getMapUnlockByPos playerPosition = ", playerPosition)
  local mapIndex = Lib.getCurMapIndex(playerPosition)
  Lib.logDebug("getMapUnlockByPos mapIndex = ", mapIndex)
  local status = self:getMapUnlock(mapIndex)
  Lib.logDebug("getMapUnlockByPos status = ", status)
  return status
end

function Player:telegraphToMap(mapId)
  if not self or not self:isValid() then
    return
  end
  local map_config = MapConfig:getMapById(mapId)
  self:setMapPos(World.cfg.defaultMap, Lib.v3(map_config.born[1], map_config.born[2], map_config.born[3]))
  self:sendPacket({
    pid = "finishTelegraph",
    mapId = mapId
  })
  if self:isJoinTeam() and self:isTeamCaptain() then
    local teamMateId = self:getMyTeamMateId()
    local teamMate = World.CurWorld:getEntity(teamMateId)
    if teamMate and teamMate:isValid() then
      local status = teamMate:getMapUnlock(mapId)
      if status == 0 then
        Lib.logDebug("showMapUnlockTip mapId = ", mapId)
        teamMate:sendPacket({
          pid = "showMapUnlockTip",
          mapId = mapId
        })
      end
    end
  end
end

function Player:closeResult()
  self:sendPacket({
    pid = "CloseResult"
  })
end

function Player:doConsumeDiamonds(coinName, price, callBack, uniqueId)
  self:consumeDiamonds(coinName, price, function(ret)
    if not self or not self:isValid() then
      callBack(false)
      return
    end
    callBack(ret)
    if ret then
      Lib.emitEvent(Event.EVENT_CONSUME_DIAMONDS, {
        objID = self.objID,
        coinName = coinName,
        count = price
      })
    end
  end, uniqueId)
end

local payCurrency = Player.payCurrency

function Player:payCurrency(coinName, count, clear, check, reason, related)
  local ret = payCurrency(self, coinName, count, clear, check, reason, related)
  if ret and coinName == "fDiamonds" then
    Lib.emitEvent(Event.EVENT_CONSUME_DIAMONDS, {
      objID = self.objID,
      coinName = "gDiamonds",
      count = count
    })
  end
  return ret
end

function Player:setFollowPetTargetWhenLeaveBattle()
  local followPet = self:getFollowPetEntity()
  if followPet then
    local aiControl = followPet:getAIControl()
    aiControl:setFollowTarget(self)
  end
end

function Player:getGuideReward(guide_data)
  if guide_data then
    if self:isGainGuideAward(guide_data.id) then
      return
    end
    local reward_exp = guide_data.reward_exp
    if reward_exp ~= 0 then
      self:setPlayerExLevel(self:getPlayerLevel())
      Lib.logDebug("getGuideReward reward_exp = ", reward_exp)
      self:addPlayerExp(reward_exp)
    end
    local reward_items = guide_data.reward_items
    for i = 1, #reward_items do
      local reward_item = reward_items[i]
      local item_name = "myplugin/" .. reward_item[1]
      local item_count = reward_item[2]
      for j = 1, item_count do
        self:obtainItemsByFullName(item_name, 1, "getguidereward")
      end
    end
    self:obtainGuideAward(guide_data.id)
  end
end

function Player:gotoNextGuide()
  if not self:isGuideFinish() then
    local cur_guide_index = self:getCurGuideIndex()
    local guide_data = PokemonGuideConfig:getGuideData(self:getCurGuideIndex())
    local next_guide_index = guide_data.next_guide_index
    if next_guide_index ~= -1 then
      if next_guide_index == Define.GUIDE_INDEX.GOTO_FIRST_NPC then
        Lib.logDebug("setNpcChallenge 10109 10110 10111")
        self:setNpcChallenge(10109, 0)
        self:setNpcChallenge(10110, 0)
        self:setNpcChallenge(10111, 0)
      end
      self:setCurGuideIndex(next_guide_index)
      self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.TASK_FINISH, cur_guide_index)
      self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.TASK_IN, next_guide_index)
    else
      self:setGuideFinish(true)
      local packet = {
        pid = "HideBlockInputEvents"
      }
      self:sendPacket(packet)
    end
  end
end

function Player:checkAllPVPGymStatus()
  local unlockLevel = PlayerExpConfig:getLvByUnlockMod(Define.MODULE_TYPE.MAIN_LEADERBOARD)
  if unlockLevel <= self:getPlayerLevel() then
    local rankType = self:getLangType()
    local rankIndex = self:getRankIndex()
    local userId = self.platformUserId
    local configs = GymConfig:getPVPGyms()
    for _, gym_config in pairs(configs) do
      local gym_id = gym_config.id
      local gym_type = gym_config.type
      local rank = self:getPVPRank(gym_id)
      Lib.logInfo("checkAllPVPGymStatus gym_id and rank = ", gym_id, rank)
      if rank == nil or rank ~= nil and 0 < rank then
        Lib.logInfo("get pvp gym data gym_id = ", gym_id)
        Rank.GetSubRankData(rankType, gym_config.type, rankIndex, function(rankDatas)
          local player = Game.GetPlayerByUserId(userId)
          if player and player:isValid() then
            player:updateGloryStatus(gym_id, rankDatas)
            Lib.logInfo("checkAllPVPGymStatus set gym_id status = ", gym_id)
            player:updateGymChallengeStatus(gym_id, rankDatas)
          end
        end)
      end
    end
  end
end

function Player:checkPVPGymStatus(gym_id, challengeId, rank, playerName)
  Lib.logInfo("checkPVPGymStatus gym_id, challengeId, rank, playerName = ", challengeId, rank, playerName)
  local npcId = self:isInNpcBattle()
  local inBattle = self:isInBattle()
  if inBattle and npcId then
    local npc_config = NPCConfig:getNPCById(npcId)
    if npcId and npc_config and npc_config.gym_id == gym_id and npc_config.is_pvp == 1 then
      Lib.logInfo("self challengeId = ", self:getGymChallengeId())
      Lib.logInfo("self challengeRank = ", self:getGymChallengeRank())
      if self:getGymChallengeId() == challengeId and self:getGymChallengeRank() == rank then
        Lib.logInfo("checkPVPGymStatus same id and same rank =  ", challengeId, rank)
        self:sendPacket({
          pid = "ShowPVPPrompt",
          playerName = playerName,
          rank = rank
        })
      end
    else
      self:updatePVPGymStatus(gym_id)
    end
  else
    self:updatePVPGymStatus(gym_id)
  end
end

function Player:updatePVPGymStatus(gym_id)
  Lib.logInfo("updatePVPGymStatus gym_id = ", gym_id)
  local unlockLevel = PlayerExpConfig:getLvByUnlockMod(Define.MODULE_TYPE.MAIN_LEADERBOARD)
  if unlockLevel <= self:getPlayerLevel() then
    local rankType = self:getLangType()
    local rankIndex = self:getRankIndex()
    local userId = self.platformUserId
    local gym_config = GymConfig:getGymById(gym_id)
    if gym_config then
      Rank.GetSubRankData(rankType, gym_config.type, rankIndex, function(rankDatas)
        local player = Game.GetPlayerByUserId(userId)
        if player and player:isValid() then
          player:updateGloryStatus(gym_id, rankDatas)
          player:updateGymChallengeStatus(gym_id, rankDatas)
        end
      end)
    end
  end
end

function Player:updateGymChallengeStatus(gym_id, rankDatas)
  Lib.logInfo("updateGymChallengeStatus gym_id = ", gym_id)
  local has_rank = false
  for _, rankData in pairs(rankDatas) do
    if rankData.isnpc == false and rankData.userId == self.platformUserId then
      has_rank = true
      Lib.logInfo("updateGloryStatus has_rank setPVPRank gym_id and rank = ", gym_id, rankData.rank)
      self:setPVPRank(gym_id, rankData.rank)
      break
    end
  end
  if not has_rank then
    self:resetPVPGymNpcChallenge(gym_id)
    self:setGymProgress(gym_id, 0)
    self:setGymFinish(gym_id, 0)
    Lib.logInfo("updateGymChallengeStatus no rank")
    self:setPVPRank(gym_id, 0)
  end
end

function Player:updateGloryStatus(gym_id, rankDatas)
  Lib.logInfo("updateGloryStatus gym_id = ", gym_id)
  local allGlory = self:getAllGlory()
  for id, data in pairs(allGlory) do
    local glory = GloryConfig:getGloryById(id)
    if glory.type == gym_id then
      local isKeeyGlory = false
      local npcs = NPCConfig:getNPCByGymIdAndGymProgress(glory.type, glory.type_int)
      for _, npc in pairs(npcs) do
        local rank = 8 - npc.gym_index
        local rankData = rankDatas[rank]
        if rankData and rankData.isnpc == false and rankData.userId == self.platformUserId then
          isKeeyGlory = true
          break
        end
      end
      if not isKeeyGlory then
        self:lostGlory(id)
      end
    end
  end
end

local function insertSort(pokemonList)
  local function compare(targetObjId, insertObjId)
    local targetPokemon = PokemonManager:getPokemon(targetObjId)
    
    local insertPokemon = PokemonManager:getPokemon(insertObjId)
    if insertPokemon:getStar() == targetPokemon:getStar() then
      if insertPokemon:getQuality() == targetPokemon:getQuality() then
        if insertPokemon:getWake() == targetPokemon:getWake() then
          if insertPokemon:getLevel() == targetPokemon:getLevel() then
            return insertPokemon:getBookId() < targetPokemon:getBookId()
          end
          return insertPokemon:getLevel() > targetPokemon:getLevel()
        end
        return insertPokemon:getWake() > targetPokemon:getWake()
      end
      return insertPokemon:getQuality() > targetPokemon:getQuality()
    end
    return insertPokemon:getStar() > targetPokemon:getStar()
  end
  
  local listChanged = false
  for i = 2, #pokemonList do
    local temp = pokemonList[i]
    local j = i - 1
    while 1 <= j and compare(pokemonList[j], temp) do
      listChanged = true
      pokemonList[j + 1] = pokemonList[j]
      j = j - 1
    end
    pokemonList[j + 1] = temp
  end
  return listChanged
end

function Player:sortPokemonList()
  local packetPetList = self:getValue("packetPetList")
  if insertSort(packetPetList) then
    self:setValue("packetPetList", packetPetList)
  end
end

function Player:updateTodayLoginTime()
  local curTime = os.time()
  self:setCurLoginTime(curTime)
  local todayFirstLoginTime = self:getTodayFirstLoginTime()
  if todayFirstLoginTime == 0 then
    self:setTodayFirstLoginTime(curTime)
  elseif not Lib.isSameDay(curTime, todayFirstLoginTime) then
    self:setTodayFirstLoginTime(curTime)
  end
end

function Player:updateAllPokemonFlag()
  local flag = self:getAllPokemonFlag()
  if flag ~= nil and 0 < flag then
    return
  end
  local oldFlag = flag
  local allIds = PokemonConfig:getAllIds()
  local isAllObtain = false
  local allCollect = self:getAllPokemonCollect() or {}
  local oldCollectCount = allCollect.count or 0
  local oldCollectTotal = allCollect.total or 0
  local collectTotal = 0
  local collectCount = 0
  if allIds and next(allIds) then
    collectTotal = #allIds
    isAllObtain = true
    local bookRecord = self:getValue("bookRecord") or {}
    for _, cfgId in pairs(allIds) do
      if not bookRecord[tostring(cfgId)] then
        isAllObtain = false
      else
        collectCount = collectCount + 1
      end
    end
  end
  if isAllObtain then
    flag = 1
    collectCount = collectTotal
  else
    flag = 0
  end
  if collectTotal < collectCount then
    collectCount = collectTotal
  end
  if collectCount ~= oldCollectCount or collectTotal ~= oldCollectTotal then
    allCollect.count = collectCount
    allCollect.total = collectTotal
    self:setAllPokemonCollect(allCollect)
    local HighlightDataHandler = T(Lib, "HighlightDataHandler")
    HighlightDataHandler:reportHighlightData(self.platformUserId, "g2038", "allPokemonCollectPro", tostring(collectCount) .. "/" .. tostring(collectTotal))
  end
  if oldFlag ~= flag then
    self:setAllPokemonFlag(flag)
    local HighlightDataHandler = T(Lib, "HighlightDataHandler")
    HighlightDataHandler:reportHighlightData(self.platformUserId, "g2038", "allPokemonFlag", flag)
  end
end

function Player:updateAllPokemonPower()
  if self._updateAllPokemonPowerTimer ~= nil then
    self:setUpdateAllPokemonPower(1)
    return
  end
  local userId = self.platformUserId
  self:setUpdateAllPokemonPower(1)
  
  local function _updateFunc()
    local player = Game.GetPlayerByUserId(userId)
    if not player or not player:isValid() then
      return
    end
    player._updateAllPokemonPowerTimer = nil
    player:setUpdateAllPokemonPower(0)
    local allPower = 0
    local pokemonList = player:getBattlePokemon()
    if pokemonList and next(pokemonList) then
      local power = 0
      for _, pokemon in pairs(pokemonList) do
        power = pokemon:getFightPower() or 0
        allPower = allPower + power
      end
    end
    local oldPower = player:getAllPokemonPower()
    if allPower ~= oldPower then
      player:setAllPokemonPower(allPower)
      local HighlightDataHandler = T(Lib, "HighlightDataHandler")
      HighlightDataHandler:reportHighlightData(player.platformUserId, "g2038", "allPokemonPower", allPower)
    end
  end
  
  self._updateAllPokemonPowerTimer = LuaTimer:scheduleTimer(_updateFunc, 5000, 1)
end

function Player:checkPokemonInTeam(pokemonObjId)
  for _, obj in pairs(self:getValue("battlePetList")) do
    if obj == pokemonObjId then
      return true
    end
  end
end

function Player:checkCanStarUp(pokemon)
  local sameStarCount = 0
  local costMap = PokemonConfig:getStarConfig(pokemon:getStar()).starUpCost
  local pokemonList = self:getPacketPokemon()
  for _, packetPokemon in pairs(pokemonList) do
    if not packetPokemon:isLocked() and not self:checkPokemonInTeam(packetPokemon:getObjId()) and pokemon:getObjId() ~= packetPokemon:getObjId() and pokemon:getStar() == packetPokemon:getStar() then
      sameStarCount = sameStarCount + 1
    end
  end
  return sameStarCount >= tonumber(costMap[1]) and pokemon:getStar() < 6
end

local oldLoadDBData = Player.loadDBData

function Player:loadDBData(data)
  if World.cfg.saveMapPos and data.saveMapPos and (Lib.checkNumberValueIsNan(data.saveMapPos.x) or Lib.checkNumberValueIsNan(data.saveMapPos.y) or Lib.checkNumberValueIsNan(data.saveMapPos.z)) then
    Lib.logError("Error:data.saveMapPos contain a nan value:", Lib.v2s(data.saveMapPos))
    local initPos = WorldServer.defaultMap.cfg.initPos or World.cfg.initPos
    data.saveMapPos = initPos
    data.saveMapPos.map = World.cfg.defaultMap or "map001"
  end
  return oldLoadDBData(self, data)
end

function Player:showFollowPet(fullName, objId)
  local curFollowPetId = tostring(self:getCurFollowPetId())
  local pokemon = self:getSelfPokemon(objId)
  if pokemon then
    Lib.reportPetWalk(self, pokemon:getCfgId())
  end
  if not self:getFollowPetPrivilege() then
    return Define.FOLLOW_PET_STATUS.UNPAY
  end
  if curFollowPetId ~= "0" and curFollowPetId == objId then
    self:removeFollowPetEntity(true, curFollowPetId)
    return Define.FOLLOW_PET_STATUS.UNUSE
  end
  if curFollowPetId ~= "0" then
    self:removeFollowPetEntity(true, curFollowPetId)
  end
  self:createFollowPetEntity(fullName, objId)
  self:setCurFollowPetId(objId)
  self:setFollowPokemon(objId)
  return Define.FOLLOW_PET_STATUS.USE
end

function Player:getStarAndWakeRedPointList()
  local starUpRedShowIndexList = {}
  local wakeRedShowIndexList = {}
  local pokemonList = self:getPacketPokemon()
  for index, battlePokemon in pairs(self:getBattlePokemon()) do
    if PokemonConfig:checkCanRise(battlePokemon, pokemonList, self:getBattlePokemon()) then
      table.insert(wakeRedShowIndexList, index)
    end
    if self:checkCanStarUp(battlePokemon) then
      table.insert(starUpRedShowIndexList, index)
    end
  end
  return starUpRedShowIndexList, wakeRedShowIndexList
end

function Player:getMapPos()
  local map = self.map
  if map and map.static and self:isSaveMapPos(map) then
    if map.name == World.cfg.gloryHallMap then
      if self.gloryLastMapInfo then
        local mapPos = self.gloryLastMapInfo.lastPos
        mapPos.map = self.gloryLastMapInfo.lastMap
        mapPos.yaw = self.gloryLastMapInfo.lastRotationYaw
        mapPos.pitch = self.gloryLastMapInfo.lastRotationPitch
        self.saveMapPos = mapPos
      else
        local mapPos = World.cfg.initPos
        mapPos.map = World.cfg.defaultMap
        self.saveMapPos = mapPos
      end
    else
      local mapPos = self:getPosition()
      mapPos.map = map.name
      mapPos.yaw = self:getRotationYaw()
      mapPos.pitch = self:getRotationPitch()
      self.saveMapPos = mapPos
    end
  end
  return self.saveMapPos
end

function Player:setPacketPetList(packetPetList)
  self:setValue("packetPetList", checkTableSame(packetPetList))
  self:sortPokemonList()
end
