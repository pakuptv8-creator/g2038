local Interact = T(World, "Interact")

function Interact.showPlayerInteractionUI(target, params, from, add)
  if not (target and target:isValid()) or from.objID ~= Me.objID or target.objID == Me.objID then
    return
  end
  if Me:getInteractPlayerUpID() ~= 0 then
    return
  end
  Me.clickPlayerObjID = target.objID
  Me:recheckAllInteractionUIs()
end
