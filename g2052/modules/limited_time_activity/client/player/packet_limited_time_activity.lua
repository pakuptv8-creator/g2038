local handles = T(Player, "PackageHandlers")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local FacePhotoHelper = T(Lib, "FacePhotoHelper")
local HeartWarmingGiftConfig = T(Config, "HeartWarmingGiftConfig")

function handles:SyncCombinationLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT, packet.status, packet.params)
  local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
  LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(isOpen)
  LimitedTimeActivityGameMgr:updateCombinedLimitBtnRedDot(isOpen)
end

function handles:SyncCombinationLimitTimeResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
end

function handles:SyncSignalLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT, packet.status, packet.params)
  local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT)
  LimitedTimeActivityGameMgr:updateSignalLimitBtnShow(isOpen)
  LimitedTimeActivityGameMgr:updateSignalLimitBtnRedDot(isOpen)
end

function handles:SyncSignalLimitTimeResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
end

function handles:SCLimitTimeItemBoughtResult(packet)
  LimitedTimeActivityGameMgr:showBoughtResultTips(packet)
  Lib.emitEvent(Event.EVENT_LIMITED_TIME_BUY_RESULT, false)
  self.isLimitWeekGiftPlaying = false
  self.isLimitMonthGiftPlaying = false
  self.isLimitDiscountGiftPlaying = false
  self.isLimitOptionalGiftPlaying = false
end

function handles:SyncMustWinLotteryActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
  FacePhotoHelper:checkOpenFaceWnd()
end

function handles:SyncPlayMustWinLotteryResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    if UI:isOpen("limitedTimeActivityWnd") then
      Lib.emitEvent(Event.EVENT_PLAY_MUST_WIN_LOTTERY_RESULT, addition)
    else
      UI:openWnd("limitedTimeActivityAwardPopup", addition)
    end
    LimitedTimeActivityGameMgr:showPlayMustWinLotterySuccess()
  end
  self.inPlayMustWinLottery = false
end

function handles:SyncMonthLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT)
end

function handles:SyncWeekLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT)
end

function handles:SyncLimitedTimeDrawActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_DRAW)
end

function handles:SyncLimitedTimeCardActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_CARD)
end

function handles:SyncLimitedTimeGoldWheelActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.LIMITED_TIME_GOLD_WHEEL)
end

function handles:SyncPlayLimitedTimeDrawResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.inPlayLimitedTimeDraw = false
end

function handles:SyncPlayLimitedTimeCardResult(packet)
  self.inPlayLimitedTimeCard = false
end

function handles:SyncPlayLimitedTimeGoldWheelResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    local wnd = UI:getWnd("limitedTimeGoldWheel")
    if wnd.isOpen then
      Lib.emitEvent(Event.EVENT_GET_LIMITED_TIME_GOLD_WHEEL_RESULT, addition)
      return
    else
      UI:openWnd("limitedTimeActivityAwardPopup", addition)
    end
  end
  self.inPlayLimitedTimeGoldWheel = false
end

function handles:SyncPlayWeekLimitGiftResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    addition.showItemBg = true
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.isLimitWeekGiftPlaying = false
end

function handles:SyncPlayMonthLimitGiftResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    addition.showItemBg = true
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.isLimitMonthGiftPlaying = false
end

function handles:SyncDiscountLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT)
end

function handles:SyncPlayDiscountLimitGiftResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.isLimitDiscountGiftPlaying = false
end

function handles:SCGetLimitTimeCardReward(packet)
  local item = packet.item
  if not item then
    return
  end
  local addition = {
    item = item,
    showItemBg = true,
    isCombined = true
  }
  if self.inShowLimitedTimeActivityAwardPopup then
    if not self.combinedLimitTimeCardRewards then
      self.combinedLimitTimeCardRewards = {}
    end
    table.insert(self.combinedLimitTimeCardRewards, addition)
  else
    UI:openWnd("limitedTimeActivityAwardPopup", addition, "gui.limit.time.card.congratulations" .. item.cardType)
  end
end

function handles:SyncOptionalLimitTimeActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.OPTIONAL_GIFT, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
end

function handles:SyncPlayOptionalLimitGiftResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed then
    addition.showItemBg = true
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.isLimitOptionalGiftPlaying = false
  UI:closeWnd("limitTimeOptionalCustomWnd")
end

function handles:SyncHeartWarmGiftActivity(packet)
  LimitTimeClientHelper:updateActiveData(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT, packet.status, packet.params)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
end

function handles:SCReceiveHeartWarmResult(packet)
  local addition = packet.addition
  if addition and addition.isSucceed and addition.giftId ~= nil then
    local giftCfg = HeartWarmingGiftConfig:getCfgById(addition.giftId)
    addition.item = giftCfg
    UI:openWnd("limitedTimeActivityAwardPopup", addition)
  end
  self.isHeartWarmingPlaying = false
end
