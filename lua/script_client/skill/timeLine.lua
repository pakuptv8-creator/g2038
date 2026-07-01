local MovieManager = require("script_client.movie.movie_manager")
local SkillTimeLine = Skill.GetType("TimeLine")
require("common.skill.timeLine")
local behavior = SkillTimeLine.behavior or {}
local bm = Blockman.Instance()

local function is2V2BattlePosition()
  if not Me.battleFieldInfo then
    return false
  end
  return Me:getBpIndex() == 2 or Me:getBpIndex() == 3 or Me:getBpIndex() == 8 or Me:getBpIndex() == 9
end

local function getCamaraShowName(vals, isEnemy, casterBp)
  if isEnemy then
    return is2V2BattlePosition() and vals.camaraEnemyShowName2V2 or vals.camaraEnemyShowName
  else
    return is2V2BattlePosition() and vals.camaraShowName2V2 or vals.camaraShowName
  end
end

function behavior:back(packet, from, vals)
  if not from:isControl() then
    return
  end
  local forceDelayTime = 0
  local forceTime = 0
  World.Timer(forceDelayTime, function()
    from:setForceMove(packet.backPos, forceTime, self.isSimpleMove)
  end)
end

function behavior:None(packet, from, vals)
  packet.isEnemy = packet.isEnemy or Me:getCampId() ~= from:getCampId()
  Lib.logDebug("behavior None", packet.isEnemy, packet.casterBp, packet.targetBp)
  Me.movieCasterBp = packet.casterBp or 1
  Me.movieTargetBp = packet.targetBp or 7
end
