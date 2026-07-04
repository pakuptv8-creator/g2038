local setting = require("common.setting")
local PartCfg = setting:mod("part")
local HouseConfig = T(Config, "HouseConfig")
local DisasterConfig = T(Config, "DisasterConfig")
local InteractEventConfig = T(Config, "InteractEventConfig")
local MessageNoticeManager = T(Lib, "MessageNoticeManager")
local BusinessGoodsConfig = T(Config, "BusinessGoodsConfig")
HouseManager = {}
HouseManager.createTimeList = {}
local createHouseCd = World.cfg.createHouseCd or 60
local createPartHelper
local locationIndex = 0
local landIndex = {}
local inspectLocationTime = World.cfg.inspectLocationTime or 20
local houseTransferPos = World.cfg.houseTransferPos or {
  x = 0,
  y = 5,
  z = -25
}

local function syncHouseInfo(pid, params, targetId)
  if targetId then
    local player = Game.GetPlayerByUserId(targetId)
    if not player or not player:isValid() then
      return
    end
    player:sendPacket({pid = pid, params = params})
  else
    WorldServer.BroadcastPacket({pid = pid, params = params})
  end
end

local function getLocationInitPosInfo(pos, rotation, landName, map)
  local initPosInfo = {}
  local rotate = Lib.v3(rotation.x, rotation.y, rotation.z)
  local yaw = rotate.y * -1
  local landInfo = HouseConfig:getLandInfo(landName) or {}
  local offset = landInfo.houseTransferPos or Lib.v3(0, 0, 0)
  initPosInfo.pos = pos + Lib.correctMoveDistance(rotate, offset)
  local map = World.CurWorld:getMapById(map.id)
  initPosInfo.map = map and map.name
  initPosInfo.yaw = yaw
  return initPosInfo
end

function HouseManager:init()
  self.locationList = {}
  self.locationCfgs = {}
  World.Timer(20 * inspectLocationTime, function()
    self:inspectLocation()
    return true
  end)
end

function HouseManager:inspectLocation()
  for id, v in pairs(self.locationList) do
    if v.ownerId then
      local player = Game.GetPlayerByUserId(v.ownerId)
      if not player or not player:isValid() then
        self:breakAwayFromLocation(v.ownerId)
      end
    end
  end
  return true
end

function HouseManager:verifyHouseVip(player, locationId, houseName, checkAdFree)
  if not self.locationList[locationId] then
    return
  end
  local landInfo = HouseConfig:getHouseInfoByCfgName(self.locationList[locationId].landName, houseName)
  if landInfo then
    if landInfo.needPrivilege ~= 0 then
      local hasVip = Plugins.CallTargetPluginFunc("business_model", "getPlayerPrivilegeInfo", player.platformUserId, landInfo.needPrivilege)
      if hasVip then
        return true
      elseif landInfo.needBuy and 0 < landInfo.needBuy then
        if checkAdFree then
          if player:getIsWatchedAd() then
            return true
          elseif landInfo.id and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", player, Define.BUSINESS_ITEM_TYPE.House, landInfo.id) then
            return true
          end
        end
        local subscribeVipStage = player:getSubscribeVipStage()
        if subscribeVipStage == Define.SubscribeVIPStage.Height then
          local subscribe_vipSetting = World.cfg.subscribe_vipSetting
          for _, houseId in pairs(subscribe_vipSetting.heightVipHouseIdList) do
            if houseId == landInfo.id then
              return true
            end
          end
        end
        local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.House, landInfo.id)
        if goodsCfg then
          local businessData = player:getBusinessData()
          return businessData[goodsCfg.goodsId]
        end
      end
    elseif landInfo.needBuy and 0 < landInfo.needBuy then
      if checkAdFree then
        if player:getIsWatchedAd() then
          return true
        elseif landInfo.id and 0 < Plugins.CallTargetPluginFunc("advertisement_module", "getFreeItemCount", player, Define.BUSINESS_ITEM_TYPE.House, landInfo.id) then
          return true
        end
      end
      local subscribeVipStage = player:getSubscribeVipStage()
      if subscribeVipStage == Define.SubscribeVIPStage.Height then
        local subscribe_vipSetting = World.cfg.subscribe_vipSetting
        for _, houseId in pairs(subscribe_vipSetting.heightVipHouseIdList) do
          if houseId == landInfo.id then
            return true
          end
        end
      end
      local goodsCfg = BusinessGoodsConfig:getCfgByTabTypeAndItemId(Define.BUSINESS_ITEM_TYPE.House, landInfo.id)
      if goodsCfg then
        local businessData = player:getBusinessData()
        return businessData[goodsCfg.goodsId]
      end
    end
    return true
  else
    return
  end
