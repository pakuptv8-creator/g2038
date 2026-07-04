local PropsConfig = T(Config, "PropsConfig")
local InteractEventConfig = T(Config, "InteractEventConfig")
local InteractionHelper = T(Lib, "InteractionHelper")
local DanceConfig = T(Config, "DanceConfig")
local Player = _ENV.Player

function Player:requestStopDanceAction(isOnlyStop)
  local danceId = UI:getWnd("dance").curPlayDanceId or 0
  if 0 < danceId then
    Me:sendPacket({
      pid = "PlayerStopDanceBroadcast",
      isOnlyStop = isOnlyStop
    })
  end
  local info = {
    fromID = Me.objID,
    actionId = 0,
    isAdd = false,
    oldDanceId = danceId,
    isOnlyStop = isOnlyStop,
    isClientRequest = true
  }
  self:clientDoDanceAction(info)
end

function Player:requestDoDanceAction(actionId)
  Me:sendPacket({
    pid = "PlayerDanceBroadcast",
    actionId = actionId
  })
  local info = {
    fromID = Me.objID,
    actionId = actionId,
    isAdd = true,
    oldDanceId = UI:getWnd("dance").oldPlayDanceId,
    isClientRequest = true
  }
  self:clientDoDanceAction(info)
end

local ConditionCheckUtils = T(Lib, "ConditionCheckUtils")

function Player:processClickEntity(hit, packet)
  local target = World.CurWorld:getEntity(packet.targetID)
  if not target or target:isWatch() then
    return
  end
  if target.isPlayer and target.platformUserId ~= self.platformUserId then
    if ConditionCheckUtils.canCatchRobber(self, target) then
      Me:sendPacket({
        pid = "tryCatchRobber",
        targetId = packet.targetID
      })
      return
    end
    if packet.targetID == self:getInteractPlayerHorseID() or packet.targetID == self:getInteractPlayerUpID() then
      return
    end
    self:showPlayerFriendPop(packet.targetID)
    Lib.emitEvent(Event.EVENT_UPDATE_INTERACT_CLICK_SHOW, packet.targetID, true, Define.InteractClickType.ActionShow)
  end
  Plugins.CallPluginFunc("entity_click_client", packet.targetID)
end

function Player:showPlayerFriendPop(targetID)
  UI:getWnd("playerInteractPop"):onShow(true, targetID)
end

function Player:showPartInteractionUI(partID, type)
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  local partName = part.name
  local pos = part.getPosition and part:getPosition() or Lib.v3(0, 0, 0)
  local prop = InteractEventConfig:getCfgById(partName) or {}
  local isTv = type == "isTv"
  if isTv then
    if part.className == "Decal" then
      local parent = part:getParent()
      if not parent or not parent.getPosition then
        return
      end
      partName = parent.name
      pos = parent.getPosition and parent:getPosition() or Lib.v3(0, 0, 0)
      prop = InteractEventConfig:getCfgById(partName) or {}
      if prop.params and prop.params[2] ~= "1" then
        self.curPartInteractPop[partID] = {
          pos = pos,
          partID = partID,
          isTv = isTv
        }
        return
      end
    else
      return
    end
  end
  local partPop = UIMgr:new_widget("partInteractionPop")
  partPop:invoke("updatePopData", partID, isTv)
  local removeFun = UILib.uiFollowInstance(partPop, pos, {
    anchor = {x = 0.5, y = 0.5},
    offset = prop.interactPopOffset,
    minScale = 0.1,
    maxScale = 1,
    autoScale = true,
    autoAddDeskop = true,
    showRange = 5,
    canAroundYaw = false
  })
  self.curPartInteractPop[partID] = {
    removeFun = removeFun,
    pos = pos,
    partID = partID,
    isTv = isTv
  }
end

function Player:showTVInteractionUI(partID, isShow)
  if isShow then
    if self.curPartInteractPop[partID] then
      self:sendPacket({
        pid = "CloseTelevision"
      })
    else
      self:showPartInteractionUI(partID, "isTv")
    end
  elseif partID then
    self:removePartInteractPop(partID)
  end
end

