local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:inUseCar(value)
  Lib.emitEvent(Event.EVENT_UPDATE_IN_USE_CAR, value, self.objID)
end
