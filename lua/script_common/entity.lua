local Entity = _ENV.Entity
local ValueDef = T(Entity, "ValueDef")
local PlayerExpConfig = T(Config, "PlayerExpConfig")
local PokemonGuideConfig = T(Config, "PokemonGuideConfig")
local NPCConfig = T(Config, "NPCConfig")
ValueDef.isLogin = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.enterBattle = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.inBattle = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.battleResult = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.battleNpcId = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.campId = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.maxHp = {
  false,
  false,
  true,
  true,
  1,
  false
}
ValueDef.speed = {
  false,
  false,
  false,
  false,
  1,
  false
}
ValueDef.pAtk = {
  false,
  false,
  false,
  false,
  1,
  false
}
ValueDef.sAtk = {
  false,
  false,
  false,
  false,
  1,
  false
}
ValueDef.pDef = {
  false,
  false,
  false,
  false,
  1,
  false
}
ValueDef.sDef = {
  false,
  false,
  false,
  false,
  1,
  false
}
ValueDef.speedRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.pAtkRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.sAtkRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.pDefRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.sDefRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.accuracyRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.powerRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.lifeRBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.speedNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.pAtkNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.sAtkNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.pDefNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.sDefNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.accuracyNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.powerNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.lifeNBonus = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.battlePreType = {
  false,
  true,
  true,
  false,
  0,
  false
}
ValueDef.hurtSubPct = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.bpIndex = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.playerLevel = {
  false,
  false,
  true,
  true,
  1,
  true
}
ValueDef.playerExLevel = {
  false,
  false,
  true,
  true,
  1,
  true
}
ValueDef.playerExp = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.playerTitleList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.playerTitle = {
  false,
  false,
  true,
  true,
  0,
  true
}
ValueDef.passedForceEnemy = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.packetPetAttr = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.battlePetAttr = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.noConfigPetAttr = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef.pvpBattlePetAttrs = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.pvpSkins = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.pvpActorNames = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.packetPetList = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.battlePetList = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.capturePetList = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.bookRecord = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.swapPokemonObjId = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.swapSure = {
  false,
  false,
  true,
  true,
  false,
  false
}
ValueDef.curBattlePetList = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.curEnemyPetList = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.curBattlePetName = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.curBattlePetBallId = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.curBattlePetObjID = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.lastLoginTime = {
  false,
  false,
  false,
  false,
  false,
  true
}
ValueDef.curFollowPetId = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.swapTargetId = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.isBanSwap = {
  false,
  false,
  false,
  false,
  false,
  false
}
ValueDef.readyCloseResult = {
  false,
  true,
  false,
  false,
  false,
  false
}
ValueDef.hostTeamMateId = {
  false,
  false,
  true,
  false,
  -1,
  false
}
ValueDef.followPetPrivilege = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.todayFirstLoginTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.curLoginTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.cheatingList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.pokemonId = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.masterId = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.initPokemonId = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.firstLuckyEgg = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.crashThreeSel = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.allPokemonPower = {
  false,
  false,
  false,
  false,
  -1,
  true
}
ValueDef.allPokemonFlag = {
  false,
  false,
  false,
  false,
  -1,
  true
}
ValueDef.allPokemonCollect = {
  false,
  false,
  false,
  false,
  {},
  true
}
ValueDef.updateAllPokemonPower = {
  false,
  false,
  false,
  false,
  0,
  true
}
ValueDef.npcChallengeList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.curGym = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.gymProgressList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.gymFinishList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.gymChallengeId = {
  false,
  false,
  true,
  false,
  -1,
  true
}
ValueDef.gymChallengeRank = {
  false,
  false,
  true,
  false,
  -1,
  true
}
ValueDef.gymChallengeName = {
  false,
  false,
  true,
  false,
  "",
  true
}
ValueDef.nextNpc = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.inNpc = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.mapUnlockList = {
  false,
  false,
  true,
  false,
  {
    1,
    0,
    0,
    0,
    0,
    0
  },
  true
}
ValueDef.isReturnHome = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.curGuideIndex = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.isGuideFinish = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.isThrowBall = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.guideGainAward = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.activePoint = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.curActiveIndex = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.activeDay = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.dailyTaskList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.dailyTaskStatusList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.lastRankReward = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.rankRewardStatusList = {
  false,
  false,
  true,
  false,
  {
    0,
    0,
    0,
    0,
    0,
    0,
    0
  },
  true
}
ValueDef.rankIndex = {
  false,
  false,
  true,
  false,
  -1,
  true
}
ValueDef.lastRankIndex = {
  false,
  false,
  true,
  false,
  -1,
  true
}
ValueDef.langType = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.lastLangType = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.rankGrade = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.PVPRankList = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.rechargeSum = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.rechargeAwardStatus = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.consumeDiamond = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.shopBuyInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.dailyFDiamond = {
  false,
  false,
  true,
  false,
  false,
  true
}
ValueDef.regularBuyInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.luckyEggInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.luckyEggExtra = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.luckyEggWish = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.firstRotaryTable = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.addSkillEffects = {
  false,
  true,
  true,
  true,
  {},
  false
}
ValueDef.teamDate = {
  false,
  true,
  true,
  true,
  nil,
  false
}
ValueDef.triggerGiftInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.haveBuyGiftInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.onlineGiftBagStatus = {
  false,
  false,
  true,
  false,
  true,
  true
}
ValueDef.firstTriggerGift = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.gainFirstOrangePet = {
  false,
  true,
  true,
  false,
  0,
  true
}
ValueDef.sprayEndTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.canPK = {
  false,
  false,
  true,
  false,
  1,
  true
}
ValueDef.curLotteryInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.lastAddLotteryChanceTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.lastLotteryResetTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.announcementVersion = {
  false,
  false,
  true,
  false,
  0,
  true
}
local oldDoSetValue = Entity.doSetValue