end

function HouseManager:occupyLocation(player, locationId, verify)
  if not self.locationList[locationId] or self.locationList[locationId].ownerId then
    return
  end
  local landInfo = HouseConfig:getLandInfo(self.locationList[locationId].landName)
  if not landInfo then
    return
  else
  end
  if verify then
    return true, self.locationList[locationId]
  end
  local info, id = self:inquireLocationInfoByPlatformUserId(player.platformUserId)
  if info then
    return
  end
  self.locationList[locationId].ownerId = player.platformUserId
  self.locationList[locationId].ownerName = player.name
  self:syncLocationInfo(nil, locationId)
  Plugins.CallTargetPluginFunc("report", "report", "use_new_land", {
    land_id = self.locationList[locationId].index
  }, player)
  return true
end

function HouseManager:locationBeGenerated(location, map, locationCfg)
  local id = location:getInstanceID()
  if locationCfg then
    locationCfg.scene = nil
  end
  if not self.locationList[id] then
    locationIndex = locationIndex + 1
    if not landIndex[location.name] then
      landIndex[location.name] = 0
    end
    landIndex[location.name] = landIndex[location.name] + 1
    local rotation = location:getRotation()
    local pos = location:getPosition()
    local initPosInfo = getLocationInitPosInfo(pos, rotation, location.name, map)
    self.locationCfgs[id] = locationCfg
    self.locationList[id] = {
      id = id,
      landName = location.name,
      ownerId = false,
      houseId = nil,
      houseName = nil,
      pos = pos,
      size = location:getSize(),
      rotation = rotation,
      index = locationIndex,
      landIndex = landIndex[location.name],
      initPosInfo = initPosInfo,
      limitList = {},
      operatingInfo = {},
      mapId = map.id,
      bgm = nil
    }
  end
end

function createPartHelper(cfg, scene, map, targetRotation, targetPos, houseId)
  local inst = Instance.newInstance(cfg, map)
  if inst then
    local nodes = {}
    Lib.getInstanceAllChild(inst, nodes, Define.ABILITY.AABB)
    if targetRotation then
      inst:setRotation(targetRotation)
      for _, v in pairs(nodes) do
        if v.className == "RegionPart" then
          local yaw = targetRotation.y or 0
          yaw = math.floor(math.abs(yaw) + 0.5)
          if yaw == 180 or yaw == 0 and v.getScale and v.setScale then
            local scale = v:getScale()
            v:setScale(Lib.v3(scale.z, scale.y, scale.x))
          end
          break
        end
      end
    end
    if targetPos then
      inst:setPosition(targetPos)
    end
    inst:setParent(scene:getRoot())
  else
    return
  end
  return inst
end

