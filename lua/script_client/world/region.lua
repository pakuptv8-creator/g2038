local Region = World.Region
local RegionSafe = require("script_client.world.region.region_safe")
local RegionHidePKM = require("script_client.world.region.region_hide_pkm")
local RegionBrightPKM = require("script_client.world.region.region_bright_pkm")
local RegionObstacle = require("script_client.world.region.region_obstacle")
local eventRegionMap = {
  safe = RegionSafe,
  hide_pkm = RegionHidePKM,
  bright_pkm = RegionBrightPKM,
  obstacle = RegionObstacle
}

function Region:init()
  if self.cfg.type == "break" then
    C_MineAreaMgr:initMineArea(self.map, self.cfg.id, self.min, self.max)
  end
end

function Region:findTargetTypeRegion()
  local cfg = self.cfg
  local type = cfg.type
  if not type then
    return
  end
  return eventRegionMap[type]
end

function Region:onEntityEnter(entity)
  if not entity.isPlayer then
    return
  end
  if entity.objID ~= Me.objID then
    return
  end
  local targetRegion = self:findTargetTypeRegion()
  if targetRegion then
    targetRegion:onEntityEnter(entity, self.cfg)
  end
end

function Region:onEntityLeave(entity)
  if not entity.isPlayer then
    return
  end
  if entity.objID ~= Me.objID then
    return
  end
  local targetRegion = self:findTargetTypeRegion()
  if targetRegion then
    targetRegion:onEntityLeave(entity, self.cfg)
  end
end
