local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
ValueFunc[Define.PET_VAR_KEY.CurCarryPetId] = function(entity, value)
  Lib.emitEvent(Event.EVENT_PET_CARRY_CHANGE)
end
ValueFunc[Define.PET_VAR_KEY.CurCarryPetObjId] = function(entity, value)
  Lib.emitEvent(Event.EVENT_PET_CARRY_OBJ_ID_CHANGE, value)
end
ValueFunc[Define.PET_VAR_KEY.PeakDayPetReceived] = function(entity, value)
  if value == true then
    Lib.emitEvent(Event.EVENT_PEAK_DAY_PET_RECEIVED)
  end
end
ValueFunc[Define.PET_VAR_KEY.PetReceived] = function(entity, value)
  UI:getWnd("partner"):resetHasInitListTag()
end
ValueFunc[Define.PET_VAR_KEY.PeakDayPetReceivedSeason] = function(entity, value)
  Lib.emitEvent(Event.EVENT_PEAK_DAY_PET_RECEIVED)
end
