local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:houseLimitList(value)
  HouseManager:updateLimit(self)
end
