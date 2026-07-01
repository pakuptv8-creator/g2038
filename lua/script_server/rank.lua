local GymDefaultRankConfig = T(Config, "GymDefaultRankConfig")
local RedisHandler = require("script_server.redishandler")
local DBHandler = require("dbhandler")
local tunpack = table.unpack
local tonumber = _ENV.tonumber
local pairs = _ENV.pairs
local self = Rank

function Rank.Init()
  local rankDatas = {}
  local rankTypes = {}
  local curTime = os.time()
  for _, rankCfg in pairs(World.cfg.ranks or {}) do
    local rankType = rankCfg.type or 0
    rankDatas[rankType] = {}
    for subId, cfg in pairs(rankCfg.subRanks) do
      rankDatas[rankType][subId] = {}
      for i = 0, World.cfg.maxRankLength do
        local key = Rank.getRankKey(curTime, rankType, subId, i)
        rankTypes[key] = {
          rankType,
          subId,
          i
        }
        rankDatas[rankType][subId][i] = {}
        local expireTime = Rank.getRankExpireTime(curTime, rankType, subId)
        if expireTime then
          if subId == Define.RANK_SUB_TYPE.POWER then
            RedisHandler:ZExpireat(key, expireTime)
          else
            RedisHandler:HExpireat(key, expireTime)
          end
        end
      end
    end
  end
  self.rankDatas = rankDatas
  self.rankTypes = rankTypes
  self.rankDirtyTimes = {}
end

function Rank.getRankKey(curTime, rankType, subId, index)
  local cfg = Rank.GetSubRankCfgs(rankType)[subId]
  local suffix = ""
  local sufType = cfg.keySufType
  if sufType == "CurMin" then
    suffix = ".min." .. Lib.getMinStartTime(curTime)
  elseif sufType == "CurHour" then
    suffix = ".hour." .. Lib.getHourStartTime(curTime)
  elseif sufType == "LastDay" then
    suffix = ".day." .. Lib.getDayStartTime(curTime - 86400)
  elseif sufType == "CurDay" then
    suffix = ".day." .. Lib.getDayStartTime(curTime)
  elseif sufType == "LastWeek" then
    suffix = ".week." .. Lib.getWeekStartTime(curTime - 604800)
  elseif sufType == "CurWeek" then
    suffix = ".week." .. Lib.getWeekStartTime(curTime)
  elseif sufType == "LastMonth" then
    suffix = ".month." .. Lib.getMonthStartTime(Lib.getMonthEndTime(curTime) + 1)
  elseif sufType == "CurMonth" then
    suffix = ".month." .. Lib.getMonthStartTime(curTime)
  elseif sufType == "Hist" then
    suffix = ".hist"
  end
  local version = ""
  local roomGameConfig = Server.CurServer:getConfig()
  if roomGameConfig:isDebug() then
    version = "debug"
  else
    version = "release"
  end
  return Lib.getLangCode(rankType) .. "." .. cfg.keyPrefix .. suffix .. "." .. index .. "." .. version
end

function Rank.getRankExpireTime(curTime, rankType, subId)
  local cfg = Rank.GetSubRankCfgs(rankType)[subId]
  local expireTime
  local expireType = cfg.expireType
  if expireType == "NextMin" then
    expireTime = Lib.getMinEndTime(curTime + 60)
  elseif expireType == "NextHour" then
    expireTime = Lib.getHourEndTime(curTime + 3600)
  elseif expireType == "CurDay" then
    expireTime = Lib.getDayEndTime(curTime)
  elseif expireType == "NextDay" then
    expireTime = Lib.getDayEndTime(curTime + 86400)
  elseif expireType == "CurWeek" then
    expireTime = Lib.getWeekEndTime(curTime)
  elseif expireType == "NextWeek" then
    expireTime = Lib.getWeekEndTime(curTime + 604800)
  elseif expireType == "CurMonth" then
    expireTime = Lib.getMonthEndTime(curTime)
  elseif expireType == "NextMonth" then
    expireTime = Lib.getMonthEndTime(Lib.getMonthEndTime(curTime) + 1)
  elseif expireType == "Hist" then
    expireTime = false
  end
  return expireTime
