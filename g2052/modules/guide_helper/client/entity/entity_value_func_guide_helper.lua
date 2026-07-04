local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:guideData(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_GUIDE_DATA_UPDATE)
  end
end
