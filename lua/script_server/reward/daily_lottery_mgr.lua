local DailyLotteryConfig = T(Config, "DailyLotteryConfig")

function DailyLotteryMgr:init()
  Lib.subscribeEvent(Event.EVENT_CONSUME_DIAMONDS, function(pagram)
    DailyLotteryMgr:onConsumeDiamonds(pagram.objID, pagram.count)
  end)
end

function DailyLotteryMgr:onConsumeDiamonds(objID, count)
  if count <= 0 then
    return
  end
  local player = World.CurWorld:getObject(objID)
  if not player or not player:isValid() then
    return
  end
  local lotteryData = player:getCurLotteryInfo()
  if World.cfg.isCloseLotteryEntrance then
    local curPickList = lotteryData.curPickList or {}
    local curlotteryNum = lotteryData and lotteryData.curLotteryNum or 0
    if #curPickList <= 3 and curlotteryNum <= 0 then
      return
    end
  end
  local curCircle = lotteryData and lotteryData.curLotteryCircle or 1
  local maxCircle = DailyLotteryConfig:getMaxCircle()
  if curCircle > maxCircle then
    return
  end
  local lastAddTime = player:getLastAddLotteryChanceTime()
  local curTime = os.time()
  if 0 < lastAddTime and curTime - lastAddTime <= World.cfg.dailyLotteryRTInterval * 60 * 60 then
    return
  end
  player:setLastAddLotteryChanceTime(curTime)
  local curLotteryNum = lotteryData and lotteryData.curLotteryNum or 0
  curLotteryNum = curLotteryNum + 1
  lotteryData.curLotteryNum = curLotteryNum
  player:setCurLotteryInfo(lotteryData)
end

function DailyLotteryMgr:countdownBegin()
  local remainTime = DailyLotteryMgr:calNextRefreshTime()
  local curTime = os.time()
  if remainTime <= 0 then
    for _, player in pairs(Game.GetAllPlayers()) do
      if player and not player.removed then
        player:setLastAddLotteryChanceTime(0)
        player:setLastLotteryResetTime(curTime)
      end
    end
  end
end

function DailyLotteryMgr:calNextRefreshTime()
  local curServertime = os.time()
  local tbTime = Lib.getFormatDateTime(curServertime)
  local refreshDay = tbTime.day
  local refreshMonth = tbTime.month
  local refreshyear = tbTime.year
  local refreshHour = tbTime.hour
  local refreshMinute = tbTime.minute
  local refreshSecond = tbTime.second
  local dailyLotteryRT = World.cfg.dailyLotteryRT
  if tbTime.hour > dailyLotteryRT.hour and tbTime.hour < 24 or tbTime.hour == dailyLotteryRT.hour and tbTime.minute > dailyLotteryRT.minute and tbTime.hour < 24 or tbTime.hour == dailyLotteryRT.hour and tbTime.minute == dailyLotteryRT.minute and tbTime.second > dailyLotteryRT.second and tbTime.hour < 24 then
    refreshDay = refreshDay + 1
    local days = os.date("%d", os.time({
      year = os.date("%Y"),
      month = tbTime.month + 1,
      day = 0
    }))
    if tonumber(refreshDay > tonumber(days)) then
      refreshDay = 1
      refreshMonth = refreshMonth + 1
      if tonumber(refreshMonth) > 12 then
        refreshDay = 1
        refreshMonth = 1
        refreshyear = refreshyear + 1
      end
    end
  end
  refreshHour = dailyLotteryRT.hour
  refreshMinute = dailyLotteryRT.minute
  refreshSecond = dailyLotteryRT.second
  local refreshTime = os.time({
    year = refreshyear,
    month = refreshMonth,
    day = refreshDay,
    hour = refreshHour,
    min = refreshMinute,
    sec = refreshSecond
  })
  local remainTime = refreshTime - curServertime
  return remainTime
end