function Entity:doSetValue(key, value)
  oldDoSetValue(self, key, value)
  if key == "curLotteryInfo" then
    Lib.emitEvent(Event.EVENT_DAILY_LOTTERY_NUM_CHANGE, value.curLotteryNum or 0)
  elseif key == "addSkillEffects" then
    Lib.emitEvent(Event.EVENT_ADD_EFFECT_DATA_CHANGE, self:getPokemonId() or 0)
  end
end

function Entity:getAnnouncementVersion()
  return self:getValue("announcementVersion")
end

function Entity:setAnnouncementVersion(version)
  self:setValue("announcementVersion", version)
end

function Entity:getThreeSelCache()
  return self:getValue("crashThreeSel")
end

function Entity:cacheThreeSel(targetGiftId)
  self:setValue("crashThreeSel", targetGiftId)
end

function Entity:getAllPokemonPower()
  local totalPower = self:getValue("allPokemonPower")
  if totalPower == nil then
    totalPower = -1
  end
  return totalPower
end

function Entity:setAllPokemonPower(value)
  self:setValue("allPokemonPower", value)
end

function Entity:getAllPokemonFlag()
  local flag = self:getValue("allPokemonFlag")
  if flag == nil then
    flag = -1
  end
  return flag
end

function Entity:setAllPokemonFlag(value)
  self:setValue("allPokemonFlag", value)
end

function Entity:getAllPokemonCollect()
  return self:getValue("allPokemonCollect")
end

function Entity:setAllPokemonCollect(value)
  self:setValue("allPokemonCollect", value)
end

function Entity:getUpdateAllPokemonPower()
  local isUpdate = self:getValue("updateAllPokemonPower")
  if isUpdate == nil then
    isUpdate = 0
  end
  return isUpdate
end

function Entity:setUpdateAllPokemonPower(value)
  self:setValue("updateAllPokemonPower", value)
end

function Entity:getLastAddLotteryChanceTime()
  return self:getValue("lastAddLotteryChanceTime") or 0
end

function Entity:setLastAddLotteryChanceTime(time)
  self:setValue("lastAddLotteryChanceTime", time)
end

function Entity:getLastLotteryResetTime()
  return self:getValue("lastLotteryResetTime") or 0
end

function Entity:setLastLotteryResetTime(time)
  self:setValue("lastLotteryResetTime", time)
end

function Entity:getCurLotteryInfo()
  return self:getValue("curLotteryInfo")
end

function Entity:getCurLotteryCircle()
  local data = self:getValue("curLotteryInfo")
  return data and data.curLotteryCircle or 1
end

function Entity:getCurLotteryNum()
  local data = self:getValue("curLotteryInfo")
  return data and data.curLotteryNum or 0
end

function Entity:getCurLotteryPickList()
  local data = self:getValue("curLotteryInfo")
  return data and data.curPickList or {}
end

function Entity:setCurLotteryInfo(Date)
  self:setValue("curLotteryInfo", Date)
