local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local BusinessHelper = T(Lib, "BusinessHelper")

function Entity.ValueFunc:privilegeInfo(value)
  if self.isMainPlayer then
    Lib.emitEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO, value)
  end
end

function Entity.ValueFunc:businessData(value)
  if self.isMainPlayer then
    Lib.emitEvent(Event.EVENT_UPDATE_PRIVILEGE_INFO)
    Lib.emitEvent(Event.EVENT_UPDATE_BUSINESS_RED)
  end
end

function Entity.ValueFunc:isDayFirstLogin(value)
  if self.isMainPlayer then
    Lib.emitEvent(Event.EVENT_UPDATE_BUSINESS_RED)
    Lib.emitEvent(Event.EVENT_UPDATE_DAY_FIRST_LOGIN)
  end
end