function DailyLotteryMgr:doDailyLottery(player)
  local lotteryData = player:getCurLotteryInfo() or {}
  local curCircle = lotteryData and lotteryData.curLotteryCircle or 1
  local curLotteryNum = lotteryData and lotteryData.curLotteryNum or 0
  if curLotteryNum <= 0 then
    return
  end
  local maxCircle = DailyLotteryConfig:getMaxCircle()
  if curCircle > maxCircle then
    return
  end
  local tbLotteryPool = {}
  local cfg = DailyLotteryConfig:getConfigById(curCircle)
  local ablePickList = {}
  for i = 1, World.cfg.dailyLotteryMaxItemNum do
    local curPickList = lotteryData and lotteryData.curPickList and lotteryData.curPickList or {}
    local isCanPick = true
    for j = 1, #curPickList do
      if i == lotteryData.curPickList[j] then
        isCanPick = false
      end
    end
    if isCanPick then
      table.insert(ablePickList, i)
      table.insert(tbLotteryPool, {
        index = i,
        weight = cfg.items[i].weight
      })
    end
  end
  local result = Lib.randomItemByWeight(1, tbLotteryPool, false)
  if not (result and result[1].index) or not cfg.items[result[1].index] then
    return
  end
  if cfg.items[result[1].index].type == 1 then
    local itemFullName = cfg.items[result[1].index].fullName
    local itemNum = cfg.items[result[1].index].itemNum
    local items = {}
    items[itemFullName] = itemNum
    local isPutBag = player:determineBackpackCapacity(items)
    if not isPutBag then
      player:sendPacket({
        pid = "showCommonTips",
        message = "gui_bag_not_enough",
        time = 40
      })
      return
    end
    player:obtainItemsByFullName(itemFullName, itemNum, "dailyLotteryRewards")
  elseif cfg.items[result[1].index].type == 2 and cfg.items[result[1].index].petId then
    player:randomPokemon(cfg.items[result[1].index].petId)
  end
  if not lotteryData.curPickList then
    lotteryData.curPickList = {}
  end
  local curCrlcle = curCircle
  local curPickList = lotteryData.curPickList
  curLotteryNum = curLotteryNum - 1
  lotteryData.curLotteryNum = curLotteryNum
  table.insert(lotteryData.curPickList, result[1].index)
  local tbPickList = {}
  for _, index in pairs(lotteryData.curPickList) do
    tbPickList[index] = true
  end
  local count = 0
  for i, v in pairs(tbPickList) do
    if v then
      count = count + 1
    end
  end
  if count >= World.cfg.dailyLotteryMaxItemNum then
    curCircle = curCircle + 1
    lotteryData.curLotteryCircle = curCircle
    lotteryData.curPickList = {}
  end
  player:setCurLotteryInfo(lotteryData)
  player:sendPacket({
    pid = "responeDoDailyLottery",
    objID = player.objID,
    itemIndex = result[1].index,
    curCrlcle = curCrlcle,
    curPickList = curPickList
  })
end

local function getSecondByTime(time)
  return time.hour * 3600 + time.minute * 60 + time.second
end

function DailyLotteryMgr:onPlayerLogin(player)
  local lastTime = player:getLastLotteryResetTime()
  Lib.logInfo("DailyLotteryMgr.onPlayerLogin:", player.name, player.platformUserId, player.objID, lastTime)
  local curTime = os.time()
  local tbServerTime = Lib.getFormatDateTime(curTime)
  local oldRefreshTime = Lib.getFormatDateTime(lastTime)
  local isRefresh = false
  Lib.logInfo("DailyLotteryMgr.onPlayerLogin-timeInfo:", curTime - lastTime, Lib.v2s(tbServerTime), Lib.v2s(oldRefreshTime))
  if World.cfg.dailyLotteryRT and oldRefreshTime then
    if oldRefreshTime.year ~= tbServerTime.year or oldRefreshTime.month ~= tbServerTime.month or oldRefreshTime.day ~= tbServerTime.day then
      if curTime - lastTime < 86400 then
        Lib.logInfo("DailyLotteryMgr.onPlayerLogin-timeInfo-1:", getSecondByTime(tbServerTime), getSecondByTime(World.cfg.dailyLotteryRT))
        if getSecondByTime(tbServerTime) > getSecondByTime(World.cfg.dailyLotteryRT) then
          isRefresh = true
        end
      else
        isRefresh = true
      end
    else
      Lib.logInfo("DailyLotteryMgr.onPlayerLogin-timeInfo-2:", getSecondByTime(tbServerTime), getSecondByTime(World.cfg.dailyLotteryRT), getSecondByTime(oldRefreshTime))
      if getSecondByTime(oldRefreshTime) < getSecondByTime(World.cfg.dailyLotteryRT) and getSecondByTime(tbServerTime) > getSecondByTime(World.cfg.dailyLotteryRT) then
        isRefresh = true
      end
    end
  end
  Lib.logInfo("DailyLotteryMgr.onPlayerLogin--result:", player.name, player.platformUserId, player.objID, isRefresh)
  if isRefresh then
    player:setLastLotteryResetTime(curTime)
    player:setLastAddLotteryChanceTime(0)
  end
end

return DailyLotteryMgr
