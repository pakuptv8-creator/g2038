local InteractionHelper = T(Lib, "InteractionHelper")
local DanceConfig = T(Config, "DanceConfig")

function InteractionHelper:init()
  self.actionList = {}
  self.moveStateList = {}
  self.skatePreBaseAction = {}
  self.onceActionInfo = {}
  self:initEvent()
end

function InteractionHelper:initEvent()
  Lib.subscribeEvent(Event.EVENT_ENTITY_SPAWN, function(objID)
    self:checkPlayerInteractionState(objID)
    local actionTarget = World.CurWorld:getEntity(objID)
    local partID = actionTarget:getInteractionPartID()
    if partID ~= "" then
      local actionKey = "furniture_" .. partID
      if not self.actionList[objID] or not self.actionList[objID][actionKey] then
        local actionData = {
          priority = Define.ActionMapPriority.furniturePriority,
          actionName = actionTarget:getSitPartAction(),
          actionTime = -1,
          actionType = "furniture"
        }
        InteractionHelper:updateEntityActionData(objID, actionKey, true, actionData, true)
      end
    end
    local danceID = actionTarget:getPlayDanceID()
    if 0 < danceID then
      local actionKey = "dance_" .. danceID
      if not self.actionList[objID] or not self.actionList[objID][actionKey] then
        local danceCfg = DanceConfig:getCfgById(danceID)
        local actionData = {
          priority = Define.ActionMapPriority.dancePriority,
          actionName = danceCfg.actionName,
          actionTime = -1,
          actionType = "dance"
        }
        if danceCfg.actionTime >= 9999 or danceCfg.actionTime == -1 then
          actionData.actionTime = danceCfg.actionTime
          InteractionHelper:updateEntityActionData(objID, actionKey, true, actionData, true)
        end
      end
    end
    self:updateEntityActionShow(objID)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_OFF, function(objID)
    World.Timer(3, function()
      self:updateEntityActionShow(objID)
    end)
  end)
  Lib.subscribeEvent(Event.EVENT_ENTITY_RIDE_ON, function(objID)
    local entity = World.CurWorld:getEntity(objID)
    if entity and entity:isValid() then
      entity:playClientAction("idle", -1)
    end
    World.Timer(3, function()
      self:updateEntityActionShow(objID)
    end)
  end)
end

function InteractionHelper:updateOnceActionData(info)
  if not self.onceActionInfo[info.fromID] then
    self.onceActionInfo[info.fromID] = {}
  end
  local actionKey = "onceAction_" .. info.actionName
  if self.onceActionInfo[info.fromID][actionKey] then
    self.onceActionInfo[info.fromID][actionKey]()
    self.onceActionInfo[info.fromID][actionKey] = nil
  end
  local actionTime = (Me:getUpperActionTicks(info.actionName) or 40) + 3
  local actionData = {
    priority = info.priority,
    actionName = info.actionName,
    actionTime = actionTime,
    actionType = "onceAction"
  }
  InteractionHelper:updateEntityActionData(info.fromID, actionKey, true, actionData)
  self.onceActionInfo[info.fromID][actionKey] = World.Timer(actionTime, function()
    InteractionHelper:updateEntityActionData(info.fromID, actionKey, false, actionData)
    self.onceActionInfo[info.fromID][actionKey] = nil
  end)
end

function InteractionHelper:checkPlayerInteractionState(objID)
  local entity = World.CurWorld:getEntity(objID)
  if not entity or not entity:isValid() then
    return
  end
  if entity.rideOnId > 0 then
    local car = World.CurWorld:getEntity(entity.rideOnId)
    local updateActorFun = car:cfg().updateActorFun
    if updateActorFun and car[updateActorFun] then
      car[updateActorFun](car)
    end
  end
end

function InteractionHelper:updateActionMapState(objID, value, add, actionKey, priority)
  local entity = World.CurWorld:getEntity(objID)
  if not entity or not entity:isValid() then
    return
  end
  if not entity.actionMapQueue then
    entity.actionMapQueue = {}
  end
  if add then
    table.insert(entity.actionMapQueue, {
      value = value,
      actionKey = actionKey,
      priority = priority
    })
    table.sort(entity.actionMapQueue, function(a, b)
      return a.priority > b.priority
    end)
  else
    local lastIndex
    for i = #entity.actionMapQueue, 1, -1 do
      if entity.actionMapQueue[i].actionKey == actionKey then
        lastIndex = i
        table.remove(entity.actionMapQueue, i)
        break
      end
    end
    if lastIndex and lastIndex == 1 then
      for src, dst in pairs(value) do
        entity:removeActionMapping(src)
      end
    end
  end
  self:resetPlayMapAction(entity)
  InteractionHelper:updateEntityActionShow(objID)
end

function InteractionHelper:resetPlayMapAction(entity)
  if not entity or not entity:isValid() then
    return
  end
  if not entity.actionMapQueue then
    return
  end
  if entity.actionMapQueue[1] then
    local value = entity.actionMapQueue[1].value
    for src, dst in pairs(value) do
      local channel = entity:GetActionChannel(dst)
      entity:setActionMapping(src, dst, channel == "upper")
    end
    self:checkActionMapQueen(entity)
  end
