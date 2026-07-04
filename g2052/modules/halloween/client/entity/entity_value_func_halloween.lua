local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:halloweenCandy(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_HALLOWEEN_CANDY_NUM_UPDATE, value)
  end
end
