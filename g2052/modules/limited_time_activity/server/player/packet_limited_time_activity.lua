local LimitedTimeActivityConfig = T(Config, "LimitedTimeActivityConfig")
local handles = T(Player, "PackageHandlers")
local LimitedTimeOptionalGiftConfig = T(Config, "LimitedTimeOptionalGiftConfig")

function handles:CSBuyLimitCombinationGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:PlayMustWinLottery(packet)
  local id = packet.id
  if not id then
    return
  end
  local item = LimitedTimeActivityConfig:getCfgById(id)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY then
    LimitedTimeActivityMgr:playActivity(self, item)
  end
end

function handles:PlayLimitedTimeDraw(packet)
  local params = packet.params
  if not (params and params.id) or not params.luckyDrawType then
    return
  end
  local item = LimitedTimeActivityConfig:getCfgById(params.id)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW then
    LimitedTimeActivityMgr:playActivity(self, item, {
      type = params.luckyDrawType
    })
  end
end

function handles:PlayLimitedTimeCard(packet)
  local params = packet.params
  if not (params and params.id) or not params.cardType then
    return
  end
  local item = LimitedTimeActivityConfig:getCfgById(params.id)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD then
    LimitedTimeActivityMgr:playActivity(self, item, {
      type = params.cardType
    })
  end
end

function handles:PlayLimitedTimeGoldWheel(packet)
  local params = packet.params
  if not params or not params.id then
    return
  end
  local item = LimitedTimeActivityConfig:getCfgById(params.id)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL then
    LimitedTimeActivityMgr:playActivity(self, item)
  end
end

function handles:CSBuyLimitSignalGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSBuyLimitTimeWeekGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSBuyLimitTimeMonthGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSBuyLimitTimeDiscountGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSBuyLimitTimeOptionalGift(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSReceiveHeartWarm(packet)
  local item = LimitedTimeActivityConfig:getCfgById(packet.activityId)
  if item and item.type == Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT then
    LimitedTimeActivityMgr:playActivity(self, item, packet)
  end
end

function handles:CSHeartWarmAddFriend(packet)
  Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", self, Define.HEART_WARM_TASK_TYPE.ADD_FRIEND)
end

function handles:GMLimitHeartWarming(packet)
  if not World.cfg.openGM then
    return
  end
end
