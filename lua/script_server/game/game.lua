local LuaTimer = T(Lib, "LuaTimer")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local CheatConfig = T(Config, "CheatConfig")
local oldPlayerLogin = Game.OnPlayerLogin

function Game.OnPlayerLogin(player)
  oldPlayerLogin(player)
  player:initDBData()
  player:updateTodayLoginTime()
  player:doDataExpire()
  player:pushShowLoginGiftWnd()
  player:onRechargeGCube()
  player:recoveryInGuidance()
  if not player:isGuideFinish() and player:getCurGuideIndex() == Define.GUIDE_INDEX.CAPTURE_POKEMON_GOTO then
    Lib.logDebug("in guide CAPTURE_POKEMON_GOTO, not invicible")
  else
    player:setAvoidBattle(true)
  end
  player:setIsLogin(true)
  player:startGuidance()
  local followPet = player:getFollowPokemon()
  if followPet then
    player:createFollowPetEntity(followPet:getCfgFullName(), followPet:getObjId())
    player:setCurFollowPetId(followPet:getObjId())
    player:setFollowPokemon(followPet:getObjId())
  end
  player:checkAllPVPGymStatus()
  Store.LuckyEggAward:checkCleanLuckyFlashAward(player)
  DailyLotteryMgr:onPlayerLogin(player)
  player:isCheating()
  local oldVersion = player:getAnnouncementVersion()
  if World.cfg.gameCfgVersion ~= tonumber(oldVersion) then
    player:setAnnouncementVersion(World.cfg.gameCfgVersion)
    local level = player:getPlayerLevel()
    if level >= World.cfg.versionChangeAnnounceMinLev then
      local packet = {
        pid = "gameCfgVersionChange",
        newVersion = World.cfg.gameCfgVersion,
        oldVersion = tonumber(oldVersion)
      }
      player:sendPacket(packet)
    end
  end
  if player:getAllPokemonPower() == -1 or player:getUpdateAllPokemonPower() > 0 then
    player:updateAllPokemonPower()
  end
  if player:getAllPokemonFlag() == -1 then
    player:updateAllPokemonFlag()
  end
end

function Game.OnDateChanged()
  GloryHallMgr:updateDoorsEntityShow()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and not player.removed then
      player:doDataExpire()
      player.onlineTime = 0
      GloryHallMgr:refreshKickedOutGloryHall(player)
    end
  end
end

function Game.resetRank()
  Rank.Init()
end

local oldPlayerLogout = Game.OnPlayerLogout

function Game.OnPlayerLogout(player)
  TeamMgr:onPlayerLogout(player)
  SkillEffectMgr:onPlayerLogout(player)
  Lib.reportPlayerGameTime(player)
  Lib.reportPlayerGold(player)
  Lib.reportPlayerLevel(player)
  Lib.reportPlayerPKMMaxLevel(player)
  Lib.reportPlayerPKMCount(player)
  oldPlayerLogout(player)
end

local oldGameReady = Game.Ready

function Game.Ready()
  oldGameReady()
  Lib.logDebug("game ready")
  Game.onReportedData()
end

function Game.onReportedData()
  local function ReportedAllPlayerData()
    local players = Game.GetAllPlayers()
    
    for _, player in pairs(players) do
      player:reportedRankData()
    end
  end
  
  LuaTimer:scheduleTimer(function()
    ReportedAllPlayerData()
  end, World.cfg.rankUploadTime * 1000, -1)
end

local oldGameUpdate = Game.Update

function Game.Update()
  local result = oldGameUpdate()
  DailyLotteryMgr:countdownBegin()
  return result
end

function Game.UpdatesPlayerOnlineTime()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and not player.removed then
      local isOpenOnLineGift = PlayerExpConfig:isOpenWithLvAndModID(Define.MODULE_TYPE.GIFT_ON_LINE, player:getPlayerLevel())
      if player:getValue("onlineGiftBagStatus") and isOpenOnLineGift then
        player.onlineTime = player.onlineTime + 1
        player:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.ON_LINE, player.onlineTime)
      end
    end
  end
end

function Game.verifyPlayerGiftDue()
  for _, player in pairs(Game.GetAllPlayers()) do
    if player and not player.removed then
      player:verifyGiftDue()
    end
  end
end