function HouseManager:createHouse(player, locationId, houseName, is_Ad_free)
  if not self:verifyCreateCd(player.platformUserId) then
    return
  end
  local locationInfo = self.locationList[locationId]
  local houseCfg = PartCfg:get(houseName)
  if not houseCfg then
    Lib.logError("--error-houseCfg-:", houseName)
    return
  end
  if not locationInfo or locationInfo.ownerId ~= player.platformUserId then
    return
  end
  local map = World.CurWorld:getMapById(locationInfo.mapId)
  local location = Instance.getByInstanceId(locationId)
  if not location or not location:isValid() then
    return
  end
  local scene = location:getScene()
  local targetRotation = locationInfo.rotation
  local targetPos = locationInfo.pos
  local houseInfo = HouseConfig:getHouseInfoByCfgName(locationInfo.landName, houseName)
  if houseInfo then
    targetRotation = targetRotation + houseInfo.rotateOffset
    targetPos = targetPos + houseInfo.posOffset
  end
  local inst = createPartHelper(houseCfg, scene, map, targetRotation, targetPos, houseInfo.id)
  if inst then
    locationInfo.houseId = inst:getInstanceID()
    locationInfo.houseName = houseName
    locationInfo.createTime = os.time()
    locationInfo.operatingInfo = {}
    self:updateHouseCd(player.platformUserId, locationInfo.createTime)
    self:driveVisitPlayer(locationId)
    World.Timer(20, function()
      Plugins.CallTargetPluginFunc("part_manager", "destroyPart", location)
      self:driveVisitPlayer(locationId)
    end)
    if not player.isFirstCreateHouse then
      local data = {
        house_id = houseInfo and houseInfo.id or 0,
        is_Ad_free = is_Ad_free or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "first_house", data, player)
      player.isFirstCreateHouse = true
    end
    local data = {
      house_id = houseInfo and houseInfo.id or 0,
      is_Ad_free = is_Ad_free or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "g2052_house_create_new", data, player)
    if is_Ad_free == 1 then
      if player:getIsWatchedAd() then
        player:setIsWatchedAd(false)
      elseif houseInfo.id then
        Plugins.CallTargetPluginFunc("advertisement_module", "costFreeItem", player, Define.BUSINESS_ITEM_TYPE.House, houseInfo.id)
      end
    end
    player:addOneHouseCount()
    Plugins.CallTargetPluginFunc("limited_time_activity", "updateHeartWarmTaskProgress", player, Define.HEART_WARM_TASK_TYPE.NEW_HOUSE)
    self:updateLimit(player)
  else
    return
  end
end

function HouseManager:inquireLocationInfoByPlatformUserId(platformUserId)
  for id, info in pairs(self.locationList) do
    if info.ownerId == platformUserId then
      return info, id
    end
  end
  return
end

function HouseManager:inquireLocationInfoById(id)
  if not self.locationList or not self.locationList[id] then
    Lib.logError("get locationInfo fail id:", id)
    return
  end
  return self.locationList[id]
end

function HouseManager:onDismantleHouseByLocationId(id)
  if not self.locationList or not self.locationList[id] then
    Lib.logError("get locationInfo fail id:", id)
    return
  end
  local locationInfo = self.locationList[id]
  local houseId = locationInfo.houseId
  local house = Instance.getByInstanceId(houseId)
  local locationCfg = self.locationCfgs[id]
  local map = World.CurWorld:getMapById(locationInfo.mapId)
  if not house then
    Lib.logError(" not house instance, houseId\239\188\154", houseId)
    return
  end
  local scene = house:getScene()
  local inst = createPartHelper(locationCfg, scene, map)
  if inst then
    self:onPlayerHouseReport(locationInfo.ownerId)
    locationInfo.houseId = nil
    locationInfo.houseName = nil
    locationInfo.createTime = nil
    locationInfo.limitList = {}
    locationInfo.doorplateText = nil
    locationInfo.doorplateTextColor = nil
  else
    Lib.logError(" error locationCfg, locationId\239\188\154", Lib.v2s(locationCfg))
    return
  end
  self:driveVisitPlayer(id)
  locationInfo.bgm = nil
  World.Timer(20, function()
    Plugins.CallTargetPluginFunc("part_manager", "destroyPart", house)
    self:driveVisitPlayer(id)
  end)
  Plugins.CallTargetPluginFunc("emergency", "removeEmergencyEffect", id)
  self:syncLocationInfo(nil, id)
  self:removeGhostDetectorArea()
end

