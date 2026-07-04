local EntityServer = _ENV.EntityServer

function EntityServer.playAction(params)
  local entity = params.entity
  local target = params.target
  local actionName = params.actionName
  local actionTime = params.actionTime
  local includeSelf = params.includeSelf or false
  if not entity or not entity:isValid() then
    return
  end
  local packet = {
    pid = "EntityPlayAction",
    objID = entity.objID,
    action = actionName,
    time = actionTime
  }
  if target and target.isPlayer then
    target:sendPacket(packet)
  else
    WorldServer.BroadcastPacket(packet)
  end
end

local function removeInteractiveInfo(entity)
  if entity.isPlayer and entity:getInteractPlayerUpID() <= 0 and 0 >= entity:getInteractPlayerHorseID() then
    entity:sendPacket({
      pid = "UpdateInteractiveControlShow",
      isShow = false
    })
  end
end

function EntityServer:removeInteractiveState()
  local interactionId = self:getInteractPlayerHorseID()
  if interactionId ~= 0 then
    local target = World.CurWorld:getEntity(interactionId)
    if target and target:isValid() then
      target:setInteractPlayerUpID(0)
      local targetCarId = target:getInteractPlayerHorseID()
      if targetCarId <= 0 then
        removeInteractiveInfo(target)
      end
    end
  end
  self:setInteractPlayerHorseID(0)
  removeInteractiveInfo(self)
end
