local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:takeInLandCloth(value)
  Lib.emitEvent(Event.EVENT_UPDATE_TENDERING_INFO)
end

function Entity.ValueFunc:takeInLandPet(value)
  Lib.emitEvent(Event.EVENT_UPDATE_TENDERING_INFO)
end