end

function InteractionHelper:checkActionMapQueen(entity)
  if not (entity and entity:isValid()) or not entity.isPlayer then
    return
  end
  if not entity.actionMapQueue then
    return
  end
  if entity.actionMapQueue[1] then
    local value = entity.actionMapQueue[1].value
    local curUpperAction = entity:getUpperAction()
    if value.idle and value.idle ~= "" and value.idle ~= curUpperAction then
      entity:playClientAction("idle", -1)
      entity:refreshUpperAction()
      entity:refreshBaseAction()
    end
  end
end

function InteractionHelper:showOneInteractTips(content)
  if self.updateTimer then
    self.updateTimer()
    self.updateTimer = nil
  end
  if not self.newInteractTip then
    self.newInteractTip = UIMgr:new_widget("interactTips")
    local desktop = GUISystem.instance:GetRootWindow()
    desktop:AddChildWindow(self.newInteractTip)
    self.newInteractTip:SetLevel(2)
  end
  self.newInteractTip:invoke("updateTipsData", content)
  self.newInteractTip:invoke("setVisible", true)
  self.updateTimer = World.LightTimer("FlyTipsHelper:startUpdateItemList", World.cfg.interactTipsTime * 20, function()
    self:hideOneInteractTips()
  end)
end

function InteractionHelper:hideOneInteractTips()
  if not self.newInteractTip then
    return
  end
  self.newInteractTip:invoke("setVisible", false)
end

function InteractionHelper:updateEntityActionData(objID, actionKey, isAdd, actionData, notUpdateShow)
  if not self.actionList[objID] then
    self.actionList[objID] = {}
    self.moveStateList[objID] = {}
  end
  if isAdd then
    self.actionList[objID][actionKey] = actionData
  else
    self.actionList[objID][actionKey] = nil
  end
  if not notUpdateShow then
    self:updateEntityActionShow(objID)
  end
end

function InteractionHelper:updateEntityActionShow(objID)
  if not self.actionList[objID] then
    return
  end
  local entity = World.CurWorld:getEntity(objID)
  if entity and entity:isValid() then
    self.maxActionInfo = nil
    local isHaveSkate
    for actionKey, actionInfo in pairs(self.actionList[objID]) do
      if actionInfo.priority == Define.ActionMapPriority.skatePriority then
        isHaveSkate = actionInfo
      end
      if self.maxActionInfo then
        if actionInfo.priority > self.maxActionInfo.priority then
          self.maxActionInfo = actionInfo
        end
      else
        self.maxActionInfo = actionInfo
      end
    end
    self.moveStateList[objID].status = -1
    if isHaveSkate then
      if self.maxActionInfo.priority == isHaveSkate.priority then
        if self.skatePreBaseAction[objID] then
          entity:setBaseAction(self.skatePreBaseAction[objID])
          self.skatePreBaseAction[objID] = nil
        end
      else
        if not self.skatePreBaseAction[objID] then
          self.skatePreBaseAction[objID] = entity:getBaseAction()
        end
        if isHaveSkate.actionName ~= "g2052_boy_jump_squat" then
          entity:setBaseAction(isHaveSkate.actionName)
        else
          entity:setBaseAction(self.skatePreBaseAction[objID])
        end
      end
    elseif self.skatePreBaseAction[objID] then
      entity:setBaseAction(self.skatePreBaseAction[objID])
      self.skatePreBaseAction[objID] = nil
    end
    self:entityMoveActionUpdate(objID, entity.curMoveStatus or 2)
  end
end

function InteractionHelper:isHaveEntityAction(objID)
  if not self.moveStateList[objID] then
    return false
  end
  if not self.moveStateList[objID].actionName then
    return false
  end
  if self.moveStateList[objID].actionName == "" then
    return false
  end
  if self.moveStateList[objID].actionName == "idle" then
    return false
  end
  return true
end

function InteractionHelper:entityMoveActionUpdate(objID, newState)
  local entity = World.CurWorld:getObject(objID)
  if not entity or not entity:isValid() then
    return
  end
  if not self.actionList[objID] then
    return
  end
  if not self.moveStateList[objID] then
    return
  end
  self.moveStateList[objID].status = newState
  if self.maxActionInfo then
    if self.maxActionInfo.actionType == "furniture" then
      if entity.rideOnId <= 0 then
        entity:playClientAction(self.maxActionInfo.actionName, self.maxActionInfo.actionTime, self.maxActionInfo.refreshBaseAction, nil, nil, self.maxActionInfo.actionType)
        self.moveStateList[objID].actionName = self.maxActionInfo.actionName
      end
    else
      entity:playClientAction(self.maxActionInfo.actionName, self.maxActionInfo.actionTime, self.maxActionInfo.refreshBaseAction, nil, nil, self.maxActionInfo.actionType)
      self.moveStateList[objID].actionName = self.maxActionInfo.actionName
    end
  else
    local newAction = "idle"
    entity:playClientAction(newAction, -1)
    self.moveStateList[objID].actionName = newAction
  end
end

InteractionHelper:init()
