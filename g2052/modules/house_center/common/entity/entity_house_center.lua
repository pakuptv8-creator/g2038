local HouseConfig = T(Config, "HouseConfig")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local Entity = _ENV.Entity
local ValueDef = T(Entity, "ValueDef")
ValueDef.houseLimitList = {
  false,
  true,
  true,
  false,
  {},
  false
}
ValueDef.lastHouseTransportIndex = {
  false,
  true,
  true,
  false,
  1,
  false
}
ValueDef.houseTransportIndexInit = {
  false,
  true,
  true,
  false,
  false,
  false
}
ValueDef.monitorUsingRecord = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef.allHouseFlag = {
  false,
  false,
  false,
  false,
  -1,
  true
}

function Entity:getHouseLimitList()
  return self:getValue("houseLimitList")
end

function Entity:setHouseLimitList(data)
  self:setValue("houseLimitList", data)
end

function Entity:getLastHouseTransportIndex()
  local hasInit = self:getValue("houseTransportIndexInit")
  if not hasInit then
    self:setValue("houseTransportIndexInit", true)
    if self.getFirstVacantHouseIndex then
      local idx = self:getFirstVacantHouseIndex()
      self:setLastHouseTransportIndex(idx)
      return idx
    end
  end
  return self:getValue("lastHouseTransportIndex")
end

function Entity:setLastHouseTransportIndex(index)
  self:setValue("lastHouseTransportIndex", index)
end

function Entity:addMonitorUsingRecord(userId)
  local curRecord = self:getValue("monitorUsingRecord")
  curRecord[userId] = true
  self:setValue("monitorUsingRecord", curRecord)
end

function Entity:removeMonitorUsingRecord(userId)
  local curRecord = self:getValue("monitorUsingRecord")
  if curRecord[userId] then
    curRecord[userId] = nil
    self:setValue("monitorUsingRecord", curRecord)
  end
end

function Entity:getMonitorUsingRecord()
  return self:getValue("monitorUsingRecord")
end

function Entity:getAllHouseFlag()
  local flag = self:getValue("allHouseFlag")
  if flag == nil then
    flag = -1
  end
  return flag
end

function Entity:updateAllHouseFlag()
  local flag = self:getAllHouseFlag()
  if flag ~= nil and flag == 1 then
    return
  end
  local oldFlag = flag
  local isAllUnlock = false
  local tabGoods = BusinessGoodsConfig:getAllByTabType(Define.BUSINESS_ITEM_TYPE.House)
  if tabGoods and next(tabGoods) then
    isAllUnlock = true
    local itemId, houseConfig
    for _, v in pairs(tabGoods) do
      itemId = v.itemId
      houseConfig = HouseConfig:getCfgById(itemId)
      if not houseConfig or not self:checkHouseUnlock(houseConfig) then
        isAllUnlock = false
        break
      end
    end
  else
    isAllUnlock = true
  end
  if isAllUnlock then
    flag = 1
  else
    flag = 0
  end
  if oldFlag ~= flag then
    self:setValue("allHouseFlag", flag)
    local HighlightDataHandler = T(Lib, "HighlightDataHandler")
    HighlightDataHandler:reportHighlightData(self.platformUserId, "g2052", "allHouseFlag", flag)
  end
end
