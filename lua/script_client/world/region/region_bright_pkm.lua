local RegionBase = require("world.region.region_base")
local RegionBrightPKM = L("RegionBrightPKM", Lib.derive(RegionBase))

function RegionBrightPKM:onEntityEnter(entity, cfg)
end

function RegionBrightPKM:onEntityLeave(entity, cfg)
end

RETURN(RegionBrightPKM)
