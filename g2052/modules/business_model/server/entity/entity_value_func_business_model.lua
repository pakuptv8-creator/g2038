local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local BusinessHelper = T(Lib, "BusinessHelper")

function Entity.ValueFunc:privilegeInfo(value)
  if self.isPlayer then
    BusinessHelper:updateAllPlayerPrivilegeInfo(self.platformUserId, value)
  end
end
