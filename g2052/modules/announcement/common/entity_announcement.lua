local ValueDef = T(Entity, "ValueDef")
ValueDef.announcementVision = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.announcementData = {
  false,
  false,
  false,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getAnnouncementVision()
  return self:getValue("announcementVision")
end

function Entity:setAnnouncementVision(v)
  self:setValue("announcementVision", v)
end

function Entity:getAnnouncementData()
  return self:getValue("announcementData")
end

function Entity:setAnnouncementData(v)
  self:setValue("announcementData", v)
end
