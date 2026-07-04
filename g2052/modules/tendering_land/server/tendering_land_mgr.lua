TenderingLandMgr = {}
local setting = require("common.setting")
local PartCfg = setting:mod("part")
local TenderingConfig = T(Config, "TenderingConfig")
local getBuildingCfg
local roomGameConfig = Server.CurServer:getConfig()
local regionId = roomGameConfig:getRegionId()
local participateInLand = {}
local mapsForBidding = World.cfg.mapsForBidding or {map001 = true}
local blockInfoMap = {}

function getBuildingCfg(info, isInitial)
  if not info.cfg then
    return
  end
  local buildingPath
  if isInitial then
    buildingPath = info.cfg.initialBuildings
  else
    buildingPath = info.cfg.curBuildings ~= "" and info.cfg.curBuildings or info.cfg.initialBuildings
  end
  if not buildingPath or buildingPath == "" then
    return
  end
  local buildingCfg = PartCfg:get(buildingPath)
  if not buildingCfg then
    Lib.logError("--error-buildingPath-:", buildingPath)
    return
  end
  return buildingCfg
end

function TenderingLandMgr:loadingMapLandInfo(part, map)
  if not self.startLoadingBuildings then
    self.startLoadingBuildings = {}
  end
  if self.startLoadingBuildings[map.name] or not mapsForBidding[map.name] then
    return
  end
  local cfg = TenderingConfig:getCfgByLandNameAndRegionId(part.name, regionId)
  if not participateInLand[map.name] then
    participateInLand[map.name] = {}
  end
  if cfg then
    local rotation = part:getRotation()
    local pos = part:getPosition()
    local instanceId = part:getInstanceID()
    participateInLand[map.name][part.name] = {}
    participateInLand[map.name][part.name].cfg = cfg
    participateInLand[map.name][part.name].instanceId = instanceId
    participateInLand[map.name][part.name].mapId = map.id
    participateInLand[map.name][part.name].rotation = rotation
    participateInLand[map.name][part.name].pos = pos
    participateInLand[map.name][part.name].mapName = map.name
    blockInfoMap[part.name] = participateInLand[map.name][part.name]
  end
end

function TenderingLandMgr:loadingMapBuildings()
  local needLoading = false
  for mapName, v in pairs(participateInLand) do
    if not self.startLoadingBuildings[mapName] then
      self.startLoadingBuildings[mapName] = true
      for _, info in pairs(v or {}) do
        self:createBuildingByLandInfo(info)
        needLoading = true
      end
    end
  end
  if needLoading then
    Plugins.CallPluginFunc("blockDataLoaded")
  end
end

function TenderingLandMgr:createBuildingByLandInfo(info)
  local land = Instance.getByInstanceId(info.instanceId)
  if land and land:isValid() then
    local buildingCfg = getBuildingCfg(info)
    local map = World.CurWorld:getMapById(info.mapId)
    local scene = land:getScene()
    if not (buildingCfg and map) or not scene then
      return
    end
    local targetRotation = info.rotation + info.cfg.rotateOffset
    local targetPos = info.pos + info.cfg.posOffset
    local inst = Lib.createPartHelper(buildingCfg, scene, map, targetRotation, targetPos)
    if inst then
      Plugins.CallTargetPluginFunc("part_manager", "destroyPart", land)
    end
  end
end

function TenderingLandMgr:syncAllInfo(player)
  self:syncInfo("UpdateTenderingLandInfo", participateInLand, player)
end

function TenderingLandMgr:syncInfo(pid, params, player)
  if player and player:isValid() then
    player:sendPacket({pid = pid, params = params})
  else
    WorldServer.BroadcastPacket({pid = pid, params = params})
  end
end

function TenderingLandMgr:getLandInitialBuildingCfgByLandName(mapName, landName)
  local landList = participateInLand[mapName]
  for i, v in pairs(landList or {}) do
    if landName == i then
      return getBuildingCfg(v, true)
    end
  end
  return
end

function TenderingLandMgr:getLandCfgByLandName(mapName, landName)
  local landList = participateInLand[mapName]
  for i, v in pairs(landList or {}) do
    if landName == i then
      return v
    end
  end
  return
end

function TenderingLandMgr:getCurRegionAllLandInfo()
  return participateInLand
end

function TenderingLandMgr:getBlockInfo(partName)
  return blockInfoMap[partName]
end

return TenderingLandMgr