end

function Rank.GetSubRankCfgs(rankType)
  for _, cfg in pairs(World.cfg.ranks or {}) do
    if (cfg.type or 0) == rankType then
      return cfg.subRanks
    end
  end
end

function Rank.GetSubRankCfg(rankType, subId)
  local cfgs = Rank.GetSubRankCfgs(rankType)
  return cfgs and cfgs[subId] or nil
end

function Rank.GetRankType(key)
  local typeInfo = self.rankTypes[key]
  if not typeInfo then
    return
  end
  return tunpack(typeInfo)
end

function Rank.UserUpdateGym(rankType, subId, index, lastMember, member, rank, score, callback)
  local cfgs = Rank.GetSubRankCfgs(rankType)
  if not cfgs then
    return
  end
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  local data = {
    key = key,
    lastMember = lastMember,
    member = member,
    rank = rank,
    score = score
  }
  AsyncProcess.RequestHSet(key, data, function(isSucceed)
    if isSucceed then
      if callback then
        callback(true)
      end
    elseif callback then
      callback(false)
    end
  end)
end

function Rank.RequestRankData(rankType, subId, rankIndex, callback)
  local cfgs = Rank.GetSubRankCfgs(rankType)
  if not cfgs then
    return
  end
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, rankIndex)
  Lib.logDebug("RequestRankData key = ", key)
  if subId == Define.RANK_SUB_TYPE.POWER then
    AsyncProcess.RequestSpecificRankRange(key, cfgs[subId].size or 10, function(isSucceed)
      if callback then
        callback()
      end
    end)
  else
    AsyncProcess.RequestHGetAll(key, function(isSucceed)
      if isSucceed then
        if callback then
          callback()
        end
      else
        Lib.logError("hgetall key has not data = ", key)
      end
    end)
  end
end

