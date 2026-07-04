local Handlers = T(Trigger, "Handlers")

function Handlers.SKILL_CAST(context)
  local entity = context.obj1
  if not entity or not entity:isValid() then
    return
  end
  entity:castSelfDefineSkillCallBack(context)
end
