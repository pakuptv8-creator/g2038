local ValueDef = T(Entity, "ValueDef")
ValueDef.takeInLandCloth = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.takeInLandPet = {
  false,
  false,
  true,
  false,
  {},
  false
}
local Entity = _ENV.Entity

function Entity:setTakeInLandCloth(value)
  self:setValue("takeInLandCloth", value)
end

function Entity:getTakeInLandCloth()
  return self:getValue("takeInLandCloth")
end

function Entity:addTakeInLandCloths(closeList)
  local takeInLandCloth = self:getValue("takeInLandCloth")
  for _, closeId in pairs(closeList) do
    takeInLandCloth[closeId] = true
  end
  self:setTakeInLandCloth(takeInLandCloth)
end

function Entity:setTakeInLandPet(value)
  self:setValue("takeInLandPet", value)
end

function Entity:getTakeInLandPet()
  return self:getValue("takeInLandPet")
end

function Entity:addTakeInLandPets(petList)
  local takeInLandPet = self:getValue("takeInLandPet")
  for _, petId in pairs(petList) do
    takeInLandPet[petId] = true
  end
  self:setTakeInLandPet(takeInLandPet)
end
