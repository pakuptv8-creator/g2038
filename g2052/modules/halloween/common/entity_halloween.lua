local HalloweenHelperCommon = T(Lib, "HalloweenHelperCommon")
local ValueDef = T(Entity, "ValueDef")
ValueDef.halloweenCandy = {
  false,
  false,
  true,
  false,
  0,
  true
}
ValueDef.halloweenCandyDayCount = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.halloweenCandyDayPlayer = {
  false,
  false,
  true,
  false,
  {},
  true
}
ValueDef.halloweenFindGhostRecord = {
  false,
  false,
  true,
  false,
  {},
  true
}
local Entity = _ENV.Entity

function Entity:getHalloweenCandy()
  return self:getValue("halloweenCandy")
end

function Entity:changeHalloweenCandy(value)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  if value then
    self:setValue("halloweenCandy", self:getHalloweenCandy() + value)
  end
end

function Entity:getCandyDayCount()
  local data = self:getValue("halloweenCandyDayCount")
  if not data.count then
    data.count = {}
  end
  if not data.date then
    data.date = {}
  end
  return data
end

function Entity:setCandyDayCount(data)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  if data then
    self:setValue("halloweenCandyDayCount", data)
  end
end

function Entity:getCandyDayCountByType(type)
  if not type then
    return 0
  end
  local data = self:getCandyDayCount()
  return data.count[type] or 0
end

function Entity:addCandyDayCount(value, type)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  if not type then
    return
  end
  local data = self:getCandyDayCount()
  if not data.count[type] then
    data.count[type] = 0
  end
  data.count[type] = data.count[type] + value
  data.date[type] = os.date("*t", os.time()).yday
  self:setCandyDayCount(data)
end

function Entity:checkClearCandyDayCount()
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local data = self:getCandyDayCount()
  local curDay = os.date("*t", os.time()).yday
  for k, v in pairs(data.date) do
    print(">>>>>>>>>>>>>>>>>>>>>>>> checkClearCandyDayCount ", k, v)
    if v ~= curDay then
      self:clearCandyDayCount(k)
    end
  end
end

function Entity:clearCandyDayCount(type)
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  if not type then
    return
  end
  local data = self:getCandyDayCount()
  data.count[type] = 0
  self:setCandyDayCount(data)
end

function Entity:clearCandyDayCountAll()
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local data = self:getCandyDayCount()
  for k, _ in pairs(data.count) do
    data.count[k] = 0
  end
  self:setCandyDayCount(data)
end

function Entity:getHalloweenCandyDayPlayer()
  return self:getValue("halloweenCandyDayPlayer")
end

function Entity:addHalloweenCandyDayPlayer(userId)
  local halloweenCandyDayPlayer = self:getValue("halloweenCandyDayPlayer")
  halloweenCandyDayPlayer[userId] = true
  halloweenCandyDayPlayer.date = os.date("*t", os.time()).yday
  self:setValue("halloweenCandyDayPlayer", halloweenCandyDayPlayer)
end

function Entity:cleanHalloweenCandyDayPlayer()
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  self:setValue("halloweenCandyDayPlayer", {})
end

function Entity:checkClearHalloweenCandyDayPlayer()
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  local data = self:getHalloweenCandyDayPlayer()
  if data.date then
    local curDay = os.date("*t", os.time()).yday
    if curDay ~= data.date then
      self:cleanHalloweenCandyDayPlayer()
    end
  end
end

function Entity:getHalloweenFindGhostRecord()
  return self:getValue("halloweenFindGhostRecord")
end

function Entity:addHalloweenFindGhostRecord(ghostId)
  if not ghostId then
    return
  end
  local data = self:getHalloweenFindGhostRecord()
  data[ghostId] = true
  self:setValue("halloweenFindGhostRecord", data)
end

function Entity:clearHalloweenFindGhostRecord()
  if not HalloweenHelperCommon:isHalloweenDay() then
    return
  end
  self:setValue("halloweenFindGhostRecord", {})
end
