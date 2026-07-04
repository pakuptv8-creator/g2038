local ShipManagerHelper = T(Lib, "ShipManagerHelper")

local function tableNum(array)
  local num = 0
  for _, _ in pairs(array or {}) do
    num = num + 1
  end
  return num
end

function ShipManagerHelper:init()
  self.outRegionList = {}
  self.lastCreateTime = {}
  self.newPlaneIDList = {}
  self.inRegionList = {}
  self.regionCreateInfo = {}
  self.shipNameList = {}
  for _, val in pairs(World.cfg.vehicleSetting.shipInfo.bornList) do
    self.outRegionList[val.cfgName] = {}
    if not self.lastCreateTime[val.regionName] then
      self.lastCreateTime[val.regionName] = {}
    end
    self.lastCreateTime[val.regionName][val.cfgName] = 0
    if not self.inRegionList[val.regionName] then
      self.inRegionList[val.regionName] = {}
    end
    self.inRegionList[val.regionName][val.cfgName] = {}
    if not self.newPlaneIDList[val.regionName] then
      self.newPlaneIDList[val.regionName] = {}
    end
    self.newPlaneIDList[val.regionName][val.cfgName] = {}
    if not self.regionCreateInfo[val.regionName] then
      self.regionCreateInfo[val.regionName] = {}
    end
    self.regionCreateInfo[val.regionName][val.cfgName] = val.createCD
    self.shipNameList[val.cfgName] = true
  end
  self.playerLoginEnd = false
end

function ShipManagerHelper:updatePlayerLoginState(val)
  self.playerLoginEnd = val
end

function ShipManagerHelper:updateShipList()
  if not Lib.isGameDrama() then
    return
  end
  if not DramaManager:checkInTemplateMod(Define.DramaTemplateKey.FLOOD) then
    return
  end
  if not self.playerLoginEnd then
    return
  end
  if not self.lastUpdateTime then
    self.lastUpdateTime = os.time()
    return
  end
  if os.time() - self.lastUpdateTime < 10 then
    return
  end
  for shipName, _ in pairs(self.shipNameList) do
    local outNum = tableNum(self.outRegionList[shipName])
    local totalNum = outNum
    for _, val in pairs(World.cfg.vehicleSetting.shipInfo.bornList) do
      local inNum = tableNum(self.inRegionList[val.regionName][shipName])
      totalNum = inNum + totalNum
    end
    for _, val in pairs(World.cfg.vehicleSetting.shipInfo.bornList) do
      if val.cfgName == shipName then
        if self.newPlaneIDList[val.regionName][shipName] and self.newPlaneIDList[val.regionName][shipName].createTime and os.time() - self.newPlaneIDList[val.regionName][shipName].createTime > 30 then
          local curObjId = self.newPlaneIDList[val.regionName][shipName].objID
          local shipEntity = World.CurWorld:getEntity(curObjId)
          if shipEntity and shipEntity:isValid() then
            shipEntity:destroy()
          end
          if self.outRegionList[shipName][curObjId] then
            self.outRegionList[shipName][curObjId].noneTime = nil
          end
          self.newPlaneIDList[val.regionName][shipName] = {}
          self.inRegionList[val.regionName][shipName][curObjId] = nil
        end
        local inNum = tableNum(self.inRegionList[val.regionName][shipName])
        if self:checkIsCanCreateTime(inNum, totalNum, val.regionName, shipName) then
          if self.lastCreateTime[val.regionName][shipName] then
            if os.time() - self.lastCreateTime[val.regionName][shipName] >= self.regionCreateInfo[val.regionName][shipName] then
              local shipEntity = self:createOneNewShip(val, shipName)
              self.lastCreateTime[val.regionName][shipName] = nil
              totalNum = totalNum + 1
              self:enterShipRegion(shipEntity, val.regionName)
            end
          else
            self.lastCreateTime[val.regionName][shipName] = os.time()
          end
        else
          self.lastCreateTime[val.regionName][shipName] = nil
        end
      end
    end
    if 0 < outNum then
      self:updateOutShipShow(shipName)
    end
  end
end

function ShipManagerHelper:checkIsCanCreateTime(inNum, totalNum, regionName, shipName)
  if 0 < inNum then
    return false
  end
  if totalNum >= World.cfg.vehicleSetting.shipInfo.maxCount[shipName] then
    return false
  end
  if self.newPlaneIDList[regionName][shipName] and self.newPlaneIDList[regionName][shipName].objID then
    return false
  end
  return true
end

function ShipManagerHelper:createOneNewShip(regionInfo, shipName)
  local params = {
    cfgName = regionInfo.cfgName,
    map = regionInfo.bornMap,
    pos = {
      x = regionInfo.bornPos.x,
      y = regionInfo.bornPos.y,
      z = regionInfo.bornPos.z
    },
    ry = regionInfo.bornYaw,
    rp = regionInfo.bornPitch
  }
  local shipEntity = EntityServer.Create(params)
  self.newPlaneIDList[regionInfo.regionName][shipName] = {
    objID = shipEntity.objID,
    createTime = os.time()
  }
  return shipEntity
end

function ShipManagerHelper:enterShipRegion(entity, regionName)
  local cfg = entity:cfg()
  if cfg and cfg.isShip and self.inRegionList[regionName][cfg.cfgName] then
    self.inRegionList[regionName][cfg.cfgName][entity.objID] = entity
    self.outRegionList[cfg.cfgName][entity.objID] = nil
    if self.newPlaneIDList[regionName][cfg.cfgName] and self.newPlaneIDList[regionName][cfg.cfgName].objID == entity.objID then
      self.newPlaneIDList[regionName][cfg.cfgName] = {}
    end
  end
end

function ShipManagerHelper:leaveShipRegion(entity, regionName)
  local cfg = entity:cfg()
  if cfg and cfg.isShip and self.inRegionList[regionName][cfg.cfgName] then
    self.inRegionList[regionName][cfg.cfgName][entity.objID] = nil
    self.outRegionList[cfg.cfgName][entity.objID] = {
      shipEntity = entity,
      leaveTime = os.time()
    }
  end
end

function ShipManagerHelper:updateOutShipShow(shipName)
  for objID, planeInfo in pairs(self.outRegionList[shipName]) do
    local shipEntity = planeInfo.shipEntity
    if shipEntity and shipEntity:isValid() then
      local passengers = shipEntity:data("passengers")
      local havePassenger = next(passengers)
      if not havePassenger then
        if self.outRegionList[shipName][objID] and self.outRegionList[shipName][objID].noneTime then
          if os.time() - self.outRegionList[shipName][objID].noneTime >= World.cfg.vehicleSetting.shipInfo.destroyCD[shipName] then
            shipEntity:destroy()
            self.outRegionList[shipName][objID].noneTime = nil
          end
        elseif self.outRegionList[shipName][objID] then
          self.outRegionList[shipName][objID].noneTime = os.time()
        end
      elseif self.outRegionList[shipName][objID] then
        self.outRegionList[shipName][objID].noneTime = nil
      end
    else
      self.outRegionList[shipName][objID] = nil
    end
  end
end

ShipManagerHelper:init()