function HouseManager:switchHouseModel(id, houseName, force, is_Ad_free)
  if not self.locationList or not self.locationList[id] then
    Lib.logError("get locationInfo fail id:", id)
    return
  end
  local locationInfo = self.locationList[id]
  if houseName == locationInfo.houseName and not force then
    return
  end
  if not self:verifyCreateCd(locationInfo.ownerId) then
    return
  end
  local houseCfg = PartCfg:get(houseName)
  if not houseCfg then
    Lib.logError("--error-houseCfg-:", houseName)
    return
  end
  local houseId = locationInfo.houseId
  local house = Instance.getByInstanceId(houseId)
  local map = World.CurWorld:getMapById(locationInfo.mapId)
  if not house then
    Lib.logError(" not house instance, houseId\239\188\154", houseId)
    return
  end
  local scene = house:getScene()
  self:driveVisitPlayer(id)
  World.Timer(20, function()
    Plugins.CallTargetPluginFunc("part_manager", "destroyPart", house)
    self:driveVisitPlayer(id)
  end)
  Plugins.CallTargetPluginFunc("emergency", "removeEmergencyEffect", id)
  local targetRotation = locationInfo.rotation
  local targetPos = locationInfo.pos
  local houseInfo = HouseConfig:getHouseInfoByCfgName(locationInfo.landName, houseName)
  if houseInfo then
    targetRotation = targetRotation + houseInfo.rotateOffset
    targetPos = targetPos + houseInfo.posOffset
  end
  local inst = createPartHelper(houseCfg, scene, map, targetRotation, targetPos, houseInfo.id)
  if inst then
    self:onPlayerHouseReport(locationInfo.ownerId)
    locationInfo.houseId = inst:getInstanceID()
    locationInfo.houseName = houseName
    locationInfo.createTime = os.time()
    locationInfo.operatingInfo = {}
    local player = Game.GetPlayerByUserId(locationInfo.ownerId or 0)
    if player and player:isValid() then
      player:addOneHouseCount()
      local data = {
        house_id = houseInfo and houseInfo.id or 0,
        is_Ad_free = is_Ad_free or 0
      }
      Plugins.CallTargetPluginFunc("report", "report", "g2052_house_create_new", data, player)
      if is_Ad_free == 1 then
        if player:getIsWatchedAd() then
          player:setIsWatchedAd(false)
        elseif houseInfo.id then
          Plugins.CallTargetPluginFunc("advertisement_module", "costFreeItem", player, Define.BUSINESS_ITEM_TYPE.House, houseInfo.id)
        end
      end
    end
    self:updateHouseCd(locationInfo.ownerId, locationInfo.createTime)
  else
    Lib.logError(" error locationCfg, locationId\239\188\154", Lib.v2s(houseCfg))
    return
  end
  self:syncLocationInfo(nil, id)
end

function HouseManager:breakAwayFromLocation(platformUserId)
  local curLocationId
  for id, info in pairs(self.locationList) do
    if info.ownerId == platformUserId then
      curLocationId = id
      break
    end
  end
  if curLocationId then
    local houseId = self.locationList[curLocationId].houseId
    if houseId then
      self:onDismantleHouseByLocationId(curLocationId)
    end
    self.locationList[curLocationId].ownerId = false
    self.locationList[curLocationId].ownerName = nil
    self.locationList[curLocationId].doorplateText = nil
    self.locationList[curLocationId].doorplateTextColor = nil
    self:syncLocationInfo(nil, curLocationId)
  end
end

function HouseManager:syncLocationInfo(platformUserId, id)
  local params = {}
  if id and self.locationList then
    local info = self.locationList[id]
    table.insert(params, info)
  else
    for id, info in pairs(self.locationList or {}) do
      table.insert(params, info)
    end
  end
  syncHouseInfo("SyncHouseInfo", params, platformUserId)
  Lib.emitEvent(Event.EVENT_UPDATE_HOUSE_INFO, self.locationList)
end

function HouseManager:getLocationList()
  return self.locationList
end

function HouseManager:verifyingOperationRights(platformUserId, target, type)
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info then
    local houseNode = Instance.getByInstanceId(info.houseId)
    if houseNode and houseNode:isValid() then
      local nodes = {}
      Lib.getInstanceAllChild(houseNode, nodes, Define.ABILITY.AABB, target.name)
      local targetId = target:getInstanceID()
      for i, v in pairs(nodes) do
        if v:getInstanceID() == targetId then
          if type then
            info.operatingInfo[type] = not target.hasTriggered
            self:syncLocationInfo(platformUserId, id)
          end
          return true
        end
      end
    end
  end
  return false
