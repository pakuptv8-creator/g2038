local Entity = _ENV.Entity

function Entity:resetSpecialEntityMoveAction(newState, oldState)
  local cfg = self._cfg
  if cfg and cfg.vehicleType == "helicopter" then
    if newState == 12 and oldState == 13 then
      self:setAlwaysAction("fly_front")
    elseif newState == 13 and oldState == 12 then
      self:setAlwaysAction("fly3")
    end
  end
end

function Entity:changeBrightnessScale(brightnessScale)
  local defaultBrightnessScale = self._cfg.brightnessScale or 1.3
  local curBrightnessScale = self:prop("brightnessScale")
  local newBrightnessScale = brightnessScale
  if not Me.isNight then
    newBrightnessScale = defaultBrightnessScale
  end
  if newBrightnessScale ~= curBrightnessScale then
    self:doSetProp("brightnessScale", newBrightnessScale)
  end
end

function Entity:triggerSpringBed(type, target, params)
  if type ~= Define.PART_INTERACT_TYPE.TOUCH_BEGIN then
    return
  end
  local cfg = self:cfg()
  if cfg and cfg.rejectSpringBed then
    return
  end
  if not self:isControl() then
    return
  end
  if params[1] ~= "" then
    local height = 0
    if params.jumpCount then
      height = params.jumpCount * params.jumpCount
    elseif self.previousVantagePoint and self.previousVantagePoint.y then
      local curPos = self:getPosition()
      height = self.previousVantagePoint.y - curPos.y
      if height < 0 then
        height = 0
      end
    end
    local jumpSpeed = math.sqrt(height) * tonumber(params[1])
    local minJumpSpeed = tonumber(params[2]) or 1
    local maxJumpSpeed = tonumber(params[3]) or 4
    if jumpSpeed > maxJumpSpeed then
      jumpSpeed = maxJumpSpeed
    elseif minJumpSpeed > jumpSpeed then
      jumpSpeed = minJumpSpeed
    end
    self:onSpringBed(jumpSpeed)
  end
end

function Entity:onSpringBed(jumpSpeed)
  self:setEntityProp("jumpSpeed", tonumber(jumpSpeed))
  Blockman.Instance():control():jump()
  self:recoverEntityProp("jumpSpeed")
end

function Entity:setEntityProp(prop, value)
  self:recoverEntityProp(prop)
  local curValue = tonumber(self:getEntityProp(prop))
  self:deltaEntityProp(prop, -curValue + tonumber(value))
end

function Entity:updateActorShape(value, shapeEyeHeight)
  self:setActorScale({
    x = value,
    y = value,
    z = value
  })
  self:updateBoundingVolume(value)
  local BoundingBox = self:getBoundingBox()
  if BoundingBox then
    local adaptPos = {
      x = (BoundingBox[2].x + BoundingBox[3].x) / 2,
      y = (BoundingBox[2].y + BoundingBox[3].y) / 2 - 0.89,
      z = (BoundingBox[2].z + BoundingBox[3].z) / 2
    }
    self:data("main").adaptPos = Lib.v3cut(adaptPos, self:getPosition())
  end
  if self.objID == Me.objID then
    local entityCfg = Me:cfg()
    local changeScale = value - 1
    Me:setProp("eyeHeight", entityCfg.eyeHeight + changeScale * shapeEyeHeight)
  end
  if self:data("main").billboardUI then
    local BillboardHelper = T(Lib, "BillboardHelper")
    BillboardHelper:hideBillboardUI(self, self.objID)
    BillboardHelper:showBillboardUI(self, self.objID)
  end
end
