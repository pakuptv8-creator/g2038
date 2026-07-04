local Entity = _ENV.Entity
local InteractionHelper = T(Lib, "InteractionHelper")

function Entity:addPlayerSkateAction(skateID, actionName, actionTime)
  local actionKey = "skateAction_" .. skateID
  local actionData = {
    priority = Define.ActionMapPriority.skatePriority,
    actionName = actionName,
    actionTime = actionTime,
    actionType = "skatePlayer"
  }
  InteractionHelper:updateEntityActionData(self.objID, actionKey, true, actionData)
end
