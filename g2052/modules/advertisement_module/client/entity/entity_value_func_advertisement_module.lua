local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:freeItemData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_WATCH_AD_UPDATE)
  end
end
