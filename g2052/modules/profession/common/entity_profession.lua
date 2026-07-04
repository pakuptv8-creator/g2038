local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.professionId = {
  false,
  true,
  true,
  true,
  {},
  false
}
ValueDef.professionTime = {
  false,
  true,
  true,
  true,
  0,
  false
}
ValueDef.nameContent = {
  false,
  true,
  true,
  true,
  "",
  true
}
ValueDef.nameColor = {
  false,
  true,
  true,
  true,
  "FFFFFF",
  true
}
ValueDef.introduceContent = {
  false,
  true,
  true,
  true,
  "",
  true
}
ValueDef.introduceColor = {
  false,
  true,
  true,
  true,
  "FFFFFF",
  true
}

function Entity:getProfessionId()
  return self:getValue("professionId").professionId or 0
end

function Entity:setProfessionId(professionId, isFromScene)
  local oldData = self:getValue("professionId")
  local oldJobId = self:getProfessionId()
  local oldJobTime = self:getValue("professionTime")
  if oldJobId ~= 0 then
    local defaultData = {
      job_id = oldJobId,
      job_time = os.time() - oldJobTime
    }
    Plugins.CallTargetPluginFunc("report", "report", "job_call", defaultData, self)
  end
  oldData.professionId = professionId
  oldData.isFromScene = isFromScene
  self:setValue("professionId", oldData)
  self:setValue("professionTime", os.time())
  if professionId and 0 < professionId then
    if not self.changeProfessionCount then
      self.changeProfessionCount = 0
    end
    self.changeProfessionCount = self.changeProfessionCount + 1
  end
end

function Entity:getNameContent()
  return self:getValue("nameContent")
end

function Entity:setNameContent(nameContent)
  self:setValue("nameContent", nameContent)
end

function Entity:getNameColor()
  return self:getValue("nameColor")
end

function Entity:setNameColor(nameColor)
  self:setValue("nameColor", nameColor)
end

function Entity:getIntroduceContent()
  return self:getValue("introduceContent")
end

function Entity:setIntroduceContent(introduceContent)
  self:setValue("introduceContent", introduceContent)
end

function Entity:getIntroduceColor()
  return self:getValue("introduceColor")
end

function Entity:setIntroduceColor(introduceColor)
  self:setValue("introduceColor", introduceColor)
end
