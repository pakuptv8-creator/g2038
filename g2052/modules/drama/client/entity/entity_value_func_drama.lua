local Entity = _ENV.Entity
local ValueFunc = T(Entity, "ValueFunc")

function Entity.ValueFunc:giantScale(value)
  if self.objID == Me.objID then
    Lib.emitEvent(Event.EVENT_SHAPE_SCALE_UPDATE)
  end
end

function Entity.ValueFunc:giantHamburger(value, oldValue)
  if self.objID == Me.objID and value > World.cfg.dramaSetting.giantSetting.hamburgerEffectNum then
    Plugins.CallTargetPluginFunc("fly_tips", "pushNormalFlyTipsItem", "g2052.gui.drama.hamburger.max")
  end
end

function Entity.ValueFunc:giantShape(value)
  self:updateActorShape(value, World.cfg.dramaSetting.giantSetting.shapeEyeHeight)
end
