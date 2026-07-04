local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local PartManagerHelper = T(Lib, "PartManagerHelper")

function Entity.ValueFunc:onSwingState(value)
  if self.objID ~= Me.objID and value == 1 and not self:data("main").beginSwing then
    World.Timer(20, function()
      local partID = self:getInteractionPartID()
      local part = Instance.getByInstanceId(partID)
      if not self:data("main").beginSwing then
        if part and part:isValid() then
          PartManagerHelper:startSwing(self, part, tonumber(self:getEntityProp("gravity")))
          return false
        end
      else
        return false
      end
      return true
    end)
  end
end
