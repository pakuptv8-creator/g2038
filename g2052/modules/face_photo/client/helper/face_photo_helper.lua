local FacePhotoHelper = T(Lib, "FacePhotoHelper")
local FacePhotoConfig = T(Config, "FacePhotoConfig")
local LimitTimeClientHelper = T(Lib, "LimitTimeClientHelper")
local MustWinLotteryAwardConfig = T(Config, "MustWinLotteryAwardConfig")
local LimitedTimeGiftItemConfig = T(Config, "LimitedTimeGiftItemConfig")
local LuaTimer = T(Lib, "LuaTimer")

function FacePhotoHelper:init()
  self.isOpenFaceWnd = false
  self.delayTimeEnd = false
  LuaTimer:scheduleTimer(function()
    self.delayTimeEnd = true
    self:checkOpenFaceWnd()
  end, 3000, 1)
end

function FacePhotoHelper:getEffectFacePhotoCfg()
  local initCfg = FacePhotoConfig:getAllCfgs()
  local curMustId
  if LimitTimeClientHelper:checkActiveIsOpen(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY) then
    local params = LimitTimeClientHelper:getParamsByActiveType(Define.LIMITED_TIME_ACTIVITY_TYPE.MUST_WIN_LOTTERY)
    curMustId = params.id
  end
  local resultCfg = {}
  for _, v in ipairs(initCfg) do
    if v.typeId == 1 then
      if v.activityId == curMustId and 0 < curMustId then
        local mustWinLotteryAwards = MustWinLotteryAwardConfig:getCfgByActivityId(curMustId)
        local giftItemCfgs = LimitedTimeGiftItemConfig:getAllCfgs() or {}
        local allCanUse = true
        for i, v in pairs(mustWinLotteryAwards) do
          local awardId = v.giftContent[1]
          local goodsCfg = giftItemCfgs[awardId]
          local canUse = Me:checkBusinessItemUnlock(goodsCfg.awardType, goodsCfg.itemId)
          if not canUse then
            allCanUse = false
          end
        end
        if not allCanUse then
          table.insert(resultCfg, v)
        end
      end
    else
      table.insert(resultCfg, v)
    end
  end
  return resultCfg
end

function FacePhotoHelper:checkOpenFaceWnd()
  local isWeekFirstLogin = Me:getIsWeekFirstLogin()
  if not self.delayTimeEnd then
    return
  end
  if self.isOpenFaceWnd then
    return
  end
  local resultCfg = self:getEffectFacePhotoCfg()
  if #resultCfg <= 0 then
    return
  end
  if isWeekFirstLogin then
    self:openFacePhotoWnd(resultCfg)
    return
  end
  local mustRoundFirstLogin = Me:getMustRoundFirstLogin()
  if mustRoundFirstLogin then
    self:openFacePhotoWnd(resultCfg)
    return
  end
end

function FacePhotoHelper:openFacePhotoWnd(resultCfg)
  self.isOpenFaceWnd = true
  UI:openWnd("facePhotoWnd", resultCfg)
end

FacePhotoHelper:init()
return FacePhotoHelper
