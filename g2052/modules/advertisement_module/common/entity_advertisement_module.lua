local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.openWndData = {
  false,
  true,
  false,
  false,
  0,
  true
}
ValueDef.dailyLoginData = {
  false,
  true,
  false,
  false,
  0,
  false
}
ValueDef.drawCountData = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.lockSlotData = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.freeItemData = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef.drawItemData = {
  false,
  true,
  false,
  false,
  {},
  false
}

function Entity:getOpenWndData()
  return self:getValue("openWndData")
end

function Entity:setOpenWndData(value)
  self:setValue("openWndData", value)
end

function Entity:getDailyLoginData()
  return self:getValue("dailyLoginData")
end

function Entity:setDailyLoginData(value)
  self:setValue("dailyLoginData", value)
end

function Entity:getLockSlotData()
  return self:getValue("lockSlotData")
end

function Entity:setLockSlotData(value)
  self:setValue("lockSlotData", value)
end

function Entity:getDrawCountData()
  return self:getValue("drawCountData")
end

function Entity:setDrawCountData(value)
  self:setValue("drawCountData", value)
end

function Entity:getFreeItemData()
  return self:getValue("freeItemData")
end

function Entity:setFreeItemData(value)
  self:setValue("freeItemData", value)
end

function Entity:getDrawItemData()
  return self:getValue("drawItemData")
end

function Entity:setDrawItemData(value)
  self:setValue("drawItemData", value)
end