function Player:showPartClickInteractionTip(partID)
  local part = Instance.getByInstanceId(partID)
  if not part or not part:isValid() then
    return
  end
  if not self.curPartClickInteractionTip then
    self.curPartClickInteractionTip = {}
  end
  local partName = part.name
  local partPos = part.getPosition and part:getPosition() or Lib.v3(0, 0, 0)
  local pos = partPos
  local prop = InteractEventConfig:getCfgById(partName) or {}
  local clickTipOffset = prop.clickTipOffset
  if clickTipOffset then
    local offset = Lib.correctMoveDistance(part:getRotation(), clickTipOffset)
    pos = pos + offset
  end
  if self.curPartClickInteractionTip[partID] and self.curPartClickInteractionTip[partID].effectNode then
    self.curPartClickInteractionTip[partID].effectNode:setWorldPosition(pos)
    return
  end
  local effectName = prop.clickTipEffect or "g2052_scene_click.effect"
  local scale = Lib.v3(1, 1, 1)
  local scene = part:getScene()
  if effectName then
    local effectNode = EffectNode.Load(effectName)
    effectNode:start()
    effectNode:setWorldPosition(pos)
    effectNode:setWorldScale(scale)
    scene:getRoot():addChild(effectNode)
    self.curPartClickInteractionTip[partID] = {
      partPos = partPos,
      pos = pos,
      effectNode = effectNode
    }
  end
end

function Player:closePartClickInteractionTip(partID)
  local list = self.curPartClickInteractionTip[partID] or {}
  local effectNode = list.effectNode
  if effectNode and effectNode:isValid() then
    effectNode:destroy()
  end
  self.curPartClickInteractionTip[partID] = nil
end

function Player:clientDoDanceAction(packet)
  if packet.isAdd then
    if packet.oldDanceId and packet.oldDanceId > 0 then
      local oldActionKey = "dance_" .. packet.oldDanceId
      InteractionHelper:updateEntityActionData(packet.fromID, oldActionKey, false)
    end
    if packet.fromID == Me.objID and packet.oldDanceId ~= UI:getWnd("dance").oldPlayDanceId and UI:getWnd("dance").oldPlayDanceId and 0 < UI:getWnd("dance").oldPlayDanceId then
      local oldActionKey = "dance_" .. UI:getWnd("dance").oldPlayDanceId
      InteractionHelper:updateEntityActionData(packet.fromID, oldActionKey, false)
    end
    local danceCfg = DanceConfig:getCfgById(packet.actionId)
    local actionKey = "dance_" .. packet.actionId
    local actionData = {
      priority = Define.ActionMapPriority.dancePriority,
      actionName = danceCfg.actionName,
      actionTime = -1,
      actionType = "dance"
    }
    if danceCfg.actionTime >= 9999 then
      actionData.actionTime = danceCfg.actionTime
    end
    InteractionHelper:updateEntityActionData(packet.fromID, actionKey, true, actionData)
    if packet.fromID == Me.objID then
      UI:getWnd("dance"):updateOldDanceId(packet.actionId)
      UI:getWnd("dance"):updateCurDanceId(packet.actionId)
      UI:getWnd("gameMain"):updateStopDanceBtnShow(packet.isAdd, danceCfg.actionTime)
    end
  else
    local actionKey = "dance_" .. packet.oldDanceId
    InteractionHelper:updateEntityActionData(packet.fromID, actionKey, false, nil, true)
    if not packet.isOnlyStop then
      InteractionHelper:updateEntityActionShow(packet.fromID)
    end
    if packet.fromID == Me.objID then
      UI:getWnd("dance"):updateCurDanceId(0)
      UI:getWnd("dance"):updateOldDanceId(packet.oldDanceId)
      UI:getWnd("gameMain"):updateStopDanceBtnShow(packet.isAdd)
    end
    if packet.actionId == 0 then
      Lib.emitEvent(Event.EVENT_DANCE_ACTION_CANCEL, packet.fromID)
    end
  end
  if packet.fromID == Me.objID then
    Lib.emitEvent(Event.EVENT_DANCE_ITEM_SHOW)
  end
  local actionTarget = World.CurWorld:getEntity(packet.fromID)
  if actionTarget and actionTarget:isValid() then
    actionTarget.isFirstChangeIdle = false
  end
end