end

function Entity:getBpIndex()
  return self:getValue("bpIndex")
end

function Entity:setBpIndex(bpIndex)
  self:setValue("bpIndex", bpIndex)
end

function Entity:getMyTeam()
  return self:getValue("teamDate")
end

function Entity:setMyTeam(teamDate)
  self:setValue("teamDate", teamDate)
end

function Entity:getTriggerGiftInfo()
  return self:getValue("triggerGiftInfo")
end

function Entity:setTriggerGiftInfo(teamDate)
  self:setValue("triggerGiftInfo", teamDate)
end

function Entity:getHaveBuyGiftInfo()
  return self:getValue("haveBuyGiftInfo")
end

function Entity:setHaveBuyGiftInfo(teamDate)
  self:setValue("haveBuyGiftInfo", teamDate)
end

function Entity:isReadyCloseResult()
  return self:getValue("readyCloseResult")
end

function Entity:setReadyCloseResult(isReady)
  self:setValue("readyCloseResult", isReady)
end

function Entity:isJoinTeam()
  if self:getMyTeam() then
    return true
  end
  return false
end

function Entity:isTeamCaptain()
  local myTeam = self:getMyTeam()
  if myTeam and myTeam.isCaptain == 1 then
    return true
  end
  return false
end

function Entity:getMyTeamMateId()
  local myTeam = self:getMyTeam()
  if myTeam then
    return myTeam.teamMateID
  end
  return nil
end

function Entity:getMyHostTeamMateId()
  return self:getValue("hostTeamMateId")
end

function Entity:getAddSkillEffects()
  return self:getValue("addSkillEffects") or {}
end

function Entity:setAddSkillEffects(tbEffect)
  self:setValue("addSkillEffects", tbEffect)
end

function Entity:getShopBuyInfo()
  return self:getValue("shopBuyInfo") or {}
end

function Entity:setShopBuyInfo(data)
  self:setValue("shopBuyInfo", data)
end

function Entity:getRegularBuyInfo()
  return self:getValue("regularBuyInfo") or {}
end

function Entity:setRegularBuyInfo(data)
  self:setValue("regularBuyInfo", data)
end

function Entity:getLuckyEggInfo()
  return self:getValue("luckyEggInfo") or {}
end

function Entity:setLuckyEggInfo(data)
  self:setValue("luckyEggInfo", data)
end

function Entity:getLuckyEggExtra()
  return self:getValue("luckyEggExtra") or {}
end

function Entity:setLuckyEggExtra(data)
  self:setValue("luckyEggExtra", data)
end

function Entity:setLuckyEggWish(value)
  self:setValue("luckyEggWish", value)
end

function Entity:getLuckyEggWish()
  return self:getValue("luckyEggWish") or {}
end

function Entity:getHurtSubPct()
  return self:getValue("hurtSubPct") or 0
end

function Entity:setHurtSubPct(value)
  self:setValue("hurtSubPct", value)
end

function Entity:isInBattle()
  return self:getValue("inBattle") or false
end

function Entity:setInBattle(value)
  self:setValue("inBattle", value)
end

function Entity:isEnterBattle()
  return self:getValue("enterBattle") or false
end

function Entity:setEnterBattle(value)
  self:setValue("enterBattle", value)
end

function Entity:getBattleResult()
  return self:getValue("battleResult")
end

function Entity:setBattleResult(value)
  Lib.logDebug("setBattleResult value = ", value)
  self:setValue("battleResult", value)
end

function Entity:isInNpcBattle()
  return self:getValue("battleNpcId")
end

function Entity:setInNpcBattle(value)
  self:setValue("battleNpcId", value)
end

function Entity:getCampId()
  return self:getValue("campId") or 0
end

function Entity:setCampId(value)
  self:setValue("campId", value)
end

function Entity:setPokemonId(value)
  self:setValue("pokemonId", value)
end

function Entity:getPokemonId()
  return self:getValue("pokemonId")
end

function Entity:setCurBattlePetName(value)
  self:setValue("curBattlePetName", value)
end

function Entity:setBattlePreType(value)
  self:setValue("battlePreType", value)
end

function Entity:getSpeed()
  return self:getValue("speed") or 1
end

function Entity:getEffectiveSpeed()
  local firstSpeed = self:getSpeed()
  local lastSpeed = math.max(firstSpeed + self:getSpeedNBonus(), firstSpeed * 0.2)
  return lastSpeed * math.max(1 + self:getSpeedRBonus(), 0.2)