end

function HouseManager:switchAreaLimit(platformUserId)
end

function HouseManager:SwitchLockState(player)
  local platformUserId = player.platformUserId
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    local house = Instance.getByInstanceId(info.houseId)
    local nodes = {}
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName) or {}
    local doorLock = houseInfo.doorLock or "house1_suo"
    Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB, doorLock)
    for _, part in pairs(nodes) do
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.CLICKED, part, player, true)
      info.operatingInfo.inLock = part.hasTriggered
      break
    end
    self:syncLocationInfo(platformUserId, id)
  end
end

function HouseManager:updateLimit(player)
  local info, id = self:inquireLocationInfoByPlatformUserId(player.platformUserId)
  if info then
    info.limitList = player:getHouseLimitList()
    self:driveVisitPlayer(id, info.limitList)
    self:syncLocationInfo(nil, id)
  end
end

function HouseManager:checkPlayerIsOtherVisit(player)
  if not self.visitPlayers then
    return false
  end
  for id, v1 in pairs(self.locationList) do
    if v1.ownerId and self.visitPlayers[id] then
      for i, v2 in pairs(self.visitPlayers[id]) do
        if v2.platformUserId == player.platformUserId then
          return id, v1.ownerId
        end
      end
    end
  end
  return false
end

function HouseManager:setVisitPlayers(player, target, add, locationId)
  if not self.visitPlayers then
    self.visitPlayers = {}
  end
  local id
  if locationId then
    id = locationId
  else
    local parent = target:getParent()
    if not parent then
      return
    end
    id = parent:getInstanceID()
  end
  local isManor = false
  if self.locationList[id] then
    isManor = true
  else
    for i, v in pairs(self.locationList) do
      if v.houseId == id then
        isManor = true
        id = i
        break
      end
    end
  end
  if isManor then
    if not self.visitPlayers[id] then
      self.visitPlayers[id] = {}
    end
    for i, v in pairs(self.visitPlayers[id]) do
      if not v or not v:isValid() then
        self.visitPlayers[id][i] = nil
      end
    end
    if add then
      table.insert(self.visitPlayers[id], player)
      player:setPlaySpecialBgm(true)
      if self.locationList[id].bgm then
        player:sendPacket({
          pid = "updateAreaBgm",
          key = self.locationList[id].bgm
        })
      end
    else
      for i, v in pairs(self.visitPlayers[id]) do
        if v.platformUserId == player.platformUserId then
          if self.locationList[id].bgm then
            v:setPlaySpecialBgm(false)
            v:sendPacket({
              pid = "updateAreaBgm",
              key = "weather"
            })
          end
          self.visitPlayers[id][i] = nil
          break
        end
      end
    end
  end
end

local function verifyingPlayerPermissions(player, list, ownerId)
  if not list then
    return false
  end
  if player.platformUserId == ownerId then
    return true
  end
  for _, id in pairs(list) do
    if id == player.platformUserId then
      return false
    end
  end
  return true
end

function HouseManager:driveVisitPlayer(id, list)
  local locationInfo = self.locationList[id]
  if not locationInfo then
    return
  end
  local initPosInfo = locationInfo.initPosInfo or {}
  if self.visitPlayers and self.visitPlayers[id] then
    for _, v in pairs(self.visitPlayers[id]) do
      if not verifyingPlayerPermissions(v, list, locationInfo.ownerId) then
        if v and v:isValid() then
          v:setMapPos(initPosInfo.map, initPosInfo.pos, initPosInfo.yaw, nil, false, {
            yaw = initPosInfo.yaw
          })
          if list then
            Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", v, "g2052.gui.owner.ask.you.leave")
            Plugins.CallTargetPluginFunc("report", "report", "house_visit_leave", nil, v)
          end
        end
        self:setVisitPlayers(v, nil, nil, id)
      end
    end
    if #self.visitPlayers[id] == 0 then
      self.visitPlayers[id] = nil
    end
  end
  T(Lib, "VehicleManager"):destroyCarsInArea(locationInfo.pos, locationInfo.size)
