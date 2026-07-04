local ValueDef = T(Entity, "ValueDef")
ValueDef.joinDramaTime = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.giantScale = {
  false,
  false,
  true,
  true,
  1,
  false
}
ValueDef.giantHamburger = {
  false,
  false,
  true,
  true,
  0,
  false
}
ValueDef.giantShape = {
  false,
  false,
  true,
  true,
  1,
  false
}
local Entity = _ENV.Entity

function Entity:setJoinDramaTime(time)
  self:setValue("joinDramaTime", time)
end

function Entity:getJoinDramaTime()
  return self:getValue("joinDramaTime")
end

function Entity:getGiantScale()
  return self:getValue("giantScale")
end

function Entity:setGiantScale(shapeScale)
  self:setValue("giantScale", shapeScale)
  self:updateGiantShape()
end

function Entity:getGiantHamburger()
  return self:getValue("giantHamburger")
end

function Entity:setGiantHamburger(num)
  self:setValue("giantHamburger", num)
  self:updateGiantShape()
end

function Entity:addGiantHamburger(num)
  local val = self:getValue("giantHamburger")
  self:setGiantHamburger(val + num)
end

function Entity:getGiantShape()
  return self:getValue("giantShape")
end

function Entity:updateGiantShape()
  local hamburgerNum = self:getValue("giantHamburger")
  if hamburgerNum > World.cfg.dramaSetting.giantSetting.hamburgerEffectNum then
    hamburgerNum = World.cfg.dramaSetting.giantSetting.hamburgerEffectNum
  end
  local shapeScale = self:getValue("giantScale") * (1 + hamburgerNum * World.cfg.dramaSetting.giantSetting.hamburgerScale)
  self:setValue("giantShape", shapeScale)
  self:updateBoundingVolume(shapeScale)
  if shapeScale == 1 then
    self:updateInitBoundBox()
  end
  local changeScale = shapeScale - 1
  local entityCfg = self:cfg()
  local moveSpeedOffset = changeScale * World.cfg.dramaSetting.giantSetting.shapeMoveSpeed
  self:setMoveSpeedOffset(moveSpeedOffset)
  self:resetMoveSpeed()
  self:setProp("jumpSpeed", entityCfg.jumpSpeed + changeScale * World.cfg.dramaSetting.giantSetting.shapeJumpSpeed)
end