end

function Entity:setSpeed(value)
  self:setValue("speed", value)
end

function Entity:getSAtk()
  return self:getValue("sAtk") or 1
end

function Entity:getEffectiveSAtk()
  local firstSAtk = self:getSAtk()
  local lastSAtk = math.max(firstSAtk + self:getSAtkNBonus(), firstSAtk * 0.2)
  return lastSAtk * math.max(1 + self:getSAtkRBonus(), 0.2)
end

function Entity:getEffectiveSDef()
  local firstSDef = self:getSDef()
  local lastSDef = math.max(firstSDef + self:getSDefNBonus(), firstSDef * 0.2)
  return lastSDef * math.max(1 + self:getSDefRBonus(), 0.2)
end

function Entity:getEffectivePDef()
  local firstPDef = self:getPDef()
  local lastPDef = math.max(firstPDef + self:getPDefNBonus(), firstPDef * 0.2)
  return lastPDef * math.max(1 + self:getPDefRBonus(), 0.2)
end

function Entity:setSAtk(value)
  self:setValue("sAtk", value)
end

function Entity:getPAtk()
  return self:getValue("pAtk") or 1
end

function Entity:getEffectivePAtk()
  local firstPAtk = self:getPAtk()
  local lastPAtk = math.max(firstPAtk + self:getPAtkNBonus(), firstPAtk * 0.2)
  return lastPAtk * math.max(1 + self:getPAtkRBonus(), 0.2)
end

function Entity:setPAtk(value)
  self:setValue("pAtk", value)
end

function Entity:getSDef()
  return self:getValue("sDef") or 1
end

function Entity:setSDef(value)
  self:setValue("sDef", value)
end

function Entity:getPDef()
  return self:getValue("pDef") or 1
end

function Entity:setPDef(value)
  self:setValue("pDef", value)
end

function Entity:getPAtkRBonus()
  return self:getValue("pAtkRBonus") or 0
end

function Entity:setPAtkRBonus(value)
  self:setValue("pAtkRBonus", value)
end

function Entity:getPAtkNBonus()
  return self:getValue("pAtkNBonus") or 0
end

function Entity:setPAtkNBonus(value)
  self:setValue("pAtkNBonus", value)
end

function Entity:getPDefRBonus()
  return self:getValue("pDefRBonus") or 0
end

function Entity:setPDefRBonus(value)
  self:setValue("pDefRBonus", value)
end

function Entity:getPDefNBonus()
  return self:getValue("pDefNBonus") or 0
end

function Entity:setPDefNBonus(value)
  self:setValue("pDefNBonus", value)
end

function Entity:getSDefRBonus()
  return self:getValue("sDefRBonus") or 0
end

function Entity:setSDefRBonus(value)
  self:setValue("sDefRBonus", value)
end

function Entity:getSDefNBonus()
  return self:getValue("sDefNBonus") or 0
end

function Entity:setSDefNBonus(value)
  self:setValue("sDefNBonus", value)
end

function Entity:getSAtkRBonus()
  return self:getValue("sAtkRBonus") or 0
end

function Entity:setSAtkRBonus(value)
  self:setValue("sAtkRBonus", value)
end

function Entity:getSAtkNBonus()
  return self:getValue("sAtkNBonus") or 0
end

function Entity:setSAtkNBonus(value)
  self:setValue("sAtkNBonus", value)
end

function Entity:getSpeedRBonus()
  return self:getValue("speedRBonus") or 0
end

function Entity:setSpeedRBonus(value)
  self:setValue("speedRBonus", value)
end

function Entity:getSpeedNBonus()
  return self:getValue("speedNBonus") or 0
end

function Entity:setSpeedNBonus(value)
  self:setValue("speedNBonus", value)
end

function Entity:getAccuracyRBonus()
  return self:getValue("accuracyRBonus") or 0
end

function Entity:setAccuracyRBonus(value)
  self:setValue("accuracyRBonus", value)
end

function Entity:getAccuracyNBonus()
  return self:getValue("accuracyNBonus") or 0
end

function Entity:setAccuracyNBonus(value)
  self:setValue("accuracyNBonus", value)
end

function Entity:getEffectiveAccuracy(accuracy)
  local firstAccuracy = accuracy or 0
  local lastAccuracy = math.min((firstAccuracy + self:getAccuracyNBonus()) * (1 + self:getAccuracyRBonus()), 100)
  return math.max(lastAccuracy, 0)
