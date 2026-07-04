local ValueDef = T(Entity, "ValueDef")
ValueDef[Define.APPEARANCE_VAR_KEY.ShapeScale] = {
  false,
  false,
  true,
  true,
  1,
  true
}
ValueDef[Define.APPEARANCE_VAR_KEY.ShapeInfo] = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef[Define.APPEARANCE_VAR_KEY.OriginalSkin] = {
  false,
  false,
  true,
  false,
  {},
  false
}
ValueDef[Define.APPEARANCE_VAR_KEY.ExclusiveParts] = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef[Define.APPEARANCE_VAR_KEY.InitBoundBox] = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef[Define.APPEARANCE_VAR_KEY.DressCount] = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.freeAdStartTime = {
  false,
  false,
  true,
  false,
  {},
  false
}
local Entity = _ENV.Entity

function Entity:getFreeAdStartTime()
  return self:getValue("freeAdStartTime")
end

function Entity:setFreeAdStartTime(value)
  self:setValue("freeAdStartTime", value)
end

function Entity:setOneFreeAdStartTime(dressId, time)
  local freeAdStartTime = self:getValue("freeAdStartTime")
  freeAdStartTime[dressId] = time
  self:setFreeAdStartTime(freeAdStartTime)
end

function Entity:getOneFreeAdStartTime(dressId)
  return self:getValue("freeAdStartTime")[dressId]
end

function Entity:getShapeScale()
  return self:getValue(Define.APPEARANCE_VAR_KEY.ShapeScale)
end

function Entity:setShapeScale(shapeScale)
  self:setValue(Define.APPEARANCE_VAR_KEY.ShapeScale, shapeScale)
  self:updateBoundingVolume(shapeScale)
  if shapeScale == 1 then
    self:updateInitBoundBox()
  end
end

function Entity:clearShapeInfo()
  self:setValue(Define.APPEARANCE_VAR_KEY.ShapeInfo, {})
end

function Entity:getShapeInfo()
  return self:getValue(Define.APPEARANCE_VAR_KEY.ShapeInfo)
end

function Entity:setOriginalSkin(skinData)
  self:setValue(Define.APPEARANCE_VAR_KEY.OriginalSkin, skinData)
end

function Entity:getOriginalSkin()
  return self:getValue(Define.APPEARANCE_VAR_KEY.OriginalSkin)
end

function Entity:setExclusiveParts(exclusiveParts)
  self:setValue(Define.APPEARANCE_VAR_KEY.ExclusiveParts, exclusiveParts)
end

function Entity:getExclusiveParts()
  return self:getValue(Define.APPEARANCE_VAR_KEY.ExclusiveParts)
end

function Entity:updateInitBoundBox()
  local boundingBox = self:getBoundingBox()
  local box = {
    x = boundingBox[3].x - boundingBox[2].x,
    y = boundingBox[3].y - boundingBox[2].y,
    z = boundingBox[3].z - boundingBox[2].z
  }
  self:setInitBoundBox(box)
end

function Entity:setInitBoundBox(initBoundBox)
  self:setValue(Define.APPEARANCE_VAR_KEY.InitBoundBox, initBoundBox)
end

function Entity:getInitBoundBox()
  return self:getValue(Define.APPEARANCE_VAR_KEY.InitBoundBox)
end

function Entity:updateBoundingVolume(shapeScale)
  local radius = World.cfg.shapeScaleBox.radius
  local height = World.cfg.shapeScaleBox.height
  local boxTable = {
    boundingVolume = {
      type = "Capsule",
      params = {
        0,
        (shapeScale * height + shapeScale * radius) / 2,
        0,
        shapeScale * radius,
        shapeScale * height - shapeScale * radius
      }
    }
  }
  self:setBoundingVolume(boxTable)
end

function Entity:addDressCountOnce()
  local count = self:getValue(Define.APPEARANCE_VAR_KEY.DressCount)
  count = count + 1
  self:setValue(Define.APPEARANCE_VAR_KEY.DressCount, count)
end

function Entity:getDressCount()
  return self:getValue(Define.APPEARANCE_VAR_KEY.DressCount)
end
