local PokemonLeaderboardRewardConfig = T(Config, "PokemonLeaderboardRewardConfig")
local RankRequestCDTime = 5

function Player:initRank()
end

function Player:getRankScore(rankType, subId, index)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  local scoreRecord = self:data("rankScoreRecord")
  return scoreRecord[key] or 0
end

function Player:addRankScore(rankType, subId, index, score)
  local old = self:getRankScore(rankType, subId, index)
  Lib.logDebug("addRankScore old = ", old)
  self:updateRankScore(rankType, subId, index, old + score)
end

function Player:updateRankScore(rankType, subId, index, score)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  local scoreRecord = self:data("rankScoreRecord")
  local old = scoreRecord[key]
  local add = score - (old or 0)
  local cfg = Rank.GetSubRankCfg(rankType, subId)
  local orderByDesc = cfg.orderByDesc
  if old and (not orderByDesc and add <= 0 or orderByDesc and 0 <= add) then
    return
  end
  scoreRecord[key] = score
  Rank.UserAddScore(self.platformUserId, rankType, subId, index, orderByDesc and -add or add, true)
end

function Player:requestRankInfo(rankType)
  local rankIndex = self:getRankIndex()
  if rankIndex ~= -1 then
    local cfgs = Rank.GetSubRankCfgs(rankType)
    assert(cfgs, rankType)
    local userId = self.platformUserId
    for subId in pairs(cfgs) do
      Rank.RequestUserRankInfo(userId, rankType, subId, rankIndex)
    end
  end
end

function Player:receiveLastWeekRankInfo(key, score, rank)
  local keyInfos = Lib.splitString(key, ".")
  local langCode = keyInfos[1]
  local rankType = Lib.getLangType(langCode)
  local keyPrefix = keyInfos[2]
  local cfgs = Rank.GetSubRankCfgs(rankType)
  local subId = 0
  for sid, cfg in pairs(cfgs) do
    if keyPrefix == cfg.keyPrefix then
      subId = sid
      break
    end
  end
  Lib.logInfo("receiveLastWeekRankInfo key, subId = ", key, subId)
  if subId ~= 0 then
    local reward_status = self:getRankRewardStatus(subId)
    if reward_status == 0 and rank ~= 0 then
      Lib.logInfo("get reward subId = ", subId)
      local coin = PokemonLeaderboardRewardConfig:getRankCoin(subId, rank)
      Lib.logDebug("coin = ", Lib.v2s(coin))
      if coin and coin.type and coin.cnt then
        self:addCurrency(coin.type, coin.cnt, "getrankreward_" .. key)
      end
      local rewards = PokemonLeaderboardRewardConfig:getRankRewards(subId, rank)
      Lib.logDebug("rewards = ", Lib.v2s(rewards))
      if rewards then
        for i = 1, #rewards do
          local reward = rewards[i]
          local fullName = "myplugin/" .. reward[1]
          local itemCount = tonumber(reward[2])
          for j = 1, itemCount do
            self:obtainItemsByFullName(fullName, 1, "getrankreward_" .. key)
          end
        end
        self:setRankRewardStatus(subId, 1)
        self:sendPacket({
          pid = "CheckRankReward",
          subId = subId,
          rank = rank
        })
      end
    end
  end
end

function Player:receiveRankInfo(rankType, subId, index, rank, score)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  local scoreRecord = self:data("rankScoreRecord")
  local record = scoreRecord[key] or 0
  local cfg = Rank.GetSubRankCfg(rankType, subId)
  local orderByDesc = cfg.orderByDesc
  if not orderByDesc and score > record or orderByDesc and score < record then
    scoreRecord[key] = orderByDesc and -score or score
  end
  self:sendPacket({
    pid = "RequestPlayerRank",
    rankType = rankType,
    subId = subId,
    rankIndex = index,
    rank = rank,
    score = score
  })
end

function Player:syncRankData(subId)
  Lib.logDebug("Player:syncRankData subId = ", subId)
  self:trySyncRankData(subId)
end

function Player:trySyncRankData(subId)
  local rankType = self:getLangType()
  local rankIndex = self:getRankIndex()
  local cfgs = Rank.GetSubRankCfgs(rankType)
  if not cfgs then
    return
  end
  Rank.GetSubRankData(rankType, subId, rankIndex, function(rankDatas)
    Lib.logInfo("GetSubRankData rankDatas = ", Lib.v2s(rankDatas))
    if not rankDatas or rankDatas and #rankDatas == 0 then
      return
    end
    local packet = {
      pid = "RankData",
      rankType = rankType,
      subId = subId,
      rankIndex = rankIndex,
      rankDatas = rankDatas
    }
    Lib.logDebug("trySyncRankData packet = ", Lib.v2s(packet, 2))
    self:sendPacket(packet)
  end)
end

function Player:listenPVPGYMMessage(rankType, rankIndex, gym_id, gym_type, rank, playerId, playerName, challengeId, challengeName)
  Lib.logInfo("listenPVPGYMMessage playerName and challengeName = ", playerName, challengeName)
  if self:getLangType() == rankType and self:getRankIndex() == rankIndex then
    local tipsInfo = {
      tipType = Define.WORLD_TIP_TYPE.WINPVP,
      id = 11,
      playerName = playerName,
      challengeId = challengeId,
      challengeName = challengeName,
      gym_type = gym_type,
      rank = rank
    }
    self:sendPacket({
      pid = "PVPGYM",
      normalMsg = "",
      tipsInfo = tipsInfo
    })
    Lib.logInfo("listenPVPGYMMessage self.platformUserId = ", self.platformUserId)
    if playerId ~= self.platformUserId then
      local pvpRank = self:getPVPRank(gym_id)
      Lib.logInfo("listenPVPGYMMessage pvpRank = ", pvpRank)
      if pvpRank and 0 < pvpRank or self:getGymChallengeId() == challengeId then
        Lib.logInfo("listenPVPGYMMessage checkPVPGymStatus self.platformUserId = ", self.platformUserId)
        self:checkPVPGymStatus(gym_id, challengeId, rank, playerName)
      end
    end
  end
end