end

function Entity:getPowerRBonus()
  return self:getValue("powerRBonus") or 0
end

function Entity:setPowerRBonus(value)
  self:setValue("powerRBonus", value)
end

function Entity:getPowerNBonus()
  return self:getValue("powerNBonus") or 0
end

function Entity:setPowerNBonus(value)
  self:setValue("powerNBonus", value)
end

function Entity:getEffectivePower(power)
  local firstPower = power or 0
  local powerN = math.max(firstPower + self:getPowerNBonus(), 10)
  local powerR = math.max(1 + self:getPowerRBonus(), 0.2)
  return math.min(powerN * powerR, 300)
end

function Entity:getLifeRBonus()
  return self:getValue("lifeRBonus") or 0
end

function Entity:setLifeRBonus(value)
  self:setValue("lifeRBonus", value)
end

function Entity:getLifeNBonus()
  return self:getValue("lifeNBonus") or 0
end

function Entity:setLifeNBonus(value)
  self:setValue("lifeNBonus", value)
end

function Entity:getMaxHp()
  return self:getValue("maxHp")
end

function Entity:setMaxHp(maxHp)
  self:setValue("maxHp", maxHp)
end

function Entity:updatePKMBonusHp()
  local lastMaxHp = self.pokemon:getBattleMaxHp()
  local firstMaxHp = 0
  if self.pokemon then
    firstMaxHp = self.pokemon:getMaxHp()
  end
  local maxHpN = math.max(firstMaxHp + self:getLifeNBonus(), firstMaxHp * 0.2)
  local maxHpR = math.max(1 + self:getLifeRBonus(), 0.2)
  local nowMaxHp = math.ceil(maxHpN * maxHpR)
  self:setMaxHp(nowMaxHp)
  self.pokemon:setBattleMaxHp(nowMaxHp)
  local changeHp = nowMaxHp - lastMaxHp
  local newCurHp = self.curHp + changeHp
  newCurHp = math.min(newCurHp, nowMaxHp)
  newCurHp = math.max(newCurHp, 1)
  self:setHp(newCurHp)
end

function Entity:getPetList()
  return self:getValue("battlePetList")
end

function Entity:getExpHasAndNeed(isAll)
  return PlayerExpConfig:getUpHasAndNeedExp(self, isAll)
end

function Entity:addPlayerExp(val)
  if not val or val <= 0 or PlayerExpConfig:isFull(self) then
    return
  end
  self:setValue("playerExp", self:getPlayerExp() + val)
  self:checkLvUp()
end

function Entity:getAllGlory()
  return self:getValue("playerTitleList")
end

function Entity:getGloryStatus(id)
  local glory = self:getValue("playerTitleList")[id]
  if not glory then
    return Define.GLORY_STATUS.INIT
  end
  return glory.status
end

function Entity:getGloryInfoById(id)
  return self:getValue("playerTitleList")[id]
end

function Entity:catchGlory(id)
  local tb = self:getValue("playerTitleList")
  if not tb[id] or type(tb[id]) ~= "table" then
    tb[id] = {}
  end
  tb[id].time = os.time()
  tb[id].status = Define.GLORY_STATUS.GAIN
  self:setValue("playerTitleList", tb)
  if self.isPlayer then
    self:sendPacket({pid = "CatchGlory", id = id})
  end
end

function Entity:lostGlory(id)
  local tb = self:getValue("playerTitleList")
  if not tb[id] then
    return
  end
  tb[id].status = Define.GLORY_STATUS.LOST
  self:setValue("playerTitleList", tb)
  if self:getCurSelGlory() == id then
    self:setValue("playerTitle", 0)
  end
end

function Entity:getCurSelGlory()
  return self:getValue("playerTitle")
end

function Entity:switchCurSelGlory(id)
  if self:getCurSelGlory() == id then
    self:setValue("playerTitle", 0)
  else
    self:setValue("playerTitle", id)
  end
end

function Entity:checkLvUp()
  local has, need, isFull = self:getExpHasAndNeed()
  if isFull then
    self:setValue("playerExp", PlayerExpConfig:getFullExp())
    return
  end
  if need <= has then
    self:upLevel()
    self:checkLvUp()
  end
end

