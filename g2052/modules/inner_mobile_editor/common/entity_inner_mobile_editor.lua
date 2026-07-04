local ValueDef = T(Entity, "ValueDef")
ValueDef.playerBlockEditorData = {
  false,
  true,
  true,
  false,
  {},
  false
}

function Entity:getPlayerBlockEditorData()
  return self:getValue("playerBlockEditorData")
end

function Entity:setEditorMapScreenShootUrl(blockId, screenShootUrl)
  if not blockId then
    return
  end
  local data = self:getValue("playerBlockEditorData")
  if not data[blockId] then
    data[blockId] = {}
  end
  if screenShootUrl then
    data[blockId].screenShootUrl = screenShootUrl
  end
  self:setValue("playerBlockEditorData", data)
end

function Entity:setEditorMapSettingUrl(blockId, mapSettingUrl)
  if not blockId then
    return
  end
  local data = self:getValue("playerBlockEditorData")
  if not data[blockId] then
    data[blockId] = {}
  end
  if mapSettingUrl then
    data[blockId].mapSettingUrl = mapSettingUrl
  end
  self:setValue("playerBlockEditorData", data)
end

function Entity:getEditorMapScreenShootUrl(blockId)
  local data = self:getValue("playerBlockEditorData")[blockId]
  if not data then
    return
  end
  return data.screenShootUrl
end

function Entity:getEditorMapSettingUrl(blockId)
  local data = self:getValue("playerBlockEditorData")[blockId]
  if not data then
    return
  end
  return data.mapSettingUrl
end
