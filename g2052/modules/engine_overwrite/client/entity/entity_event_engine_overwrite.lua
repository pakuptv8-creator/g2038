local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)
local events = {}

function entity_event(entity, event, ...)
  if not entity or not entity:isValid() then
    return
  end
  local func = events[event]
  if func and not func(entity, ...) then
    return
  end
  entityEventEngineHandler(entity, event, ...)
end

local function resetClickPlayerObjID(entity)
  if Me.objID == entity.objID then
    if Me.clickPlayerObjID then
      Me.clickPlayerObjID = nil
    end
  elseif Me.clickPlayerObjID == entity.objID then
    Me.clickPlayerObjID = nil
  end
end

local function controlItemSound(entity, newState)
  if entity.curMoveStatus == newState then
    return
  end
  entity.curMoveStatus = newState
  entity.isCanPlayItemSound = false
  if newState == 2 or newState == 3 or newState == 4 or newState == 5 then
    entity.isCanPlayItemSound = true
  end
  if entity.curItemSoundId then
    if entity.isCanPlayItemSound and entity.curItemSoundVolume then
      TdAudioEngine.Instance():setSoundsVolume(entity.curItemSoundId, entity.curItemSoundVolume)
    else
      TdAudioEngine.Instance():setSoundsVolume(entity.curItemSoundId, 0)
    end
  end
end

local function recordZenith(entity, newState, oldState)
  if newState == 9 and oldState == 8 then
    entity.previousVantagePoint = entity:getPosition()
    entity.inJumpHigh = true
  end
  if (newState == 3 or newState == 5 or newState == 2) and entity.onGround and entity.inJumpHigh then
    entity.inJumpHigh = false
    World.Timer(1, function()
      if not (entity and entity:isValid()) or not entity.onGround then
        return
      end
      entity.previousVantagePoint = entity:getPosition()
    end)
  end
end

function events:moveStatusChange(entityId, newState, oldState)
  local entity = World.CurWorld:getObject(entityId)
  if not entity or not entity:isValid() then
    return false
  end
  if self.isMainPlayer then
    resetClickPlayerObjID(entity)
  end
  if entity.isPlayer then
  else
    entity:resetSpecialEntityMoveAction(newState, oldState)
  end
  recordZenith(entity, newState, oldState)
  Lib.emitEvent(Event.EVENT_ENTITY_MOVE_STATUS_CHANGE, entityId, newState, oldState)
  if self.isMainPlayer and Me.rideOnInstanceId then
    entityEventEngineHandler(self, "moveStatusChange", entityId, 1, oldState)
    return false
  end
  return true
end
