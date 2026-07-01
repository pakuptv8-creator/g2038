function RegionBrightPKM:init(region)
  local cfg = region.cfg
  
  if not cfg.type then
    return
  end
  cfg.map = region.map
  EncounterMgr:pushTheBrightList(cfg)
end

function RegionBrightPKM:onEntityEnter(entity, cfg, region)
end

function RegionBrightPKM:onEntityLeave(entity, cfg, region)
end

return RegionBrightPKM
