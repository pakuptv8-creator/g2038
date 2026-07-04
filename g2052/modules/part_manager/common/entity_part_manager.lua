local ValueDef = T(Entity, "ValueDef")
ValueDef.onSwingState = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.swingSpeedRate = {
  false,
  true,
  true,
  true,
  0,
  false
}
ValueDef.onSlideState = {
  false,
  false,
  true,
  false,
  0,
  false
}
local Entity = _ENV.Entity

function Entity:getOnSlideState()
  return self:getValue("onSlideState")
end

function Entity:setOnSlideState(state)
  self:setValue("onSlideState", state)
end

function Entity:getOnSwingState()
  return self:getValue("onSwingState")
end

function Entity:setOnSwingState(state)
  self:setValue("onSwingState", state)
end

function Entity:getSwingSpeedRate()
  return self:getValue("swingSpeedRate")
end

function Entity:setSwingSpeedRate(nRate)
  self:setValue("swingSpeedRate", nRate)
end
