local SkillBase = Skill.GetType("Base")
local ClickSkill = Skill.GetType("Click")
ClickSkill.isClick = true
ClickSkill.isTouch = true

function ClickSkill:cast(packet, from)
  if packet.targetID then
    local target = World.CurWorld:getEntity(packet.targetID)
    if target then
      local cfg = target:cfg()
      if packet.isTouch then
        if cfg.canTouch then
          Trigger.CheckTriggers(cfg, "ENTITY_TOUCH", {obj1 = target, obj2 = from})
        end
      elseif cfg.canClick then
        if World.cfg.enableShowEditEntityPosRot and from and from.isPlayer and target then
          from:sendPacket({
            pid = "ShowEditEntityPosRot",
            objID = target.objID
          })
        end
        Trigger.CheckTriggers(cfg, "ENTITY_CLICK", {obj1 = target, obj2 = from})
        Trigger.CheckTriggers(from:cfg(), "CLICK_ENTITY", {obj1 = from, obj2 = target})
        from:addTarget("FindObject", target._cfg.fullName)
      end
    end
  elseif packet.blockPos then
    Block.Click(packet.blockPos, from)
  end
  SkillBase.cast(self, packet, from)
end
