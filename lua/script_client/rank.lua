local self = Rank
local needReq = {}

function Rank.Init()
  self.rankDatas = {}
  self.myRanks = {}
  self.myScores = {}
end

function Rank.RequestRankData(mainType, subId)
  Lib.logDebug("RequestRankData subId = ", subId)
  local CurPlayer = Player.CurPlayer
  if not CurPlayer then
    return
  end
  CurPlayer:sendPacket({pid = "RankData", rankType = subId})
end

function Rank.RequestPlayerRank(rankType, subId)
  local CurPlayer = Player.CurPlayer
  if not CurPlayer then
    return
  end
  CurPlayer:sendPacket({
    pid = "RequestPlayerRank",
    rankType = rankType,
    subId = subId
  })
end

function Rank.ReceiveRankData(packet)
  local rankType = packet.rankType
  local subId = packet.subId
  local rankIndex = packet.rankIndex
  self.rankDatas[subId] = packet.rankDatas
  Lib.emitEvent(Event.EVENT_RECEIVE_RANK_DATA, subId)
end

function Rank.GetRankData(subId)
  return self.rankDatas[subId] or {}
end

function Rank.GetMyRanks(subId)
  return self.myRanks[subId] or {}
end

function Rank.GetMyScores(subId)
  return self.myScores[subId] or {}
end

function Rank.RankDataDirty(subId)
  needReq[subId] = true
  Lib.logDebug("send EVENT_RANK_DATA_DIRTY subId = ", subId)
  Lib.emitEvent(Event.EVENT_RANK_DATA_DIRTY, subId)
end

function Rank.NeedReq(subId)
  return needReq[subId] ~= false
end
