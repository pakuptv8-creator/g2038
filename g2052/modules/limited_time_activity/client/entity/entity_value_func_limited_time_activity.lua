local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local FacePhotoHelper = T(Lib, "FacePhotoHelper")

function Entity.ValueFunc:combinedGiftData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_LIMITED_TIME_COMBINATION_BUY, value)
    local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.COMBINATION_GIFT)
    LimitedTimeActivityGameMgr:updateCombinedLimitBtnShow(isOpen)
  end
end

function Entity.ValueFunc:signalLimitGiftData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_LIMITED_TIME_SIGNAL_BUY, value)
    local isOpen = LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.SIGNAL_GIFT)
    LimitedTimeActivityGameMgr:updateSignalLimitBtnShow(isOpen)
  end
end

function Entity.ValueFunc:mustWinLotteryData(value)
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
end

function Entity.ValueFunc:limitedTimeWeekData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_LIMITED_TIME_WEEK_BUY, value)
    LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.WEEK_GIFT)
    self.isLimitWeekGiftPlaying = false
  end
end

function Entity.ValueFunc:limitedTimeMonthData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_LIMITED_TIME_MONTH_BUY, value)
    LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.MONTH_GIFT)
    self.isLimitMonthGiftPlaying = false
  end
end

function Entity.ValueFunc:limitedTimeWeekKey(value)
  if self.objID == Me.objID then
    UI:getWnd("limitTimeWeekWnd").initInfo = false
  end
end

function Entity.ValueFunc:limitedTimeMonthKey(value)
  if self.objID == Me.objID then
    UI:getWnd("limitTimeMonthWnd").initInfo = false
  end
end

function Entity.ValueFunc:limitedTimeDrawData(value)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_DRAW_GUARANTEE_COUNT)
end

function Entity.ValueFunc:firstPurchaseData(value)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_FIRST_PURCHASE_DATA)
end

function Entity.ValueFunc:limitedTimeCardData(value)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_CARD_INFO)
end

function Entity.ValueFunc:limitedTimeDiscountData(value)
  Lib.emitEvent(Event.EVENT_LIMITED_TIME_DISCOUNT_BUY)
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.DISCOUNT)
end

function Entity.ValueFunc:limitedTimeOptionalInfo(value)
  Lib.emitEvent(Event.EVENT_LIMITED_TIME_OPTIONAL_INFO)
  self.isLimitOptionalGiftCustom = false
end

function Entity.ValueFunc:limitedTimeOptionalBuy(value)
  Lib.emitEvent(Event.EVENT_LIMITED_TIME_OPTIONAL_INFO)
end

function Entity.ValueFunc:mustRoundFirstLogin(value)
  FacePhotoHelper:checkOpenFaceWnd()
end

function Entity.ValueFunc:heartWarmReward(value)
  Lib.emitEvent(Event.EVENT_UPDATE_LIMITED_TIME_ACTIVITY)
  LimitedTimeActivityGameMgr:updateLimitedTimeActivityBtnShow()
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
end

function Entity.ValueFunc:heartWarmTask(value)
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Lib.emitEvent(Event.EVENT_HEART_WARM_DAY_UPDATE)
  Lib.emitEvent(Event.EVENT_HEART_WARM_TASK_UPDATE)
end

function Entity.ValueFunc:heartWarmStart(value)
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Lib.emitEvent(Event.EVENT_HEART_WARM_DAY_UPDATE)
  Lib.emitEvent(Event.EVENT_HEART_WARM_TASK_UPDATE)
end

function Entity.ValueFunc:heartWarmIntegral(value)
  LimitTimeClientHelper:checkLimitedTimeActivityRedDot(Define.LIMITED_TIME_ACTIVITY_TYPE.HEART_WARM_GIFT)
  Lib.emitEvent(Event.EVENT_HEART_WARM_INTEGRAL_UPDATE)
end
