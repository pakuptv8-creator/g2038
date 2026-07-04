local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:handbagsInfo(value)
  Lib.emitEvent(Event.EVENT_UPDATE_HAND_BAG_INFO, value)
end

function Entity.ValueFunc:inUseProp(value)
  Lib.emitEvent(Event.EVENT_UPDATE_IN_USE_PROP, value, self.objID)
end

function Entity.ValueFunc:unlockProp(value)
  Lib.emitEvent(Event.EVENT_UPDATE_UNLOCK_PROP, value)
end

function Entity.ValueFunc:billboardState(value)
  Lib.emitEvent(Event.EVENT_UPDATE_BILLBOARD_SHOW, self.objID)
end

function Entity.ValueFunc:billboardInfo(value)
  Lib.emitEvent(Event.EVENT_UPDATE_BILLBOARD_INFO, self.objID)
end

function Entity.ValueFunc:billboardColor(value)
  Lib.emitEvent(Event.EVENT_UPDATE_BILLBOARD_INFO, self.objID)
end

function Entity.ValueFunc:shopCarName(value)
  Lib.emitEvent(Event.EVENT_UPDATE_SHOP_CAR_NAME, self.objID)
end

function Entity.ValueFunc:shopCarNameColor(value)
  Lib.emitEvent(Event.EVENT_UPDATE_SHOP_CAR_NAME, self.objID)
end

function Entity.ValueFunc:gunBulletCount(value)
end
