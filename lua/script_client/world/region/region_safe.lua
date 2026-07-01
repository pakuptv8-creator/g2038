local RegionBase = require("world.region.region_base")
local RegionSafe = L("RegionSafe", Lib.derive(RegionBase))

function RegionSafe:onEntityEnter(entity, cfg)
end

function RegionSafe:onEntityLeave(entity, cfg)
end

RETURN(RegionSafe)
