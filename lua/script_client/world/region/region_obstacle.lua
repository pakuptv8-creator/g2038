local RegionBase = require("world.region.region_base")
local RegionObstacle = L("RegionObstacle", Lib.derive(RegionBase))

function RegionObstacle:onEntityEnter(entity, cfg)
  Lib.logInfo("client RegionObstacle onEntityEnter")
  if entity.objID == Me.objID and self:needDisableMove(cfg) then
    Lib.logInfo("RegionObstacle lock player move:", Lib.v2s(cfg, 2))
    Me.disableControl = true
  end
end

function RegionObstacle:onEntityLeave(entity, cfg)
end

function RegionObstacle:needDisableMove(cfg)
  Lib.logInfo("needDisableMove hasNpcChallengeList = ", Me.hasNpcChallengeList)
  if Me.hasNpcChallengeList == true then
    local cnt = Me:getNpcChallenge(cfg.id)
    Lib.logInfo("needDisableMove cnt = ", cnt)
    if cnt and cnt <= 0 then
      return false
    end
    return true
  else
    return false
  end
end

RETURN(RegionObstacle)
