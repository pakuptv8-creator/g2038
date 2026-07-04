local ValueDef = T(Entity, "ValueDef")
ValueDef.signalLimitGiftData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.combinedGiftData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.mustWinLotteryData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.initialEnterInto = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeDrawData = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeWeekData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeMonthData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeWeekKey = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.limitedTimeMonthKey = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.limitedTimeDiscountData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeDiscountKey = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.limitedTimeCardData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.firstPurchaseData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeOptionalInfo = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.limitedTimeOptionalBuy = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.limitedLastLoginTime = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.limitedTimeRoundsTimes = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.mustRoundFirstLogin = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.heartWarmReward = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.heartWarmTask = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.heartWarmStart = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.heartWarmIntegral = {
  false,
  false,
  true,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getHeartWarmIntegral()
  return self:getValue("heartWarmIntegral")
end

function Entity:setHeartWarmIntegral(value)
  self:setValue("heartWarmIntegral", value)
end

function Entity:getHeartWarmStart()
  return self:getValue("heartWarmStart")
end

function Entity:setHeartWarmStart(value)
  self:setValue("heartWarmStart", value)
end

function Entity:getHeartWarmReward()
  return self:getValue("heartWarmReward")
end

function Entity:setHeartWarmReward(value)
  self:setValue("heartWarmReward", value)
end

function Entity:getHeartWarmTask()
  return self:getValue("heartWarmTask")
end

function Entity:setHeartWarmTask(value)
  self:setValue("heartWarmTask", value)
end

function Entity:getMustRoundFirstLogin()
  return self:getValue("mustRoundFirstLogin")
end

function Entity:setMustRoundFirstLogin(value)
  self:setValue("mustRoundFirstLogin", value)
end

function Entity:getLimitedTimeRoundsTimes()
  return self:getValue("limitedTimeRoundsTimes")
end

function Entity:setLimitedTimeRoundsTimes(data)
  self:setValue("limitedTimeRoundsTimes", data)
end

function Entity:getLimitedLastLoginTime()
  return self:getValue("limitedLastLoginTime")
end

function Entity:setLimitedLastLoginTime(val)
  self:setValue("limitedLastLoginTime", val)
end

function Entity:getLimitedTimeOptionalBuy()
  return self:getValue("limitedTimeOptionalBuy")
end

function Entity:setLimitedTimeOptionalBuy(val)
  return self:setValue("limitedTimeOptionalBuy", val)
end

function Entity:addLimitedTimeOptionalBuy(giftKey, count)
  local optionalBuy = self:getValue("limitedTimeOptionalBuy")
  optionalBuy[giftKey] = (optionalBuy[giftKey] or 0) + count
  self:setValue("limitedTimeOptionalBuy", optionalBuy)
end

function Entity:getLimitedTimeOptionalData()
  return self:getValue("limitedTimeOptionalInfo")
end

function Entity:getLimitedTimeOptionalKeyData(giftKey)
  local optionalData = self:getValue("limitedTimeOptionalInfo")
  return optionalData[giftKey] or {}
end

function Entity:setLimitedTimeOptionalData(data)
  self:setValue("limitedTimeOptionalInfo", data)
end

function Entity:getFirstPurchaseData()
  return self:getValue("firstPurchaseData")
end

function Entity:setFirstPurchaseData(data)
  self:setValue("firstPurchaseData", data)
end

function Entity:getLimitedTimeCardData()
  return self:getValue("limitedTimeCardData")
end

function Entity:setLimitedTimeCardData(data)
  self:setValue("limitedTimeCardData", data)
end

function Entity:getLimitedTimeDiscountKey()
  return self:getValue("limitedTimeDiscountKey")
end

function Entity:setLimitedTimeDiscountKey(val)
  self:setValue("limitedTimeDiscountKey", val)
end

function Entity:getLimitedTimeDiscountData()
  return self:getValue("limitedTimeDiscountData") or {}
end

function Entity:setLimitedTimeDiscountData(val)
  self:setValue("limitedTimeDiscountData", val)
end

function Entity:addLimitedTimeDiscountData(key, count)
  local data = self:getLimitedTimeDiscountData()
  data[key] = (data[key] or 0) + count
  self:setLimitedTimeDiscountData(data)
end

function Entity:getLimitedTimeWeekKey()
  return self:getValue("limitedTimeWeekKey")
end

function Entity:setLimitedTimeWeekKey(val)
  self:setValue("limitedTimeWeekKey", val)
end

function Entity:getLimitedTimeMonthKey()
  return self:getValue("limitedTimeMonthKey")
end

function Entity:setLimitedTimeMonthKey(val)
  self:setValue("limitedTimeMonthKey", val)
end

function Entity:getLimitedTimeWeekData()
  return self:getValue("limitedTimeWeekData") or {}
end

function Entity:setLimitedTimeWeekData(val)
  self:setValue("limitedTimeWeekData", val)
end

function Entity:addLimitedTimeWeekData(key, count)
  local data = self:getLimitedTimeWeekData()
  data[key] = (data[key] or 0) + count
  self:setLimitedTimeWeekData(data)
end

function Entity:getLimitedTimeMonthData()
  return self:getValue("limitedTimeMonthData") or {}
end

function Entity:setLimitedTimeMonthData(val)
  self:setValue("limitedTimeMonthData", val)
end

function Entity:addLimitedTimeMonthData(key, count)
  local data = self:getLimitedTimeMonthData()
  data[key] = (data[key] or 0) + count
  self:setLimitedTimeMonthData(data)
end

function Entity:getLimitedTimeDrawData()
  return self:getValue("limitedTimeDrawData") or {}
end

function Entity:setLimitedTimeDrawData(val)
  self:setValue("limitedTimeDrawData", val)
end

function Entity:getCombinedGiftData()
  return self:getValue("combinedGiftData") or {}
end

function Entity:setCombinedGiftData(val)
  self:setValue("combinedGiftData", val)
end

function Entity:getInitialEnterInto()
  return self:getValue("initialEnterInto")
end

function Entity:setInitialEnterInto(val)
  self:setValue("initialEnterInto", val)
end

function Entity:addCombinedGiftData(val)
  local data = self:getCombinedGiftData()
  data[val] = true
  self:setCombinedGiftData(data)
end

function Entity:getSignalLimitGiftData()
  return self:getValue("signalLimitGiftData") or {}
end

function Entity:setSignalLimitGiftData(val)
  self:setValue("signalLimitGiftData", val)
end

function Entity:addSignalLimitGiftData(giftKey, count)
  local data = self:getSignalLimitGiftData()
  if data[giftKey] then
    if data[giftKey] == true then
      data[giftKey] = count + 1
    else
      data[giftKey] = data[giftKey] + count
    end
  else
    data[giftKey] = count
  end
  self:setSignalLimitGiftData(data)
end

function Entity:getMustWinLotteryData()
  return self:getValue("mustWinLotteryData")
end

function Entity:setMustWinLotteryData(data)
  self:setValue("mustWinLotteryData", data)
end
