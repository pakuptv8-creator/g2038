local handles = T(Player, "PackageHandlers")
local DanceConfig = T(Config, "DanceConfig")
local InteractionHelper = T(Lib, "InteractionHelper")

function handles:UpdateDanceActionState(packet)
  if packet.fromID == Me.objID and packet.isClientRequest then
    return
  else
    self:clientDoDanceAction(packet)
  end
end

function handles:CUpdateFurnitureState(packet)
  local actionTarget = World.CurWorld:getEntity(packet.fromID)
  if actionTarget and actionTarget:isValid() then
    if packet.isAdd then
      actionTarget.onGround = true
      actionTarget:clientDoFurnitureAction(packet.passengerAction, packet.partID)
    else
      actionTarget:clientStopFurnitureAction(packet.passengerAction, packet.partID)
    end
  end
  local actionKey = "furniture_" .. packet.partID
  if packet.isAdd then
    local actionData = {
      priority = Define.ActionMapPriority.furniturePriority,
      actionName = packet.passengerAction,
      actionTime = -1,
      actionType = "furniture"
    }
    InteractionHelper:updateEntityActionData(packet.fromID, actionKey, true, actionData)
  else
    InteractionHelper:updateEntityActionData(packet.fromID, actionKey, false)
  end
end

function handles:pushCleanFurnitureActionData(packet)
  local actionKey = "furniture_" .. packet.partID
  InteractionHelper:updateEntityActionData(packet.objID, actionKey, false)
end

function handles:EntityPlayAction(packet)
  local entity = World.CurWorld:getEntity(packet.objID)
  if entity then
    entity:playClientAction(packet.action, packet.time, packet.refreshBaseAction or false)
  end
end

function handles:PushInteractiveRequest(packet)
  if UI:isOpen("role") then
    return
  end
  UI:getWnd("playerInteractRequest"):onShow(true, packet.fromId, packet.interactiveID)
end

function handles:CleanPlayerInteractiveUI(packet)
  UI:getWnd("playerInteractPop"):onShow(false)
  UI:getWnd("playerInteractRequest"):onShow(false)
end

function handles:UpdateInteractiveControlShow(packet)
  if not self.isPlayer then
    return
  end
  UI:getWnd("gameMain"):updateCancelInteractiveShow(packet.isShow)
end

function handles:ClientUpdateInteractTips(packet)
  if packet.isShow then
    InteractionHelper:showOneInteractTips(packet.content)
  else
    InteractionHelper:hideOneInteractTips()
  end
end

function handles:pushInteractBedActionData(packet)
  local actionKey = "interactBed_" .. packet.partID
  if packet.isAdd then
    local actionData = {
      priority = Define.ActionMapPriority.furniturePriority,
      actionName = packet.actionName,
      actionTime = -1,
      actionType = "interactBed"
    }
    InteractionHelper:updateEntityActionData(packet.objID, actionKey, true, actionData)
  else
    InteractionHelper:updateEntityActionData(packet.objID, actionKey, false)
  end
end
