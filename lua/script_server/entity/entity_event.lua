local entityEventEngineHandler = L("entityEventEngineHandler", entity_event)
local events = {}
local hideEngineHandler = {entityTouchAll = true}

function entity_event(entity, event, ...)
  if not hideEngineHandler[event] then
    entityEventEngineHandler(entity, event, ...)
  end
  local func = events[event]
  if func then
    func(entity, ...)
  end
end

function events:entityTouchAll(entity)
  if entity.isPlayer and self:cfg().entityType == Define.ENTITY_TYPE.MONSTER and self:cfg().isBrightPkm then
    entity:triggerMonster(self)
    return
  end
  if self.isPlayer and entity:cfg().entityType == Define.ENTITY_TYPE.MONSTER and entity:cfg().isBrightPkm then
    self:triggerMonster(entity)
    return
  end
end

function events:entityPropNotifyEvent(event, add)
  local self = self
  if event == "ENTITY_HP_NOTIFY" and self and self:isValid() and self:getPokemon() then
    self:getPokemon():setCurHp(self.curHp)
    if self.curHp <= 0 and self:isInBattle() and self.battleField then
      self.battleField:onPokemonDead(self)
      self:removeBattleEffectBuff()
    end
  end
end

function events:moveStatusChange(entityId, newState, oldState)
  if newState ~= 3 then
    return
  end
  local player = World.CurWorld:getObject(entityId)
  if not (player and player:isValid()) or not player.isPlayer then
    return
  end
  if player:isAvoidBattle() and not player.avoidBattleTimer then
    player.avoidBattleTimer = World.Timer(World.cfg.avoidBattleTime, function()
      if player and player:isValid() then
        self:setAvoidBattle(false)
        player.avoidBattleTimer = nil
      end
    end)
  end
end
