local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.privilegeInfo = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.marketData = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.businessData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.isDayFirstLogin = {
  false,
  false,
  true,
  false,
  false,
  false
}

function Entity:setBusinessData(data)
  self:setValue("businessData", data)
end

function Entity:getBusinessData()
  return self:getValue("businessData")
end

function Entity:setMarketData(data)
  self:setValue("marketData", data)
end

function Entity:getMarketData()
  return self:getValue("marketData")
end

function Entity:getPrivilegeInfo()
  return self:getValue("privilegeInfo")
end

function Entity:setPrivilegeInfo(info)
  self:setValue("privilegeInfo", info)
end

function Entity:getIsDayFirstLogin()
  return self:getValue("isDayFirstLogin")
end

function Entity:setIsDayFirstLogin(value)
  self:setValue("isDayFirstLogin", value)
end