function Entity:upLevel()
  self:setValue("playerLevel", self:getPlayerLevel() + 1)
  if not World.isClient then
    self:verifyTriggerGiftCondition(Define.GIFT_TRIGGER_CONDITION.LV, self:getPlayerLevel())
    local unlockDetail = PlayerExpConfig:getPresentUnlockModByLv(self:getPlayerLevel())
    if 0 < #unlockDetail then
      for i = 1, #unlockDetail do
        if unlockDetail[i] == Define.MODULE_TYPE.MAIN_DAILY_TASK then
          self:initDailyTask()
          break
        end
      end
    end
  end
end

function Entity:getPlayerExp()
  return self:getValue("playerExp")
end

function Entity:getPlayerLevel()
  return self:getValue("playerLevel")
end

function Entity:setPlayerExLevel(level)
  self:setValue("playerExLevel", level)
end

function Entity:getPlayerExLevel()
  return self:getValue("playerExLevel")
end

function Entity:getLastLoginTime()
  return self:getValue("lastLoginTime")
end

function Entity:updateLastLoginTime()
  self:setValue("lastLoginTime", os.time())
end

function Entity:resetPVPGymNpcChallenge(gym_id)
  local datas = self:getValue("npcChallengeList")
  for npc_id, npc_count in pairs(datas) do
    local npc_config = NPCConfig:getNPCById(npc_id)
    if npc_config and npc_config.gym_id == gym_id and npc_config.is_pvp == 1 then
      self:setNpcChallenge(npc_id, nil)
    end
  end
end

function Entity:getNpcChallenge(npcId)
  local datas = self:getValue("npcChallengeList")
  if datas[npcId] ~= nil then
    return datas[npcId]
  end
  return nil
end

function Entity:setNpcChallenge(npcId, count)
  local datas = self:getValue("npcChallengeList")
  datas[npcId] = count
  self:setValue("npcChallengeList", datas)
end

function Entity:setCurGym(value)
  self:setValue("curGym", value)
end

function Entity:getCurGym()
  return self:getValue("curGym")
end

function Entity:setPVPBattlePetAttr(type, pokemons)
  local datas = self:getValue("pvpBattlePetAttrs")
  datas[type] = pokemons
  Lib.logInfo("setPVPBattlePetAttr by userId = ", self.platformUserId)
  self:setValue("pvpBattlePetAttrs", datas)
end

function Entity:setPVPActorName(type, name)
  local datas = self:getValue("pvpActorNames")
  datas[type] = name
  Lib.logInfo("setPVPActorName by userId = ", self.platformUserId)
  self:setValue("pvpActorNames", datas)
end

function Entity:setPVPSkin(type, skin)
  local datas = self:getValue("pvpSkins")
  datas[type] = skin
  Lib.logInfo("setPVPActorName by userId = ", self.platformUserId)
  self:setValue("pvpSkins", datas)
end

function Entity:getGymProgress(id)
  local datas = self:getValue("gymProgressList")
  Lib.logDebug("getGymProgress datas = ", Lib.v2s(datas))
  if datas[id] ~= nil then
    return datas[id]
  end
  return nil
end

function Entity:setGymProgress(id, progress)
  local datas = self:getValue("gymProgressList")
  datas[id] = progress
  self:setValue("gymProgressList", datas)
end

function Entity:getGymFinish(id)
  local datas = self:getValue("gymFinishList")
  if datas[id] ~= nil then
    return datas[id]
  end
  return nil
end

function Entity:setGymFinish(id, index)
  local datas = self:getValue("gymFinishList")
  datas[id] = index
  self:setValue("gymFinishList", datas)
end

function Entity:getGymFinishCount()
  local datas = self:getValue("gymFinishList")
  local count = 0
  for i = 1, #datas do
    if datas[i] == 1 then
      count = count + 1
    end
  end
  return count
end

function Entity:setInNpc(value)
  Lib.logDebug("setInNpc value = ", value)
  self:setValue("inNpc", value)
end

function Entity:getInNpc()
  return self:getValue("inNpc")
end

function Entity:setGymChallengeId(value)
  self:setValue("gymChallengeId", value)
end

function Entity:getGymChallengeId()
  return self:getValue("gymChallengeId")
end

function Entity:setGymChallengeRank(value)
  self:setValue("gymChallengeRank", value)
end

function Entity:getGymChallengeRank()
  return self:getValue("gymChallengeRank")
end

function Entity:setGymChallengeName(value)
  self:setValue("gymChallengeName", value)
end

function Entity:getGymChallengeName()
  return self:getValue("gymChallengeName")
