local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")
local distance, eyeHeight
ValueFunc[Define.APPEARANCE_VAR_KEY.ShapeScale] = function(entity, value)
  entity:setActorScale({
    x = value,
    y = value,
    z = value
  })
  entity:updateBoundingVolume(value)
  local BoundingBox = entity:getBoundingBox()
  if BoundingBox then
    local adaptPos = {
      x = (BoundingBox[2].x + BoundingBox[3].x) / 2,
      y = (BoundingBox[2].y + BoundingBox[3].y) / 2 - 0.89,
      z = (BoundingBox[2].z + BoundingBox[3].z) / 2
    }
    entity:data("main").adaptPos = Lib.v3cut(adaptPos, entity:getPosition())
  end
  if entity == Me then
    if not eyeHeight then
      eyeHeight = entity:prop("eyeHeight")
    end
    Lib.emitEvent(Event.EVENT_SHAPE_SCALE_UPDATE)
  end
  if entity:data("main").billboardUI then
    local BillboardHelper = T(Lib, "BillboardHelper")
    BillboardHelper:hideBillboardUI(entity, entity.objID)
    BillboardHelper:showBillboardUI(entity, entity.objID)
  end
end
ValueFunc[Define.APPEARANCE_VAR_KEY.ShapeInfo] = function(entity, value)
  if entity.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_DRESS_FREE_AD_TIME)
  end
end

function Entity.ValueFunc:freeAdStartTime(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_DRESS_FREE_AD_TIME)
  end
end