end

function HouseManager:updateHouseColor(id, color)
  local locationInfo = self.locationList[id]
  if not locationInfo or not locationInfo.houseId then
    return
  end
  local house = Instance.getByInstanceId(locationInfo.houseId)
  if house then
    local houseInfo = HouseConfig:getHouseInfoByCfgName(locationInfo.landName, locationInfo.houseName) or {}
    if houseInfo.colorChangingPart then
      local nodes = {}
      for _, name in pairs(houseInfo.colorChangingPart or {}) do
        Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB, name)
      end
      for _, v in pairs(nodes) do
        if v.setColor then
          v:setColor(color)
        end
      end
    end
  end
end

function HouseManager:controlTheWindow(platformUserId)
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    local house = Instance.getByInstanceId(info.houseId)
    if not house then
      return
    end
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName) or {}
    if houseInfo.glassChangingPart then
      local nodes = {}
      for _, name in pairs(houseInfo.glassChangingPart or {}) do
        Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB, name)
      end
      for i, part in pairs(nodes) do
        local materialAlpha = part:getProperty("materialAlpha")
        local default = "0.95"
        if materialAlpha ~= default then
          if not part.defaultMaterialAlpha then
            part.defaultMaterialAlpha = materialAlpha
          end
          part:setProperty("materialAlpha", default)
        elseif part.defaultMaterialAlpha then
          part:setProperty("materialAlpha", part.defaultMaterialAlpha)
        end
      end
      info.operatingInfo.window = not info.operatingInfo.window
      self:syncLocationInfo(platformUserId, id)
    end
  end
end

function HouseManager:controlGarageDoor(player)
  local platformUserId = player.platformUserId
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName) or {}
    local house = Instance.getByInstanceId(info.houseId)
    local nodes = {}
    local garageDoorName = houseInfo.garageDoorName or World.cfg.garageDoorName or "chekumen_switch"
    Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB, garageDoorName)
    for _, part in pairs(nodes) do
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.CLICKED, part, player, true)
      break
    end
  end
end

function HouseManager:updateDoorState(platformUserId, target)
  if not target or not target:isValid() then
    return
  end
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info then
    if not info.operatingInfo.garageDoors then
      info.operatingInfo.garageDoors = {}
    end
    local instanceId = target:getInstanceID()
    info.operatingInfo.garageDoors[instanceId] = target.hasTriggered
    local hasTriggered = false
    for _, v in pairs(info.operatingInfo.garageDoors) do
      if v then
        hasTriggered = not hasTriggered
      end
    end
    info.operatingInfo.garageDoor = hasTriggered
    self:syncLocationInfo(platformUserId, id)
  end
end

function HouseManager:setDoorplateText(platformUserId, dec, color)
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    self.locationList[id].doorplateText = dec
    self.locationList[id].doorplateTextColor = color
    self:syncLocationInfo(nil, id)
  end
end

function HouseManager:onPlayerHouseReport(ownerId)
  local info, id = self:inquireLocationInfoByPlatformUserId(ownerId)
  if not info then
    return
  end
  local player = Game.GetPlayerByUserId(ownerId)
  if player and player:isValid() then
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName)
    local is_Ad_free = 0
    if not HouseManager:verifyHouseVip(player, id, info.houseName) then
      is_Ad_free = 1
    end
    local data = {
      house_id = houseInfo and houseInfo.id or 0,
      house_time = info.createTime and os.time() - info.createTime or 0,
      is_Ad_free = is_Ad_free or 0
    }
    Plugins.CallTargetPluginFunc("report", "report", "create_house", data, player)
  end
end

function HouseManager:onPlayHouseBgmByKey(ownerId, key)
  local info, id = self:inquireLocationInfoByPlatformUserId(ownerId)
  if info and info.houseId and self.visitPlayers then
    self.locationList[id].bgm = key
    for _, v in pairs(self.visitPlayers[id] or {}) do
      v:setPlaySpecialBgm(true)
      v:sendPacket({
        pid = "updateAreaBgm",
        key = key
      })
    end
    self:syncLocationInfo(nil, id)
  end
