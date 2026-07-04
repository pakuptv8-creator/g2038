local Entity = _ENV.Entity
local EntityServer = _ENV.EntityServer

function Entity.EntityProp:gravity(value, add, buff)
  if not self.isPlayer then
    return
  end
  local offsetNum = tonumber(value)
  local oldOffset = self:getGravityOffset()
  if add then
    oldOffset = oldOffset + offsetNum
  else
    oldOffset = oldOffset - offsetNum
  end
  self:setGravityOffset(oldOffset)
end

function Entity:doStopPlayerFurniture()
  local oldPartId = self:getInteractionPartID()
  if oldPartId == "" then
    return
  end
  local part = Instance.getByInstanceId(oldPartId)
  local PartManagerHelper = T(Lib, "PartManagerHelper")
  local parentId = PartManagerHelper:isBelongPartGroup(oldPartId)
  if parentId and parentId ~= 0 then
    local parentPart = Instance.getByInstanceId(parentId)
    if parentPart and parentPart:isValid() then
      Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, parentPart, self, true, true)
    end
  else
    Plugins.CallTargetPluginFunc("interact", "tryPartInteract", Define.PART_INTERACT_TYPE.FORCE_TRIGGER, part, self, true, true)
  end
end
