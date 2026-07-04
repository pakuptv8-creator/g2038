local HelicopterManagerHelper = T(Lib, "HelicopterManagerHelper")
local ShipManagerHelper = T(Lib, "ShipManagerHelper")

local function tableNum(array)
  local num = 0
  for _, _ in pairs(array) do
    num = num + 1
  end
  return num
end

function HelicopterManagerHelper:init()
  self.outRegionList = {}
  self.lastCreateTime = {}
  self.newPlaneIDList = {}
  self.inRegionList = {}
  for _, val in pairs(World.cfg.helicopterInfo.bornList) do
    self.lastCreateTime[val.regionName] = 0
    self.inRegionList[val.regionName] = {}
    self.newPlaneIDList[val.regionName] = nil
  end
  World.Timer(20, function()
    self:updateHelicopterList()
    ShipManagerHelper:updateShipList()
    return true
  end)
end

function HelicopterManagerHelper:updateHelicopterList()
  local outNum = tableNum(self.outRegionList)
  local totalNum = outNum
  for _, val in pairs(World.cfg.helicopterInfo.bornList) do
    local inNum = tableNum(self.inRegionList[val.regionName])
    totalNum = inNum + totalNum
  end
  for _, val in pairs(World.cfg.helicopterInfo.bornList) do
    local inNum = tableNum(self.inRegionList[val.regionName])
    if self:checkIsCanCreateTime(inNum, totalNum, val.regionName) then
      if self.lastCreateTime[val.regionName] then
        if os.time() - self.lastCreateTime[val.regionName] >= World.cfg.helicopterInfo.createCD then
          self:createOneNewHelicopter(val)
          self.lastCreateTime[val.regionName] = nil
          totalNum = totalNum + 1
        end
      else
        self.lastCreateTime[val.regionName] = os.time()
      end
    else
      self.lastCreateTime[val.regionName] = nil
    end
  end
  if 0 < outNum then
    self:updateOutHelicopterShow()
  end
end

function HelicopterManagerHelper:checkIsCanCreateTime(inNum, totalNum, regionName)
  if 0 < inNum then
    return false
  end
  if totalNum >= World.cfg.helicopterInfo.maxCount then
    return false
  end
  if self.newPlaneIDList[regionName] then
    return false
  end
  return true
end

function HelicopterManagerHelper:createOneNewHelicopter(regionInfo)
  local params = {
    cfgName = World.cfg.helicopterInfo.cfgName,
    map = regionInfo.bornMap,
    pos = {
      x = regionInfo.bornPos.x,
      y = regionInfo.bornPos.y,
      z = regionInfo.bornPos.z
    },
    ry = regionInfo.bornYaw,
    rp = regionInfo.bornPitch
  }
  local planeEntity = EntityServer.Create(params)
  self.newPlaneIDList[regionInfo.regionName] = planeEntity.objID
end

function HelicopterManagerHelper:enterPoliceRegion(entity, regionName)
  local cfg = entity:cfg()
  if cfg and cfg.isAircraft then
    self.inRegionList[regionName][entity.objID] = entity
    self.outRegionList[entity.objID] = nil
    if self.newPlaneIDList[regionName] == entity.objID then
      self.newPlaneIDList[regionName] = nil
    end
  end
end

function HelicopterManagerHelper:leavePoliceRegion(entity, regionName)
  local cfg = entity:cfg()
  if cfg and cfg.isAircraft then
    self.inRegionList[regionName][entity.objID] = nil
    self.outRegionList[entity.objID] = {
      planeEntity = entity,
      leaveTime = os.time()
    }
  end
end

function HelicopterManagerHelper:updateOutHelicopterShow()
  for objID, planeInfo in pairs(self.outRegionList) do
    local planeEntity = planeInfo.planeEntity
    if planeEntity and planeEntity:isValid() then
      local isOnGround = planeEntity.onGround
      local passengers = planeEntity:data("passengers")
      local havePassenger = next(passengers)
      if not havePassenger then
        if self.outRegionList[objID].noneTime then
          if os.time() - self.outRegionList[objID].noneTime >= World.cfg.helicopterInfo.destroyCD then
            planeEntity:destroy()
            self.outRegionList[objID].noneTime = nil
          end
        else
          self.outRegionList[objID].noneTime = os.time()
        end
      else
        self.outRegionList[objID].noneTime = nil
      end
    else
      self.outRegionList[objID] = nil
    end
  end
end

HelicopterManagerHelper:init()
