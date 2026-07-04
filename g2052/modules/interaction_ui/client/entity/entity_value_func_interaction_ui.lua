local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:curPlayActionData(value, oldValue)
  if value.actionName then
    self:clientDoPlayActionData(value)
  end
end

function Entity:clientDoPlayActionData(value)
  if self.objID ~= Me.objID then
    self:updateUpperAction1(value.actionName, value.actionTime, value.refreshBaseAction or false, value.upperActionStart or 0, value.needLoop or false)
  end
end

function Entity.ValueFunc:paletteData(value)
  print("--paletteData----", value)
  if not value then
    return
  end
  Lib.emitEvent(Event.EVENT_UPDATE_PREVIEW_PALETTE, self.objID, value)
end

function Entity.ValueFunc:interactCarEnterID(value)
  if self.objID == Me.objID then
    Me.isInteractCarEnterID = value
    if value ~= "" then
      UI:closeWnd("takePhotos")
    end
  end
end
