local handles = T(Player, "PackageHandlers")

function handles:playBasketball(packet)
  local player = World.CurWorld:getEntity(packet.objID)
  if not player or not player:isValid() then
    return
  end
  player:doPlayBasketball(packet.pos, packet.itemId)
end

function handles:requestGiveProp(packet)
  local itemId = packet.itemId
  local fromId = packet.fromId
  local from = World.CurWorld:getEntity(fromId)
  if from and from:isValid() then
    if UI:isOpen("propReceive") then
      UI:closeWnd("propReceive")
    end
    UI:openWnd("propReceive", itemId, packet.fromUserId)
  end
end

function handles:givePropSucceed(packet)
  Lib.logDebug("--givePropSucceed  targetId = " .. packet.targetId .. "   itemId = " .. packet.itemId)
  if UI:isOpen("propGiveSuccess") then
    UI:closeWnd("propGiveSuccess")
  end
  UI:openWnd("propGiveSuccess", packet.itemId, packet.targetUserId)
end

function handles:receivePropSucceed(packet)
  if UI:isOpen("propReceiveSuccess") then
    UI:closeWnd("propReceiveSuccess")
  end
  UI:openWnd("propReceiveSuccess", packet.itemId, packet.fromUserId)
  Lib.logDebug("--receivePropSucceed  fromId = " .. packet.fromUserId .. "   itemId = " .. packet.itemId)
end

function handles:divingFromServer(packet)
  Me:jump(0, 0)
end

function handles:startDivingForceMove(packet)
  Lib.logDebug("=====rec startDivingForceMove---")
  if self.divingForceMoveCount then
    self.divingForceMoveCount()
    self.divingForceMoveCount = nil
    Lib.logDebug("==== StartDivingForceMove")
  end
  local motion = packet.motion or {
    x = 0,
    y = 0,
    z = 0
  }
  local interval = packet.interval or 1
  local total = packet.total
  local clNow = World.Now()
  self.divingForceMoveCount = World.LightTimer("self.divingForceMoveCount", interval, function()
    self:moveUntilCollide(motion)
    local isFinish = total == nil or World.Now() < clNow + total
    return isFinish
  end)
end

function handles:finishDivingForceMove(packet)
  if self.divingForceMoveCount then
    self.divingForceMoveCount()
    self.divingForceMoveCount = nil
    Lib.logDebug("==== FinishDivingForceMove")
  end
end
