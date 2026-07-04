local function getSync(value)
  return (not value or value == true) and "all" or value
end

local function resetSkinQueue(entity, buff_id, skinQueue, reset, defaultQueue)
  for i = #skinQueue, 1, -1 do
    local skinData = skinQueue[i]
    if skinData and skinData.buff_id == buff_id then
      table.remove(skinQueue, i)
      break
    end
  end
  for k, v in pairs(defaultQueue and defaultQueue.value or {}) do
    reset[k] = v
  end
  for _, queue in ipairs(skinQueue or {}) do
    for k, v in pairs(queue.value or {}) do
      reset[k] = v
    end
  end
end

function Entity.EntityProp:skin(value, add, buff)
  local sync = getSync(buff.cfg.sync)
  local buff_id = buff.id
  if not self.skinQueue then
    self.skinQueue = {}
  end
  local defaultSkin = self:getOriginalSkin() or {}
  local extraShapeInfo = self:getShapeInfo()
  if next(extraShapeInfo) ~= nil then
    local changeSkinData = self:parseNewSkinData()
    for i, v in pairs(changeSkinData) do
      defaultSkin[i] = v
    end
  end
  if add then
    self:changeSkinPart(value, sync)
    table.insert(self.skinQueue, {value = value, buff_id = buff_id})
  else
    local reset = {}
    for m, _ in pairs(value) do
      reset[m] = ""
    end
    resetSkinQueue(self, buff_id, self.skinQueue, reset, {value = defaultSkin})
    self:changeSkinPart(reset, sync)
  end
end

function Entity.EntityProp:buffAction(value, add, buff)
  if value.isClient then
    return
  end
  local actionData
  if add then
    actionData = value.startAction
  else
    actionData = value.endAction
  end
  if actionData then
    local actionName = actionData.actionName
    local time = actionData.time or -1
    if actionName and actionName ~= "" then
      EntityServer.playAction({
        entity = self,
        actionName = actionName,
        actionTime = time,
        includeSelf = true
      })
    end
  end
end
