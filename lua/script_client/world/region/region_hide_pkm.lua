local RegionBase = require("world.region.region_base")
local RegionHidePKM = L("RegionHidePKM", Lib.derive(RegionBase))

function RegionHidePKM:onEntityEnter(entity, cfg)
end

function RegionHidePKM:onEntityLeave(entity, cfg)
end

RETURN(RegionHidePKM)
