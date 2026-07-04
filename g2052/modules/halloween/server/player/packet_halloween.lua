local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local HalloweenGhostConfig = T(Config, "HalloweenGhostConfig")
local handles = T(Player, "PackageHandlers")

function handles:CSShareCandyToOthers(packet)
  local entity = World.CurWorld:getEntity(packet.targetID)
  if not entity or not entity:isValid() then
    return
  end
  local halloweenCandyDayPlayer = self:getHalloweenCandyDayPlayer()
  if halloweenCandyDayPlayer[entity.platformUserId] then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.share.exist")
    return
  end
  local sharedNum = self:getCandyDayCountByType(Define.GetCandyType.Share)
  if sharedNum >= World.cfg.halloweenSetting.shareMaxCount then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.share.limit")
    return
  end
  local askedNum = entity:getCandyDayCountByType(Define.GetCandyType.AskFor)
  if askedNum >= World.cfg.halloweenSetting.acceptMaxCount then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.accept.limit")
    return
  end
  self:addCandyDayCount(1, Define.GetCandyType.Share)
  self:addHalloweenCandyDayPlayer(entity.platformUserId)
  entity:addCandyDayCount(1, Define.GetCandyType.AskFor)
  entity:changeHalloweenCandy(World.cfg.halloweenSetting.oneShareNum)
  local packet1 = {
    pid = "SCShowShareCandySuccess",
    targetUserID = entity.platformUserId,
    remainCounts = World.cfg.halloweenSetting.shareMaxCount - (sharedNum + 1)
  }
  self:sendPacket(packet1)
  local packet2 = {
    pid = "SCShowAcceptCandySuccess",
    fromUserID = self.platformUserId
  }
  entity:sendPacket(packet2)
  Plugins.CallTargetPluginFunc("report", "report", "halloween_deliver", nil, self)
end

function handles:CSAskForCandyFromOthers(packet)
  local entity = World.CurWorld:getEntity(packet.targetID)
  if not entity or not entity:isValid() then
    return
  end
  local halloweenCandyDayPlayer = entity:getHalloweenCandyDayPlayer()
  if halloweenCandyDayPlayer[self.platformUserId] then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.askFor.exist")
    return
  end
  local askedNum = self:getCandyDayCountByType(Define.GetCandyType.AskFor)
  if askedNum >= World.cfg.halloweenSetting.acceptMaxCount then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.askFor.limit")
    return
  end
  local packet2 = {
    pid = "SCShowAskForCandyWnd",
    fromUserID = self.platformUserId,
    fromName = self.name
  }
  entity:sendPacket(packet2)
  Plugins.CallTargetPluginFunc("report", "report", "halloween_ask", nil, self)
end

function handles:CSResponseCandyAskFor(packet)
  local fromEntity = Game.GetPlayerByUserId(packet.fromUserId)
  if not fromEntity or not fromEntity:isValid() then
    return
  end
  if not packet.result then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, {
      "g2052.gui.halloween.askFor.refuse",
      self.name
    })
    return
  end
  local halloweenCandyDayPlayer = self:getHalloweenCandyDayPlayer()
  if halloweenCandyDayPlayer[fromEntity.platformUserId] then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.askFor.exist")
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, "g2052.gui.halloween.share.exist")
    return
  end
  local sharedNum = self:getCandyDayCountByType(Define.GetCandyType.Share)
  if sharedNum >= World.cfg.halloweenSetting.shareMaxCount then
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, "g2052.gui.halloween.share.limit")
    Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", fromEntity, {
      "g2052.gui.halloween.askFor.refuse",
      self.name
    })
    return
  end
  self:addCandyDayCount(1, Define.GetCandyType.Share)
  self:addHalloweenCandyDayPlayer(fromEntity.platformUserId)
  fromEntity:addCandyDayCount(1, Define.GetCandyType.AskFor)
  fromEntity:changeHalloweenCandy(World.cfg.halloweenSetting.oneAcceptNum)
  local askForNum = fromEntity:getCandyDayCountByType(Define.GetCandyType.AskFor)
  local packet1 = {
    pid = "SCShowAcceptCandySuccess",
    fromUserID = self.platformUserId,
    remainCounts = World.cfg.halloweenSetting.acceptMaxCount - askForNum
  }
  fromEntity:sendPacket(packet1)
  local remainCounts = World.cfg.halloweenSetting.shareMaxCount - (sharedNum + 1)
  Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", self, {
    "g2052.gui.halloween.share.remain",
    remainCounts
  })
end

function handles:findGhostGetCandyC2S(packet)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local findGhostLimit = World.cfg.halloweenSetting.findGhostMaxCount or 10
  if findGhostLimit <= self:getCandyDayCountByType(Define.GetCandyType.FindGhost) then
    return
  end
  self:addHalloweenFindGhostRecord(packet.ghostId)
  self:addCandyDayCount(1, Define.GetCandyType.FindGhost)
  local cfg = HalloweenGhostConfig:getCfgById(packet.ghostId)
  if cfg then
    local candyNum = World.cfg.halloweenSetting.oneFindGhostCandyNum[cfg.type]
    if candyNum then
      self:changeHalloweenCandy(candyNum)
    end
  end
end

function handles:CSConfirmCandyExchange(packet)
  self:doHalloweenExchange(packet.keyId)
end