end

function HouseManager:onStopHouseBgmByKey(ownerId)
  local info, id = self:inquireLocationInfoByPlatformUserId(ownerId)
  if info and info.houseId and self.visitPlayers then
    self.locationList[id].bgm = nil
    for _, v in pairs(self.visitPlayers[id] or {}) do
      v:setPlaySpecialBgm(false)
      v:sendPacket({
        pid = "updateAreaBgm",
        key = "weather"
      })
    end
    self:syncLocationInfo(nil, id)
  end
end

function HouseManager:playCurHouseBgm(userId)
  if not self.visitPlayers then
    return
  end
  for locationId, players in pairs(self.visitPlayers) do
    for i, v in pairs(players or {}) do
      if v.platformUserId == userId and self.locationList[locationId].bgm then
        v:sendPacket({
          pid = "updateAreaBgm",
          key = self.locationList[locationId].bgm
        })
        return true
      end
    end
  end
  return false
end

function HouseManager:updateHouseCd(targetId, time)
  self.createTimeList[targetId] = time
  if not time then
    local info, id = self:inquireLocationInfoByPlatformUserId(targetId)
    if info then
      info.createTime = time
    end
  end
end

function HouseManager:verifyCreateCd(targetId)
  if self.createTimeList[targetId] then
    local canCreate = false
    if os.time() - self.createTimeList[targetId] > createHouseCd then
      canCreate = true
    end
    if not canCreate then
      local player = Game.GetPlayerByUserId(targetId)
      if player and player:isValid() then
        local time = createHouseCd - (os.time() - self.createTimeList[targetId])
        Plugins.CallTargetPluginFunc("fly_tips", "pushServerNormalFlyTipsItem", player, {
          "g2052.gui.house.create.cd",
          time
        })
      end
    end
    return canCreate
  end
  return true
end

function HouseManager:getDisasterSelectState(player)
  local platformUserId = player.platformUserId
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName) or {}
    local house = Instance.getByInstanceId(info.houseId)
    if house and house:isValid() then
      if not house.disasterSelectList then
        house.disasterSelectList = {}
      end
      local temp = {
        maxDisasterNum = houseInfo.maxDisasterNum,
        disasterSelectList = house.disasterSelectList
      }
      return temp
    end
  end
  return
end

function HouseManager:updateDisasterSelectState(player, disasterId)
  local platformUserId = player.platformUserId
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    local houseInfo = HouseConfig:getHouseInfoByCfgName(info.landName, info.houseName) or {}
    local house = Instance.getByInstanceId(info.houseId)
    if house and house:isValid() then
      if not house.disasterSelectList then
        house.disasterSelectList = {}
      end
      local hasNum = 0
      for _, val in pairs(house.disasterSelectList) do
        if val then
          hasNum = hasNum + 1
        end
      end
      if hasNum >= houseInfo.maxDisasterNum and not house.disasterSelectList[disasterId] then
        local temp = {
          maxDisasterNum = houseInfo.maxDisasterNum,
          disasterSelectList = house.disasterSelectList
        }
        return temp
      end
      local disasterCfg = DisasterConfig:getCfgById(disasterId)
      if 1 <= disasterCfg.messageNoticeId then
        if not house.disasterSelectList[disasterId] then
          local checkCD = player:checkSendMessageNoticeCD(disasterCfg.messageNoticeId)
          if checkCD then
            house.onFireNoticeId = MessageNoticeManager:pushMessageNotice(disasterCfg.messageNoticeId, Game.GetAllPlayers(), tostring(info.landIndex))
            player:sendMessageNoticeCDRecord(disasterCfg.messageNoticeId)
          end
        elseif house.onFireNoticeId then
          MessageNoticeManager:deleteMessageNotice(house.onFireNoticeId)
          house.onFireNoticeId = nil
        end
      end
      for _, partName in pairs(disasterCfg.switchPartList) do
        local nodes = {}
        Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB, partName)
        if house.disasterSelectList[disasterId] then
          for _, part in pairs(nodes) do
            if part.isInteracting then
              Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, player, true)
            end
          end
        else
          for _, part in pairs(nodes) do
            Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, player, false)
          end
        end
      end
      if not house.disasterSelectList[disasterId] then
        local defaultData = {house_event_id = disasterId}
        Plugins.CallTargetPluginFunc("report", "report", "house_event", defaultData, player)
      end
      house.disasterSelectList[disasterId] = not house.disasterSelectList[disasterId]
      local temp = {
        maxDisasterNum = houseInfo.maxDisasterNum,
        disasterSelectList = house.disasterSelectList
      }
      return temp
    end
  end
  return
