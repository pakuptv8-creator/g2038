local ValueDef = T(Entity, "ValueDef")
ValueDef.guideInfo = {
  false,
  true,
  true,
  false,
  {},
  true
}
ValueDef.guideData = {
  false,
  true,
  true,
  false,
  {},
  true
}

function Entity:getGuideInfo()
  return self:getValue("guideInfo")
end

function Entity:addGuideInfo(uiName)
  local data = self:getValue("guideInfo")
  if not data[uiName] then
    data[uiName] = true
    self:setValue("guideInfo", data)
  end
end

function Entity:getGuideData()
  return self:getValue("guideData")
end

function Entity:addGuideData(uiName)
  if not uiName then
    return
  end
  local data = self:getGuideData()
  if not data[uiName] then
    data[uiName] = true
    self:setValue("guideData", data)
  end
end
