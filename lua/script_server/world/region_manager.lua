local eventRegionMap = {
  safe = RegionSafe,
  hide_pkm = RegionHidePKM,
  bright_pkm = RegionBrightPKM,
  obstacle = RegionObstacle
}

function RegionManager:init()
  Lib.unsubscribeEvent("EVENT_REGION_ENTER", self.eventIndexRegionEnter)
  globalValue, self.eventIndexRegionEnter = Lib.subscribeEvent("EVENT_REGION_ENTER", self.onRegionEnter)
  Lib.unsubscribeEvent("EVENT_REGION_LEAVE", self.eventIndexRegionLeave)
  globalValue, self.eventIndexRegionLeave = Lib.subscribeEvent("EVENT_REGION_LEAVE", self.onRegionLeave)
  Lib.unsubscribeEvent("EVENT_REGION_INIT", self.eventRegionInit)
  globalValue, self.eventRegionInit = Lib.subscribeEvent("EVENT_REGION_INIT", self.OnRegionInit)
end

function RegionManager.OnRegionInit(param)
  if not param.region then
    return
  end
  local cfg = param.region.cfg
  if not cfg.type then
    return
  end
  local class = eventRegionMap[cfg.type]
  if not class then
    return
  end
  if class.init then
    class:init(param.region)
  end
end

function RegionManager.onRegionEnter(param)
  local cfg = param.region.cfg
  if not cfg.type then
    return
  end
  local class = eventRegionMap[cfg.type]
  if not class then
    return
  end
  class:onEntityEnter(param.player, cfg, param.region)
end

function RegionManager.onRegionLeave(param)
  local cfg = param.region.cfg
  if not cfg.type then
    return
  end
  local class = eventRegionMap[cfg.type]
  if not class then
    return
  end
  class:onEntityLeave(param.player, cfg, param.region)
end

return RegionManager
