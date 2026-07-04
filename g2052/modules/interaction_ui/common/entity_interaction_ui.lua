local ValueDef = T(Entity, "ValueDef")
local Entity = _ENV.Entity
ValueDef.interactPlayerHorseID = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.interactPlayerUpID = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.playDanceID = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.interactCarEnterID = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.interactionPartID = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.sitPartIdx = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.sitPartAction = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.sitPartPosInfo = {
  false,
  false,
  true,
  true,
  {},
  false
}
ValueDef.singleInteractPartID = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.catchAsRobber = {
  false,
  false,
  false,
  true,
  false,
  false
}
ValueDef.curPlayActionData = {
  false,
  true,
  true,
  true,
  {},
  false
}
ValueDef.interactPartList = {
  false,
  false,
  true,
  true,
  {},
  false
}
ValueDef.paletteData = {
  false,
  true,
  false,
  true,
  nil,
  false
}

function Entity:getInteractPartList()
  return self:getValue("interactPartList")
end

function Entity:setInteractPartList(data)
  self:setValue("interactPartList", data)
end

function Entity:getCurPlayActionData()
  return self:getValue("curPlayActionData")
end

function Entity:setCurPlayActionData(data)
  self:setValue("curPlayActionData", data)
end

function Entity:isCatchAsRobber()
  return self:getValue("catchAsRobber")
end

function Entity:setCatchAsRobber(value)
  self:setValue("catchAsRobber", value)
end

function Entity:getInteractCarEnterID()
  return self:getValue("interactCarEnterID")
end

function Entity:setInteractCarEnterID(id)
  self:setValue("interactCarEnterID", id)
end

function Entity:getInteractPlayerHorseID()
  return self:getValue("interactPlayerHorseID")
end

function Entity:setInteractPlayerHorseID(id)
  self:setValue("interactPlayerHorseID", id)
end

function Entity:getInteractPlayerUpID()
  return self:getValue("interactPlayerUpID")
end

function Entity:setInteractPlayerUpID(id)
  self:setValue("interactPlayerUpID", id)
end

function Entity:getPlayDanceID()
  return self:getValue("playDanceID")
end

function Entity:setPlayDanceID(id)
  self:setValue("playDanceID", id)
end

function Entity:getSingleInteractPartID()
  return self:getValue("singleInteractPartID")
end

function Entity:setSingleInteractPartID(partID)
  self:setValue("singleInteractPartID", partID)
end

function Entity:getInteractionPartID()
  return self:getValue("interactionPartID")
end

function Entity:setInteractionPartID(partID)
  self:setValue("interactionPartID", partID)
end

function Entity:getSitPartPosInfo()
  return self:getValue("sitPartPosInfo")
end

function Entity:setSitPartPosInfo(posInfo)
  self:setValue("sitPartPosInfo", posInfo)
end

function Entity:getSitPartIdx()
  return self:getValue("sitPartIdx")
end

function Entity:setSitPartIdx(idx)
  self:setValue("sitPartIdx", idx)
end

function Entity:getSitPartAction()
  return self:getValue("sitPartAction")
end

function Entity:setSitPartAction(action)
  self:setValue("sitPartAction", action)
end

function Entity:setPaletteData(value)
  self:setValue("paletteData", value)
end

function Entity:getPaletteData()
  return self:getValue("paletteData")
end
