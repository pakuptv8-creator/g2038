local table_insert = table.insert
local CarConfig = T(Config, "CarConfig")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
local ValueDef = T(Entity, "ValueDef")
ValueDef.inUseCar = {
  false,
  false,
  true,
  true,
  nil,
  false
}
ValueDef.useCarTime = {
  false,
  false,
  false,
  false,
  {},
  false
}
ValueDef.useCarCount = {
  false,
  false,
  false,
  false,
  0,
  false
}
ValueDef.inUseOilGunID = {
  false,
  false,
  false,
  false,
  nil,
  false
}
ValueDef.allVehicleFlag = {
  false,
  false,
  false,
  false,
  -1,
  true
}
local Entity = _ENV.Entity

function Entity:getAllVehicle()
  local allCfg = CarConfig:getAllCfgs()
  local data = {}
  local exclusionInfo = {}
  if World.isClient then
    local DramaClientHelper = T(Lib, "DramaClientHelper")
    exclusionInfo = DramaClientHelper:getsTemplateExclusionContent(Define.BTN_SORT.CAR)
  else
    exclusionInfo = DramaManager:getsTemplateExclusionContent(Define.BTN_SORT.CAR)
  end
  for _, v in pairs(allCfg) do
    if not exclusionInfo[v.id] then
      table_insert(data, v)
    end
  end
  table.sort(data, function(a, b)
    return a.order < b.order
  end)
  return data
end

function Entity:getInUseCar()
  return self:getValue("inUseCar")
end

function Entity:setInUseCar(carInfo)
  self:setValue("inUseCar", carInfo)
end

function Entity:checkVehicleIsPrimary(id)
  return CarConfig:isPrimaryCar(id)
end

function Entity:checkVehicleIsAdvanced(id)
  return CarConfig:isAdvancedCar(id)
end

function Entity:recordCarUseTime(carId, act, driverUserId)
  if not carId then
    return
  end
  local record = self:getValue("useCarTime")
  record = {
    time = os.time(),
    id = carId,
    action = act,
    driverUserId = driverUserId
  }
  self:setValue("useCarTime", record)
end

function Entity:clearCarUseTime()
  self:setValue("useCarTime", {})
end

function Entity:addUseCarCountOnce()
  local count = self:getValue("useCarCount")
  count = count + 1
  self:setValue("useCarCount", count)
end

function Entity:getUseCarCount()
  return self:getValue("useCarCount")
end

function Entity:setInUseOilGunID(instanceID)
  self:setValue("inUseOilGunID", instanceID)
end

function Entity:getInUseOilGunID()
  return self:getValue("inUseOilGunID")
end

function Entity:updateAllVehicleFlag()
  local flag = self:getAllVehicleFlag()
  if flag ~= nil and flag == 1 then
    return
  end
  local oldFlag = flag
  local isAllUnlock = false
  local tabGoods = BusinessGoodsConfig:getAllByTabType(Define.BUSINESS_ITEM_TYPE.Car)
  if tabGoods and next(tabGoods) then
    isAllUnlock = true
    local itemId, carConfig
    for _, v in pairs(tabGoods) do
      itemId = v.itemId
      carConfig = CarConfig:getCfgById(itemId)
      if not carConfig or not self:checkCarUnlock(carConfig) then
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
    self:setValue("allVehicleFlag", flag)
    local HighlightDataHandler = T(Lib, "HighlightDataHandler")
    HighlightDataHandler:reportHighlightData(self.platformUserId, "g2052", "allVehicleFlag", flag)
  end
end

function Entity:getAllVehicleFlag()
  local flag = self:getValue("allVehicleFlag")
  if flag == nil then
    flag = -1
  end
  return flag
end
