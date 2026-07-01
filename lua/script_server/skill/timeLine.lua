local SkillBase = Skill.GetType("Base")
local SkillTimeLine = Skill.GetType("TimeLine")
require("common.skill.timeLine")
local behavior = SkillTimeLine.behavior or {}

function behavior:back(packet, from, vals)
  local forceDelayTime = vals.forceDelayTime or 0
  local forceTime = vals.time - (packet.lastLinePos and packet.lastLinePos.time or 0) - forceDelayTime
  forceTime = math.floor(forceTime * (vals.backTimePct or 1))
  World.Timer(forceDelayTime, function()
    if from and from:isValid() then
      Lib.logInfo("_______behavior:back:", packet.uid or "not uid", from.name, from.objID, from:cfg().fullName, Lib.v2s(packet.backPos))
      from:setForceMove(packet.backPos, forceTime, self.isSimpleMove)
    end
  end)
end
