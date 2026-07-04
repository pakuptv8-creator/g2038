local ValueDef = T(Entity, "ValueDef")
ValueDef.playerPersonView = {
  false,
  true,
  true,
  false,
  1,
  true
}
ValueDef.playerCurArea = {
  false,
  true,
  false,
  false,
  {},
  false
}
ValueDef.playSpecialBgm = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.curInteractiveSound = {
  false,
  false,
  true,
  true,
  "",
  false
}
ValueDef.curWatchTelevision = {
  false,
  false,
  true,
  false,
  nil,
  false
}
ValueDef.gravityOffset = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.floatState = {
  false,
  false,
  true,
  false,
  false,
  false
}
ValueDef.moveSpeedOffset = {
  false,
  false,
  true,
  false,
  0,
  false
}
ValueDef.isAutoPlayVoice = {
  false,
  true,
  true,
  false,
  true,
  true
}
ValueDef.textVipColor = {
  false,
  true,
  true,
  true,
  "FFFFFF",
  true
}
ValueDef.activityDress = {
  false,
  false,
  true,
  true,
  {},
  true
}
ValueDef.activityPet = {
  false,
  false,
  true,
  true,
  {},
  true
}
ValueDef.activityCar = {
  false,
  false,
  true,
  true,
  {},
  true
}
ValueDef.activityHouse = {
  false,
  false,
  true,
  true,
  {},
  true
}
ValueDef.isWatchedAd = {
  false,
  false,
  true,
  false,
  false,
  false
}

function Entity:getIsWatchedAd()
  return self:getValue("isWatchedAd")
end

function Entity:setIsWatchedAd(val)
  self:setValue("isWatchedAd", val)
end

function Entity:getCurWatchTelevision()
  return self:getValue("curWatchTelevision")
end

function Entity:updateCurWatchTelevision(id)
  local oldTelevisionId = self:getValue("curWatchTelevision")
  if oldTelevisionId and oldTelevisionId ~= id then
    self:exitWatchTelevision(oldTelevisionId)
  end
  self:setValue("curWatchTelevision", id)
end

function Entity:getTextVipColor()
  return self:getValue("textVipColor")
end

function Entity:setTextVipColor(value)
  self:setValue("textVipColor", value)
end

function Entity:getIsAutoPlayVoice()
  return self:getValue("isAutoPlayVoice")
end

function Entity:setIsAutoPlayVoice(value)
  self:setValue("isAutoPlayVoice", value)
end

function Entity:getPlayerCurArea()
  return self:getValue("playerCurArea")
end

function Entity:setPlayerCurArea(areaName)
  self:setValue("playerCurArea", areaName)
end

function Entity:getPlaySpecialBgm()
  return self:getValue("playSpecialBgm")
end

function Entity:setPlaySpecialBgm(bool)
  self:setValue("playSpecialBgm", bool)
end

function Entity:getCurInteractiveSound()
  return self:getValue("curInteractiveSound")
end

function Entity:setCurInteractiveSound(key)
  self:setValue("curInteractiveSound", key)
end

function Entity:updateSeesawAction()
  local passengers = self:data("passengers")
  local anim = "idle"
  if passengers then
    if passengers[1] then
      anim = "idle1"
    end
    if passengers[2] then
      if anim == "idle1" then
        anim = "shake"
      else
        anim = "idle2"
      end
    end
  end
  if World.isClient then
    self:updateUpperAction(anim, -1, false)
  else
    EntityServer.playAction({
      entity = self,
      actionName = anim,
      actionTime = -1,
      includeSelf = true
    })
  end
end

function Entity:updateRockingcarAction()
  local passengers = self:data("passengers")
  local anim = "idle"
  if passengers and passengers[1] then
    anim = "shake"
  end
  if World.isClient then
    self:updateUpperAction(anim, -1, false)
  else
    EntityServer.playAction({
      entity = self,
      actionName = anim,
      actionTime = -1,
      includeSelf = true
    })
  end
end

function Entity:getGravityOffset()
  return self:getValue("gravityOffset")
end

function Entity:setGravityOffset(value)
  self:setValue("gravityOffset", value)
end

function Entity:getMoveSpeedOffset()
  return self:getValue("moveSpeedOffset")
end

function Entity:setMoveSpeedOffset(value)
  self:setValue("moveSpeedOffset", value)
end

function Entity:resetMoveSpeed()
  local cfg = self:cfg()
  local curValue = (cfg.moveSpeed or 0.3) + self:getMoveSpeedOffset()
  self:setProp("moveSpeed", curValue)
end

function Entity:getFloatState()
  return self:getValue("floatState")
end

function Entity:setFloatState(state)
  self:setValue("floatState", state)
end

function Entity:isInFloatState()
  return self:getFloatState()
end

function Entity:resetInitGravity()
  if not self:isInFloatState() then
    local cfg = self:cfg()
    local curValue = cfg.gravity or 0.08
    if self.getGravityOffset then
      curValue = curValue + self:getGravityOffset()
    end
    self:setProp("gravity", curValue)
  end
end

function Entity:resetInitMoveSpeed()
  local cfg = self:cfg()
  self:resetMoveSpeed()
  self:setProp("walkSpeedRate", cfg.walkSpeedRate or 0.5)
  self:setProp("sprintUpRate", cfg.sprintUpRate or 2)
end

function Entity:getActivityDress()
  return self:getValue("activityDress")
end

function Entity:addActivityDress(itemId)
  local activityDress = self:getValue("activityDress")
  activityDress[itemId] = true
  self:setValue("activityDress", activityDress)
end

function Entity:checkActivityDressIsUnlock(itemId)
  local activityDress = self:getValue("activityDress")
  return activityDress[itemId]
end

function Entity:getActivityPet()
  return self:getValue("activityPet")
end

function Entity:addActivityPet(itemId)
  local activityPet = self:getValue("activityPet")
  activityPet[itemId] = true
  self:setValue("activityPet", activityPet)
end

function Entity:checkActivityPetIsUnlock(itemId)
  local activityPet = self:getValue("activityPet")
  return activityPet[itemId]
end

function Entity:getActivityCar()
  return self:getValue("activityCar")
end

function Entity:addActivityCar(itemId)
  local activityCar = self:getValue("activityCar")
  activityCar[itemId] = true
  self:setValue("activityCar", activityCar)
end

function Entity:checkActivityCarIsUnlock(itemId)
  local activityCar = self:getValue("activityCar")
  return activityCar[itemId]
end

function Entity:getActivityHouse()
  return self:getValue("activityHouse")
end

function Entity:addActivityHouse(itemId)
  local activityHouse = self:getValue("activityHouse")
  activityHouse[itemId] = true
  self:setValue("activityHouse", activityHouse)
end

function Entity:checkActivityHouseIsUnlock(itemId)
  local activityCar = self:getValue("activityHouse")
  return activityCar[itemId]
end
