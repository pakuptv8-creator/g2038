local InteractionHelper = T(Lib, "InteractionHelper")
local Entity = _ENV.Entity

function Entity:playClientAction(actionName, actionTime, refreshBaseAction, upperActionStart, needLoop, actionType)
  needLoop = true
  if self.isPlayer then
    if self.objID == Me.objID then
      local actionData = {
        actionName = actionName,
        actionTime = actionTime,
        refreshBaseAction = refreshBaseAction,
        upperActionStart = upperActionStart,
        needLoop = needLoop,
        actionType = actionType
      }
      Me:setCurPlayActionData(actionData)
      self:updateUpperAction1(actionName, actionTime, refreshBaseAction or false, upperActionStart or 0, needLoop or false)
    end
  else
    self:updateUpperAction1(actionName, actionTime, refreshBaseAction or false, upperActionStart or 0, needLoop or false)
  end
end

function Entity:clientDoFurnitureAction(actionName, partID)
  self:setAlwaysAction(actionName)
  if self.objID == Me.objID then
    Me.sitDisableControl = true
    Blockman.instance:setKeyPressing("key.jump", false)
  end
end

function Entity:clientStopFurnitureAction(actionName, partID)
  self:setAlwaysAction("")
  if self.objID == Me.objID then
    Me.sitDisableControl = false
  end
end

function Entity:isInTheInteraction(args)
  local passengers = self:data("passengers") or {}
  local inTheInteraction = false
  if passengers[args] then
    inTheInteraction = true
  end
  return inTheInteraction
end