function Rank.ReceiveLastWeekRankData(userId, key, rankDataStr)
  Lib.logInfo("ReceiveLastWeekRankData userId, key, rankDataStr = ", userId, key, rankDataStr)
  local split = Lib.splitString
  for _, data in pairs(split(rankDataStr, "#")) do
    local info = split(data, ":")
    if not (#info < 3) then
      Lib.logInfo("ReceiveLastWeekRankData info = ", Lib.v2s(info))
      local _userRank = tonumber(info[1])
      local _userId = tonumber(info[2])
      local _userScore = tonumber(info[3])
      if _userId == tonumber(userId) then
        Lib.logInfo("ReceiveLastWeekUserRankInfo userId and userRank = ", userId, _userRank)
        Rank.ReceiveLastWeekUserRankInfo(tonumber(userId), key, _userScore, _userRank)
      end
    end
  end
end

function Rank.ReceiveRankData(key, rankDataStr)
  local rankType, subId, index = Rank.GetRankType(key)
  if not rankType then
    print("Rank.ReceiveRankData unknow data", key, rankDataStr)
    return
  end
  local curTime = os.time()
  local checkKey = Rank.getRankKey(curTime, rankType, subId, index)
  if checkKey ~= key then
    print("Rank.ReceiveRankData key not match", key, checkKey, rankDataStr)
    return
  end
  local cfg = Rank.GetSubRankCfg(rankType, subId)
  local orderByDesc = cfg.orderByDesc
  local rankData = self.rankDatas[rankType]
  local subRanks = {}
  local ranks = {}
  local userIds = {}
  local split = Lib.splitString
  if subId == Define.RANK_SUB_TYPE.POWER then
    for i, data in pairs(split(rankDataStr, "#")) do
      local info = split(data, ":")
      if not (#info < 2) then
        local userId = tonumber(info[1])
        local userScore = tonumber(info[2])
        local userName = "anonymous_" .. info[1]
        local rank = {
          rank = i,
          userId = userId,
          score = userScore,
          vip = 0,
          name = userScore,
          isnpc = false
        }
        if orderByDesc then
          rank.score = -rank.score
        end
        local cache
        cache = UserInfoCache.GetCache(userId)
        if cache then
          rank.vip = cache.vip
          rank.name = cache.name
        else
          userIds[#userIds + 1] = userId
        end
        ranks[#ranks + 1] = rank
      end
    end
  else
    local default_ranks = {
      0,
      0,
      0,
      0,
      0,
      0,
      0
    }
    for _, data in pairs(split(rankDataStr, "#")) do
      local info = split(data, ":")
      if not (#info < 3) then
        Lib.logDebug("info = ", Lib.v2s(info))
        local userRank = tonumber(info[1])
        local userId = tonumber(info[2])
        local userScore = tonumber(info[3])
        local userName = "anonymous_" .. info[2]
        local rankData = {
          rank = userRank,
          userId = userId,
          score = userScore,
          vip = 0,
          name = userName,
          isnpc = false
        }
        if orderByDesc then
          rankData.score = -rankData.score
        end
        local cache
        cache = UserInfoCache.GetCache(userId)
        if cache then
          rankData.vip = cache.vip
          rankData.name = cache.name
        else
          userIds[#userIds + 1] = userId
        end
        Lib.logDebug("rankData = ", Lib.v2s(rankData))
        ranks[userRank] = rankData
        default_ranks[userRank] = 1
      end
    end
    for i = 1, #default_ranks do
      local default_rank = default_ranks[i]
      if default_rank == 0 then
        local npc_rank_data = GymDefaultRankConfig:getNpc(subId, i)
        if npc_rank_data then
          local userRank = npc_rank_data.rank
          local userId = npc_rank_data.npc_id
          local userScore = npc_rank_data.score
          local userName = npc_rank_data.name
          local rankData = {
            rank = userRank,
            userId = userId,
            score = userScore,
            vip = 0,
            name = userName,
            isnpc = true
          }
          if orderByDesc then
            rankData.score = -rankData.score
          end
          ranks[i] = rankData
        end
      end
    end
  end
  self.rankDatas[rankType][subId][index] = ranks
  AsyncProcess.RankLoadPlayersInfo(userIds, rankType, subId, index)
end

function Rank.UpdatePlayerInfo(playerInfos, rankType, subId, index)
  if not (self.rankDatas[rankType] and self.rankDatas[rankType][subId]) or not self.rankDatas[rankType][subId][index] then
    print("Rank.UpdatePlayerGameInfo sub rank not exist", rankType, subId, index)
    return
  end
  local subRank = self.rankDatas[rankType][subId][index]
  for _, rank in pairs(subRank) do
    local info = playerInfos[rank.userId]
    if info then
      rank.vip = info.vip
      rank.name = info.name
    end
  end
end

function Rank.GetRankData(rankType)
  return self.rankDatas[rankType]
end

function Rank.GetSubRankData(rankType, subId, rankIndex, callback)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, rankIndex)
  local dirtyTime = self.rankDirtyTimes[key]
  if not dirtyTime then
    local expireTime = curTime + World.cfg.rankRefreshTime
    self.rankDirtyTimes[key] = expireTime
    Rank.RequestRankData(rankType, subId, rankIndex, function()
      if callback then
        callback(self.rankDatas[rankType][subId][rankIndex])
      end
    end)
  elseif 0 < curTime - dirtyTime then
    Lib.logDebug("dirtyTime expire get data from redis curTime and dirtyTime = ", curTime, dirtyTime)
    local expireTime = curTime + World.cfg.rankRefreshTime
    self.rankDirtyTimes[key] = expireTime
    Rank.RequestRankData(rankType, subId, rankIndex, function()
      if callback then
        callback(self.rankDatas[rankType][subId][rankIndex])
      end
    end)
  else
    Lib.logDebug("use cached data")
    if callback then
      callback(self.rankDatas[rankType][subId][rankIndex])
    end
  end
end

function Rank.GetSpecificRankData(rankType, subId, index)
  return self.rankDatas[rankType][subId][index]
end

function Rank.UserUpdateScore(userId, rankType, subId, index, score)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  RedisHandler:ZAdd(key, tostring(userId), score)
end

function Rank.UserAddScore(userId, rankType, subId, index, score, immediatly)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  RedisHandler:ZIncrBy(key, tostring(userId), score, immediatly)
end

function Rank.removeFromRank(userId, rankType, subId, index, immediately)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  RedisHandler:ZRemove(key, tostring(userId), immediately)
end

function Rank.RequestUserRankInfo(userId, rankType, subId, index)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime, rankType, subId, index)
  AsyncProcess.RequestPlayerRankInfo(userId, key)
end

function Rank.RequestLastWeekUserRankInfo(userId, rankType, subId, rankIndex)
  Lib.logInfo("RequestLastWeekUserRankInfo userId, rankType, subId, rankIndex = ", userId, rankType, subId, rankIndex)
  local curTime = os.time()
  local key = Rank.getRankKey(curTime - 604800, rankType, subId, rankIndex)
  Lib.logInfo("RequestLastWeekUserRankInfo key = ", key)
  if subId == Define.RANK_SUB_TYPE.POWER then
    Lib.logInfo("call RequestLastWeekPlayerRankInfo userId and key = ", userId, key)
    AsyncProcess.RequestLastWeekPlayerRankInfo(userId, key)
  else
    Lib.logInfo("call RequestLastWeekGymPlayerRankInfo userId and key = ", userId, key)
    AsyncProcess.RequestLastWeekGymPlayerRankInfo(userId, key)
  end
end

function Rank.ReceiveUserRankInfo(userId, key, score, rank)
  local player = Game.GetPlayerByUserId(userId)
  if not player then
    print("Rank.ReceiveUserRankInfo cannot find player by userId", userId, key, score, rank)
    return
  end
  local rankType, subId, index = Rank.GetRankType(key)
  if not rankType then
    print("Rank.ReceiveUserRankInfo cannot find rank type by key", userId, key, score, rank)
    return
  end
  local curTime = os.time()
  local checkKey = Rank.getRankKey(curTime, rankType, subId, index)
  if checkKey ~= key then
    print("Rank.ReceiveUserRankInfo key not match", userId, key, checkKey, score, rank)
    return
  end
  player:receiveRankInfo(rankType, subId, index, rank, score)
end

function Rank.ReceiveLastWeekUserRankInfo(userId, key, score, rank)
  Lib.logDebug("Rank.ReceiveLastWeekUserRankInfo = ", userId, key, score, rank)
  local player = Game.GetPlayerByUserId(userId)
  if not player then
    print("Rank.ReceiveUserRankInfo cannot find player by userId", userId, key, score, rank)
    return
  end
  if score ~= 0 then
    player:receiveLastWeekRankInfo(key, score, rank)
  end
end

function Rank.RequestRankCounter(userId, key)
  Lib.logDebug("Rank.RequestRankCounter userId and  key = ", userId, key)
  AsyncProcess.RequestRankCounter(userId, key)
end

function Rank.ReceiveRankCounter(userId, key, counter)
  Lib.logDebug("Rank.ReceiveRankCounter userId and key and counter = ", userId, key, counter)
  local player = Game.GetPlayerByUserId(userId)
  if not player then
    print("Rank.ReceiveRankCounter cannot find player by userId", userId, key, counter)
    return
  end
  local rankIndex = counter % World.cfg.maxRankLength
  if rankIndex == 0 then
    rankIndex = 1
  end
  Lib.logDebug("Rank.ReceiveRankIndex rankIndex = ", rankIndex)
  player:setRankIndex(rankIndex)
end

function Rank.ResetRankCounter(keys)
  AsyncProcess.ResetRankCounter(keys)
end

function Rank.ReceiveResetRankCounter(key, counter)
  Lib.logDebug("Rank.ReceiveResetRankCounter key and counter = ", key, counter)
end
