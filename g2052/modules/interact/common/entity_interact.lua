local ValueDef = T(Entity, "ValueDef")
ValueDef.inIndoor = {
  false,
  true,
  true,
  false,
  false,
  false
}

function Entity:getInIndoor()
  return self:getValue("inIndoor")
end

function Entity:setInIndoor(bool)
  self:setValue("inIndoor", bool)
end

function Entity:checkSex()
  local sex = self:data("main").sex
  if sex == nil and World.isClient then
    if self.objID == Me.objID and Me.userDetailData then
      return Me.userDetailData.sex
    else
      local actorName = self:getActorName()
      if string.find(actorName, "boy") then
        return 1
      else
        return 2
      end
    end
  end
  return self:data("main").sex
end

function Entity:canClearRide(isKeepOldRide)
  if self:isCatchAsRobber() then
    return false
  end
  if isKeepOldRide and self.rideOnId > 0 then
    return false
  end
  return true
end

function Entity:preClearRide()
  if World.isClient then
  elseif self.isPlayer and self:canReleaseRobber() then
    self:releaseRobber()
  end
end

local OldClearRide = Entity.clearRide

function Entity:clearRide()
  self:preClearRide()
  OldClearRide(self)
end

function Entity:tryClearRide(isKeepOldRide)
  if self:canClearRide(isKeepOldRide) then
    self:preClearRide()
    self:rideOn(nil)
    return true
  end
  return false
end

function Entity:onlyClearPlayerHorse(isKeepOldRide)
  if self:canClearRide(isKeepOldRide) then
    self:rideOn(nil)
    return true
  end
  return false
end