end

function HouseManager:updatePlayerInGhostDetectorArea(isEnter, part, player)
  if not (part and part:isValid()) or not player then
    return
  end
  if not self.playerInGhostDetectorArea then
    self.playerInGhostDetectorArea = {}
  end
  if isEnter then
    if not part:isValid() or not player:isValid() then
      return
    end
    local id = part:getInstanceID()
    if not self.playerInGhostDetectorArea[id] then
      self.playerInGhostDetectorArea[id] = {}
    end
    self.playerInGhostDetectorArea[id][player.platformUserId] = player
  else
    local id = part:getInstanceID()
    if not self.playerInGhostDetectorArea[id] then
      self.playerInGhostDetectorArea[id] = {}
    end
    self.playerInGhostDetectorArea[id][player.platformUserId] = nil
  end
end

function HouseManager:getPlayerInGhostDetectorArea(part)
  if not (part and part:isValid()) or not self.playerInGhostDetectorArea then
    return nil
  end
  return self.playerInGhostDetectorArea[part:getInstanceID()]
end

function HouseManager:notifyPlayerInGhostDetectorArea(areaPart, isBreak)
  local playerList = self:getPlayerInGhostDetectorArea(areaPart)
  if playerList and next(playerList) ~= nil then
    for _, player in pairs(playerList) do
      if player:isValid() then
        local prop = InteractEventConfig:getCfgById(areaPart.name)
        if prop and prop.params then
          local params = prop.params
          if prop.params then
            player:setGhostDetectorStatus(areaPart, tonumber(params[3]), not isBreak)
          end
        end
      else
        print("****************** notifyPlayerInGhostDetectorArea ,player is leave ", player.platformUserId)
      end
    end
  end
end

function HouseManager:removePlayerInGhostDetectorArea(player)
  if not player or not self.playerInGhostDetectorArea then
    return
  end
  for k, v in pairs(self.playerInGhostDetectorArea) do
    v[player.platformUserId] = nil
    print("<<<<------------------------------- removePlayerInGhostDetectorArea ", player.platformUserId, k)
  end
end

function HouseManager:removeGhostDetectorArea()
  if not self.playerInGhostDetectorArea then
    return
  end
  for k, _ in pairs(self.playerInGhostDetectorArea) do
    local part = Instance.getByInstanceId(k)
    if not part or not part:isValid() then
      self.playerInGhostDetectorArea[k] = nil
      print("<<<<<< ------------------------------- removeGhostDetectorArea,instanceId: ", k)
    end
  end
end

function HouseManager:controlLight(player, houseId, value)
  local platformUserId = player.platformUserId
  local info, id = self:inquireLocationInfoByPlatformUserId(platformUserId)
  if info and info.houseId then
    if houseId and info.houseId ~= houseId then
      return
    end
    local house = Instance.getByInstanceId(info.houseId)
    local nodes = {}
    Lib.getInstanceAllChild(house, nodes, Define.ABILITY.AABB)
    for _, part in pairs(nodes) do
      if not part.initBakeLightIntensity then
        part.initBakeLightIntensity = part:getProperty("bakeLightIntensity")
      end
      if part:getProperty("bakeLightIntensity") ~= part.initBakeLightIntensity then
        part:setProperty("bakeLightIntensity", part.initBakeLightIntensity)
      else
        part:setProperty("bakeLightIntensity", value or "0.0")
      end
    end
  end
end
