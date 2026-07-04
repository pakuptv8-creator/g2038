local Player = _ENV.Player
local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local HalloweenExchangeConfig = T(Config, "HalloweenExchangeConfig")
local HalloweenPartHelper = T(Lib, "HalloweenPartHelper")

function Player:onHalloweenExchange(type, part, params)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local keyId = tonumber(params[2]) or 0
  local cfgInfo = HalloweenExchangeConfig:getCfgById(keyId)
  if cfgInfo then
    local startTime = os.time(cfgInfo.startTime)
    local remainTime = startTime - os.time()
    if 0 < remainTime then
      HalloweenPartHelper:pushClientHalloweenUIInfo(self.map.name, self, true)
      return
    end
    local isHas = false
    if cfgInfo.awardType == 1 then
      isHas = self:checkActivityCarIsUnlock(cfgInfo.awardId)
    elseif cfgInfo.awardType == 2 then
      isHas = self:checkActivityPetIsUnlock(cfgInfo.awardId)
    elseif cfgInfo.awardType == 3 then
      isHas = self:checkActivityDressIsUnlock(cfgInfo.awardId)
    end
    if isHas then
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.exchange.success")
      return
    else
      local num = self:getHalloweenCandy()
      if num >= cfgInfo.costNum then
        local packet = {
          pid = "SCShowCandyExchangeTips",
          keyId = keyId
        }
        self:sendPacket(packet)
      else
        Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.exchange.fail")
      end
    end
  end
end

function Player:doHalloweenExchange(keyId)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local cfgInfo = HalloweenExchangeConfig:getCfgById(keyId)
  if cfgInfo then
    local num = self:getHalloweenCandy()
    if num >= cfgInfo.costNum then
      self:changeHalloweenCandy(-cfgInfo.costNum)
      if cfgInfo.awardType == 1 then
        self:addActivityCar(cfgInfo.awardId)
      elseif cfgInfo.awardType == 2 then
        self:addActivityPet(cfgInfo.awardId)
      elseif cfgInfo.awardType == 3 then
        self:addActivityDress(cfgInfo.awardId)
      end
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.exchange.success")
      local reportData = {halloween_exchange_id = keyId}
      Plugins.CallTargetPluginFunc("report", "report", "halloween_exchange", reportData, self)
    else
      Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.exchange.fail")
    end
  end
end