end

function Entity:getIsReturnHome()
  return self:getValue("isReturnHome")
end

function Entity:setIsReturnHome(value)
  Lib.logDebug("setIsReturnHome value = ", value)
  self:setValue("isReturnHome", value)
end

function Entity:setGuideFinish(value)
  self:setValue("isGuideFinish", value)
end

function Entity:isGuideFinish()
  return self:getValue("isGuideFinish")
end

function Entity:setGuideGainAward(value)
  self:setValue("guideGainAward", value)
end

function Entity:getGuideGainAward()
  return self:getValue("guideGainAward")
end

function Entity:isGainGuideAward(id)
  local guideGainAward = self:getValue("guideGainAward")
  return guideGainAward[id]
end

function Entity:obtainGuideAward(id)
  local guideGainAward = self:getValue("guideGainAward")
  guideGainAward[id] = true
  self:setGuideGainAward(guideGainAward)
end

function Entity:setThrowBall(value)
  self:setValue("isThrowBall", value)
end

function Entity:isThrowBall()
  return self:getValue("isThrowBall")
end

function Entity:setCurGuideIndex(index)
  self:setValue("curGuideIndex", index)
end

function Entity:getCurGuideIndex()
  return self:getValue("curGuideIndex")
end

function Entity:getMapUnlock(mapId)
  local datas = self:getValue("mapUnlockList")
  if datas[mapId] ~= nil then
    return datas[mapId]
  end
  return nil
end

function Entity:setMapUnlock(mapId, status)
  local datas = self:getValue("mapUnlockList")
  datas[mapId] = status
  self:setValue("mapUnlockList", datas)
end

function Entity:getActivePoint()
  return self:getValue("activePoint")
end

function Entity:setActivePoint(value)
  self:setValue("activePoint", value)
end

function Entity:setCurActiveIndex(value)
  Lib.logDebug("setCurActiveIndex value = ", value)
  self:setValue("curActiveIndex", value)
end

function Entity:getCurActiveIndex()
  return self:getValue("curActiveIndex")
end

function Entity:getActiveDay()
  return self:getValue("activeDay")
end

function Entity:setActiveDay(value)
  self:setValue("activeDay", value)
end

function Entity:getDailyTaskList()
  local datas = self:getValue("dailyTaskList")
  return datas
end

function Entity:setDailyTaskList(value)
  self:setValue("dailyTaskList", value)
end

function Entity:getDailyTaskStatus(id)
  local datas = self:getValue("dailyTaskStatusList")
  if datas[id] ~= nil then
    return datas[id]
  end
  return nil
end

function Entity:getDailyTaskStatusList()
  local datas = self:getValue("dailyTaskStatusList")
  return datas
end

function Entity:setDailyTaskStatus(id, value)
  local datas = self:getValue("dailyTaskStatusList")
  datas[id] = value
  self:setValue("dailyTaskStatusList", datas)
end

function Entity:initDailyTaskStatusList(value)
  self:setValue("dailyTaskStatusList", value)
end

function Entity:getRechargeSum()
  return math.max(self:getValue("rechargeSum"), 0)
end

function Entity:setRechargeSum(int)
  self:setValue("rechargeSum", int)
end

function Entity:getRechargeAwardStatus()
  return math.max(self:getValue("rechargeAwardStatus"), 0)
end

function Entity:setRechargeAwardStatus(int)
  self:setValue("rechargeAwardStatus", int)
end

function Entity:getCanPK()
  return self:getValue("canPK")
end

function Entity:setCanPK(value)
  self:setValue("canPK", value)
end

function Entity:getCurFollowPetId()
  return self:getValue("curFollowPetId")
end

function Entity:setCurFollowPetId(value)
  self:setValue("curFollowPetId", value)
end

function Entity:getLastRankReward()
  return self:getValue("lastRankReward")
end

function Entity:setLastRankReward(value)
  self:setValue("lastRankReward", value)
end

function Entity:getRankRewardStatus(subId)
  local datas = self:getValue("rankRewardStatusList")
  Lib.logDebug("getRankRewardStatus datas = ", Lib.v2s(datas))
  return datas[subId]
end

function Entity:setRankRewardStatus(subId, status)
  local datas = self:getValue("rankRewardStatusList")
  datas[subId] = status
  Lib.logDebug("setRankRewardStatus datas = ", Lib.v2s(datas))
  self:setValue("rankRewardStatusList", datas)
