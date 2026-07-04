local BiddingRankHelper = T(Lib, "BiddingRankHelper")

local function findIndex(rankList, mapId)
  for i, info in ipairs(rankList) do
    if info.mapId == mapId then
      return i, info
    end
  end
end

function BiddingRankHelper.resortRank(rankList, mapId, isAdd)
  local index, compareInfo = findIndex(rankList, mapId)
  local compareNum = compareInfo.likeNumber
  compareInfo.isLost = true
  local startIndex, endIndex
  if isAdd then
    startIndex = 1
    endIndex = index
  else
    startIndex = index
    endIndex = #rankList
  end
  while 0 < endIndex - startIndex do
    local halfIndex = (startIndex + endIndex) * 0.5
    if isAdd then
      halfIndex = math.floor(halfIndex)
    else
      halfIndex = math.ceil(halfIndex)
    end
    local info = rankList[halfIndex]
    if compareNum > info.likeNumber then
      if endIndex == halfIndex then
        break
      end
      endIndex = halfIndex
    elseif info.up == compareNum then
      if startIndex == halfIndex then
        break
      end
      if isAdd then
        startIndex = halfIndex
      else
        endIndex = halfIndex - 1
      end
    else
      if startIndex == halfIndex then
        break
      end
      startIndex = halfIndex
    end
  end
  if isAdd then
    for i = index, endIndex + 1, -1 do
      rankList[i] = rankList[i - 1]
      rankList[i].isLost = true
    end
    rankList[endIndex] = compareInfo
  else
    for i = index, startIndex - 1 do
      rankList[i] = rankList[i + 1]
      rankList[i].isLost = true
    end
    rankList[startIndex] = compareInfo
  end
  for i, info in ipairs(rankList) do
    info.rank = i
  end
end

function BiddingRankHelper.addRank(rankList, idList, addRankList, startIndex)
  if #rankList < startIndex - 1 then
    local n = startIndex - #rankList - 1
    local maxInfo = rankList[#rankList]
    local minInfo = addRankList[1]
    local maxUp = maxInfo and maxInfo.likeNumber or minInfo.likeNumber + n + 1
    local minUp = minInfo.likeNumber
    local delay = (maxUp - minUp) * 1.0 / n
    for i = 1, n do
      table.insert(rankList, {
        userId = "unKnow",
        likeNumber = minUp + delay * i,
        isLost = true
      })
    end
  end
  for i, info in ipairs(addRankList) do
    info.updateTime = os.time()
    rankList[startIndex + i - 1] = info
    if idList[info.mapId] then
      local oldInfo = idList[info.mapId]
      oldInfo.userId = "unKnow"
      oldInfo.mapId = nil
    end
    idList[info.mapId] = info
  end
end
