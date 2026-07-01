function Skill.DoCast(cfg, packet, from)
  if from and from.isPlayer and from:isWatch() then
    Lib.logWarning("warning:Skill.DoCast fail because from and from.isPlayer and from:isWatch()", from.isPlayer, from:isWatch(), Lib.v2s(packet))
    
    return false
  end
  print("server Skill.DoCast -", cfg.fullName, from and from.objID)
  if cfg:cast(packet, from) == false then
    Lib.logWarning("warning:Skill.DoCast fail because cfg:cast return false", Lib.v2s(packet))
    return false
  end
  local target
  if packet.targetID then
    target = World.CurWorld:getObject(packet.targetID)
  end
  if packet.partID and Instance and Instance.getByInstanceId then
    target = Instance.getByInstanceId(packet.partID)
  end
  local context = {
    obj1 = from,
    obj2 = target,
    pos = packet.targetPos,
    fullName = cfg.fullName,
    blockPos = packet.blockPos,
    startPos = packet.startPos,
    sideNormal = packet.sideNormal
  }
  if packet.ownerID then
    context.owner = World.CurWorld:getObject(packet.ownerID)
  end
  Trigger.CheckTriggers(cfg, "SKILL_CAST", context)
  if from and cfg.objTrigger then
    Trigger.CheckTriggers(from:cfg(), cfg.objTrigger, context)
  end
  packet.pid = "CastSkill"
  packet.fromID = from and from.objID
  packet.name = cfg.fullName
  if cfg.broadcast ~= false then
    if from and from.isEntity then
      from:sendPacketToTracking(packet, true)
    else
      WorldServer.BroadcastPacket(packet)
    end
  elseif from.isPlayer then
    from:sendPacket(packet)
  end
  if cfg.castActionTime then
    World.Timer(cfg.castActionTime, function()
      if from:isValid() then
        Trigger.CheckTriggers(from:cfg(), "SKILL_CAST_FINISH", context)
      end
    end)
  end
  return true
end

function Skill.Cast(skillName, packet, from)
  local cfg = Skill.Cfg(skillName)
  if not cfg:canCast(packet or {}, from) then
    Lib.logWarning("warning:Skill.Cast fail because cfg:canCast return false", skillName, Lib.v2s(packet))
    return false
  end
  return Skill.DoCast(cfg, packet or {}, from)
end
