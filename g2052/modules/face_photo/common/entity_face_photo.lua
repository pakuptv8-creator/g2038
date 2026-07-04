local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.isWeekFirstLogin = {
  false,
  false,
  true,
  false,
  false,
  false
}

function Entity:getIsWeekFirstLogin()
  return self:getValue("isWeekFirstLogin")
end

function Entity:setIsWeekFirstLogin(value)
  self:setValue("isWeekFirstLogin", value)
end
