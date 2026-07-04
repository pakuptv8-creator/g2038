local MustWinLotteryConfig = T(Config, "MustWinLotteryConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local Player = _ENV.Player

function Player:playMustWinLottery(params)
  if self.inPlayMustWinLottery then
    return
  end
  if not params or not params.id then
    return
  end
  local mustWinLotteryData = self:getMustWinLotteryData()
  if not mustWinLotteryData[params.id] then
    mustWinLotteryData[params.id] = {}
  end
  local completeNumber = #mustWinLotteryData[params.id]
  local info = MustWinLotteryConfig:getCfgByCount(completeNumber + 1)
  if not info or not info.price then
    return
  end
  if not Lib.checkMoney(Me, 0, info.price, true) then
    LimitedTimeActivityGameMgr:showBuyFailTip()
    return
  end
  self.inPlayMustWinLottery = true
  Me:sendPacket({
    pid = "PlayMustWinLottery",
    id = params.id
  })
end

function Player:playLimitedTimeDraw(params)
  if self.inPlayLimitedTimeDraw then
    return
  end
  if not (params and params.luckyDrawType and params.id) or not params.price then
    return
  end
  if not Lib.checkMoney(Me, 0, params.price, true) then
    LimitedTimeActivityGameMgr:showBuyFailTip()
    return
  end
  if not LimitedTimeActivityGameMgr:checkDrawContent(params.luckyDrawType) then
    return
  end
  self.inPlayLimitedTimeDraw = true
  Me:sendPacket({
    pid = "PlayLimitedTimeDraw",
    params = params
  })
end

function Player:playLimitedTimeCard(params)
  if self.inPlayLimitedTimeCard then
    return
  end
  if not (params and params.cardType and params.id) or not params.price then
    return
  end
  if not Lib.checkMoney(Me, 0, params.price, true) then
    LimitedTimeActivityGameMgr:showBuyFailTip()
    return
  end
  self.inPlayLimitedTimeCard = true
  Me:sendPacket({
    pid = "PlayLimitedTimeCard",
    params = params
  })
end

function Player:playUiSoundByKey(key)
  local sound = World.cfg.limited_time_activitySetting[key]
  if sound then
    if not self.curUiSoundIds then
      self.curUiSoundIds = {}
    end
    self.curUiSoundIds[key] = Me:playSound(sound)
  end
end

function Player:stopUiSoundByKey(key)
  if self.curUiSoundIds[key] then
    Me:stopSound(self.curUiSoundIds[key])
  end
end

function Player:clientBuyLimitTimeWeekGift(data)
  if self.isLimitWeekGiftPlaying then
    return
  end
  if not data then
    return
  end
  if Lib.checkMoney(Me, 0, data.finalPrice, true) then
    Me:sendPacket({
      pid = "CSBuyLimitTimeWeekGift",
      activityId = data.activityId,
      id = data.id
    })
    self.isLimitWeekGiftPlaying = true
  else
    LimitedTimeActivityGameMgr:showBuyFailTip()
  end
end

function Player:clientBuyLimitTimeMonthGift(data)
  if self.isLimitMonthGiftPlaying then
    return
  end
  if not data then
    return
  end
  if Lib.checkMoney(Me, 0, data.finalPrice, true) then
    Me:sendPacket({
      pid = "CSBuyLimitTimeMonthGift",
      activityId = data.activityId,
      id = data.id
    })
    self.isLimitMonthGiftPlaying = true
  else
    LimitedTimeActivityGameMgr:showBuyFailTip()
  end
end

function Player:clientBuyLimitDiscountGift(data)
  if self.isLimitDiscountGiftPlaying then
    return
  end
  if not data then
    return
  end
  if Lib.checkMoney(Me, 0, data.finalPrice, true) then
    Me:sendPacket({
      pid = "CSBuyLimitTimeDiscountGift",
      activityId = data.activityId,
      id = data.id
    })
    self.isLimitDiscountGiftPlaying = true
  else
    LimitedTimeActivityGameMgr:showBuyFailTip()
  end
end

function Player:showCombinedLimitTimeCardRewards()
  if not self.inShowLimitedTimeActivityAwardPopup and self.combinedLimitTimeCardRewards and self.combinedLimitTimeCardRewards[1] then
    local cardType = self.combinedLimitTimeCardRewards[1].item.cardType
    UI:openWnd("limitedTimeActivityAwardPopup", self.combinedLimitTimeCardRewards[1], "gui.limit.time.card.congratulations" .. cardType)
    table.remove(self.combinedLimitTimeCardRewards, 1)
  end
end

function Player:clientBuyLimitOptionalGift(data)
  if self.isLimitOptionalGiftPlaying then
    return
  end
  if self.isLimitOptionalGiftCustom then
    return
  end
  if not data then
    return
  end
  local optionalData = Me:getLimitedTimeOptionalData()
  local optionalBuy = Me:getLimitedTimeOptionalBuy()
  if optionalData[data.giftKey] and #optionalData[data.giftKey] < data.optionalNum then
    Client.ShowTip(1, Lang:toText("gui.limit.time.buy.fail"), 40)
    return
  end
  if data.limitCounts > 0 and optionalBuy[data.giftKey] and optionalBuy[data.giftKey] >= data.limitCounts then
    Client.ShowTip(1, Lang:toText("gui.limit.time.buy.fail"), 40)
    return
  end
  if 0 < data.limitDayNum and optionalBuy[data.giftKey] and optionalBuy[data.giftKey] >= data.limitDayNum then
    Client.ShowTip(1, Lang:toText("gui.limit.time.buy.fail"), 40)
    return
  end
  if Lib.checkMoney(Me, 0, data.finalPrice, true) then
    Me:sendPacket({
      pid = "CSBuyLimitTimeOptionalGift",
      activityId = data.activityId,
      id = data.id
    })
    self.isLimitOptionalGiftPlaying = true
  else
    LimitedTimeActivityGameMgr:showBuyFailTip()
  end
end

function Player:playLimitedTimeGoldWheel(params)
  if self.inPlayLimitedTimeGoldWheel then
    return
  end
  if not (params and params.id) or not params.price then
    return
  end
  if not Lib.checkMoney(Me, 0, params.price, true) then
    LimitedTimeActivityGameMgr:showBuyFailTip()
    return
  end
  self.inPlayLimitedTimeGoldWheel = true
  Me:sendPacket({
    pid = "PlayLimitedTimeGoldWheel",
    params = params
  })
end

function Player:clientReceiveHeartWarm(data)
  if self.isHeartWarmingPlaying then
    return
  end
  if not data then
    return
  end
  self.isHeartWarmingPlaying = true
  Me:sendPacket({
    pid = "CSReceiveHeartWarm",
    activityId = data.activityId,
    taskId = data.taskId,
    giftId = data.giftId
  })
  if data.taskId == nil then
    local reportData = {
      d3_gift_id = data.giftId
    }
    Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_event_receive", reportData, Me)
  else
    local reportData = {
      d3_task_id = data.taskId
    }
    Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_task_receive", reportData, Me)
  end
end

function Player:clientHeartWarmAddFriend(targetUserId)
  Me:sendPacket({
    pid = "CSHeartWarmAddFriend",
    targetUserId = targetUserId
  })
end

local HeartWarmingTaskConfig = T(Config, "HeartWarmingTaskConfig")

function Player:clientHeartWarmGoTo(taskId)
  local taskCfg = HeartWarmingTaskConfig:getCfgById(taskId)
  if taskCfg.taskDesc ~= "" then
    UI:getWnd("commonDialog"):onShow(true, {
      title = "g2052.gui.tendering.tips",
      desc = taskCfg.taskDesc
    })
  end
  local reportData = {d3_task_id = taskId}
  Plugins.CallTargetPluginFunc("report", "report", "g2052_3d_task_guide", reportData, Me)
  if taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.ADD_FRIEND then
    Plugins.CallTargetPluginFunc("friend", "openCloseFriendWnd", true)
  elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.PROFESSION then
    UI:openWnd("professionWnd")
  elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.CHANGE_DRESS then
    UI:openWnd("role")
  elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.NEW_HOUSE then
    local isHasHouse, houseInfo = Me:doIOwnAHouse()
    if isHasHouse then
      Me:sendPacket({
        pid = "clientInitiatesTransfer",
        params = houseInfo.initPosInfo
      })
    else
      local houseInfo = Me.allHouseInfo
      local index = Me:getFirstVacantHouseIndex()
      Me:sendPacket({
        pid = "clientInitiatesTransfer",
        params = houseInfo[index].initPosInfo,
        transportInfo = {
          type = Define.TRANSPORT_TYPE.HOUSE,
          id = houseInfo[index].id
        }
      })
    end
  elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.CAR_OTHERS or taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.GIFT_OTHERS or taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.FIRE_HOUSE or taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.PUT_OUT_FIRE then
    local targetItemId = 1032
    if taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.GIFT_OTHERS then
      targetItemId = 1045
    elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.FIRE_HOUSE then
      targetItemId = 1601
    elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.PUT_OUT_FIRE then
      targetItemId = 1021
      Me:clientSetProfession(Define.CareerType.Fireman)
    end
    local handBagInfo = Me:getHandbagsInfo()
    for i, v in pairs(handBagInfo) do
      if targetItemId == v.itemId then
        if not v.inUse then
          Me:sendPacket({
            pid = "SwitchHandItem",
            slot = i
          })
        end
        return
      end
    end
    local data = {id = targetItemId}
    Me:selectPropLogic(data)
  elseif taskCfg.taskType == Define.HEART_WARM_TASK_TYPE.POLICE_LOCK then
    Me:clientSetProfession(Define.CareerType.Police)
  end
end