end

function Entity:resetRankRewardStatus()
  self:setValue("rankRewardStatusList", {
    0,
    0,
    0,
    0,
    0,
    0,
    0
  })
end

function Entity:getRankIndex()
  return self:getValue("rankIndex")
end

function Entity:setRankIndex(value)
  self:setValue("rankIndex", value)
end

function Entity:getLastRankIndex()
  return self:getValue("lastRankIndex")
end

function Entity:setLastRankIndex(value)
  self:setValue("lastRankIndex", value)
end

function Entity:getLangType()
  return self:getValue("langType")
end

function Entity:setLangType(value)
  Lib.logDebug("setLangType langType = ", value)
  self:setValue("langType", value)
end

function Entity:getLastLangType()
  return self:getValue("lastLangType")
end

function Entity:setLastLangType(value)
  self:setValue("lastLangType", value)
end

function Entity:getRankGrade()
  return self:getValue("rankGrade")
end

function Entity:setRankGrade(value)
  self:setValue("rankGrade", value)
end

function Entity:getPVPRank(gym_id)
  local datas = self:getValue("PVPRankList")
  return datas[gym_id]
end

function Entity:setPVPRank(gym_id, rank)
  local datas = self:getValue("PVPRankList")
  datas[gym_id] = rank
  Lib.logDebug("setPVPRank gym_id and rank = ", gym_id, rank)
  Lib.logDebug("setPVPRank datas = ", Lib.v2s(datas))
  self:setValue("PVPRankList", datas)
end

function Entity:getPVPRankList()
  return self:getValue("PVPRankList")
end

function Entity:resetPVPRankList()
  self:setValue("PVPRankList", {})
end

function Entity:getIsLogin()
  return self:getValue("isLogin")
end

function Entity:setIsLogin(value)
  self:setValue("isLogin", value)
end

function Entity:getSwapTargetId()
  return self:getValue("swapTargetId")
end

function Entity:setSwapTargetId(value)
  self:setValue("swapTargetId", value)
end

function Entity:isBanSwap()
  return self:getValue("isBanSwap")
end

function Entity:setBanSwap(value)
  self:setValue("isBanSwap", value)
end

function Entity:checkSwapCode(target)
  if self:isJoinTeam() and not self:isTeamCaptain() then
    if target:getMyTeamMateId() == self.objID then
      return Define.ERROR_CODE.SUCCESS
    else
      return Define.ERROR_CODE.ONLY_CAP
    end
  end
  if target:isJoinTeam() and not target:isTeamCaptain() then
    if self:getMyTeamMateId() == target.objID then
      return Define.ERROR_CODE.SUCCESS
    else
      return Define.ERROR_CODE.IN_TEAM
    end
  end
  return Define.ERROR_CODE.SUCCESS
end

function Entity:getFollowPetPrivilege()
  return self:getValue("followPetPrivilege")
end

function Entity:setFollowPetPrivilege(value)
  self:setValue("followPetPrivilege", value)
end

function Entity:setInitPokemonId(value)
  self:setValue("initPokemonId", value)
end

function Entity:getInitPokemonId()
  return self:getValue("initPokemonId")
end

function Entity:setFirstLuckyEgg(value)
  self:setValue("firstLuckyEgg", value)
end

function Entity:getFirstLuckyEgg()
  return self:getValue("firstLuckyEgg")
end

function Entity:isPokemonPacketFull()
  local packetPetList = self:getValue("packetPetList")
  return #packetPetList >= World.cfg.maxBoxPetsCnt
end

function Entity:setCurLoginTime(value)
  self:setValue("curLoginTime", value)
end

function Entity:getCurLoginTime()
  return self:getValue("curLoginTime")
end

function Entity:setTodayFirstLoginTime(value)
  self:setValue("todayFirstLoginTime", value)
end

function Entity:getTodayFirstLoginTime()
  return self:getValue("todayFirstLoginTime")
end

function Entity:setGainFirstOrangePet(value)
  self:setValue("gainFirstOrangePet", value)
end

function Entity:getGainFirstOrangePet()
  return self:getValue("gainFirstOrangePet")
end

function Entity:getCheating(time)
  local datas = self:getValue("cheatingList")
  if datas[time] ~= nil then
    return datas[time]
  end
  return nil
end

function Entity:setCheating(time, status)
  local datas = self:getValue("cheatingList")
  datas[time] = status
  self:setValue("cheatingList", datas)
end
