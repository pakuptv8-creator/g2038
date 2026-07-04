local Interact = T(World, "Interact")
local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)
local events = {}

function entity_event(entity, event, ...)
  if not entity or not entity:isValid() then
    return
  end
  entityEventEngineHandler(entity, event, ...)
  local func = events[event]
  if func then
    func(entity, ...)
  end
end

function events:entityEnter(entity)
  if not (self and self:isValid() and entity and entity:isValid()) or not not entity:isWatch() then
    Lib.logDebug("entity enter client error, self or entity invalid")
    return
  end
  if not self:cfg() then
    Lib.logDebug("entity enter client error, no enter cfg")
    return
  end
  Lib.logDebug(Lib.v2s(self:cfg().enterProps))
  Interact.tryInteract(self, self:cfg().enterProps, entity, {noSync = true})
end

function events:entityLeave(entity)
  if not (self and self:isValid() and entity and entity:isValid()) or not not entity:isWatch() then
    Lib.logDebug("entity enter client error, self or entity invalid")
    return
  end
  if not self:cfg() then
    Lib.logDebug("entity enter client error, no cfg")
    return
  end
  Interact.tryInteract(self, self:cfg().leaveProps, entity, {noSync = true})
end

function events:entityHit(entity, hitPos, hitNormal, hitDistance)
  Interact.tryInteract(self, self:cfg().hitProps, entity, {
    noSync = true,
    hitPos = hitPos,
    hitNormal = hitNormal,
    hitDistance = hitDistance
  })
end

function events:enterRegion(id)
  local region = assert(World.idRegions[id], id)
  if self.justLoginOrLogout and region.cfg.ignoreWhenLoginAndLogout then
    return
  end
  if region and region.cfg then
    if region.regionPartId then
      local part = Instance.getByInstanceId(region.regionPartId)
      Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_BEGIN, part, self)
    else
      Interact.tryInteract(region, region.cfg.enterProps, self, {noSync = true})
    end
  end
end

function events:leaveRegion(id)
  local region = assert(World.idRegions[id], id)
  if self.justLoginOrLogout and region.cfg.ignoreWhenLoginAndLogout then
    return
  end
  if region and region.cfg then
    if region.regionPartId then
      local part = Instance.getByInstanceId(region.regionPartId)
      Interact.tryPartInteract(Define.PART_INTERACT_TYPE.TOUCH_END, part, self)
    else
      Interact.tryInteract(region, region.cfg.leaveProps, self, {noSync = true})
    end
  end
end
