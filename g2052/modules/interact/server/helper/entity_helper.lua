local EntityHelper = T(Lib, "EntityHelper")

function EntityHelper:replaceEntity(entityList, replacePlugin)
  local replaceList = {}
  for _, entity in pairs(entityList) do
    if entity and entity:isValid() then
      local replace_entity = EntityServer.Create({
        map = entity.map,
        pos = Lib.copyTable1(entity:getPosition()),
        cfgName = replacePlugin,
        rp = entity:getRotationPitch(),
        ry = entity:getRotationYaw(),
        rr = entity:getRotationRoll()
      })
      table.insert(replaceList, replace_entity)
      entity:destroy()
    end
  end
  return replaceList
end
