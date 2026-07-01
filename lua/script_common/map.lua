local lfs = require("lfs")
local setting = require("common.setting")
local mapList = T(World, "mapList")
local staticList = T(World, "staticList")
local nextRegionId = L("nextRegionId", 1)
local idRegions = T(World, "idRegions")
local Map = T(World, "Map")
Map.__index = Map
local Region = T(World, "Region")
Region.__index = Region

function World:loadMap(id, name, static)
  print("loadMap", id, name, static, World.CurWorld:checkEditor(255))
  assert(not mapList[id], id)
  static = not not static
  if static then
    assert(not staticList[name], name)
  end
  local cfg = Map.GetCfg(name)
  local useRemoteMap = cfg.useRemoteMap
  local openedExclusively = World.CurWorld:checkEditor(255) or World.gameCfg.editMap or useRemoteMap
  local dir = Root.Instance():getGamePath() .. cfg.dir
  local path = useRemoteMap and dir .. "#MEMORY#_mapId=" .. id or dir
  local mapObj = self:createMap(id, path, openedExclusively)
  if useRemoteMap then
    mapObj:copyStorageWithMemoryMap(getSourceMemoryMap(self, dir))
  end
  local map = {
    id = id,
    name = name,
    dir = cfg.dir,
    cfg = cfg,
    static = static,
    world = self,
    obj = mapObj,
    objects = {},
    players = {},
    npcEntities = {},
    keyRegions = {},
    keyEntitys = {},
    keyItems = {},
    allBlockData = cfg.blockData or {},
    lastRegionSubKey = 0,
    newRegionInfos = {},
    delRegionInfos = {},
    timers = {}
  }
  mapList[id] = setmetatable(map, Map)
  if static then
    staticList[name] = map
  end
  for key, region in pairs(cfg.region or {}) do
    map:addRegion(key, region.box.min, region.box.max, region.regionCfg)
  end
  if Map.init then
    map:init()
  end
  for i, entity in ipairs(cfg.entity or {}) do
    local et = map:addEntity(i, entity)
    local cfg = setting:fetch("entity", et.data.cfg)
    if not cfg then
      print("cant find some entity plugin:", et.data.cfg)
    end
  end
  for i, item in ipairs(cfg.item or {}) do
    map:addItem(i, item.ry, item.pos, item.cfg, item.blockID)
  end
  for _, collisionBoxTb in ipairs(cfg.staticCollisionBox or {}) do
    if map.addStaticCollisionBox then
      map:addStaticCollisionBox(collisionBoxTb.position, collisionBoxTb.boundingVolume)
    end
  end
  if cfg.cacheTimeout then
    map:setCacheTimeout(cfg.cacheTimeout)
  end
  return map
end

function Map:addNPC(entity, cfg)
  local entity_cfg = setting:fetch("entity", cfg)
  if entity_cfg.interactionUI and entity_cfg.interactionUI.id then
    self.npcEntities[entity.objID] = entity_cfg.interactionUI.id
  end
end
