local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:houseLimitList(value)
  UI:getWnd("playerInteractPop"):updateHouseLimitList(value)
end
