function RegionHidePKM:onEntityEnter(entity, cfg, region)
  EncounterMgr:pushTheHideQueue(entity, cfg)
end

function RegionHidePKM:onEntityLeave(entity, cfg, region)
  EncounterMgr:popTheHideQueue(entity)
end

return RegionHidePKM
